import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart'; 
import 'subject_model.dart';

enum ClassType { theory, practical }

class ClassInfo {
  final Subject subject;
  final ClassType type;
  final int duration;
  final bool isBlockedSlot;
  final String? timeSlot;

  ClassInfo({
    required this.subject,
    required this.type,
    required this.duration,
    this.isBlockedSlot = false,
    this.timeSlot,
  });

  bool get isTheory => type == ClassType.theory;

  Map<String, dynamic> toJson() {
    return {
      'subject': subject.toJson(),
      'type': type.name,
      'duration': duration,
      'isBlockedSlot': isBlockedSlot,
      'timeSlot': timeSlot,
    };
  }

  static ClassInfo fromJson(Map<String, dynamic> json) {
    return ClassInfo(
      subject: Subject.fromJson(json['subject']),
      type: ClassType.values.firstWhere((e) => e.name == json['type']),
      duration: json['duration'],
      isBlockedSlot: json['isBlockedSlot'] ?? false,
      timeSlot: json['timeSlot'],
    );
  }
}

enum AttendanceStatus { present, absent, holiday, massBunk, teacherAbsent }

class AttendanceRecord {
  final String subjectName;
  final String classType;
  final AttendanceStatus status;
  final DateTime date;
  final String timeSlot;
  final double hours;

  AttendanceRecord({
    required this.subjectName,
    required this.classType,
    required this.status,
    required this.date,
    required this.timeSlot,
    required this.hours,
  });

  Map<String, dynamic> toJson() {
    return {
      'subjectName': subjectName,
      'classType': classType,
      'status': status.name,
      'date': date.toIso8601String(),
      'timeSlot': timeSlot,
      'hours': hours,
    };
  }

  static AttendanceRecord fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      subjectName: json['subjectName'],
      classType: json['classType'],
      status: AttendanceStatus.values.firstWhere(
        (e) => e.name == json['status'],
      ),
      date: DateTime.parse(json['date']),
      timeSlot: json['timeSlot'],
      hours: json['hours'].toDouble(),
    );
  }
}

class AttendanceSummary {
  double totalHoursHeld = 0.0;
  double totalHoursAttended = 0.0;
  double hoursHeldExclMassBunk = 0.0;
  double hoursAttendedExclMassBunk = 0.0;
  double totalScheduledHours = 0.0;

  AttendanceSummary({this.totalScheduledHours = 0.0});

  void addEntry(AttendanceStatus status, double hours) {
    switch (status) {
      case AttendanceStatus.present:
        totalHoursHeld += hours;
        totalHoursAttended += hours;
        hoursHeldExclMassBunk += hours;
        hoursAttendedExclMassBunk += hours;
        break;
      case AttendanceStatus.absent:
        totalHoursHeld += hours;
        hoursHeldExclMassBunk += hours;
        break;
      case AttendanceStatus.holiday:
        totalScheduledHours -= hours;
        break;
      case AttendanceStatus.massBunk:
        totalHoursHeld += hours;
        break;
      case AttendanceStatus.teacherAbsent:
        totalScheduledHours -= hours;
        break;
    }
  }

  void removeEntry(AttendanceStatus status, double hours) {
    switch (status) {
      case AttendanceStatus.present:
        totalHoursHeld -= hours;
        totalHoursAttended -= hours;
        hoursHeldExclMassBunk -= hours;
        hoursAttendedExclMassBunk -= hours;
        break;
      case AttendanceStatus.absent:
        totalHoursHeld -= hours;
        hoursHeldExclMassBunk -= hours;
        break;
      case AttendanceStatus.holiday:
        totalScheduledHours += hours;
        break;
      case AttendanceStatus.massBunk:
        totalHoursHeld -= hours;
        break;
      case AttendanceStatus.teacherAbsent:
        totalScheduledHours += hours;
        break;
    }
  }

  double get percentage =>
      totalHoursHeld == 0 ? 0.0 : (totalHoursAttended / totalHoursHeld) * 100;

  double get percentageExclMassBunk => hoursHeldExclMassBunk == 0
      ? 0.0
      : (hoursAttendedExclMassBunk / hoursHeldExclMassBunk) * 100;

  double get hoursCanMiss {
    final requiredAttendance = totalScheduledHours * 0.75;
    final maxMissable = totalScheduledHours - requiredAttendance;
    final alreadyMissed = totalHoursHeld - totalHoursAttended;
    return (maxMissable - alreadyMissed).clamp(0.0, double.infinity);
  }

  Map<String, dynamic> toJson() {
    return {
      'totalHoursHeld': totalHoursHeld,
      'totalHoursAttended': totalHoursAttended,
      'hoursHeldExclMassBunk': hoursHeldExclMassBunk,
      'hoursAttendedExclMassBunk': hoursAttendedExclMassBunk,
      'totalScheduledHours': totalScheduledHours,
    };
  }

  static AttendanceSummary fromJson(Map<String, dynamic> json) {
    final summary = AttendanceSummary();
    summary.totalHoursHeld = json['totalHoursHeld']?.toDouble() ?? 0.0;
    summary.totalHoursAttended = json['totalHoursAttended']?.toDouble() ?? 0.0;
    summary.hoursHeldExclMassBunk =
        json['hoursHeldExclMassBunk']?.toDouble() ?? 0.0;
    summary.hoursAttendedExclMassBunk =
        json['hoursAttendedExclMassBunk']?.toDouble() ?? 0.0;
    summary.totalScheduledHours =
        json['totalScheduledHours']?.toDouble() ?? 0.0;
    return summary;
  }
}

class TimetableModel extends ChangeNotifier {
  Map<String, Map<String, ClassInfo?>> _timetable = {};
  Map<String, Map<String, AttendanceSummary>> _attendanceData = {};
  List<AttendanceRecord> _attendanceRecords = [];
  List<Subject> _subjects = [];

  final List<String> _days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday'
  ];
  final List<String> _timeSlots = [
    '8:00-9:00',
    '9:00-10:00',
    '10:00-11:00',
    '11:00-12:00',
    '12:00-1:00',
    '1:00-2:00',
    '2:00-3:00',
    '3:00-4:00',
    '4:00-5:00',
    '5:00-6:00'
  ];

  Map<String, Map<String, ClassInfo?>> get timetable => _timetable;
  Map<String, Map<String, AttendanceSummary>> get attendanceData =>
      _attendanceData;
  List<AttendanceRecord> get attendanceRecords => _attendanceRecords;
  List<Subject> get subjects => _subjects;
  List<String> get days => _days;
  List<String> get timeSlots => _timeSlots;

  void _initializeTimetable() {
    for (String day in _days) {
      _timetable[day] = {};
      for (String timeSlot in _timeSlots) {
        _timetable[day]![timeSlot] = null;
      }
    }
  }

  void _initializeAttendanceData() {
    final newAttendanceData = <String, Map<String, AttendanceSummary>>{};
    for (final subject in _subjects) {
      if (_attendanceData.containsKey(subject.name)) {
        newAttendanceData[subject.name] = _attendanceData[subject.name]!;
      } else {
        newAttendanceData[subject.name] = {
          'theory': AttendanceSummary(
              totalScheduledHours: subject.totalTheoryHours.toDouble()),
          'practical': AttendanceSummary(
              totalScheduledHours: subject.totalPracticalHours.toDouble()),
        };
      }
    }
    _attendanceData = newAttendanceData;
  }

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final subjectsJson = prefs.getString('timewise_subjects');
      if (subjectsJson != null) {
        final subjectsList = jsonDecode(subjectsJson) as List;
        _subjects = subjectsList.map((json) => Subject.fromJson(json)).toList();
      } else {
        _subjects = [];
      }

      final timetableJson = prefs.getString('timewise_timetable');
      if (timetableJson != null) {
        final timetableData = jsonDecode(timetableJson) as Map<String, dynamic>;
        _timetable = {};
        for (String day in _days) {
          _timetable[day] = {};
          final dayData = timetableData[day] as Map<String, dynamic>?;
          if (dayData != null) {
            for (String timeSlot in _timeSlots) {
              final classData = dayData[timeSlot];
              _timetable[day]![timeSlot] =
                  classData != null ? ClassInfo.fromJson(classData) : null;
            }
          } else {
            for (String timeSlot in _timeSlots) {
              _timetable[day]![timeSlot] = null;
            }
          }
        }
      } else {
        _initializeTimetable();
      }

      final attendanceRecordsJson =
          prefs.getString('timewise_attendance_records');
      if (attendanceRecordsJson != null) {
        final recordsList = jsonDecode(attendanceRecordsJson) as List;
        _attendanceRecords =
            recordsList.map((json) => AttendanceRecord.fromJson(json)).toList();
      }

      final attendanceSummaryJson =
          prefs.getString('timewise_attendance_summary');
      if (attendanceSummaryJson != null) {
        final summaryData =
            jsonDecode(attendanceSummaryJson) as Map<String, dynamic>;
        _attendanceData = {};
        for (String subjectName in summaryData.keys) {
          final subjectData = summaryData[subjectName] as Map<String, dynamic>;
          _attendanceData[subjectName] = {
            'theory': AttendanceSummary.fromJson(subjectData['theory']),
            'practical': AttendanceSummary.fromJson(subjectData['practical']),
          };
        }
      }
      _initializeAttendanceData();
      notifyListeners();
    } catch (e) {
      _subjects = [];
      _initializeTimetable();
      _attendanceRecords = [];
      _attendanceData = {};
      _initializeAttendanceData();
    }
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    final subjectsJson = jsonEncode(_subjects.map((s) => s.toJson()).toList());
    await prefs.setString('timewise_subjects', subjectsJson);

    final timetableData = {};
    for (String day in _days) {
      final dayData = {};
      for (String timeSlot in _timeSlots) {
        dayData[timeSlot] = _timetable[day]![timeSlot]?.toJson();
      }
      timetableData[day] = dayData;
    }
    await prefs.setString('timewise_timetable', jsonEncode(timetableData));

    final recordsJson =
        jsonEncode(_attendanceRecords.map((r) => r.toJson()).toList());
    await prefs.setString('timewise_attendance_records', recordsJson);

    final summaryData = {};
    for (String subjectName in _attendanceData.keys) {
      summaryData[subjectName] = {
        'theory': _attendanceData[subjectName]!['theory']!.toJson(),
        'practical': _attendanceData[subjectName]!['practical']!.toJson(),
      };
    }
    await prefs.setString(
        'timewise_attendance_summary', jsonEncode(summaryData));
  }

  void updateSubjects(List<Subject> newSubjects) {
    _subjects = newSubjects;
    _initializeAttendanceData();
    save();
    notifyListeners();
  }

  void updateClass(String day, String timeSlot, ClassInfo? classInfo) {
    _timetable[day]![timeSlot] = classInfo;
    if (classInfo != null && classInfo.duration == 2) {
      final currentIndex = _timeSlots.indexOf(timeSlot);
      if (currentIndex < _timeSlots.length - 1) {
        final nextSlot = _timeSlots[currentIndex + 1];
        _timetable[day]![nextSlot] = ClassInfo(
          subject: classInfo.subject,
          type: classInfo.type,
          duration: 0,
          isBlockedSlot: true,
        );
      }
    }
    save();
    notifyListeners();
  }

  void removeClass(String day, String timeSlot) {
    final classInfo = _timetable[day]![timeSlot];
    _timetable[day]![timeSlot] = null;
    if (classInfo != null && classInfo.duration == 2) {
      final currentIndex = _timeSlots.indexOf(timeSlot);
      if (currentIndex < _timeSlots.length - 1) {
        final nextSlot = _timeSlots[currentIndex + 1];
        if (_timetable[day]![nextSlot]?.isBlockedSlot == true) {
          _timetable[day]![nextSlot] = null;
        }
      }
    }
    save();
    notifyListeners();
  }

  void markAttendance(String subjectName, String classType,
      AttendanceStatus status, DateTime date, String timeSlot, double hours) {
    final existingIndex = _attendanceRecords.indexWhere((record) =>
        record.subjectName == subjectName &&
        record.classType == classType &&
        record.date.year == date.year &&
        record.date.month == date.month &&
        record.date.day == date.day &&
        record.timeSlot == timeSlot);

    if (existingIndex != -1) {
      final oldRecord = _attendanceRecords[existingIndex];
      _attendanceData[subjectName]![classType]!
          .removeEntry(oldRecord.status, oldRecord.hours);
      _attendanceRecords[existingIndex] = AttendanceRecord(
        subjectName: subjectName,
        classType: classType,
        status: status,
        date: date,
        timeSlot: timeSlot,
        hours: hours,
      );
    } else {
      _attendanceRecords.add(AttendanceRecord(
        subjectName: subjectName,
        classType: classType,
        status: status,
        date: date,
        timeSlot: timeSlot,
        hours: hours,
      ));
    }
    _attendanceData[subjectName]![classType]!.addEntry(status, hours);
    save();
    notifyListeners();
  }

  AttendanceStatus? getAttendanceStatus(
      String subjectName, String classType, DateTime date, String timeSlot) {
    try {
      final record = _attendanceRecords.firstWhere((r) =>
          r.subjectName == subjectName &&
          r.classType == classType &&
          r.date.year == date.year &&
          r.date.month == date.month &&
          r.date.day == date.day &&
          r.timeSlot == timeSlot);
      return record.status;
    } catch (e) {
      return null;
    }
  }

  void copyDaySchedule(String fromDay, String toDay) {
    _timetable[toDay] = Map.from(_timetable[fromDay]!);
    save();
    notifyListeners();
  }

  void clearDaySchedule(String day) {
    for (String timeSlot in _timeSlots) {
      _timetable[day]![timeSlot] = null;
    }
    save();
    notifyListeners();
  }

  bool isSlotBlocked(String day, String timeSlot) {
    final currentIndex = _timeSlots.indexOf(timeSlot);
    if (currentIndex > 0) {
      final previousSlot = _timeSlots[currentIndex - 1];
      final previousClass = _timetable[day]![previousSlot];
      return previousClass != null &&
          previousClass.duration == 2 &&
          !previousClass.isBlockedSlot;
    }
    return false;
  }

  List<ClassInfo> getClassesForDay(String day) {
    final classes = <ClassInfo>[];
    final daySchedule = _timetable[day];
    if (daySchedule != null) {
      for (final entry in daySchedule.entries) {
        final classInfo = entry.value;
        if (classInfo != null && !classInfo.isBlockedSlot) {
          classes.add(ClassInfo(
            subject: classInfo.subject,
            type: classInfo.type,
            duration: classInfo.duration,
            isBlockedSlot: classInfo.isBlockedSlot,
            timeSlot: entry.key,
          ));
        }
      }
    }

    classes.sort((a, b) => _timeSlots.indexOf(a.timeSlot!).compareTo(_timeSlots.indexOf(b.timeSlot!)));
    return classes;
  }

  double getOverallAttendancePercentage() {
    if (_attendanceData.isEmpty) return 100.0;

    double totalHeld = 0;
    double totalAttended = 0;

    _attendanceData.forEach((_, subjectSummary) {
      subjectSummary.forEach((_, summary) {
        totalHeld += summary.totalHoursHeld;
        totalAttended += summary.totalHoursAttended;
      });
    });

    if (totalHeld == 0) return 100.0; 
    return (totalAttended / totalHeld) * 100;
  }

  ClassInfo? getNextClass() {
    final now = DateTime.now();
    final currentTime = TimeOfDay.fromDateTime(now);
    final todayDayName = DateFormat('EEEE').format(now);

    if (!_days.contains(todayDayName)) {
      return _findFirstClassFromDay(_days.first);
    }
    
    final todayIndex = _days.indexOf(todayDayName);

    double timeOfDayToMinutes(TimeOfDay time) => time.hour * 60.0 + time.minute;
    final currentTimeInMinutes = timeOfDayToMinutes(currentTime);

    final todaysClasses = getClassesForDay(todayDayName);
    for (final classInfo in todaysClasses) {
      final startTimeString = classInfo.timeSlot!.split('-')[0]; 
      final timeParts = startTimeString.split(':');
      final classStartTime = TimeOfDay(hour: int.parse(timeParts[0]), minute: int.parse(timeParts[1]));

      if (timeOfDayToMinutes(classStartTime) > currentTimeInMinutes) {
        return classInfo;
      }
    }

    for (int i = 1; i < _days.length; i++) {
      final nextDayIndex = (todayIndex + i) % _days.length;
      final nextDayName = _days[nextDayIndex];
      final nextDayClass = _findFirstClassFromDay(nextDayName);
      if (nextDayClass != null) {
        return nextDayClass; 
      }
    }

    return null;
  }

  ClassInfo? _findFirstClassFromDay(String dayName) {
    final classes = getClassesForDay(dayName);
    if (classes.isNotEmpty) {
      
      return classes.first;
    }
    return null;
  }
}