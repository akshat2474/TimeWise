// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:timewise_dtu/models/subject_model.dart';
import 'package:timewise_dtu/screens/subject_details_screen.dart';
import 'package:timewise_dtu/services/export_service.dart';
import 'timetable_grid_screen.dart';
import '../models/timetable_model.dart';
import '../theme/app_theme.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  late DateTime _selectedDate;
  late DateTime _focusedDate;
  CalendarFormat _calendarFormat = CalendarFormat.week;
  final ExportService _exportService = ExportService();

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
    final theme = Theme.of(context);
    final currentStatus = classInfo.timeSlot == null
        ? null
        : model.getAttendanceStatus(
            classInfo.subject.name,
            classInfo.isTheory ? 'theory' : 'practical',
            _selectedDate,
            classInfo.timeSlot!,
          );

    final List<Map<String, dynamic>> attendanceOptions = [
      {
        'label': 'Present',
        'icon': Icons.check_circle_outline,
        'color': theme.colorScheme.secondary,
        'status': AttendanceStatus.present
      },
      {
        'label': 'Absent',
        'icon': Icons.cancel_outlined,
        'color': theme.colorScheme.error,
        'status': AttendanceStatus.absent
      },
      {
        'label': 'Holiday',
        'icon': Icons.beach_access_outlined,
        'color': Colors.grey,
        'status': AttendanceStatus.holiday
      },
      {
        'label': 'Mass Bunk',
        'icon': Icons.group_off_outlined,
        'color': Colors.orangeAccent,
        'status': AttendanceStatus.massBunk
      },
      {
        'label': 'Teacher Absent',
        'icon': Icons.person_off_outlined,
        'color': AppTheme.primary,
        'status': AttendanceStatus.teacherAbsent
      },
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        List<Widget> buttonRows = [];
        final screenWidth = MediaQuery.of(context).size.width;
        final horizontalPadding = 24.0 * 2; 
        final modalContentWidth = screenWidth - horizontalPadding;
        final spacing = 12.0;
        final itemWidth = (modalContentWidth - spacing) / 2;

        for (int i = 0; i < attendanceOptions.length; i += 2) {
          final option1 = attendanceOptions[i];
          final button1 = _buildAttendanceOption(
            icon: option1['icon'],
            label: option1['label'],
            color: option1['color'],
            onTap: () {
              _markAttendance(classInfo, option1['status']);
              Navigator.pop(context);
            },
          );

          Widget row;
          if (i + 1 < attendanceOptions.length) {
            final option2 = attendanceOptions[i + 1];
            final button2 = _buildAttendanceOption(
              icon: option2['icon'],
              label: option2['label'],
              color: option2['color'],
              onTap: () {
                _markAttendance(classInfo, option2['status']);
                Navigator.pop(context);
              },
            );
            row = Row(children: [
              Expanded(child: button1),
              const SizedBox(width: 12),
              Expanded(child: button2),
            ]);
          } else {
            row = Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: itemWidth,
                  child: button1,
                ),
              ],
            );
          }
          buttonRows.add(row);
        }

        final Widget attendanceButtons = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < buttonRows.length; i++) ...[
              buttonRows[i],
              if (i < buttonRows.length - 1) const SizedBox(height: 12),
            ],
          ],
        );

        return Container(
          margin: const EdgeInsets.all(8),
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              top: 24,
              left: 24,
              right: 24),
          decoration: BoxDecoration(
              color: theme.colorScheme.surface.withOpacity(0.95),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.2))),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: (classInfo.subject.color).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        classInfo.isTheory
                            ? Icons.book_outlined
                            : Icons.science_outlined,
                        color: classInfo.subject.color,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            classInfo.subject.name,
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${classInfo.isTheory ? 'Theory' : 'Practical'} • ${classInfo.duration}h • ${_getDayName(_selectedDate)}',
                            style: theme.textTheme.bodyMedium,
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
                        const SizedBox(width: 12),
                        Text(
                          'Current Status: ${_getStatusText(currentStatus)}',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: _getStatusColor(currentStatus),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Text(
                  'Mark Attendance:',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                attendanceButtons,
              ],
            ),
          ),
        );
      },
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
    _showStatusMessage(
        'Marked as ${_getStatusText(status)} for ${classInfo.subject.name}',
        _getStatusColor(status));
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
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
    final theme = Theme.of(context);
    switch (status) {
      case AttendanceStatus.present:
        return theme.colorScheme.secondary;
      case AttendanceStatus.absent:
        return theme.colorScheme.error;
      case AttendanceStatus.holiday:
        return Colors.grey;
      case AttendanceStatus.massBunk:
        return Colors.orangeAccent;
      case AttendanceStatus.teacherAbsent:
        return AppTheme.primary;
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
    if (percentage >= 75) return Theme.of(context).colorScheme.secondary;
    if (percentage >= 60) return Colors.orangeAccent;
    return Theme.of(context).colorScheme.error;
  }

  void _showStatusMessage(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showEditOptions() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TimetableGridScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer<TimetableModel>(
      builder: (context, model, child) {
        final dayName = _getDayName(_selectedDate);
        final classesForSelectedDay =
            _isWeekday(_selectedDate) ? model.getClassesForDay(dayName) : [];
        final heatmapData = model.getCalendarHeatmapData();

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                title: const Text('Attendance Tracker'),
                pinned: true,
                floating: true,
                actions: [
                  IconButton(
                    onPressed: () => _exportService.exportAttendance(model.attendanceRecords),
                    icon: const Icon(Icons.share),
                    tooltip: 'Export Attendance',
                  ),
                  IconButton(
                    onPressed: _showEditOptions,
                    icon: const Icon(Icons.edit_calendar_outlined),
                    tooltip: 'Edit Timetable',
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  decoration: BoxDecoration(
                      color: theme.colorScheme.surface.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.1))),
                  child: TableCalendar(
                    focusedDay: _focusedDate,
                    firstDay: DateTime.utc(2020),
                    lastDay: DateTime.utc(2030),
                    calendarFormat: _calendarFormat,
                    selectedDayPredicate: (day) =>
                        isSameDay(_selectedDate, day),
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
                    headerStyle: HeaderStyle(
                        titleTextStyle: theme.textTheme.titleMedium!,
                        formatButtonTextStyle:
                            const TextStyle(color: Colors.white),
                        formatButtonDecoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(8))),
                    calendarStyle: CalendarStyle(
                      defaultTextStyle: theme.textTheme.bodyMedium!,
                      weekendTextStyle: theme.textTheme.bodyMedium!.copyWith(
                          color: theme.colorScheme.primary.withOpacity(0.7)),
                      selectedTextStyle: const TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                      todayTextStyle: TextStyle(
                          color: theme.colorScheme.secondary,
                          fontWeight: FontWeight.bold),
                      selectedDecoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      todayDecoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border.all(
                            color: theme.colorScheme.secondary, width: 2),
                        shape: BoxShape.circle,
                      ),
                    ),
                    calendarBuilders: CalendarBuilders(
                      markerBuilder: (context, day, events) {
                        final date = DateTime(day.year, day.month, day.day);
                        if (heatmapData.containsKey(date)) {
                          return Container(
                            decoration: BoxDecoration(
                              color: heatmapData[date]!.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                          );
                        }
                        return null;
                      },
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Classes for $dayName',
                          style: theme.textTheme.titleLarge,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            iconSize: 22,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () => model.bulkMarkDay(_selectedDate, AttendanceStatus.present),
                            icon: const Icon(Icons.check_circle),
                            tooltip: "Mark All Present",
                            color: AppTheme.secondary,
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            iconSize: 22,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () => model.bulkMarkDay(_selectedDate, AttendanceStatus.absent),
                            icon: const Icon(Icons.cancel),
                            tooltip: "Mark All Absent",
                            color: AppTheme.error,
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            iconSize: 22,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () => model.bulkMarkDay(_selectedDate, AttendanceStatus.holiday),
                            icon: const Icon(Icons.beach_access),
                            tooltip: "Mark All as Holiday",
                            color: Colors.grey,
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
              if (!_isWeekday(_selectedDate) || classesForSelectedDay.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: _buildInfoCard(
                      _isWeekday(_selectedDate)
                          ? 'No classes scheduled for this day'
                          : 'No classes scheduled for weekends',
                      _isWeekday(_selectedDate)
                          ? Icons.free_breakfast_outlined
                          : Icons.weekend_outlined,
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final classInfo = classesForSelectedDay[index];
                      final status = classInfo.timeSlot == null
                          ? null
                          : model.getAttendanceStatus(
                              classInfo.subject.name,
                              classInfo.isTheory ? 'theory' : 'practical',
                              _selectedDate,
                              classInfo.timeSlot!);
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                        child: _buildClassCard(classInfo, status),
                      );
                    },
                    childCount: classesForSelectedDay.length,
                  ),
                ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
                  child: Text(
                    'Attendance Summary',
                    style: theme.textTheme.titleLarge,
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
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child:
                          _buildSummaryCard(subject, theoryData, practicalData),
                    );
                  },
                  childCount: model.subjects.length,
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoCard(String text, IconData icon) {
    final theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon,
            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
            size: 40),
        const SizedBox(height: 16),
        Text(
          text,
          style: theme.textTheme.bodyLarge,
        ),
      ],
    );
  }

  Widget _buildClassCard(ClassInfo classInfo, AttendanceStatus? status) {
    final theme = Theme.of(context);
    final cardColor = classInfo.subject.color;

    return GestureDetector(
      onTap: () => _showAttendanceDialog(classInfo),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border(
            left: BorderSide(color: cardColor, width: 4),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  classInfo.isTheory ? Icons.book_outlined : Icons.science_outlined,
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
                        style: theme.textTheme.bodyLarge
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${classInfo.isTheory ? "Theory" : "Practical"} • ${classInfo.timeSlot ?? "N/A"}',
                        style: theme.textTheme.bodyMedium,
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
                  Icon(Icons.touch_app_outlined, color: Colors.grey[600], size: 24),
              ],
            ),
            if (classInfo.notes != null && classInfo.notes!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12.0, left: 40),
                child: Row(
                  children: [
                    Icon(Icons.notes, size: 12, color: Colors.grey[400]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        classInfo.notes!,
                        style: TextStyle(fontSize: 12, color: Colors.grey[400], fontStyle: FontStyle.italic),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(Subject subject, AttendanceSummary theoryData,
      AttendanceSummary practicalData) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SubjectDetailsScreen(subject: subject))),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(subject.name, style: theme.textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(subject.creditDescription, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  if (theoryData.totalScheduledHours > 0)
                    Expanded(
                      child: _buildRadialGauge(
                        title: 'Theory',
                        data: theoryData,
                        color: subject.color,
                        percentageWithMassBunk: theoryData.percentage,
                      ),
                    ),
                  if (subject.hasPractical &&
                      practicalData.totalScheduledHours > 0)
                    Expanded(
                      child: _buildRadialGauge(
                        title: 'Practical',
                        data: practicalData,
                        color: subject.color.withGreen(200),
                        percentageWithMassBunk: practicalData.percentage,
                      ),
                    ),
                ],
              ),
              if (theoryData.totalScheduledHours == 0 &&
                  (!subject.hasPractical ||
                      practicalData.totalScheduledHours == 0))
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Center(
                    child: Text(
                      'No attendance data yet',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(fontStyle: FontStyle.italic),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRadialGauge(
      {required String title,
      required AttendanceSummary data,
      required Color color,
      double? percentageWithMassBunk}) {
    final theme = Theme.of(context);
    final percentage = data.percentage / 100;
    final percentageExclMassBunk = data.percentageExclMassBunk;

    final bool hasMassBunk = percentageWithMassBunk != null &&
        (percentage * 100).toStringAsFixed(1) !=
            percentageExclMassBunk.toStringAsFixed(1);

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
            style: theme.textTheme.headlineSmall?.copyWith(
                color: _getPercentageColor(data.percentage),
                fontWeight: FontWeight.bold),
          ),
          circularStrokeCap: CircularStrokeCap.round,
          progressColor: _getPercentageColor(data.percentage),
          backgroundColor: theme.colorScheme.surfaceVariant,
        ),
        const SizedBox(height: 12),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(color: color),
        ),
        const SizedBox(height: 4),
        Text(
          '${data.totalHoursAttended.toStringAsFixed(1)} / ${data.totalScheduledHours.toStringAsFixed(1)}h',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 4),
        if (hasMassBunk)
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: RichText(
              text: TextSpan(
                style: theme.textTheme.bodySmall,
                children: [
                  const TextSpan(
                    text: 'w/o bunks: ',
                    style: TextStyle(color: Colors.orangeAccent),
                  ),
                  TextSpan(
                    text: '${percentageExclMassBunk.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: _getPercentageColor(percentageExclMassBunk),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (data.hoursCanMiss > 0)
          Text(
            'Can miss: ${data.hoursCanMiss.toStringAsFixed(1)}h',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.secondary),
          )
        else
          Text(
            'Cannot miss more',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.error),
          ),
      ],
    );
  }
}
