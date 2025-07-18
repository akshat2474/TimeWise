import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timewise_dtu/models/achievement_model.dart';
import 'package:timewise_dtu/models/timetable_model.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final model = context.watch<TimetableModel>();
    final unlockedIds = model.unlockedAchievementIds;

    final achievements = Achievements.allAchievements.map((a) {
      a.isUnlocked = unlockedIds.contains(a.id);
      return a;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: achievements.length,
        itemBuilder: (context, index) {
          final achievement = achievements[index];
          return Card(
            color: achievement.isUnlocked
                ? theme.colorScheme.surface
                : theme.colorScheme.surface.withOpacity(0.5),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(
                    achievement.icon,
                    size: 40,
                    color: achievement.isUnlocked
                        ? theme.colorScheme.primary
                        : Colors.grey[600],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          achievement.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: achievement.isUnlocked
                                ? Colors.white
                                : Colors.grey[400],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          achievement.description,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: achievement.isUnlocked
                                ? Colors.grey[400]
                                : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
