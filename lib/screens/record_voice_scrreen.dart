// lib/screens/record_voice_screen.dart

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:uuid/uuid.dart';
import '../models/alarm_model.dart';
import '../providers/alarm_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/waveform_widget.dart';

enum _RecordState { idle, recording, recorded }

class RecordVoiceScreen extends ConsumerStatefulWidget {
  const RecordVoiceScreen({super.key});

  @override
  ConsumerState<RecordVoiceScreen> createState() => _RecordVoiceScreenState();
}

class _RecordVoiceScreenState extends ConsumerState<RecordVoiceScreen>
    with SingleTickerProviderStateMixin {
  final _recorder = AudioRecorder();
  final _player = AudioPlayer();

  _RecordState _state = _RecordState.idle;
  int _seconds = 0;
  String? _filePath;
  Timer? _timer;
  bool _isPlaying = false;

  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(
      begin: 1.0,
      end: 1.18,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _isPlaying = false);
    });
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _timer?.cancel();
    _recorder.dispose();
    _player.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) return;

    final dir = await getApplicationDocumentsDirectory();
    final path = '${dir.path}/${const Uuid().v4()}.m4a';

    await _recorder.start(const RecordConfig(), path: path);
    _filePath = path;

    setState(() {
      _state = _RecordState.recording;
      _seconds = 0;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _seconds++);
    });

    _pulseCtrl.repeat(reverse: true);
  }

  Future<void> _stopRecording() async {
    await _recorder.stop();
    _timer?.cancel();
    _pulseCtrl.stop();
    setState(() => _state = _RecordState.recorded);
  }

  Future<void> _togglePlay() async {
    if (_filePath == null) return;
    if (_isPlaying) {
      await _player.stop();
      setState(() => _isPlaying = false);
    } else {
      await _player.play(DeviceFileSource(_filePath!));
      setState(() => _isPlaying = true);
    }
  }

  void _reRecord() {
    _timer?.cancel();
    _player.stop();
    setState(() {
      _state = _RecordState.idle;
      _seconds = 0;
      _isPlaying = false;
    });
  }

  Future<void> _saveAlarm(AlarmModel draft) async {
    final label = _labelFromPath(_filePath);
    final alarm = draft.copyWith(voiceFilePath: _filePath, voiceLabel: label);
    ref.read(alarmProvider.notifier).addAlarm(alarm);
    if (mounted) Navigator.popUntil(context, (r) => r.isFirst);
  }

  String _labelFromPath(String? path) {
    // In a real app, you'd do speech-to-text here. We mock it.
    const samples = [
      'RISE AND SHINE!',
      'TAKE MEDICINE',
      'TIME TO GO',
      'WAKE UP NOW',
    ];
    return samples[Random().nextInt(samples.length)];
  }

  @override
  Widget build(BuildContext context) {
    final routeArg = ModalRoute.of(context)?.settings.arguments;
    final draft = routeArg is AlarmModel
        ? routeArg
        : AlarmModel(
            id: const Uuid().v4(),
            title: 'Voice Alarm',
            hour: 8,
            minute: 30,
            isPm: false,
          );
    final isRecording = _state == _RecordState.recording;
    final isRecorded = _state == _RecordState.recorded;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Record Voice Alarm'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 32),
              const Text(
                'Set your reminder',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isRecording
                    ? 'Recording... tap mic to stop'
                    : isRecorded
                    ? 'Recording complete!'
                    : 'Tap the mic to start recording',
                style: const TextStyle(fontSize: 14, color: AppColors.textGrey),
              ),
              const Spacer(),

              // ── Mic button with pulse ──────────────────────────────────
              GestureDetector(
                onTap: isRecording ? _stopRecording : _startRecording,
                child: AnimatedBuilder(
                  animation: _pulseAnim,
                  builder: (_, child) {
                    final scale = isRecording ? _pulseAnim.value : 1.0;
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        // outer glow ring
                        Transform.scale(
                          scale: scale * 1.45,
                          child: Container(
                            width: 130,
                            height: 130,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary.withOpacity(
                                isRecording ? 0.12 : 0.06,
                              ),
                            ),
                          ),
                        ),
                        // mid ring
                        Transform.scale(
                          scale: scale * 1.2,
                          child: Container(
                            width: 130,
                            height: 130,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary.withOpacity(
                                isRecording ? 0.08 : 0.04,
                              ),
                            ),
                          ),
                        ),
                        // mic button
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isRecorded
                                ? AppColors.success
                                : AppColors.primary,
                            boxShadow: [
                              BoxShadow(
                                color:
                                    (isRecorded
                                            ? AppColors.success
                                            : AppColors.primary)
                                        .withOpacity(0.35),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Icon(
                            isRecorded ? Icons.check : Icons.mic,
                            color: Colors.white,
                            size: 44,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),

              // ── Waveform / timer ────────────────────────────────────────
              WaveformWidget(
                isRecording: isRecording,
                durationSeconds: _seconds,
              ),

              const Spacer(),

              // ── Actions ─────────────────────────────────────────────────
              if (isRecorded) ...[
                Row(
                  children: [
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.refresh,
                        label: 'Re-record',
                        onTap: _reRecord,
                        outlined: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ActionButton(
                        icon: _isPlaying ? Icons.stop : Icons.play_arrow,
                        label: _isPlaying ? 'Stop' : 'Play',
                        onTap: _togglePlay,
                        outlined: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () => _saveAlarm(draft),
                    child: const Text(
                      'Save Alarm',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool outlined;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.disabled),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.textDark, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
