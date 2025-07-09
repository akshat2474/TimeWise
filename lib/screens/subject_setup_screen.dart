import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'timetable_grid_screen.dart';
import '../models/subject_model.dart';
import '../models/timetable_model.dart';

class SubjectSetupScreen extends StatefulWidget {
  final List<Subject>? existingSubjects;
  final bool isEditing;

  const SubjectSetupScreen({
    Key? key,
    this.existingSubjects,
    this.isEditing = false,
  }) : super(key: key);

  @override
  State<SubjectSetupScreen> createState() => _SubjectSetupScreenState();
}

class _SubjectSetupScreenState extends State<SubjectSetupScreen> {
  final TextEditingController _subjectCountController = TextEditingController();
  List<Subject> _subjects = [];
  int _subjectCount = 0;
  bool _showSubjectInputs = false;

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
        }
        if (widget.isEditing && _subjects.length > count) {
          _subjects = _subjects.sublist(0, count);
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid number between 1 and 15'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showAddSubjectDialog([int? index]) {
    final nameController = TextEditingController();
    CreditType creditType = CreditType.fourCredit;
    SubjectType subjectType = SubjectType.theory;
    bool hasPractical = false;

    if (index != null && index < _subjects.length) {
      nameController.text = _subjects[index].name;
      creditType = _subjects[index].creditType;
      subjectType = _subjects[index].subjectType;
      hasPractical = _subjects[index].hasPractical;
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
                    final subject = index != null
                        ? _subjects[index]
                            .copyWith(name: nameController.text.trim())
                        : Subject(
                            name: nameController.text.trim(),
                            hasPractical: hasPractical,
                            creditType: creditType,
                            subjectType: subjectType,
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

  void _showDeleteConfirmation(int index) {
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
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          widget.isEditing ? 'Edit Subjects' : 'Setup Subjects',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w300,
            letterSpacing: 1,
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.isEditing
                      ? 'Edit Your Subjects'
                      : 'Configure Your Subjects',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.isEditing
                      ? 'Modify your subjects and credit information. Existing timetable and attendance data will be preserved.'
                      : 'Set up your subjects with credit and practical information',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[400],
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(height: 40),
                if (!_showSubjectInputs) ...[
                  const Text(
                    'How many subjects do you have?',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
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
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Enter number of subjects (1-15)',
                            hintStyle: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                            filled: true,
                            fillColor: Colors.grey[900],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          onSubmitted: (_) => _onSubjectCountSubmitted(),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _onSubjectCountSubmitted,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Next',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if (_showSubjectInputs) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Subjects (${_subjects.length}/$_subjectCount)',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      if (_subjects.length < _subjectCount)
                        ElevatedButton.icon(
                          onPressed: () => _showAddSubjectDialog(),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Add'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  LimitedBox(
                    maxHeight: MediaQuery.of(context).size.height * 0.5,
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      itemCount: _subjects.length,
                      itemBuilder: (context, index) {
                        final subject = _subjects[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[900],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey[700]!,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        subject.name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        subject.creditDescription,
                                        style: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.book,
                                            color: Colors.blue[400],
                                            size: 14,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Theory: ${subject.totalTheoryHours}h',
                                            style: TextStyle(
                                              color: Colors.grey[400],
                                              fontSize: 11,
                                            ),
                                          ),
                                          if (subject.hasPractical) ...[
                                            const SizedBox(width: 12),
                                            Icon(
                                              Icons.science,
                                              color: Colors.green[400],
                                              size: 14,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Practical: ${subject.totalPracticalHours}h',
                                              style: TextStyle(
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
                                  onPressed: () =>
                                      _showDeleteConfirmation(index),
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
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _subjects.length == _subjectCount
                          ? _proceedToTimetable
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        widget.isEditing
                            ? 'Update Subjects'
                            : 'Create Timetable',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
