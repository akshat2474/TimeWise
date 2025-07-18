// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import 'package:timewise_dtu/theme/app_theme.dart';
import 'timetable_grid_screen.dart';
import '../models/subject_model.dart';
import '../models/timetable_model.dart';

class SubjectSetupScreen extends StatefulWidget {
  final List<Subject>? existingSubjects;
  final bool isEditing;

  const SubjectSetupScreen({
    super.key,
    this.existingSubjects,
    this.isEditing = false,
  });

  @override
  State<SubjectSetupScreen> createState() => _SubjectSetupScreenState();
}

class _SubjectSetupScreenState extends State<SubjectSetupScreen> {
  final TextEditingController _subjectCountController = TextEditingController();
  List<Subject> _subjects = [];
  int _subjectCount = 0;
  bool _showSubjectInputs = false;

  // Predefined list of colors for automatic assignment
  final List<Color> _colorPalette = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
    Colors.amber,
    Colors.cyan,
    Colors.brown,
    Colors.lime,
  ];

  Color _getNextColor() {
    // Assign a color from the palette, looping if necessary
    return _colorPalette[_subjects.length % _colorPalette.length];
  }


  @override
  void initState() {
    super.initState();
    if (widget.isEditing && widget.existingSubjects != null) {
      _subjects = List.from(widget.existingSubjects!);
      _subjectCount = _subjects.length;
      _showSubjectInputs = true;
      _subjectCountController.text = _subjectCount.toString();
    }
  }

  @override
  void dispose() {
    _subjectCountController.dispose();
    super.dispose();
  }

  void _onSubjectCountSubmitted() {
    final count = int.tryParse(_subjectCountController.text);
    if (count != null && count > 0 && count <= 15) {
      setState(() {
        _subjectCount = count;
        _showSubjectInputs = true;
        if (!widget.isEditing) {
          _subjects.clear();
        } else {
          if (_subjects.length > count) {
            _subjects = _subjects.sublist(0, count);
          }
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid number between 1 and 15.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _resetSubjectCount() {
    setState(() {
      _showSubjectInputs = false;
    });
  }

  void _showAddSubjectDialog([int? index]) {
    final theme = Theme.of(context);
    final nameController = TextEditingController();
    CreditType creditType = CreditType.fourCredit;
    SubjectType subjectType = SubjectType.theory;
    bool hasPractical = false;
    // Assign a new color automatically if it's a new subject
    Color color = (index != null) ? _subjects[index].color : _getNextColor();

    if (index != null && index < _subjects.length) {
      final subject = _subjects[index];
      nameController.text = subject.name;
      creditType = subject.creditType;
      subjectType = subject.subjectType;
      hasPractical = subject.hasPractical;
      color = subject.color;
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            index != null ? 'Edit Subject' : 'Add Subject',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Subject Name',
                    labelStyle: TextStyle(color: Colors.grey[400]),
                    hintText: 'e.g., Mathematics, Physics',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    filled: true,
                    fillColor: Colors.grey[800],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => _pickColor(context, color, (newColor) => setDialogState(() => color = newColor)),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Text('Subject Color', style: theme.textTheme.bodyLarge),
                        const Spacer(),
                        Container(width: 24, height: 24, color: color),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Credit Type:',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setDialogState(() {
                            creditType = CreditType.fourCredit;
                            if (subjectType == SubjectType.elective) {
                              subjectType = SubjectType.theory;
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: creditType == CreditType.fourCredit
                                ? Colors.blue[600]
                                : Colors.grey[800],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: creditType == CreditType.fourCredit
                                  ? Colors.blue[400]!
                                  : Colors.grey[600]!,
                              width: 1,
                            ),
                          ),
                          child: const Text(
                            '4-Credit',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setDialogState(() {
                            creditType = CreditType.twoCredit;
                            hasPractical = false;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: creditType == CreditType.twoCredit
                                ? Colors.green[600]
                                : Colors.grey[800],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: creditType == CreditType.twoCredit
                                  ? Colors.green[400]!
                                  : Colors.grey[600]!,
                              width: 1,
                            ),
                          ),
                          child: const Text(
                            '2-Credit',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (creditType == CreditType.fourCredit) ...[
                  const Text(
                    'Subject Type:',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.science,
                          color: Colors.green[400],
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Has Practical Classes?',
                            style: TextStyle(
                              color: Colors.grey[300],
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Switch(
                          value: hasPractical,
                          onChanged: (value) {
                            setDialogState(() {
                              hasPractical = value;
                            });
                          },
                          activeColor: Colors.green[400],
                        ),
                      ],
                    ),
                  ),
                ],
                if (creditType == CreditType.twoCredit) ...[
                  const Text(
                    'Subject Type:',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setDialogState(() {
                              subjectType = SubjectType.elective;
                              hasPractical = false;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: subjectType == SubjectType.elective
                                  ? Colors.orange[600]
                                  : Colors.grey[800],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: subjectType == SubjectType.elective
                                    ? Colors.orange[400]!
                                    : Colors.grey[600]!,
                                width: 1,
                              ),
                            ),
                            child: const Text(
                              'Elective',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setDialogState(() {
                              subjectType = SubjectType.practical;
                              hasPractical = true;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: subjectType == SubjectType.practical
                                  ? Colors.purple[600]
                                  : Colors.grey[800],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: subjectType == SubjectType.practical
                                    ? Colors.purple[400]!
                                    : Colors.grey[600]!,
                                width: 1,
                              ),
                            ),
                            child: const Text(
                              'Practical',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[900]?.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.blue[600]!,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.blue[300],
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Total Hours:',
                            style: TextStyle(
                              color: Colors.blue[300],
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        Subject(
                          name: '',
                          creditType: creditType,
                          subjectType: subjectType,
                          hasPractical: hasPractical,
                        ).creditDescription,
                        style: TextStyle(
                          color: Colors.blue[100],
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey[400]),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isNotEmpty) {
                  setState(() {
                    final subject = Subject(
                      id: (index != null) ? _subjects[index].id : null,
                      name: nameController.text.trim(),
                      hasPractical: hasPractical,
                      creditType: creditType,
                      subjectType: subjectType,
                      color: color,
                    );

                    if (index != null) {
                      _subjects[index] = subject;
                    } else {
                      _subjects.add(subject);
                    }
                  });
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Subject name cannot be empty'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _pickColor(BuildContext context, Color initialColor, Function(Color) onColorChanged) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick a color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: initialColor,
            onColorChanged: onColorChanged,
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Got it'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(int index) {
    Theme.of(context);
    final subject = _subjects[index];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Delete Subject',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete "${subject.name}"?',
              style: TextStyle(color: Colors.grey[300]),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[900]?.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.orange[600]!,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber,
                    color: Colors.orange[300],
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This will also remove all timetable entries and attendance records for this subject.',
                      style: TextStyle(
                        color: Colors.orange[200],
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
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
          TextButton(
            onPressed: () {
              setState(() {
                _subjects.removeAt(index);
              });
              Navigator.pop(context);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _proceedToTimetable() {
    if (_subjects.length == _subjectCount) {
      final model = context.read<TimetableModel>();
      model.updateSubjects(_subjects);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const TimetableGridScreen(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please add all $_subjectCount subjects'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          widget.isEditing ? 'Edit Subjects' : 'Setup Subjects',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w300,
            letterSpacing: 1,
          ),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.onBackground),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.isEditing
                    ? 'Edit Your Subjects'
                    : 'Configure Your Subjects',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.isEditing
                    ? 'Modify your subjects and credit information. Existing timetable and attendance data will be preserved.'
                    : 'Set up your subjects with credit and practical information.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontSize: 16,
                  color: Colors.grey[400],
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(height: 40),
              if (!_showSubjectInputs)
                _buildSubjectCountInput()
              else
                Expanded(child: _buildSubjectList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubjectCountInput() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How many subjects do you have?',
          style: theme.textTheme.titleMedium?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _subjectCountController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(2),
                ],
                style: theme.textTheme.bodyLarge?.copyWith(fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Enter number of subjects (1-15)',
                  hintStyle: theme.textTheme.bodyMedium
                      ?.copyWith(color: Colors.grey[600], fontSize: 14),
                ),
                onSubmitted: (_) => _onSubjectCountSubmitted(),
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: _onSubjectCountSubmitted,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
              ),
              child: Text(
                'Confirm',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSubjectList() {
    final theme = Theme.of(context);
    final isUpdateEnabled = _subjects.length == _subjectCount;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Subjects (${_subjects.length}/$_subjectCount)',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: _resetSubjectCount,
              icon: const Icon(Icons.edit, size: 16),
              label: const Text('Edit Count'),
              style: TextButton.styleFrom(
                  foregroundColor: theme.textTheme.bodyMedium?.color),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: _subjects.isEmpty
              ? Center(
                  child: Text(
                    'Click "Add Subject" to begin.',
                    style: theme.textTheme.bodyLarge,
                  ),
                )
              : ListView.builder(
                  itemCount: _subjects.length,
                  itemBuilder: (context, index) {
                    final subject = _subjects[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: subject.color.withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    subject.name,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    subject.creditDescription,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: Colors.grey[400],
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.book,
                                        color: AppTheme.accentBlue,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Theory: ${subject.totalTheoryHours}h',
                                        style:
                                            theme.textTheme.bodySmall?.copyWith(
                                          color: Colors.grey[400],
                                          fontSize: 11,
                                        ),
                                      ),
                                      if (subject.hasPractical) ...[
                                        const SizedBox(width: 12),
                                        const Icon(
                                          Icons.science,
                                          color: AppTheme.secondary,
                                          size: 14,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Practical: ${subject.totalPracticalHours}h',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: Colors.grey[400],
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => _showAddSubjectDialog(index),
                              icon: Icon(
                                Icons.edit,
                                color: Colors.grey[400],
                                size: 20,
                              ),
                            ),
                            IconButton(
                              onPressed: () => _showDeleteConfirmation(index),
                              icon: Icon(
                                Icons.delete,
                                color: Colors.red[400],
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        const SizedBox(height: 16),
        if (_subjects.length < _subjectCount)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showAddSubjectDialog(),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Subject'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: Opacity(
            opacity: isUpdateEnabled ? 1.0 : 0.5,
            child: ElevatedButton(
              onPressed: isUpdateEnabled ? _proceedToTimetable : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: theme.colorScheme.secondary,
              ),
              child: Text(
                widget.isEditing ? 'Update Subjects' : 'Create Timetable',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}