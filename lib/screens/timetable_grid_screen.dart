import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'attendance_screen.dart';
import 'subject_setup_screen.dart';
import '../models/timetable_model.dart';
import '../models/subject_model.dart';

class TimetableGridScreen extends StatefulWidget {
  const TimetableGridScreen({Key? key}) : super(key: key);

  @override
  State<TimetableGridScreen> createState() => _TimetableGridScreenState();
}

class _TimetableGridScreenState extends State<TimetableGridScreen> {
  String _selectedDay = 'Monday';

  void _showClassDialog(String day, String timeSlot) {
    final model = context.read<TimetableModel>();
    if (model.isSlotBlocked(day, timeSlot)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This slot is blocked by a 2-hour class'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ClassSelectionDialog(
          subjects: model.subjects,
          currentClass: model.timetable[day]![timeSlot],
          timeSlot: timeSlot,
          timeSlots: model.timeSlots,
          onClassSelected: (classInfo) {
            model.updateClass(day, timeSlot, classInfo);
          },
          onClassRemoved: () {
            model.removeClass(day, timeSlot);
          },
        );
      },
    );
  }

  void _proceedToAttendance() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AttendanceScreen(),
      ),
    );
  }

  void _editSubjects() {
    final model = context.read<TimetableModel>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubjectSetupScreen(
          existingSubjects: model.subjects,
          isEditing: true,
        ),
      ),
    );
  }

  void _showTimetableOptions() {
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
              'Timetable Options',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            _buildOptionTile(
              icon: Icons.copy,
              title: 'Copy Day',
              subtitle: 'Copy $_selectedDay schedule to another day',
              onTap: () {
                Navigator.pop(context);
                _showCopyDayDialog();
              },
            ),
            _buildOptionTile(
              icon: Icons.clear_all,
              title: 'Clear Day',
              subtitle: 'Remove all classes from $_selectedDay',
              onTap: () {
                Navigator.pop(context);
                _clearDay();
              },
            ),
            _buildOptionTile(
              icon: Icons.import_export,
              title: 'Import/Export',
              subtitle: 'Share or backup your timetable',
              onTap: () {
                Navigator.pop(context);
                _showImportExportDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue[600],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.grey[400],
          fontSize: 12,
        ),
      ),
      onTap: onTap,
    );
  }

  void _showCopyDayDialog() {
    final model = context.read<TimetableModel>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Copy Day Schedule',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Copy $_selectedDay schedule to:',
              style: TextStyle(color: Colors.grey[300]),
            ),
            const SizedBox(height: 16),
            ...(model.days.where((day) => day != _selectedDay).map((day) =>
                ListTile(
                  title: Text(day, style: const TextStyle(color: Colors.white)),
                  onTap: () {
                    model.copyDaySchedule(_selectedDay, day);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Copied $_selectedDay schedule to $day'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                ))),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey[400]),
            ),
          ),
        ],
      ),
    );
  }

  void _clearDay() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Clear Day',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to clear all classes from $_selectedDay?',
          style: TextStyle(color: Colors.grey[300]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey[400]),
            ),
          ),
          TextButton(
            onPressed: () {
              final model = context.read<TimetableModel>();
              model.clearDaySchedule(_selectedDay);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Cleared $_selectedDay schedule'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: const Text(
              'Clear',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showImportExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Import/Export Timetable',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.upload, color: Colors.blue),
              title: const Text('Export Timetable',
                  style: TextStyle(color: Colors.white)),
              subtitle: Text('Save as JSON file',
                  style: TextStyle(color: Colors.grey[400])),
              onTap: () {
                Navigator.pop(context);
                _exportTimetable();
              },
            ),
            ListTile(
              leading: const Icon(Icons.download, color: Colors.green),
              title: const Text('Import Timetable',
                  style: TextStyle(color: Colors.white)),
              subtitle: Text('Load from JSON file',
                  style: TextStyle(color: Colors.grey[400])),
              onTap: () {
                Navigator.pop(context);
                _importTimetable();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey[400]),
            ),
          ),
        ],
      ),
    );
  }

  void _exportTimetable() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Timetable exported successfully (placeholder)'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _importTimetable() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Timetable imported successfully (placeholder)'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TimetableModel>(
      builder: (context, model, child) {
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            title: const Text(
              'Create Timetable',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w300,
                letterSpacing: 1,
              ),
            ),
            backgroundColor: Colors.black,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              IconButton(
                onPressed: _showTimetableOptions,
                icon: const Icon(Icons.more_vert),
                tooltip: 'Timetable Options',
              ),
              IconButton(
                onPressed: _editSubjects,
                icon: const Icon(Icons.edit_note),
                tooltip: 'Edit Subjects',
              ),
              Container(
                margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
                child: ElevatedButton(
                  onPressed: _proceedToAttendance,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
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
                    children: model.days.map((day) {
                      final isSelected = day == _selectedDay;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedDay = day;
                            });
                          },
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
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[900]?.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.grey[800]!,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue[300],
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Tap time slots to add classes for $_selectedDay',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[300],
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: model.timeSlots.length,
                    itemBuilder: (context, index) {
                      final timeSlot = model.timeSlots[index];
                      final classInfo =
                          model.timetable[_selectedDay]![timeSlot];
                      final isBlocked =
                          model.isSlotBlocked(_selectedDay, timeSlot);
                      final isBlockedSlot = classInfo?.isBlockedSlot == true;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: GestureDetector(
                          onTap: isBlockedSlot
                              ? null
                              : () => _showClassDialog(_selectedDay, timeSlot),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: _getCardGradient(
                                  classInfo, isBlocked, isBlockedSlot),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: _getBorderColor(
                                    classInfo, isBlocked, isBlockedSlot),
                                width: 1.5,
                              ),
                              boxShadow: classInfo != null && !isBlockedSlot
                                  ? [
                                      BoxShadow(
                                        color: (classInfo.isTheory
                                                ? Colors.blue
                                                : Colors.green)
                                            .withOpacity(0.2),
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 70,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        timeSlot.split('-')[0],
                                        style: TextStyle(
                                          color: isBlockedSlot
                                              ? Colors.grey[600]
                                              : Colors.grey[300],
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        timeSlot.split('-')[1],
                                        style: TextStyle(
                                          color: isBlockedSlot
                                              ? Colors.grey[700]
                                              : Colors.grey[500],
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Container(
                                  width: 2,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: isBlockedSlot
                                        ? Colors.grey[700]
                                        : Colors.grey[600],
                                    borderRadius: BorderRadius.circular(1),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: SizedBox(
                                    child: isBlockedSlot
                                        ? Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.block,
                                                color: Colors.grey[600],
                                                size: 18,
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  'Blocked by ${classInfo!.subject.name}',
                                                  style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontSize: 14,
                                                    fontStyle: FontStyle.italic,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          )
                                        : classInfo != null
                                            ? Row(
                                                children: [
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          classInfo
                                                              .subject.name,
                                                          style:
                                                              const TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                        const SizedBox(
                                                            height: 4),
                                                        Row(
                                                          children: [
                                                            Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                horizontal: 6,
                                                                vertical: 2,
                                                              ),
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: classInfo
                                                                        .isTheory
                                                                    ? Colors.blue[
                                                                        600]
                                                                    : Colors.green[
                                                                        600],
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                              ),
                                                              child: Text(
                                                                classInfo
                                                                        .isTheory
                                                                    ? 'Theory'
                                                                    : 'Practical',
                                                                style:
                                                                    const TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 9,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                width: 6),
                                                            Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                horizontal: 6,
                                                                vertical: 2,
                                                              ),
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Colors
                                                                    .grey[700],
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                              ),
                                                              child: Text(
                                                                '${classInfo.duration}h',
                                                                style:
                                                                    const TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 9,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.all(6),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white
                                                          .withOpacity(0.1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6),
                                                    ),
                                                    child: Icon(
                                                      Icons.edit_outlined,
                                                      color: Colors.white
                                                          .withOpacity(0.8),
                                                      size: 14,
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.all(6),
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey[700],
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6),
                                                    ),
                                                    child: Icon(
                                                      Icons.add,
                                                      color: Colors.grey[400],
                                                      size: 16,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    'Add Class',
                                                    style: TextStyle(
                                                      color: Colors.grey[400],
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  LinearGradient _getCardGradient(
      ClassInfo? classInfo, bool isBlocked, bool isBlockedSlot) {
    if (isBlockedSlot) {
      return LinearGradient(
        colors: [
          Colors.grey[900]!,
          Colors.grey[850]!,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (classInfo != null) {
      if (classInfo.isTheory) {
        return LinearGradient(
          colors: [
            Colors.blue[900]!,
            Colors.blue[800]!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      } else {
        return LinearGradient(
          colors: [
            Colors.green[900]!,
            Colors.green[800]!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      }
    } else {
      return LinearGradient(
        colors: [
          Colors.grey[900]!,
          Colors.grey[800]!,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
  }

  Color _getBorderColor(
      ClassInfo? classInfo, bool isBlocked, bool isBlockedSlot) {
    if (isBlockedSlot) {
      return Colors.grey[700]!;
    } else if (classInfo != null) {
      return classInfo.isTheory ? Colors.blue[600]! : Colors.green[600]!;
    } else {
      return Colors.grey[600]!;
    }
  }
}

class ClassSelectionDialog extends StatefulWidget {
  final List<Subject> subjects;
  final ClassInfo? currentClass;
  final String timeSlot;
  final List<String> timeSlots;
  final Function(ClassInfo) onClassSelected;
  final VoidCallback onClassRemoved;

  const ClassSelectionDialog({
    Key? key,
    required this.subjects,
    required this.currentClass,
    required this.timeSlot,
    required this.timeSlots,
    required this.onClassSelected,
    required this.onClassRemoved,
  }) : super(key: key);

  @override
  State<ClassSelectionDialog> createState() => _ClassSelectionDialogState();
}

class _ClassSelectionDialogState extends State<ClassSelectionDialog> {
  Subject? _selectedSubject;
  ClassType _selectedType = ClassType.theory;
  int _selectedDuration = 1;

  @override
  void initState() {
    super.initState();
    if (widget.currentClass != null && !widget.currentClass!.isBlockedSlot) {
      _selectedSubject = widget.currentClass!.subject;
      _selectedType = widget.currentClass!.type;
      _selectedDuration = widget.currentClass!.duration;
    }
  }

  bool _canSelect2Hours() {
    final currentIndex = widget.timeSlots.indexOf(widget.timeSlot);
    return currentIndex < widget.timeSlots.length - 1;
  }

  List<DropdownMenuItem<ClassType>> _getClassTypeItems() {
    List<DropdownMenuItem<ClassType>> items = [
      const DropdownMenuItem(
        value: ClassType.theory,
        child: Text('Theory'),
      ),
    ];
    if (_selectedSubject?.hasPractical == true) {
      items.add(
        const DropdownMenuItem(
          value: ClassType.practical,
          child: Text('Practical'),
        ),
      );
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue[600],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.schedule,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Configure Class',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time,
                    color: Colors.grey[400],
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Time: ${widget.timeSlot}',
                    style: TextStyle(
                      color: Colors.grey[300],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Subject:',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey[600]!,
                  width: 1,
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<Subject>(
                  value: _selectedSubject,
                  dropdownColor: Colors.grey[800],
                  style: const TextStyle(color: Colors.white),
                  hint: const Text(
                    'Select Subject',
                    style: TextStyle(color: Colors.grey),
                  ),
                  items: widget.subjects.map((subject) {
                    return DropdownMenuItem<Subject>(
                      value: subject,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(subject.name),
                          Text(
                            subject.creditDescription,
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedSubject = value;
                      if (value?.hasPractical != true &&
                          _selectedType == ClassType.practical) {
                        _selectedType = ClassType.theory;
                      }
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Class Type:',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey[600]!,
                  width: 1,
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<ClassType>(
                  value: _selectedType,
                  dropdownColor: Colors.grey[800],
                  style: const TextStyle(color: Colors.white),
                  items: _getClassTypeItems(),
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value!;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Duration:',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedDuration = 1;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: _selectedDuration == 1
                            ? Colors.white
                            : Colors.grey[800],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedDuration == 1
                              ? Colors.white
                              : Colors.grey[600]!,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        '1 Hour',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _selectedDuration == 1
                              ? Colors.black
                              : Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: _canSelect2Hours()
                        ? () {
                            setState(() {
                              _selectedDuration = 2;
                            });
                          }
                        : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: _canSelect2Hours()
                            ? (_selectedDuration == 2
                                ? Colors.white
                                : Colors.grey[800])
                            : Colors.grey[850],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _canSelect2Hours()
                              ? (_selectedDuration == 2
                                  ? Colors.white
                                  : Colors.grey[600]!)
                              : Colors.grey[700]!,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        '2 Hours',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _canSelect2Hours()
                              ? (_selectedDuration == 2
                                  ? Colors.black
                                  : Colors.white)
                              : Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (!_canSelect2Hours())
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '2-hour option not available for last time slot',
                  style: TextStyle(
                    color: Colors.orange[300],
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
      actions: [
        if (widget.currentClass != null && !widget.currentClass!.isBlockedSlot)
          TextButton.icon(
            onPressed: () {
              widget.onClassRemoved();
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
            label: const Text(
              'Remove',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
            ),
          ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(
            'Cancel',
            style: TextStyle(
              color: Colors.grey[400],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: _selectedSubject != null
              ? () {
                  widget.onClassSelected(ClassInfo(
                    subject: _selectedSubject!,
                    type: _selectedType,
                    duration: _selectedDuration,
                  ));
                  Navigator.of(context).pop();
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: const Text(
            'Save',
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
