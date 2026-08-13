import 'package:flutter/material.dart';

class CourseLevelBadge extends StatelessWidget {
  final String level;

  const CourseLevelBadge({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    final label = switch (level.toUpperCase()) {
      'BEGINNER' || 'EASY' => 'مبتدئ',
      'MEDIUM' => 'متوسط',
      'HARD' || 'ADVANCED' => 'متقدم',
      _ => level,
    };

    final color = switch (level.toUpperCase()) {
      'BEGINNER' || 'EASY' => const Color(0xff2E7D53),
      'HARD' || 'ADVANCED' => const Color(0xffD9534F),
      _ => const Color(0xffB4780F),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: color),
      ),
    );
  }
}