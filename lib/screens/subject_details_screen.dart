import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:timewise_dtu/models/subject_model.dart';
import 'package:timewise_dtu/models/timetable_model.dart';
import 'package:timewise_dtu/theme/app_theme.dart';
import 'package:fl_chart/fl_chart.dart';

class SubjectDetailsScreen extends StatefulWidget {
  final Subject subject;

  const SubjectDetailsScreen({super.key, required this.subject});

  @override
  State<SubjectDetailsScreen> createState() => _SubjectDetailsScreenState();
}

class _SubjectDetailsScreenState extends State<SubjectDetailsScreen> {
  final TextEditingController _missedClassesController = TextEditingController();
  double? _whatIfPercentage;

  @override
  void dispose() {
    _missedClassesController.dispose();
    super.dispose();
  }

  void _calculateWhatIf() {
    final model = context.read<TimetableModel>();
    final missedClasses = int.tryParse(_missedClassesController.text) ?? 0;
    if (missedClasses > 0) {
      setState(() {
        _whatIfPercentage = model.calculateWhatIf(
          widget.subject.name,
          'theory', // Assuming theory for now, can be expanded
          missedClasses,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final model = context.watch<TimetableModel>();
    final records = model.attendanceRecords
        .where((r) => r.subjectName == widget.subject.name)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subject.name),
        backgroundColor: widget.subject.color.withOpacity(0.2),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildChart(context, records),
            const SizedBox(height: 24),
            _buildWhatIfCalculator(theme),
            const SizedBox(height: 24),
            Text('Attendance Log', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            _buildAttendanceLog(records, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildWhatIfCalculator(ThemeData theme) {
    return Card(
      color: theme.colorScheme.surfaceVariant,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('\'What If\' Calculator', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _missedClassesController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'If I miss \'X\' more classes...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _calculateWhatIf,
                  child: const Text('Calculate'),
                ),
              ],
            ),
            if (_whatIfPercentage != null)
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Text(
                  'Your new attendance would be: ${_whatIfPercentage!.toStringAsFixed(2)}%',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: _whatIfPercentage! >= 75 ? AppTheme.secondary : AppTheme.error,
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceLog(List<AttendanceRecord> records, ThemeData theme) {
    if (records.isEmpty) {
      return const Center(child: Text('No attendance records yet.'));
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Icon(_getStatusIcon(record.status), color: _getStatusColor(record.status)),
            title: Text('${DateFormat.yMMMd().format(record.date)} - ${record.timeSlot}'),
            subtitle: Text('${record.classType} (${record.hours}h)'),
            trailing: Text(
              record.status.name,
              style: theme.textTheme.bodyMedium?.copyWith(color: _getStatusColor(record.status)),
            ),
          ),
        );
      },
    );
  }

  Widget _buildChart(BuildContext context, List<AttendanceRecord> records) {
    // This is a simplified trend chart. A more accurate one would need more complex logic.
    List<FlSpot> spots = [];
    if (records.isNotEmpty) {
      records.sort((a, b) => a.date.compareTo(b.date));
      double attended = 0;
      double total = 0;
      for (int i = 0; i < records.length; i++) {
        final record = records[i];
        if (record.status == AttendanceStatus.present) {
          attended++;
        }
        if (record.status == AttendanceStatus.present || record.status == AttendanceStatus.absent) {
          total++;
        }
        if (total > 0) {
          spots.add(FlSpot(i.toDouble(), (attended / total) * 100));
        }
      }
    }

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: spots.isNotEmpty ? spots : [const FlSpot(0, 0)],
              isCurved: true,
              color: widget.subject.color,
              barWidth: 3,
              belowBarData: BarAreaData(
                show: true,
                color: widget.subject.color.withOpacity(0.2),
              ),
            ),
          ],
          titlesData: const FlTitlesData(show: false),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
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
  
  Color _getStatusColor(AttendanceStatus status) {
     switch (status) {
      case AttendanceStatus.present:
        return AppTheme.secondary;
      case AttendanceStatus.absent:
        return AppTheme.error;
      case AttendanceStatus.holiday:
        return Colors.grey;
      case AttendanceStatus.massBunk:
        return Colors.orangeAccent;
      case AttendanceStatus.teacherAbsent:
        return AppTheme.primary;
    }
  }
}