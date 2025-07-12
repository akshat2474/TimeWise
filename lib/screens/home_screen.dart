import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'subject_setup_screen.dart';
import 'attendance_screen.dart';
import 'timetable_management_screen.dart';
import '../models/timetable_model.dart';
import '../services/notification_service.dart';

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

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'TimeWise',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w300,
            letterSpacing: 1,
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
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
              icon: const Icon(Icons.fact_check_outlined, color: Colors.white),
              tooltip: 'Go to Attendance',
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Welcome to TimeWise',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Smart Attendance Tracker for DTU',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[400],
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(height: 40),
              if (hasExistingTimetable) ...[
                _buildTodaysSchedule(context, model),
                const SizedBox(height: 24),
              ],
              _buildQuickActionCard(
                context,
                hasExistingTimetable: hasExistingTimetable,
                model: model,
              ),
              const SizedBox(height: 24),
              if (hasExistingTimetable) ...[
                const Text(
                  'Reminders & Tools',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 12),
                _buildToolsCard(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStyledContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900]?.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Today's Schedule",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 12),
        _buildStyledContainer(
          child: classesToday.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: Column(
                      children: [
                        Icon(Icons.free_breakfast_outlined,
                            color: Colors.grey[400], size: 32),
                        const SizedBox(height: 8),
                        Text(
                          'No classes scheduled for today!',
                          style: TextStyle(
                              color: Colors.grey[400], fontSize: 14),
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
                              ? Colors.blue[300]
                              : Colors.green[300],
                          size: 20,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            classInfo.subject.name,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                        Text(
                          classInfo.timeSlot ?? 'N/A',
                          style:
                              TextStyle(color: Colors.grey[300], fontSize: 14),
                        ),
                      ],
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(BuildContext context,
      {required bool hasExistingTimetable, required TimetableModel model}) {
    return _buildStyledContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            hasExistingTimetable ? 'Active Timetable' : 'Get Started',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hasExistingTimetable
                ? 'You have an active schedule. Track attendance or manage your timetables.'
                : 'Set up your subjects and timetable to start tracking your attendance.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SubjectSetupScreen(
                      existingSubjects:
                          hasExistingTimetable ? model.subjects : null,
                      isEditing: hasExistingTimetable,
                    ),
                  ),
                );
              },
              icon: Icon(
                hasExistingTimetable ? Icons.edit_note : Icons.add_circle,
                size: 20,
              ),
              label: Text(
                hasExistingTimetable ? 'Edit Subjects' : 'Setup Timetable',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          if (hasExistingTimetable) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TimetableManagementScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.layers_outlined, size: 20),
                label: const Text('Manage Templates'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white.withOpacity(0.5)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildToolsCard(BuildContext context) {
    return _buildStyledContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Enable daily reminders to mark your attendance at 6 PM (Mon-Fri).',
            style: TextStyle(color: Colors.grey[300], fontSize: 14),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    NotificationService().scheduleWeeklyAttendanceReminders();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Attendance reminders scheduled!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  icon: const Icon(Icons.notifications_active, size: 18),
                  label: const Text('Enable'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.green,
                    side: const BorderSide(color: Colors.green),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    NotificationService().cancelAllNotifications();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('All reminders cancelled.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  },
                  icon: const Icon(Icons.notifications_off, size: 18),
                  label: const Text('Disable'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
