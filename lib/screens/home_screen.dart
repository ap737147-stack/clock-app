// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/alarm_provider.dart';
import '../utils/app_theme.dart';
import '../utils/app_routes.dart';
import '../widgets/alarm_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alarms = ref.watch(alarmProvider);
    final activeCount = ref.watch(activeAlarmCountProvider);
    final notifier = ref.read(alarmProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _Header(activeCount: activeCount),

            Expanded(
              child: alarms.isEmpty
                  ? _EmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                      itemCount: alarms.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) {
                        final alarm = alarms[i];
                        return AlarmCard(
                          alarm: alarm,
                          onToggle: () => notifier.toggleAlarm(alarm.id),
                          onDelete: () => notifier.deleteAlarm(alarm.id),
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRoutes.alarmActive,
                            arguments: alarm,
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),

      floatingActionButton: _AddAlarmFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class _Header extends StatelessWidget {
  final int activeCount;
  const _Header({required this.activeCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary,
            ),
            child: const Icon(Icons.alarm, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          const Text(
            'Voice Alarm',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          const Spacer(),
          if (activeCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$activeCount Alarm${activeCount == 1 ? '' : 's'} Active',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryLight,
            ),
            child: const Icon(
              Icons.alarm_off,
              color: AppColors.primary,
              size: 36,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No alarms yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap + to create your first voice alarm',
            style: TextStyle(fontSize: 14, color: AppColors.textGrey),
          ),
        ],
      ),
    );
  }
}

class _AddAlarmFab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.newAlarm),
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 32),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, color: Colors.white, size: 22),
            SizedBox(width: 8),
            Text(
              'New Voice Alarm',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
