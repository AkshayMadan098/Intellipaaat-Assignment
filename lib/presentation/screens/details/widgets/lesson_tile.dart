import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../domain/entities/lesson.dart';

class LessonTile extends StatelessWidget {
  final Lesson lesson;
  final int index;
  final VoidCallback onToggle;

  const LessonTile({
    super.key,
    required this.lesson,
    required this.index,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = lesson.isCompleted;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCompleted
              ? AppTheme.successColor.withValues(alpha: 0.25)
              : AppTheme.borderColor,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Lesson index badge
                Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? AppTheme.successLight
                        : const Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$index',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isCompleted
                          ? AppTheme.successColor
                          : AppTheme.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Lesson Title
                Expanded(
                  child: Text(
                    lesson.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isCompleted
                          ? AppTheme.textPrimary
                          : AppTheme.textPrimary.withValues(alpha: 0.85),
                      decoration: isCompleted
                          ? TextDecoration.none
                          : TextDecoration.none,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Status Badge (Completed vs Pending)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? AppTheme.successLight
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isCompleted
                          ? AppTheme.successColor.withValues(alpha: 0.3)
                          : const Color(0xFFCBD5E1),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isCompleted
                            ? Icons.check_circle_rounded
                            : Icons.radio_button_unchecked_rounded,
                        size: 15,
                        color: isCompleted
                            ? AppTheme.successColor
                            : AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        isCompleted ? 'Completed' : 'Pending',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isCompleted
                              ? AppTheme.successColor
                              : AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
