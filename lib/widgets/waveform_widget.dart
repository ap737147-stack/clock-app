// lib/widgets/waveform_widget.dart

import 'dart:math';
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class WaveformWidget extends StatefulWidget {
  final bool isRecording;
  final int durationSeconds;

  const WaveformWidget({
    super.key,
    required this.isRecording,
    required this.durationSeconds,
  });

  @override
  State<WaveformWidget> createState() => _WaveformWidgetState();
}

class _WaveformWidgetState extends State<WaveformWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  final _random = Random();
  List<double> _bars = List.generate(14, (_) => 0.15);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    )..addListener(() {
        if (widget.isRecording) {
          setState(() {
            _bars = List.generate(14, (_) {
              return 0.1 + _random.nextDouble() * 0.85;
            });
          });
        }
      });

    if (widget.isRecording) _controller.repeat();
  }

  @override
  void didUpdateWidget(WaveformWidget old) {
    super.didUpdateWidget(old);
    if (widget.isRecording && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.isRecording && _controller.isAnimating) {
      _controller.stop();
      setState(() {
        _bars = List.generate(14, (i) {
          // frozen last frame
          return _bars[i];
        });
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _timeLabel {
    final s = widget.durationSeconds;
    final mm = (s ~/ 60).toString().padLeft(2, '0');
    final ss = (s % 60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: _bars.asMap().entries.map((e) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 80),
                width: 6,
                height: 64 * e.value,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(
                    0.4 + 0.6 * e.value,
                  ),
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _timeLabel,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}
