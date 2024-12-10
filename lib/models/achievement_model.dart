class Achievement {
  final String title;
  final String description;
  final bool unlocked;
  final String icon; // Store asset name or use predefined icons.
  final int progress; // For progress tracking (0 to 100).

  Achievement({
    required this.title,
    required this.description,
    this.unlocked = false,
    this.icon = "assets/icons/achievement.png", // Default icon
    this.progress = 0,
  });
  Achievement copyWith({bool? unlocked, int? progress}) {
    return Achievement(
      title: title,
      description: description,
      unlocked: unlocked ?? this.unlocked,
      progress: progress ?? this.progress,
    );
  }
}

