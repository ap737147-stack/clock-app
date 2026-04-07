// lib/widgets/alarm_card.dart

import 'package:flutter/material.dart';
import '../models/alarm_model.dart';
import '../utils/app_theme.dart';

class AlarmCard extends StatelessWidget {
  final AlarmModel alarm;
  final VoidCallback onToggle;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const AlarmCard({
    super.key,
    required this.alarm,
    required this.onToggle,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(alarm.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      onDismissed: (_) => onDelete(),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: alarm.isActive ? AppColors.cardBg : AppColors.background,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: alarm.isActive
                  ? Colors.transparent
                  : AppColors.disabled.withOpacity(0.4),
            ),
            boxShadow: alarm.isActive
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Row(
            children: [
              // Alarm / voice badge
              _PlayButton(
                isActive: alarm.isActive,
                hasVoice: alarm.voiceLabel != null,
              ),
              const SizedBox(width: 16),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          alarm.voiceLabel != null ? Icons.mic : Icons.schedule,
                          size: 18,
                          color: alarm.isActive
                              ? AppColors.primary
                              : AppColors.disabled,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            alarm.title,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: alarm.isActive
                                  ? AppColors.textDark
                                  : AppColors.textGrey,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${alarm.repeatLabel} • ${alarm.timeString}',
                      style: TextStyle(
                        fontSize: 13,
                        color: alarm.isActive
                            ? AppColors.textGrey
                            : AppColors.disabled,
                      ),
                    ),
                    if (alarm.voiceLabel != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.record_voice_over,
                            size: 13,
                            color: alarm.isActive
                                ? AppColors.primary
                                : AppColors.disabled,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '"${alarm.voiceLabel}"',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                                color: alarm.isActive
                                    ? AppColors.primary
                                    : AppColors.disabled,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              // Toggle
              _AlarmToggle(isActive: alarm.isActive, onToggle: onToggle),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlayButton extends StatelessWidget {
  final bool isActive;
  final bool hasVoice;

  const _PlayButton({required this.isActive, required this.hasVoice});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive
            ? AppColors.primaryLight
            : AppColors.disabled.withOpacity(0.3),
      ),
      child: Icon(
        hasVoice ? Icons.mic : Icons.alarm_on,
        color: isActive ? AppColors.primary : AppColors.textGrey,
        size: 26,
      ),
    );
  }
}

class _AlarmToggle extends StatelessWidget {
  final bool isActive;
  final VoidCallback onToggle;

  const _AlarmToggle({required this.isActive, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 52,
        height: 30,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: isActive ? AppColors.primary : AppColors.disabled,
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          alignment: isActive ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
