import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:timewise_dtu/theme/app_theme.dart';
import 'attendance_screen.dart';
import '../models/timetable_model.dart';
import 'subject_setup_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
        _buildDashboardSummary(context, model),
        const SizedBox(height: 32),
        _buildTodaysSchedule(context, model),
        const SizedBox(height: 24),
      ],
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

  Widget _buildDashboardSummary(BuildContext context, TimetableModel model) {
    final theme = Theme.of(context);
    final nextClass = model.getNextClass();
    final overallAttendance = model.getOverallAttendancePercentage();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Dashboard", style: theme.textTheme.titleLarge),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStyledCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Next Class", style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    if (nextClass != null) ...[
                      Text(
                        nextClass.subject.name,
                        style: theme.textTheme.bodyLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        nextClass.timeSlot ?? 'N/A',
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: Colors.white70),
                      ),
                    ] else
                      Text("No more classes!",
                          style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStyledCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Attendance", style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(
                      '${overallAttendance.toStringAsFixed(1)}%',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: overallAttendance >= 75
                            ? AppTheme.secondary
                            : AppTheme.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text("Overall",
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: Colors.white70)),
                  ],
                ),
              ),
            ),
          ],
        ),
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
          "Today's Schedule",
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
                    final timeSlotParts =
                        classInfo.timeSlot?.split(' - ') ?? [];
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

                    final double nowInMinutes =
                        now.hour * 60.0 + now.minute;
                    final double startInMinutes = startTime != null
                        ? startTime.hour * 60.0 + startTime.minute
                        : -1;
                    final double endInMinutes = endTime != null
                        ? endTime.hour * 60.0 + endTime.minute
                        : -1;

                    bool isLive = nowInMinutes >= startInMinutes &&
                        nowInMinutes < endInMinutes;
                    bool isPast = nowInMinutes >= endInMinutes;

                    return Row(
                      children: [
                        Icon(
                          classInfo.isTheory
                              ? Icons.book_outlined
                              : Icons.science_outlined,
                          color: classInfo.isTheory
                              ? AppTheme.accentBlue
                              : theme.colorScheme.secondary,
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
                          Text(
                            classInfo.timeSlot ?? 'N/A',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.textTheme.bodyMedium?.color
                                  ?.withOpacity(0.8),
                            ),
                          ),
                        ] else if (isPast) ...[
                          Text(
                            "PAST",
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: Colors.white38,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ] else ...[
                          Text(
                            classInfo.timeSlot ?? 'N/A',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.textTheme.bodyMedium?.color
                                  ?.withOpacity(0.8),
                            ),
                          ),
                        ]
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
}
