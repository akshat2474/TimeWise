import 'package:flutter/material.dart';

class TimeWiseProvider extends ChangeNotifier {
  final List<String> _subjects = [];

  List<String> get subjects => List.unmodifiable(_subjects);

  void setSubjects(List<String> newSubjects) {
    _subjects
      ..clear()
      ..addAll(newSubjects);
    _initialiseAttendance();
    notifyListeners();
  }

  final Map<String, Map<String, ClassInfo?>> _timetable = {};

  Map<String, Map<String, ClassInfo?>> get timetable =>
      _deepUnmodifiable(_timetable);

  void setClass({
    required String day,
    required String time,
    required ClassInfo info,
  }) {
    _ensureDay(day);
    _timetable[day]![time] = info;
    if (info.duration == 2) {
      final nextIndex = _timeSlots.indexOf(time) + 1;
      if (nextIndex < _timeSlots.length) {
        final nextSlot = _timeSlots[nextIndex];
        _timetable[day]![nextSlot] = info.copyWith(isContinuation: true);
      }
    }
    notifyListeners();
  }

  void removeClass(String day, String time) {
    _ensureDay(day);
    final removed = _timetable[day]![time];
    _timetable[day]![time] = null;
    if (removed?.duration == 2) {
      final nextIndex = _timeSlots.indexOf(time) + 1;
      if (nextIndex < _timeSlots.length) {
        final nextSlot = _timeSlots[nextIndex];
        if (_timetable[day]![nextSlot]?.isContinuation == true) {
          _timetable[day]![nextSlot] = null;
        }
      }
    }
    notifyListeners();
  }

  final Map<String, Map<String, Map<String, int>>> _attendance = {};

  Map<String, Map<String, Map<String, int>>> get attendance =>
      _deepUnmodifiable(_attendance);

  void markAttendance({
    required String subject,
    required bool isTheory,
    required bool attended,
  }) {
    final key = isTheory ? 'theory' : 'practical';
    _attendance[subject]![key]!['total'] =
        _attendance[subject]![key]!['total']! + 1;
    if (attended) {
      _attendance[subject]![key]!['attended'] =
          _attendance[subject]![key]!['attended']! + 1;
    }
    notifyListeners();
  }

  static const List<String> _timeSlots = [
    '8:00-9:00',
    '9:00-10:00',
    '10:00-11:00',
    '11:00-12:00',
    '12:00-1:00',
    '1:00-2:00',
    '2:00-3:00',
    '3:00-4:00',
    '4:00-5:00',
    '5:00-6:00',
  ];

  void _ensureDay(String day) {
    _timetable.putIfAbsent(day, () {
      return {for (final t in _timeSlots) t: null};
    });
  }

  void _initialiseAttendance() {
    _attendance
      ..clear()
      ..addEntries(_subjects.map(
        (s) => MapEntry(s, {
          'theory': {'attended': 0, 'total': 0},
          'practical': {'attended': 0, 'total': 0},
        }),
      ));
  }

  static T _deepUnmodifiable<T>(T value) {
    if (value is Map) {
      return Map.unmodifiable(
        value.map((k, v) => MapEntry(k, _deepUnmodifiable(v))),
      ) as T;
    }
    if (value is List) {
      return List.unmodifiable(value.map(_deepUnmodifiable)) as T;
    }
    return value;
  }
}

class ClassInfo {
  final String subject;
  final int duration;
  final bool isTheory;
  final bool isContinuation;

  ClassInfo({
    required this.subject,
    required this.duration,
    required this.isTheory,
    this.isContinuation = false,
  });

  ClassInfo copyWith({
    String? subject,
    int? duration,
    bool? isTheory,
    bool? isContinuation,
  }) {
    return ClassInfo(
      subject: subject ?? this.subject,
      duration: duration ?? this.duration,
      isTheory: isTheory ?? this.isTheory,
      isContinuation: isContinuation ?? this.isContinuation,
    );
  }
}
