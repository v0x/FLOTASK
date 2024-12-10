import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/achievement_provider.dart';

class AchievementPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final achievementProvider = Provider.of<AchievementProvider>(context);
    final achievements = achievementProvider.achievements;

    return Scaffold(
      appBar: AppBar(
        title: Text('Achievements'),
      ),
      body: ListView.builder(
        itemCount: achievements.length,
        itemBuilder: (context, index) {
          final achievement = achievements[index];
          return Card(
            margin: EdgeInsets.all(10),
            child: ListTile(
              leading: Icon(
                achievement.unlocked ? Icons.emoji_events : Icons.lock,
                size: 40,
                color: achievement.unlocked ? Colors.amber : Colors.grey,
              ),
              title: Text(
                achievement.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: achievement.unlocked ? Colors.black : Colors.grey,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(achievement.description),
                  if (achievement.progress < 100)
                    LinearProgressIndicator(
                      value: achievement.progress / 100,
                      backgroundColor: Colors.grey[200],
                      color: Colors.blue,
                    ),
                ],
              ),
              trailing: achievement.unlocked
                  ? Icon(Icons.check, color: Colors.green)
                  : null,
            ),
          );
        },
      ),
    );
  }
}
