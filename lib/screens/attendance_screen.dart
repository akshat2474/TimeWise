import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:timewise_dtu/models/subject_model.dart';
import 'timetable_grid_screen.dart';
import '../models/timetable_model.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  late DateTime _selectedDate;
  late DateTime _focusedDate;
  CalendarFormat _calendarFormat = CalendarFormat.week;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _focusedDate = DateTime.now();
  }

  String _getDayName(DateTime date) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return days[date.weekday - 1];
  }

  bool _isWeekday(DateTime date) {
    return date.weekday >= 1 && date.weekday <= 5;
  }

  void _showAttendanceDialog(ClassInfo classInfo) {
    final model = context.read<TimetableModel>();
    final currentStatus = classInfo.timeSlot == null
        ? null
        : model.getAttendanceStatus(
            classInfo.subject.name,
            classInfo.isTheory ? 'theory' : 'practical',
            _selectedDate,
            classInfo.timeSlot!,
          );

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: classInfo.isTheory
                            ? Colors.blue[600]
                            : Colors.green[600],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        classInfo.isTheory
                            ? Icons.book_outlined
                            : Icons.science_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            classInfo.subject.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${classInfo.isTheory ? 'Theory' : 'Practical'} • ${classInfo.duration}h • ${_getDayName(_selectedDate)}',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (currentStatus != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getStatusColor(currentStatus).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _getStatusColor(currentStatus).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _getStatusIcon(currentStatus),
                          color: _getStatusColor(currentStatus),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Current Status: ${_getStatusText(currentStatus)}',
                          style: TextStyle(
                            color: _getStatusColor(currentStatus),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tap to change:',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                ] else ...[
                  const Text(
                    'Mark Attendance:',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Row(
                  children: [
                    Expanded(
                      child: _buildAttendanceOption(
                        icon: Icons.check_circle,
                        label: 'Present',
                        color: Colors.green,
                        onTap: () {
                          _markAttendance(classInfo, AttendanceStatus.present);
                          Navigator.pop(context);
                          _showStatusMessage(
                              'Marked as Present for ${classInfo.subject.name}',
                              Colors.green);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildAttendanceOption(
                        icon: Icons.cancel,
                        label: 'Absent',
                        color: Colors.red,
                        onTap: () {
                          _markAttendance(classInfo, AttendanceStatus.absent);
                          Navigator.pop(context);
                          _showStatusMessage(
                              'Marked as Absent for ${classInfo.subject.name}',
                              Colors.red);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildAttendanceOption(
                        icon: Icons.beach_access,
                        label: 'Holiday',
                        color: Colors.grey,
                        onTap: () {
                          _markAttendance(classInfo, AttendanceStatus.holiday);
                          Navigator.pop(context);
                          _showStatusMessage(
                              'Marked as Holiday for ${classInfo.subject.name}',
                              Colors.grey);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildAttendanceOption(
                        icon: Icons.group_off,
                        label: 'Mass Bunk',
                        color: Colors.orange,
                        onTap: () {
                          _markAttendance(
                              classInfo, AttendanceStatus.massBunk);
                          Navigator.pop(context);
                          _showStatusMessage(
                              'Marked as Mass Bunk for ${classInfo.subject.name}',
                              Colors.orange);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildAttendanceOption(
                        icon: Icons.person_off,
                        label: 'Teacher Absent',
                        color: Colors.purple,
                        onTap: () {
                          _markAttendance(
                              classInfo, AttendanceStatus.teacherAbsent);
                          Navigator.pop(context);
                          _showStatusMessage(
                              'Marked as Teacher Absent for ${classInfo.subject.name}',
                              Colors.purple);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(child: SizedBox()),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _markAttendance(ClassInfo classInfo, AttendanceStatus status) {
    if (classInfo.timeSlot == null) return;
    final model = context.read<TimetableModel>();
    final hours = classInfo.duration.toDouble();
    model.markAttendance(
      classInfo.subject.name,
      classInfo.isTheory ? 'theory' : 'practical',
      status,
      _selectedDate,
      classInfo.timeSlot!,
      hours,
    );
  }

  Widget _buildAttendanceOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusText(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return 'Present';
      case AttendanceStatus.absent:
        return 'Absent';
      case AttendanceStatus.holiday:
        return 'Holiday';
      case AttendanceStatus.massBunk:
        return 'Mass Bunk';
      case AttendanceStatus.teacherAbsent:
        return 'Teacher Absent';
    }
  }

  Color _getStatusColor(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return Colors.green;
      case AttendanceStatus.absent:
        return Colors.red;
      case AttendanceStatus.holiday:
        return Colors.grey;
      case AttendanceStatus.massBunk:
        return Colors.orange;
      case AttendanceStatus.teacherAbsent:
        return Colors.purple;
    }
  }

  IconData _getStatusIcon(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return Icons.check_circle;
      case AttendanceStatus.absent:
        return Icons.cancel;
      case AttendanceStatus.holiday:
        return Icons.beach_access;
      case AttendanceStatus.massBunk:
        return Icons.group_off;
      case AttendanceStatus.teacherAbsent:
        return Icons.person_off;
    }
  }

  Color _getPercentageColor(double percentage) {
    if (percentage >= 75) return Colors.green;
    if (percentage >= 60) return Colors.orange;
    return Colors.red;
  }

  void _showStatusMessage(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showEditOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Edit Options',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green[600],
                  borderRadius: BorderRadius.circular(8),
                ),
                child:
                    const Icon(Icons.schedule, color: Colors.white, size: 20),
              ),
              title: const Text('Edit Timetable',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w500)),
              subtitle: Text(
                'Modify class schedule and timings',
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const TimetableGridScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.grey[900],
            title: const Text('Leave Attendance Tracker?',
                style: TextStyle(color: Colors.white)),
            content: const Text(
                'Your attendance data will be saved. Are you sure you want to go back?',
                style: TextStyle(color: Colors.white70)),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel')),
              TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Leave')),
            ],
          ),
        );
        return shouldPop ?? false;
      },
      child: Consumer<TimetableModel>(
        builder: (context, model, child) {
          final dayName = _getDayName(_selectedDate);
          final classesForSelectedDay = _isWeekday(_selectedDate)
              ? model.getClassesForDay(dayName)
              : [];
          return Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: const Text(
                'Attendance Tracker',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 1,
                ),
              ),
              backgroundColor: Colors.black,
              elevation: 0,
              actions: [
                IconButton(
                  onPressed: _showEditOptions,
                  icon: const Icon(Icons.edit_note_outlined,
                      color: Colors.white),
                  tooltip: 'Edit Options',
                ),
              ],
            ),
            body: SafeArea(
              child: NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverToBoxAdapter(
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        decoration: BoxDecoration(
                          color: Colors.grey[900]?.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: TableCalendar(
                          firstDay: DateTime.utc(2020, 1, 1),
                          lastDay: DateTime.utc(2030, 12, 31),
                          focusedDay: _focusedDate,
                          selectedDayPredicate: (day) =>
                              isSameDay(_selectedDate, day),
                          calendarFormat: _calendarFormat,
                          onDaySelected: (selectedDay, focusedDay) {
                            setState(() {
                              _selectedDate = selectedDay;
                              _focusedDate = focusedDay;
                            });
                          },
                          onFormatChanged: (format) {
                            if (_calendarFormat != format) {
                              setState(() {
                                _calendarFormat = format;
                              });
                            }
                          },
                          onPageChanged: (focusedDay) {
                            _focusedDate = focusedDay;
                          },
                          calendarStyle: CalendarStyle(
                            outsideDaysVisible: false,
                            weekendTextStyle:
                                TextStyle(color: Colors.grey[600]),
                            holidayTextStyle:
                                TextStyle(color: Colors.grey[600]),
                            defaultTextStyle:
                                const TextStyle(color: Colors.white),
                            selectedTextStyle:
                                const TextStyle(color: Colors.black),
                            todayTextStyle: const TextStyle(color: Colors.white),
                            selectedDecoration: BoxDecoration(
                              color: Colors.blue[300],
                              shape: BoxShape.circle,
                            ),
                            todayDecoration: BoxDecoration(
                              border: Border.all(color: Colors.blue[300]!),
                              shape: BoxShape.circle,
                            ),
                            markerDecoration: BoxDecoration(
                              color: Colors.green[400],
                              shape: BoxShape.circle,
                            ),
                          ),
                          headerStyle: HeaderStyle(
                            formatButtonVisible: true,
                            titleCentered: true,
                            formatButtonShowsNext: false,
                            formatButtonDecoration: BoxDecoration(
                              color: Colors.grey[800],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            formatButtonTextStyle:
                                const TextStyle(color: Colors.white),
                            titleTextStyle: const TextStyle(
                                color: Colors.white, fontSize: 16),
                            leftChevronIcon: const Icon(Icons.chevron_left,
                                color: Colors.white),
                            rightChevronIcon: const Icon(Icons.chevron_right,
                                color: Colors.white),
                          ),
                          eventLoader: (day) {
                            return model.attendanceRecords
                                .where((record) => isSameDay(record.date, day))
                                .toList();
                          },
                        ),
                      ),
                    ),
                  ];
                },
                body: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Classes for $dayName',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (!_isWeekday(_selectedDate))
                              _buildInfoCard(
                                  'No classes scheduled for weekends',
                                  Icons.weekend_outlined)
                            else if (classesForSelectedDay.isEmpty)
                              _buildInfoCard(
                                  'No classes scheduled for this day',
                                  Icons.free_breakfast_outlined)
                            else
                              ...classesForSelectedDay.map((classInfo) {
                                final status = classInfo.timeSlot == null
                                    ? null
                                    : model.getAttendanceStatus(
                                        classInfo.subject.name,
                                        classInfo.isTheory
                                            ? 'theory'
                                            : 'practical',
                                        _selectedDate,
                                        classInfo.timeSlot!);
                                return _buildClassCard(classInfo, status);
                              }).toList(),
                            const SizedBox(height: 32),
                            const Text(
                              'Attendance Summary',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final subject = model.subjects[index];
                          final theoryData =
                              model.attendanceData[subject.name]!['theory']!;
                          final practicalData =
                              model.attendanceData[subject.name]!['practical']!;
                          return Padding(
                            padding:
                                const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: _buildSummaryCard(
                                subject, theoryData, practicalData),
                          );
                        },
                        childCount: model.subjects.length,
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[700]!, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.grey[400], size: 24),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassCard(ClassInfo classInfo, AttendanceStatus? status) {
    final cardColor = classInfo.isTheory ? Colors.blue : Colors.green;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => _showAttendanceDialog(classInfo),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
            border: Border(
              left: BorderSide(color: cardColor, width: 4),
            ),
          ),
          child: Row(
            children: [
              Icon(
                classInfo.isTheory
                    ? Icons.book_outlined
                    : Icons.science_outlined,
                color: cardColor,
                size: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      classInfo.subject.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${classInfo.isTheory ? "Theory" : "Practical"} • ${classInfo.timeSlot ?? "N/A"}',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              if (status != null)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(_getStatusIcon(status),
                      color: _getStatusColor(status), size: 20),
                )
              else
                Icon(Icons.touch_app_outlined,
                    color: Colors.grey[600], size: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(Subject subject, AttendanceSummary theoryData,
      AttendanceSummary practicalData) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            subject.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subject.creditDescription,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              if (theoryData.totalScheduledHours > 0)
                Expanded(
                  child: _buildRadialGauge(
                    title: 'Theory',
                    data: theoryData,
                    color: Colors.blue,
                  ),
                ),
              if (subject.hasPractical && practicalData.totalScheduledHours > 0)
                Expanded(
                  child: _buildRadialGauge(
                    title: 'Practical',
                    data: practicalData,
                    color: Colors.green,
                  ),
                ),
            ],
          ),
          if (theoryData.totalScheduledHours == 0 &&
              (!subject.hasPractical || practicalData.totalScheduledHours == 0))
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Center(
                child: Text(
                  'No attendance data yet',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRadialGauge(
      {required String title,
      required AttendanceSummary data,
      required Color color}) {
    final percentage = data.percentage / 100;

    return Column(
      children: [
        CircularPercentIndicator(
          radius: 55.0,
          lineWidth: 8.0,
          animation: true,
          animationDuration: 1200,
          percent: percentage.isNaN ? 0 : percentage.clamp(0.0, 1.0),
          center: Text(
            "${data.percentage.toStringAsFixed(1)}%",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
                color: _getPercentageColor(data.percentage)),
          ),
          circularStrokeCap: CircularStrokeCap.round,
          progressColor: _getPercentageColor(data.percentage),
          backgroundColor: Colors.grey[800]!,
        ),
        const SizedBox(height: 12),
        Text(
          title,
          style: TextStyle(
              color: color, fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Text(
          '${data.totalHoursAttended.toStringAsFixed(1)} / ${data.totalScheduledHours.toStringAsFixed(1)}h',
          style: TextStyle(color: Colors.grey[400], fontSize: 12),
        ),
        const SizedBox(height: 4),
        if (data.hoursCanMiss > 0)
          Text(
            'Can miss: ${data.hoursCanMiss.toStringAsFixed(1)}h',
            style: TextStyle(
              color: Colors.green[300],
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          )
        else
          Text(
            'Cannot miss more',
            style: TextStyle(
              color: Colors.red[300],
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        if (data.hoursHeldExclMassBunk != data.totalHoursHeld) ...[
          const SizedBox(height: 12),
          Divider(color: Colors.grey[800], indent: 20, endIndent: 20),
          const SizedBox(height: 8),
          Text(
            'Excl. Mass Bunks',
            style: TextStyle(
              color: Colors.orange[300],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${data.percentageExclMassBunk.toStringAsFixed(1)}% (${data.hoursAttendedExclMassBunk.toStringAsFixed(1)}/${data.hoursHeldExclMassBunk.toStringAsFixed(1)}h)',
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
        ]
      ],
    );
  }
}
