// lib/widgets/drum_roll_time_picker.dart

import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class DrumRollTimePicker extends StatefulWidget {
  final int initialHour;
  final int initialMinute;
  final bool initialIsPm;
  final ValueChanged<(int hour, int minute, bool isPm)> onChanged;

  const DrumRollTimePicker({
    super.key,
    required this.initialHour,
    required this.initialMinute,
    required this.initialIsPm,
    required this.onChanged,
  });

  @override
  State<DrumRollTimePicker> createState() => _DrumRollTimePickerState();
}

class _DrumRollTimePickerState extends State<DrumRollTimePicker> {
  late int _hour;
  late int _minute;
  late bool _isPm;

  late FixedExtentScrollController _hourCtrl;
  late FixedExtentScrollController _minCtrl;

  @override
  void initState() {
    super.initState();
    _hour = widget.initialHour;
    _minute = widget.initialMinute;
    _isPm = widget.initialIsPm;
    _hourCtrl = FixedExtentScrollController(initialItem: _hour - 1);
    _minCtrl = FixedExtentScrollController(initialItem: _minute);
  }

  @override
  void dispose() {
    _hourCtrl.dispose();
    _minCtrl.dispose();
    super.dispose();
  }

  void _notify() {
    widget.onChanged((_hour, _minute, _isPm));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Hours
          Expanded(
            child: _buildWheel(
              controller: _hourCtrl,
              items: List.generate(
                12,
                (i) => (i + 1).toString().padLeft(2, '0'),
              ),
              onChanged: (i) {
                _hour = i + 1;
                _notify();
              },
            ),
          ),
          const Text(
            ':',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          // Minutes (in steps of 5)
          Expanded(
            child: _buildWheel(
              controller: _minCtrl,
              items: List.generate(60, (i) => i.toString().padLeft(2, '0')),
              onChanged: (i) {
                _minute = i;
                _notify();
              },
            ),
          ),
          const SizedBox(width: 8),
          // AM/PM
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _PeriodButton(
                label: 'AM',
                isSelected: !_isPm,
                onTap: () => setState(() {
                  _isPm = false;
                  _notify();
                }),
              ),
              const SizedBox(height: 8),
              _PeriodButton(
                label: 'PM',
                isSelected: _isPm,
                onTap: () => setState(() {
                  _isPm = true;
                  _notify();
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWheel({
    required FixedExtentScrollController controller,
    required List<String> items,
    required ValueChanged<int> onChanged,
  }) {
    return ListWheelScrollView.useDelegate(
      controller: controller,
      itemExtent: 42,
      diameterRatio: 1.4,
      physics: const FixedExtentScrollPhysics(),
      onSelectedItemChanged: onChanged,
      childDelegate: ListWheelChildBuilderDelegate(
        childCount: items.length,
        builder: (context, index) {
          final selected = controller.selectedItem == index;
          return Center(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 150),
              style: TextStyle(
                fontSize: selected ? 28 : 18,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w400,
                color: selected ? AppColors.primary : AppColors.textGrey,
              ),
              child: Text(items[index]),
            ),
          );
        },
      ),
    );
  }
}

class _PeriodButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PeriodButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 60,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : AppColors.textGrey,
          ),
        ),
      ),
    );
  }
}
