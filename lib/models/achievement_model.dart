import 'package:flutter/material.dart';

class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  bool isUnlocked;
  final bool isReAchievable;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.isUnlocked = false,
    this.isReAchievable = false,
  });
}

class Achievements {
  static final List<Achievement> allAchievements = [
    Achievement(
      id: 'perfect_week',
      title: 'Perfect Week',
      description: 'Achieve 100% attendance for a full week (Mon-Fri).',
      icon: Icons.star_rounded,
    ),
    Achievement(
      id: 'scholar_1',
      title: 'Scholar',
      description: 'Maintain over 90% attendance in any subject.',
      icon: Icons.school_rounded,
    ),
    Achievement(
      id: 'comeback_kid_1',
      title: 'Comeback Kid',
      description: 'Improve a subject\'s attendance from below 75% to above.',
      icon: Icons.trending_up_rounded,
      isReAchievable: true,
    ),
     Achievement(
      id: 'dedicated_student',
      title: 'Dedicated Student',
      description: 'Maintain an overall attendance of over 85%.',
      icon: Icons.auto_stories_rounded,
    ),
    Achievement(
      id: 'perfect_month',
      title: 'Perfect Month',
      description: 'Achieve 100% attendance for an entire month.',
      icon: Icons.calendar_month_rounded,
    ),
  ];
}
