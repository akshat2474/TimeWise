// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:timewise_dtu/models/subject_model.dart';
import 'package:timewise_dtu/models/timetable_model.dart';
import 'package:timewise_dtu/theme/app_theme.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  int touchedIndex = -1;
  String? _selectedSubject; // Null represents "All Subjects"

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.scaffoldBackgroundColor,
              theme.colorScheme.primary.withOpacity(0.1),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Consumer<TimetableModel>(
          builder: (context, model, child) {
            final subjects = model.subjects;
            final List<AttendanceRecord> filteredRecords;

            if (_selectedSubject == null) {
              filteredRecords = model.attendanceRecords;
            } else {
              filteredRecords = model.attendanceRecords
                  .where((r) => r.subjectName == _selectedSubject)
                  .toList();
            }

            if (model.attendanceRecords.isEmpty) {
              return _buildEmptyState(theme, 'No Attendance Data Yet',
                  'Start marking attendance to see your stats.');
            }

            final statusCounts = _calculateStatusCounts(filteredRecords);
            final totalRecords = filteredRecords.length;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSubjectDropdown(subjects, theme),
                  const SizedBox(height: 24),
                  Text(
                    _selectedSubject ?? 'Overall Distribution',
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  if (totalRecords == 0)
                    _buildEmptyState(theme, 'No Records Found',
                        'No attendance has been marked for this subject yet.')
                  else
                    Card(
                      elevation: 4,
                      shadowColor: Colors.black.withOpacity(0.5),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 350,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  PieChart(
                                    PieChartData(
                                      pieTouchData: PieTouchData(
                                        touchCallback: (FlTouchEvent event,
                                            pieTouchResponse) {
                                          setState(() {
                                            if (!event
                                                    .isInterestedForInteractions ||
                                                pieTouchResponse == null ||
                                                pieTouchResponse
                                                        .touchedSection ==
                                                    null) {
                                              touchedIndex = -1;
                                              return;
                                            }
                                            touchedIndex = pieTouchResponse
                                                .touchedSection!
                                                .touchedSectionIndex;
                                          });
                                        },
                                      ),
                                      borderData: FlBorderData(show: false),
                                      sectionsSpace: 4,
                                      centerSpaceRadius: 90,
                                      sections: _buildPieChartSections(
                                          statusCounts, totalRecords),
                                    ),
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        totalRecords.toString(),
                                        style: theme.textTheme.displaySmall
                                            ?.copyWith(
                                                fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        'Classes',
                                        style: theme.textTheme.bodyLarge,
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            _buildLegend(statusCounts),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, String title, String subtitle) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pie_chart_outline,
              size: 60,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSubjectDropdown(List<Subject> subjects, ThemeData theme) {
    return DropdownButtonFormField<String>(
      value: _selectedSubject,
      decoration: InputDecoration(
        labelText: 'Filter by Subject',
        filled: true,
        fillColor: theme.colorScheme.surface.withOpacity(0.8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      items: [
        const DropdownMenuItem<String>(
          value: null,
          child: Text('All Subjects'),
        ),
        ...subjects.map((subject) {
          return DropdownMenuItem<String>(
            value: subject.name,
            child: Text(subject.name),
          );
        }),
      ],
      onChanged: (value) {
        setState(() {
          _selectedSubject = value;
          touchedIndex = -1;
        });
      },
    );
  }

  Map<AttendanceStatus, int> _calculateStatusCounts(
      List<AttendanceRecord> records) {
    final Map<AttendanceStatus, int> counts = {};
    for (var record in records) {
      counts[record.status] = (counts[record.status] ?? 0) + 1;
    }
    return counts;
  }

  List<PieChartSectionData> _buildPieChartSections(
      Map<AttendanceStatus, int> statusCounts, int totalRecords) {
    final List<PieChartSectionData> sections = [];
    int i = 0;
    statusCounts.forEach((status, count) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 18.0 : 14.0;
      final radius = isTouched ? 80.0 : 70.0;
      final percentage = (count / totalRecords) * 100;

      sections.add(
        PieChartSectionData(
          color: _getStatusColor(status),
          value: count.toDouble(),
          title: '${percentage.toStringAsFixed(1)}%',
          radius: radius,
          titleStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: const [Shadow(color: Colors.black, blurRadius: 2)],
          ),
        ),
      );
      i++;
    });
    return sections;
  }

  Widget _buildLegend(Map<AttendanceStatus, int> statusCounts) {
    return Column(
      children: statusCounts.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: _buildLegendItem(
            icon: _getStatusIcon(entry.key),
            color: _getStatusColor(entry.key),
            text: _getStatusText(entry.key),
            count: entry.value,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLegendItem(
      {required IconData icon,
      required Color color,
      required String text,
      required int count}) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 12),
        Text(
          text,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const Spacer(),
        Text(
          '$count',
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Color _getStatusColor(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return AppTheme.secondary;
      case AttendanceStatus.absent:
        return AppTheme.error;
      case AttendanceStatus.holiday:
        return Colors.grey[600]!;
      case AttendanceStatus.massBunk:
        return Colors.orangeAccent;
      case AttendanceStatus.teacherAbsent:
        return AppTheme.primary;
    }
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
}
