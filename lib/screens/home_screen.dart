// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:timewise_dtu/models/subject_model.dart';
import 'package:timewise_dtu/screens/achievements_screen.dart';
import 'package:timewise_dtu/services/notification_service.dart';
import 'package:timewise_dtu/theme/app_theme.dart';
import 'attendance_screen.dart';
import '../models/timetable_model.dart';
import 'subject_setup_screen.dart';
import 'dart:async';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Rebuild the screen periodically to update "live" status
    _timer =
        Timer.periodic(const Duration(seconds: 10), (Timer t) => setState(() {}));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<TimetableModel>();
    final hasExistingTimetable = model.subjects.isNotEmpty;
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, theme, hasExistingTimetable),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: hasExistingTimetable
                      ? _buildDashboardView(context, model)
                      : _buildEmptyStateView(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildSliverAppBar(
      BuildContext context, ThemeData theme, bool hasExistingTimetable) {
    return SliverAppBar(
      pinned: true,
      stretch: true,
      expandedHeight: 220.0,
      backgroundColor: theme.scaffoldBackgroundColor,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        title: Text(
          'TimeWise',
          style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withOpacity(0.5),
                    theme.scaffoldBackgroundColor,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.7],
                ),
              ),
            ),
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_on_outlined),
          tooltip: 'Test Notification',
          onPressed: () {
            NotificationService().scheduleTestNotification();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content:
                    Text('Test notification scheduled for 1 minute from now.'),
                backgroundColor: Colors.green,
              ),
            );
          },
        ),
        if (hasExistingTimetable)
          IconButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AchievementsScreen())),
            icon: const Icon(Icons.emoji_events_outlined),
            tooltip: 'Achievements',
            color: Colors.white,
          ),
        if (hasExistingTimetable)
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AttendanceScreen(),
                ),
              );
            },
            icon: const Icon(Icons.fact_check_outlined),
            tooltip: 'Go to Attendance',
            color: Colors.white,
          ),
      ],
    );
  }

  Widget _buildDashboardView(BuildContext context, TimetableModel model) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        _buildOverallDashboard(model),
        const SizedBox(height: 24),
        _buildTodaysSchedule(context, model),
        const SizedBox(height: 24),
        _buildSubjectsAtRisk(model),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildOverallDashboard(TimetableModel model) {
    final theme = Theme.of(context);
    final overallSummary = model.getOverallAttendanceSummary();
    final overallPercentage = overallSummary.percentage;

    return _buildStyledCard(
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Row(
              children: [
                CircularPercentIndicator(
                  radius: 40.0,
                  lineWidth: 8.0,
                  percent: (overallPercentage / 100).clamp(0.0, 1.0),
                  center: Text(
                    "${overallPercentage.toStringAsFixed(0)}%",
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: _getPercentageColor(overallPercentage),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  circularStrokeCap: CircularStrokeCap.round,
                  progressColor: _getPercentageColor(overallPercentage),
                  backgroundColor: theme.colorScheme.surfaceVariant,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Overall", style: theme.textTheme.titleMedium),
                      const SizedBox(height: 4),
                       Text(
                        '${overallSummary.totalHoursAttended.toStringAsFixed(1)} / ${overallSummary.totalHoursHeld.toStringAsFixed(1)}h',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              children: [
                 Icon(
                  Icons.local_fire_department_rounded,
                  color: Colors.orangeAccent,
                  size: 28,
                ),
                const SizedBox(height: 4),
                Text(
                  "${model.attendanceStreak} Day${model.attendanceStreak == 1 ? '' : 's'}",
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text("Streak", style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyStateView(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 48),
        Icon(Icons.calendar_today_outlined,
            size: 48, color: theme.colorScheme.primary),
        const SizedBox(height: 24),
        Text(
          'Welcome to TimeWise!',
          style: theme.textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'Create your timetable to start tracking attendance and never miss a class.',
          style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white70),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const SubjectSetupScreen()),
            );
          },
          icon: const Icon(Icons.add_circle_outline),
          label: const Text('Create Your Timetable'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            textStyle: theme.textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSubjectsAtRisk(TimetableModel model) {
    final theme = Theme.of(context);
    final subjectsAtRisk = model.getSubjectsAtRisk();

    if (subjectsAtRisk.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Attendance Alert", style: theme.textTheme.titleLarge),
        const SizedBox(height: 12),
        _buildStyledCard(
            child: Column(
          children: subjectsAtRisk.map((subject) {
            final data = model.getAttendanceDataForSubject(subject.name);
            final theoryPercentage = data['theory']!.percentage;
            final practicalPercentage = data['practical']!.percentage;
            bool theoryAtRisk =
                data['theory']!.totalScheduledHours > 0 && theoryPercentage < 75;
            bool practicalAtRisk = subject.hasPractical &&
                data['practical']!.totalScheduledHours > 0 &&
                practicalPercentage < 75;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded,
                      color: theme.colorScheme.error, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Text(subject.name, style: theme.textTheme.bodyLarge)),
                  if (theoryAtRisk)
                    Text(
                      "Th: ${theoryPercentage.toStringAsFixed(1)}%",
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: theme.colorScheme.error),
                    ),
                  if (theoryAtRisk && practicalAtRisk) const SizedBox(width: 8),
                  if (practicalAtRisk)
                    Text(
                      "Pr: ${practicalPercentage.toStringAsFixed(1)}%",
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: theme.colorScheme.error),
                    ),
                ],
              ),
            );
          }).toList(),
        )),
      ],
    );
  }

  Widget _buildTodaysSchedule(BuildContext context, TimetableModel model) {
    final today = DateTime.now();
    final dayName = DateFormat('EEEE').format(today);
    final classesToday = model.getClassesForDay(dayName);
    final theme = Theme.of(context);
    final now = TimeOfDay.fromDateTime(today);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Today's Timeline",
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        _buildStyledCard(
          child: classesToday.isEmpty
              ? _buildNoClassesView(theme)
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: classesToday.length,
                  separatorBuilder: (_, __) => Divider(
                    color: Colors.white.withOpacity(0.1),
                    height: 24,
                  ),
                  itemBuilder: (context, index) {
                    final classInfo = classesToday[index];
                    final timeSlotParts = classInfo.timeSlot?.split('-') ?? [];
                    TimeOfDay? startTime;
                    TimeOfDay? endTime;

                    if (timeSlotParts.length == 2) {
                      try {
                        startTime = TimeOfDay(
                            hour: int.parse(timeSlotParts[0].split(':')[0]),
                            minute: int.parse(timeSlotParts[0].split(':')[1]));
                        endTime = TimeOfDay(
                            hour: int.parse(timeSlotParts[1].split(':')[0]),
                            minute: int.parse(timeSlotParts[1].split(':')[1]));
                      } catch (e) {
                        // Handle parsing error
                      }
                    }

                    final double nowInMinutes = now.hour * 60.0 + now.minute;
                    final double startInMinutes = startTime != null
                        ? startTime.hour * 60.0 + startTime.minute
                        : -1;
                    final double endInMinutes = endTime != null
                        ? endTime.hour * 60.0 + endTime.minute
                        : -1;

                    bool isLive = nowInMinutes >= startInMinutes &&
                        nowInMinutes < endInMinutes;
                    bool isPast = nowInMinutes >= endInMinutes;
                    
                    double progress = 0.0;
                    if (isLive) {
                      progress = (nowInMinutes - startInMinutes) / (endInMinutes - startInMinutes);
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              classInfo.isTheory
                                  ? Icons.book_outlined
                                  : Icons.science_outlined,
                              color: classInfo.subject.color,
                              size: 22,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                classInfo.subject.name,
                                style: theme.textTheme.bodyLarge,
                              ),
                            ),
                            const SizedBox(width: 12),
                            if (isLive) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.secondary.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: AppTheme.secondary, width: 1),
                                ),
                                child: Text(
                                  "LIVE",
                                  style: theme.textTheme.labelSmall?.copyWith(
                                      color: AppTheme.secondary,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 12),
                            ] else if (isPast) ...[
                              Text(
                                "PAST",
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: Colors.white38,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 12),
                            ],
                            Text(
                              classInfo.timeSlot ?? 'N/A',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.textTheme.bodyMedium?.color
                                    ?.withOpacity(isPast ? 0.5 : 0.8),
                              ),
                            ),
                          ],
                        ),
                        if (isLive)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: classInfo.subject.color.withOpacity(0.2),
                              valueColor: AlwaysStoppedAnimation<Color>(classInfo.subject.color),
                            ),
                          ),
                        if (classInfo.notes != null && classInfo.notes!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0, left: 38),
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
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildNoClassesView(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        child: Column(
          children: [
            Icon(
              Icons.free_breakfast_outlined,
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
              size: 32,
            ),
            const SizedBox(height: 12),
            Text(
              'No classes scheduled for today!',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStyledCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: Colors.white.withOpacity(0.15),
          width: 1.0,
        ),
      ),
      child: child,
    );
  }

  Color _getPercentageColor(double percentage) {
    if (percentage >= 75) return AppTheme.secondary;
    if (percentage >= 60) return Colors.orangeAccent;
    return AppTheme.error;
  }
}
