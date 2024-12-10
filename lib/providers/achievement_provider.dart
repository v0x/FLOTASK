import 'package:flutter/material.dart';
import '../models/achievement_model.dart';

class AchievementProvider with ChangeNotifier {
  List<Achievement> _achievements = [
    Achievement(
      title: "First Task Completed",
      description: "Complete your first task.",
      progress: 100,
    ),
    Achievement(
      title: "Daily Streak: 5 Days",
      description: "Use the app 5 days in a row.",
      progress: 80,
    ),
    Achievement(
      title: "10 Tasks Completed",
      description: "Complete 10 tasks.",
      progress: 50,
    ),
  ];

  List<Achievement> get achievements => _achievements;

  void unlockAchievement(String title) {
    final index = _achievements.indexWhere((a) => a.title == title);
    if (index != -1 && !_achievements[index].unlocked) {
      _achievements[index] = _achievements[index].copyWith(unlocked: true);
      notifyListeners();
    }
  }

  void updateProgress(String title, int progress) {
    final index = _achievements.indexWhere((a) => a.title == title);
    if (index != -1 && _achievements[index].progress < 100) {
      final newProgress = (progress >= 100) ? 100 : progress;
      _achievements[index] = _achievements[index].copyWith(
        progress: newProgress,
        unlocked: newProgress >= 100,
      );
      notifyListeners();
    }
  }
}
