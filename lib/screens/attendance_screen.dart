import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'timetable_grid_screen.dart';
import '../models/timetable_model.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({Key? key}) : super(key: key);

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  String _selectedDay = 'Monday';
  final List<String> _days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday'
  ];
  DateTime _getDateForSelectedDay(String day) {
    final now = DateTime.now();
    final currentWeekday = now.weekday;
    final selectedWeekday = _days.indexOf(day) + 1;
    final dayDifference = selectedWeekday - currentWeekday;
    final selectedDate = now.add(Duration(days: dayDifference));
    return DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
  }

  void _showAttendanceDialog(ClassInfo classInfo) {
    final model = context.read<TimetableModel>();
    final dateForMarking = _getDateForSelectedDay(_selectedDay);
    final currentStatus = classInfo.timeSlot == null
        ? null
        : model.getAttendanceStatus(
            classInfo.subject.name,
            classInfo.isTheory ? 'theory' : 'practical',
            dateForMarking,
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
                        classInfo.isTheory ? Icons.book : Icons.science,
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
                            '${classInfo.isTheory ? 'Theory' : 'Practical'} • ${classInfo.duration}h • $_selectedDay',
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
                          _markAttendance(classInfo, AttendanceStatus.massBunk);
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
    final dateForMarking = _getDateForSelectedDay(_selectedDay);
    final hours = classInfo.duration.toDouble();
    model.markAttendance(
      classInfo.subject.name,
      classInfo.isTheory ? 'theory' : 'practical',
      status,
      dateForMarking,
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
          final classesForSelectedDay = model.getClassesForDay(_selectedDay);
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
                  icon: const Icon(Icons.edit, color: Colors.white),
                  tooltip: 'Edit Options',
                ),
              ],
            ),
            body: SafeArea(
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                      children: _days.map((day) {
                        final isSelected = day == _selectedDay;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedDay = day),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                day.substring(0, 3),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.black
                                      : Colors.grey[400],
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Classes for $_selectedDay',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500)),
                          const SizedBox(height: 16),
                          ...classesForSelectedDay.map((classInfo) {
                            final dateForStatus =
                                _getDateForSelectedDay(_selectedDay);
                            final status = classInfo.timeSlot == null
                                ? null
                                : model.getAttendanceStatus(
                                    classInfo.subject.name,
                                    classInfo.isTheory ? 'theory' : 'practical',
                                    dateForStatus,
                                    classInfo.timeSlot!,
                                  );
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: GestureDetector(
                                onTap: () => _showAttendanceDialog(classInfo),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[900],
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: classInfo.isTheory
                                          ? Colors.blue
                                          : Colors.green,
                                      width: 2,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(classInfo.subject.name,
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.w500)),
                                                const SizedBox(width: 8),
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: classInfo.isTheory
                                                        ? Colors.blue
                                                        : Colors.green,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                  child: Text(
                                                    classInfo.isTheory
                                                        ? 'Theory'
                                                        : 'Practical',
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                                'Duration: ${classInfo.duration}h',
                                                style: TextStyle(
                                                    color: Colors.grey[400],
                                                    fontSize: 14)),
                                            Text(
                                              'Time: ${classInfo.timeSlot ?? 'N/A'}',
                                              style: TextStyle(
                                                  color: Colors.grey[400],
                                                  fontSize: 12,
                                                  fontStyle: FontStyle.italic),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (status != null)
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: _getStatusColor(status)
                                                .withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                                color: _getStatusColor(status),
                                                width: 1),
                                          ),
                                          child: Icon(_getStatusIcon(status),
                                              color: _getStatusColor(status),
                                              size: 20),
                                        )
                                      else
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                              color: Colors.grey[700],
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                          child: Icon(Icons.touch_app,
                                              color: Colors.grey[400],
                                              size: 20),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                          const SizedBox(height: 32),
                          const Text('Attendance Summary',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500)),
                          const SizedBox(height: 16),
                          ...model.subjects.map((subject) {
                            final theoryData =
                                model.attendanceData[subject.name]!['theory']!;
                            final practicalData = model
                                .attendanceData[subject.name]!['practical']!;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey[900],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: Colors.grey[700]!, width: 1),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 48,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(subject.name,
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500)),
                                          Text(
                                            subject.creditDescription,
                                            style: TextStyle(
                                                color: Colors.grey[500],
                                                fontSize: 11),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    if (theoryData.totalScheduledHours > 0) ...[
                                      Row(
                                        children: [
                                          Icon(Icons.book,
                                              color: Colors.blue[400],
                                              size: 16),
                                          const SizedBox(width: 8),
                                          const Text('Theory',
                                              style: TextStyle(
                                                  color: Colors.blue,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500)),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                    'Overall: ${theoryData.percentage.toStringAsFixed(1)}%',
                                                    style: TextStyle(
                                                        color:
                                                            _getPercentageColor(
                                                                theoryData
                                                                    .percentage),
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w600)),
                                                Text(
                                                    '${theoryData.totalHoursAttended.toStringAsFixed(1)}/${theoryData.totalScheduledHours.toStringAsFixed(1)}h',
                                                    style: TextStyle(
                                                        color: Colors.grey[400],
                                                        fontSize: 12)),
                                                if (theoryData.hoursCanMiss > 0)
                                                  Text(
                                                      'Can miss: ${theoryData.hoursCanMiss.toStringAsFixed(1)}h more',
                                                      style: TextStyle(
                                                          color:
                                                              Colors.green[300],
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.w500))
                                                else
                                                  Text(
                                                      'Cannot miss any more classes',
                                                      style: TextStyle(
                                                          color:
                                                              Colors.red[300],
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.w500)),
                                              ],
                                            ),
                                          ),
                                          if (theoryData
                                                  .hoursHeldExclMassBunk !=
                                              theoryData.totalHoursHeld)
                                            Flexible(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Text(
                                                      'Excl MB: ${theoryData.percentageExclMassBunk.toStringAsFixed(1)}%',
                                                      style: TextStyle(
                                                          color: Colors
                                                              .orange[300],
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w500)),
                                                  Text(
                                                      '${theoryData.hoursAttendedExclMassBunk.toStringAsFixed(1)}/${theoryData.hoursHeldExclMassBunk.toStringAsFixed(1)}h',
                                                      style: TextStyle(
                                                          color:
                                                              Colors.grey[500],
                                                          fontSize: 11)),
                                                ],
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      LinearProgressIndicator(
                                          value: theoryData.percentage / 100,
                                          backgroundColor: Colors.grey[700],
                                          valueColor: AlwaysStoppedAnimation(
                                              _getPercentageColor(
                                                  theoryData.percentage))),
                                      const SizedBox(height: 16),
                                    ],
                                    if (subject.hasPractical &&
                                        practicalData.totalScheduledHours >
                                            0) ...[
                                      Row(
                                        children: [
                                          Icon(Icons.science,
                                              color: Colors.green[400],
                                              size: 16),
                                          const SizedBox(width: 8),
                                          const Text('Practical',
                                              style: TextStyle(
                                                  color: Colors.green,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500)),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                    'Overall: ${practicalData.percentage.toStringAsFixed(1)}%',
                                                    style: TextStyle(
                                                        color:
                                                            _getPercentageColor(
                                                                practicalData
                                                                    .percentage),
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w600)),
                                                Text(
                                                    '${practicalData.totalHoursAttended.toStringAsFixed(1)}/${practicalData.totalScheduledHours.toStringAsFixed(1)}h',
                                                    style: TextStyle(
                                                        color: Colors.grey[400],
                                                        fontSize: 12)),
                                                if (practicalData.hoursCanMiss >
                                                    0)
                                                  Text(
                                                      'Can miss: ${practicalData.hoursCanMiss.toStringAsFixed(1)}h more',
                                                      style: TextStyle(
                                                          color:
                                                              Colors.green[300],
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.w500))
                                                else
                                                  Text(
                                                      'Cannot miss any more classes',
                                                      style: TextStyle(
                                                          color:
                                                              Colors.red[300],
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.w500)),
                                              ],
                                            ),
                                          ),
                                          if (practicalData
                                                  .hoursHeldExclMassBunk !=
                                              practicalData.totalHoursHeld)
                                            Flexible(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Text(
                                                      'Excl MB: ${practicalData.percentageExclMassBunk.toStringAsFixed(1)}%',
                                                      style: TextStyle(
                                                          color: Colors
                                                              .orange[300],
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w500)),
                                                  Text(
                                                      '${practicalData.hoursAttendedExclMassBunk.toStringAsFixed(1)}/${practicalData.hoursHeldExclMassBunk.toStringAsFixed(1)}h',
                                                      style: TextStyle(
                                                          color:
                                                              Colors.grey[500],
                                                          fontSize: 11)),
                                                ],
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      LinearProgressIndicator(
                                          value: practicalData.percentage / 100,
                                          backgroundColor: Colors.grey[700],
                                          valueColor: AlwaysStoppedAnimation(
                                              _getPercentageColor(
                                                  practicalData.percentage))),
                                    ],
                                    if (theoryData.totalScheduledHours == 0 &&
                                        (!subject.hasPractical ||
                                            practicalData.totalScheduledHours ==
                                                0))
                                      Text(
                                        'No attendance data yet',
                                        style: TextStyle(
                                          color: Colors.grey[500],
                                          fontSize: 14,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
