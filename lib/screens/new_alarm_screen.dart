// lib/screens/new_alarm_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:uuid/uuid.dart';
import '../models/alarm_model.dart';
import '../providers/alarm_provider.dart';
import '../utils/app_theme.dart';
import '../utils/app_routes.dart';
import '../widgets/drum_roll_time_picker.dart';

final _titleProvider = StateProvider<String>((ref) => '');
final _hourProvider = StateProvider<int>((ref) => 8);
final _minuteProvider = StateProvider<int>((ref) => 30);
final _isPmProvider = StateProvider<bool>((ref) => false);
final _repeatProvider = StateProvider<RepeatType>((ref) => RepeatType.once);
final _selectedDateProvider = StateProvider<DateTime?>((ref) => null);

class NewAlarmScreen extends ConsumerWidget {
  const NewAlarmScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = ref.watch(_titleProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('New Voice Alarm'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionLabel(text: 'ALARM TITLE'),
            const SizedBox(height: 10),
            _TitleField(ref: ref),
            const SizedBox(height: 28),

            _SectionLabel(text: 'TIME SELECTION'),
            const SizedBox(height: 10),
            DrumRollTimePicker(
              initialHour: ref.read(_hourProvider),
              initialMinute: ref.read(_minuteProvider),
              initialIsPm: ref.read(_isPmProvider),
              onChanged: (record) {
                final (h, m, pm) = record;
                ref.read(_hourProvider.notifier).state = h;
                ref.read(_minuteProvider.notifier).state = m;
                ref.read(_isPmProvider.notifier).state = pm;
              },
            ),
            const SizedBox(height: 28),

            _SectionLabel(text: 'REPEAT'),
            const SizedBox(height: 10),
            _RepeatSelector(ref: ref),
            const SizedBox(height: 28),

            _SectionLabel(text: 'REPEAT DATE'),
            const SizedBox(height: 10),
            _CalendarPicker(ref: ref),
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.music_note, size: 20),
                label: const Text(
                  'Choose Alarm Sound',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                onPressed: title.trim().isEmpty
                    ? null
                    : () => _showSoundOptions(context, ref),
              ),
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () {
                  final alarm = _buildDraft(ref);
                  ref.read(alarmProvider.notifier).addAlarm(alarm);
                  Navigator.popUntil(context, (r) => r.isFirst);
                },
                icon: const Icon(Icons.save_alt, color: AppColors.textGrey),
                label: const Text(
                  'Save Without Voice',
                  style: TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  AlarmModel _buildDraft(WidgetRef ref) {
    return AlarmModel(
      id: const Uuid().v4(),
      title: ref.read(_titleProvider),
      hour: ref.read(_hourProvider),
      minute: ref.read(_minuteProvider),
      isPm: ref.read(_isPmProvider),
      repeatType: ref.read(_repeatProvider),
      specificDate: ref.read(_selectedDateProvider),
      isActive: true,
    );
  }

  void _showSoundOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Choose Alarm Sound',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 24),
            _SoundOptionButton(
              icon: Icons.mic,
              title: 'Record Voice Message',
              subtitle: 'Create a custom voice recording',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  AppRoutes.recordVoice,
                  arguments: _buildDraft(ref),
                );
              },
            ),
            const SizedBox(height: 16),
            _SoundOptionButton(
              icon: Icons.folder,
              title: 'Select from Storage',
              subtitle: 'Choose an audio file from your device',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  AppRoutes.selectFromStorage,
                  arguments: _buildDraft(ref),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.2,
      color: AppColors.textGrey,
    ),
  );
}

class _TitleField extends StatelessWidget {
  final WidgetRef ref;
  const _TitleField({required this.ref});

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'e.g., Morning Medication',
        hintStyle: const TextStyle(color: AppColors.textGrey),
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
      ),
      onChanged: (v) => ref.read(_titleProvider.notifier).state = v,
    );
  }
}

class _RepeatSelector extends StatelessWidget {
  final WidgetRef ref;
  const _RepeatSelector({required this.ref});

  @override
  Widget build(BuildContext context) {
    final current = ref.watch(_repeatProvider);
    final options = [
      (RepeatType.once, 'Once'),
      (RepeatType.daily, 'Daily'),
      (RepeatType.weekdays, 'Weekdays'),
      (RepeatType.weekends, 'Weekends'),
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((o) {
        final isSelected = current == o.$1;
        return GestureDetector(
          onTap: () => ref.read(_repeatProvider.notifier).state = o.$1,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              o.$2,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textGrey,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _CalendarPicker extends StatelessWidget {
  final WidgetRef ref;
  const _CalendarPicker({required this.ref});

  @override
  Widget build(BuildContext context) {
    final selected = ref.watch(_selectedDateProvider);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TableCalendar(
        firstDay: DateTime.now(),
        lastDay: DateTime.now().add(const Duration(days: 365)),
        focusedDay: selected ?? DateTime.now(),
        selectedDayPredicate: (day) =>
            selected != null && isSameDay(day, selected),
        onDaySelected: (selected, focused) {
          ref.read(_selectedDateProvider.notifier).state = selected;
        },
        calendarStyle: const CalendarStyle(
          selectedDecoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: AppColors.primaryLight,
            shape: BoxShape.circle,
          ),
          todayTextStyle: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
          selectedTextStyle: TextStyle(color: Colors.white),
          outsideDaysVisible: false,
        ),
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: AppColors.textDark,
          ),
          leftChevronIcon: Icon(Icons.chevron_left, color: AppColors.textGrey),
          rightChevronIcon: Icon(
            Icons.chevron_right,
            color: AppColors.textGrey,
          ),
        ),
        daysOfWeekStyle: const DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            color: AppColors.textGrey,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          weekendStyle: TextStyle(
            color: AppColors.textGrey,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _SoundOptionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SoundOptionButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textGrey,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: AppColors.textGrey,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
