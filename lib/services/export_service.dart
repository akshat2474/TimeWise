import 'dart:io';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:timewise_dtu/models/timetable_model.dart';

class ExportService {
  Future<void> exportAttendance(List<AttendanceRecord> records) async {
    final List<List<dynamic>> rows = [
      ['Date', 'Subject', 'Class Type', 'Status', 'Hours']
    ];

    final DateFormat formatter = DateFormat('dd-MM-yyyy');

    for (final record in records) {
      rows.add([
        formatter.format(record.date),
        record.subjectName,
        record.classType,
        record.status.name,
        record.hours,
      ]);
    }

    final String csv = const ListToCsvConverter().convert(rows);

    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/timewise_attendance.csv';
    final file = File(path);
    await file.writeAsString(csv);

    await Share.shareXFiles([XFile(path)], text: 'My TimeWise Attendance Report');
  }
}
