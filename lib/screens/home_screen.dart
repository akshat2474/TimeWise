import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:timewise_dtu/theme/app_theme.dart';
import 'attendance_screen.dart';
import '../models/timetable_model.dart';

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
          SliverAppBar(
            pinned: true,
            stretch: true,
            expandedHeight: 220.0,
            backgroundColor: theme.scaffoldBackgroundColor,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              title: Text(
                'TimeWise',
                style: theme.textTheme.titleLarge
                    ?.copyWith(color: Colors.white),
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
                ),
            ],
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      Text(
                        'Welcome to TimeWise',
                        style: theme.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Your smart attendance tracker.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodyMedium?.color
                              ?.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 32),
                      if (hasExistingTimetable) ...[
                        _buildTodaysSchedule(context, model),
                        const SizedBox(height: 24),
                      ],
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStyledCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
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

  Widget _buildTodaysSchedule(BuildContext context, TimetableModel model) {
    final today = DateTime.now();
    final dayName = DateFormat('EEEE').format(today);
    final classesToday = model.getClassesForDay(dayName);
    final theme = Theme.of(context);

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
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.free_breakfast_outlined,
                          color: theme.textTheme.bodyMedium?.color
                              ?.withOpacity(0.5),
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
                )
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
                        Text(
                          classInfo.timeSlot ?? 'N/A',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.textTheme.bodyMedium?.color
                                ?.withOpacity(0.8),
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


}