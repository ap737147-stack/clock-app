// lib/screens/alarm_active_screen.dart

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../models/alarm_model.dart';
import '../utils/app_theme.dart';

class AlarmActiveScreen extends StatefulWidget {
  const AlarmActiveScreen({super.key});

  @override
  State<AlarmActiveScreen> createState() => _AlarmActiveScreenState();
}

class _AlarmActiveScreenState extends State<AlarmActiveScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _rippleCtrl;
  late Animation<double> _rippleAnim;
  final _player = AudioPlayer();
  bool _isPlaying = true;

  @override
  void initState() {
    super.initState();
    _rippleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _rippleAnim = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _rippleCtrl, curve: Curves.easeOut));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final alarm = ModalRoute.of(context)!.settings.arguments as AlarmModel?;
      if (alarm?.voiceFilePath != null) {
        _player.play(DeviceFileSource(alarm!.voiceFilePath!));
      }
    });
  }

  @override
  void dispose() {
    _rippleCtrl.dispose();
    _player.dispose();
    super.dispose();
  }

  void _dismiss() {
    _player.stop();
    Navigator.pop(context);
  }

  void _toggleVoice(AlarmModel alarm) async {
    if (_isPlaying) {
      await _player.stop();
    } else if (alarm.voiceFilePath != null) {
      await _player.play(DeviceFileSource(alarm.voiceFilePath!));
    }
    setState(() => _isPlaying = !_isPlaying);
  }

  @override
  Widget build(BuildContext context) {
    final alarm = ModalRoute.of(context)!.settings.arguments as AlarmModel?;
    final now = DateTime.now();
    final h = now.hour > 12 ? now.hour - 12 : now.hour;
    final m = now.minute.toString().padLeft(2, '0');
    final period = now.hour >= 12 ? 'AM' : 'PM';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Status bar ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  const Icon(
                    Icons.notifications,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'ALARM ACTIVE',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                      color: AppColors.primary,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(
                      Icons.stop_circle,
                      color: AppColors.textGrey,
                    ),
                    onPressed: _dismiss,
                  ),
                ],
              ),
            ),

            const Spacer(),

            // ── Speaker button with ripple ────────────────────────────────
            GestureDetector(
              onTap: alarm != null ? () => _toggleVoice(alarm) : null,
              child: AnimatedBuilder(
                animation: _rippleAnim,
                builder: (_, __) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // outer ripple
                      Transform.scale(
                        scale: _rippleAnim.value * 1.55,
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary.withOpacity(
                              (1 - _rippleAnim.value) * 0.2,
                            ),
                          ),
                        ),
                      ),
                      // mid ripple
                      Transform.scale(
                        scale: _rippleAnim.value * 1.28,
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary.withOpacity(
                              (1 - _rippleAnim.value) * 0.12,
                            ),
                          ),
                        ),
                      ),
                      // inner
                      Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.4),
                              blurRadius: 24,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: Icon(
                          _isPlaying ? Icons.volume_up : Icons.volume_off,
                          color: Colors.white,
                          size: 52,
                        ),
                      ),
                      // mic badge
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: const Icon(
                            Icons.mic,
                            color: AppColors.primary,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 36),

            // ── Time ─────────────────────────────────────────────────────
            Text(
              '${h.toString().padLeft(2, '0')}:$m',
              style: const TextStyle(
                fontSize: 72,
                fontWeight: FontWeight.w900,
                color: AppColors.textDark,
                letterSpacing: -2,
              ),
            ),
            Text(
              period,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                letterSpacing: 2,
              ),
            ),

            const SizedBox(height: 28),

            // ── Alarm info card ───────────────────────────────────────────
            if (alarm != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 32),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.07),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      alarm.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                    if (alarm.voiceLabel != null) ...[
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.record_voice_over,
                            color: AppColors.textGrey,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Playing voice reminder...',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textGrey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

            const Spacer(),

            // ── Dismiss button ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: GestureDetector(
                onTap: _dismiss,
                child: Container(
                  width: double.infinity,
                  height: 62,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        color: Colors.white,
                        size: 22,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Dismiss Alarm',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
