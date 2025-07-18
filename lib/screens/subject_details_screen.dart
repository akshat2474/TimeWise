import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:timewise_dtu/models/subject_model.dart';
import 'package:timewise_dtu/models/timetable_model.dart';
import 'package:timewise_dtu/theme/app_theme.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class SubjectDetailsScreen extends StatefulWidget {
  final Subject subject;

  const SubjectDetailsScreen({super.key, required this.subject});

  @override
  State<SubjectDetailsScreen> createState() => _SubjectDetailsScreenState();
}

class _SubjectDetailsScreenState extends State<SubjectDetailsScreen> {
  final TextEditingController _missedClassesController =
      TextEditingController();
  double? _whatIfPercentage;
  String _whatIfType = 'theory';

  @override
  void initState() {
    super.initState();
    if (!widget.subject.hasPractical) {
      _whatIfType = 'theory';
    }
  }

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
          _whatIfType,
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
            Text('Attendance Trend', style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            _buildChart(context, records),
            const SizedBox(height: 24),
            _buildWhatIfCalculator(theme, model),
            const SizedBox(height: 24),
            Text('Attendance Log', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            _buildAttendanceLog(records, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildWhatIfCalculator(ThemeData theme, TimetableModel model) {
    final summary = model.getAttendanceDataForSubject(widget.subject.name)[_whatIfType]!;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('\'What If\' Calculator', style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),
            if (widget.subject.hasPractical) ...[
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<String>(
                  style: SegmentedButton.styleFrom(
                    selectedBackgroundColor:
                        theme.colorScheme.primary.withOpacity(0.3),
                    selectedForegroundColor: theme.colorScheme.primary,
                  ),
                  segments: const [
                    ButtonSegment(
                        value: 'theory',
                        label: Text('Theory'),
                        icon: Icon(Icons.book_outlined)),
                    ButtonSegment(
                        value: 'practical',
                        label: Text('Practical'),
                        icon: Icon(Icons.science_outlined)),
                  ],
                  selected: {_whatIfType},
                  onSelectionChanged: (newSelection) {
                    setState(() {
                      _whatIfType = newSelection.first;
                      _whatIfPercentage = null;
                      _missedClassesController.clear();
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _missedClassesController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'If I miss \'X\' more classes...',
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
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
                padding: const EdgeInsets.only(top: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildWhatIfGauge("Current", summary.percentage, theme),
                    const Icon(Icons.arrow_forward_rounded, size: 24),
                    _buildWhatIfGauge("Projected", _whatIfPercentage!, theme),
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }
  
  Widget _buildWhatIfGauge(String title, double percentage, ThemeData theme) {
    return Column(
      children: [
        Text(title, style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        CircularPercentIndicator(
          radius: 45.0,
          lineWidth: 7.0,
          percent: (percentage / 100).clamp(0.0, 1.0),
          center: Text(
            '${percentage.toStringAsFixed(1)}%',
            style: theme.textTheme.titleLarge?.copyWith(
              color: _getPercentageColor(percentage),
              fontWeight: FontWeight.bold,
            ),
          ),
          circularStrokeCap: CircularStrokeCap.round,
          progressColor: _getPercentageColor(percentage),
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
        ),
      ],
    );
  }

  Color _getPercentageColor(double percentage) {
    if (percentage >= 75) return AppTheme.secondary;
    if (percentage >= 60) return Colors.orangeAccent;
    return AppTheme.error;
  }

  Widget _buildAttendanceLog(List<AttendanceRecord> records, ThemeData theme) {
    if (records.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Center(child: Text('No attendance records yet.')),
        ),
      );
    }
    records.sort((a, b) => b.date.compareTo(a.date));
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Icon(_getStatusIcon(record.status),
                color: _getStatusColor(record.status)),
            title: Text(
                '${DateFormat.yMMMd().format(record.date)} - ${record.timeSlot}'),
            subtitle: Text(
                '${record.classType} (${record.hours.toStringAsFixed(0)}h)'),
            trailing: Text(
              _getStatusText(record.status),
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: _getStatusColor(record.status)),
            ),
          ),
        );
      },
    );
  }

  List<FlSpot> _generateSpotsForType(List<AttendanceRecord> allRecords) {
    if (allRecords.isEmpty) return [];

    allRecords.sort((a, b) => a.date.compareTo(b.date));

    List<FlSpot> spots = [];
    double attendedHours = 0;
    double heldHours = 0;
    int dataPointIndex = 0;

    for (final record in allRecords) {
      bool changed = false;
      if (record.status == AttendanceStatus.present ||
          record.status == AttendanceStatus.teacherAbsent) {
        attendedHours += record.hours;
        heldHours += record.hours;
        changed = true;
      } else if (record.status == AttendanceStatus.absent ||
          record.status == AttendanceStatus.massBunk) {
        heldHours += record.hours;
        changed = true;
      }

      if (changed && heldHours > 0) {
        final percentage = (attendedHours / heldHours) * 100;
        spots.add(FlSpot(dataPointIndex.toDouble(), percentage));
        dataPointIndex++;
      }
    }

    if (spots.isEmpty) {
      return [const FlSpot(0, 100)];
    }

    return spots;
  }

  Widget _buildChart(BuildContext context, List<AttendanceRecord> records) {
    final theoryRecords =
        records.where((r) => r.classType == 'theory').toList();
    final practicalRecords =
        records.where((r) => r.classType == 'practical').toList();

    final theorySpots = _generateSpotsForType(theoryRecords);
    final practicalSpots = _generateSpotsForType(practicalRecords);

    bool hasTheoryData = theorySpots.length > 1;
    bool hasPracticalData =
        widget.subject.hasPractical && practicalSpots.length > 1;

    if (!hasTheoryData && !hasPracticalData) {
      return const SizedBox(
          height: 200,
          child: Center(child: Text("Not enough data for a trend graph.")));
    }

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              minY: 0,
              maxY: 100,
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  tooltipBgColor: Colors.black.withOpacity(0.8),
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      return LineTooltipItem(
                        '${spot.y.toStringAsFixed(1)}%',
                        TextStyle(
                          color: spot.bar.gradient?.colors.first ??
                              spot.bar.color ??
                              Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
              extraLinesData: ExtraLinesData(
                horizontalLines: [
                  HorizontalLine(
                    y: 75,
                    color: AppTheme.error.withOpacity(0.8),
                    strokeWidth: 2,
                    dashArray: [5, 5],
                    label: HorizontalLineLabel(
                      show: true,
                      labelResolver: (_) => "75%",
                      alignment: Alignment.topRight,
                      style: TextStyle(
                          color: AppTheme.error.withOpacity(0.8),
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              lineBarsData: [
                if (hasTheoryData)
                  _getLineChartBarData(
                      theorySpots, widget.subject.color, 'Theory'),
                if (hasPracticalData)
                  _getLineChartBarData(practicalSpots,
                      AppTheme.secondary, 'Practical'),
              ],
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    interval: 25,
                    getTitlesWidget: (value, meta) {
                      if (value == meta.max) {
                        return Container();
                      }
                      return Text('${value.toInt()}',
                          style: const TextStyle(fontSize: 10));
                    },
                  ),
                ),
                bottomTitles: const AxisTitles(),
                topTitles: const AxisTitles(),
                rightTitles: const AxisTitles(),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) =>
                    const FlLine(color: Colors.white10, strokeWidth: 1),
              ),
              borderData: FlBorderData(show: false),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (hasTheoryData)
              _buildLegendItem("Theory", widget.subject.color),
            if (hasTheoryData && hasPracticalData) const SizedBox(width: 16),
            if (hasPracticalData)
              _buildLegendItem(
                  "Practical", AppTheme.secondary),
          ],
        )
      ],
    );
  }

  Widget _buildLegendItem(String title, Color color) {
    return Row(
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 8),
        Text(title),
      ],
    );
  }

  LineChartBarData _getLineChartBarData(
      List<FlSpot> spots, Color color, String type) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      gradient: LinearGradient(
        colors: [color.withOpacity(0.5), color],
      ),
      barWidth: 4,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.3),
            color.withOpacity(0.0),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
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

  IconData _getStatusIcon(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return Icons.check_circle_outline;
      case AttendanceStatus.absent:
        return Icons.cancel_outlined;
      case AttendanceStatus.holiday:
        return Icons.beach_access_outlined;
      case AttendanceStatus.massBunk:
        return Icons.group_off_outlined;
      case AttendanceStatus.teacherAbsent:
        return Icons.person_off_outlined;
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
