import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timewise_dtu/theme/app_theme.dart';
import 'attendance_screen.dart';
import 'subject_setup_screen.dart';
import '../models/timetable_model.dart';
import '../models/subject_model.dart';

class TimetableGridScreen extends StatefulWidget {
  const TimetableGridScreen({super.key});

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
          content: Text('This slot is blocked by a 2-hour class.'),
          backgroundColor: Colors.orangeAccent,
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
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Timetable Options',
              style: theme.textTheme.titleLarge?.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 24),
            _buildOptionTile(
              icon: Icons.copy_all_outlined,
              title: 'Copy Day',
              subtitle: 'Copy $_selectedDay\'s schedule to another day',
              onTap: () {
                Navigator.pop(context);
                _showCopyDayDialog();
              },
            ),
            const SizedBox(height: 12),
            _buildOptionTile(
              icon: Icons.delete_sweep_outlined,
              title: 'Clear Day',
              subtitle: 'Remove all classes from $_selectedDay',
              onTap: () {
                Navigator.pop(context);
                _clearDay();
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
    final theme = Theme.of(context);
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: theme.colorScheme.primary, size: 22),
      ),
      title: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  void _showCopyDayDialog() {
    final model = context.read<TimetableModel>();
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        title: Text('Copy Day Schedule', style: theme.textTheme.titleLarge),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Copy $_selectedDay\'s schedule to:',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            ...model.days
                .where((day) => day != _selectedDay)
                .map((day) => ListTile(
                      title: Text(day, style: theme.textTheme.bodyLarge),
                      onTap: () {
                        model.copyDaySchedule(_selectedDay, day);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('Copied $_selectedDay schedule to $day.'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                    )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _clearDay() {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        title: Text('Clear Day', style: theme.textTheme.titleLarge),
        content: Text(
          'Are you sure you want to clear all classes from $_selectedDay?',
          style: theme.textTheme.bodyLarge,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final model = context.read<TimetableModel>();
              model.clearDaySchedule(_selectedDay);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cleared schedule.'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: Text('Clear', style: TextStyle(color: theme.colorScheme.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer<TimetableModel>(
      builder: (context, model, child) {
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text(
              'Create Timetable',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w300,
                letterSpacing: 1,
              ),
            ),
            backgroundColor: theme.scaffoldBackgroundColor,
            elevation: 0,
            iconTheme: IconThemeData(color: theme.colorScheme.onBackground),
            actions: [
              IconButton(
                onPressed: _showTimetableOptions,
                icon: const Icon(Icons.more_vert),
                tooltip: 'Timetable Options',
              ),
              IconButton(
                onPressed: _editSubjects,
                icon: const Icon(Icons.edit_note_outlined),
                tooltip: 'Edit Subjects',
              ),
              Container(
                margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
                child: ElevatedButton(
                  onPressed: _proceedToAttendance,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
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
                    color: theme.colorScheme.surface,
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
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              day.substring(0, 3),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isSelected
                                    ? theme.colorScheme.onPrimary
                                    : theme.textTheme.bodyMedium?.color,
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
                    color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.colorScheme.surfaceVariant,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: theme.colorScheme.secondary,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Tap time slots to add classes for $_selectedDay.',
                          style: theme.textTheme.bodyMedium,
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
                      final classInfo = model.timetable[_selectedDay]![timeSlot];
                      final isBlocked = model.isSlotBlocked(_selectedDay, timeSlot);
                      final isBlockedSlot = classInfo?.isBlockedSlot == true;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: GestureDetector(
                          onTap: isBlockedSlot
                              ? null
                              : () => _showClassDialog(_selectedDay, timeSlot),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isBlockedSlot
                                  ? theme.colorScheme.surface.withOpacity(0.5)
                                  : theme.colorScheme.surfaceVariant,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: _getBorderColor(classInfo, isBlocked, isBlockedSlot),
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 70,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        timeSlot.split('-')[0],
                                        style: theme.textTheme.bodyLarge?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        timeSlot.split('-')[1],
                                        style: theme.textTheme.bodySmall,
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
                                        ? theme.dividerColor.withOpacity(0.5)
                                        : theme.dividerColor,
                                    borderRadius: BorderRadius.circular(1),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildClassInfoContent(classInfo, isBlockedSlot),
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

  Widget _buildClassInfoContent(ClassInfo? classInfo, bool isBlockedSlot) {
    final theme = Theme.of(context);
    final practicalColor = Colors.teal[300]!;

    if (isBlockedSlot) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.block, color: theme.disabledColor, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Blocked by ${classInfo!.subject.name}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.disabledColor,
                fontStyle: FontStyle.italic,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    } else if (classInfo != null) {
      return Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  classInfo.subject.name,
                  style: theme.textTheme.titleMedium,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildTag(
                      classInfo.isTheory ? 'Theory' : 'Practical',
                      classInfo.isTheory ? AppTheme.accentBlue : practicalColor,
                    ),
                    const SizedBox(width: 6),
                    _buildTag(
                        '${classInfo.duration}h', theme.colorScheme.surface),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.edit_outlined,
              color: theme.colorScheme.onSurface.withOpacity(0.8),
              size: 16,
            ),
          ),
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.add, color: theme.textTheme.bodyMedium?.color, size: 16),
          ),
          const SizedBox(width: 8),
          Text(
            'Add Class',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  Color _getBorderColor(ClassInfo? classInfo, bool isBlocked, bool isBlockedSlot) {
    final theme = Theme.of(context);
    final practicalColor = Colors.teal[300]!;

    if (isBlockedSlot) {
      return theme.dividerColor.withOpacity(0.5);
    } else if (classInfo != null) {
      return classInfo.isTheory ? AppTheme.accentBlue : practicalColor;
    } else {
      return theme.colorScheme.surfaceVariant;
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
    super.key,
    required this.subjects,
    this.currentClass,
    required this.timeSlot,
    required this.timeSlots,
    required this.onClassSelected,
    required this.onClassRemoved,
  });

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
      _selectedSubject = widget.subjects.firstWhere((s) => s.id == widget.currentClass!.subject.id);
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
    final theme = Theme.of(context);
    return AlertDialog(
      backgroundColor: theme.colorScheme.surface.withOpacity(0.95),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.schedule,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Configure Class',
            style: theme.textTheme.titleLarge?.copyWith(fontSize: 18),
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
                color: theme.colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time,
                    color: theme.textTheme.bodyMedium?.color,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Time: ${widget.timeSlot}',
                    style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Subject:',
              style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.dividerColor,
                  width: 1,
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<Subject>(
                  value: _selectedSubject,
                  isExpanded: true,
                  dropdownColor: theme.colorScheme.surfaceVariant,
                  style: theme.textTheme.bodyLarge,
                  hint: Text(
                    'Select Subject',
                    style: theme.textTheme.bodyLarge?.copyWith(color: theme.hintColor),
                  ),
                  items: widget.subjects.map((subject) {
                    return DropdownMenuItem<Subject>(
                      value: subject,
                      child: Text(subject.name, overflow: TextOverflow.ellipsis),
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
            Text(
              'Class Type:',
              style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.dividerColor,
                  width: 1,
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<ClassType>(
                  value: _selectedType,
                  dropdownColor: theme.colorScheme.surfaceVariant,
                  style: theme.textTheme.bodyLarge,
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
            Text(
              'Duration:',
              style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600, fontSize: 14),
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
                        color: _selectedDuration == 1 ? theme.colorScheme.primary : theme.colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedDuration == 1 ? theme.colorScheme.primary : theme.dividerColor,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        '1 Hour',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
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
                            ? (_selectedDuration == 2 ? theme.colorScheme.primary : theme.colorScheme.surfaceVariant)
                            : theme.disabledColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _canSelect2Hours()
                              ? (_selectedDuration == 2 ? theme.colorScheme.primary : theme.dividerColor)
                              : theme.disabledColor,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        '2 Hours',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: !_canSelect2Hours()
                              ? theme.textTheme.bodyLarge?.color?.withOpacity(0.5)
                              : theme.textTheme.bodyLarge?.color,
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
                  '2-hour option not available for last time slot.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.orange[300],
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
          child: const Text('Cancel'),
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
          child: const Text('Save'),
        ),
      ],
    );
  }
}