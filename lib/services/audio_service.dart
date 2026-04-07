// lib/services/audio_service.dart

import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AudioService {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;

  bool get isPlaying => _isPlaying;

  Future<void> playFile(String path) async {
    await _player.play(DeviceFileSource(path));
    _isPlaying = true;
    _player.onPlayerComplete.listen((_) {
      _isPlaying = false;
    });
  }

  Future<void> stop() async {
    await _player.stop();
    _isPlaying = false;
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}

// ── Recording state ──────────────────────────────────────────────────────────

enum RecordingState { idle, recording, recorded }

class RecordingNotifier extends StateNotifier<RecordingState> {
  RecordingNotifier() : super(RecordingState.idle);

  void startRecording() => state = RecordingState.recording;
  void finishRecording() => state = RecordingState.recorded;
  void reset() => state = RecordingState.idle;
}

final recordingStateProvider =
    StateNotifierProvider<RecordingNotifier, RecordingState>(
  (ref) => RecordingNotifier(),
);

// ── Waveform animation data ──────────────────────────────────────────────────

final waveformProvider = StateProvider<List<double>>((ref) {
  return List.generate(12, (i) => 0.3);
});

// ── Recording duration ───────────────────────────────────────────────────────

final recordingDurationProvider = StateProvider<int>((ref) => 0); // seconds

// ── Recorded file path ───────────────────────────────────────────────────────

final recordedFilePathProvider = StateProvider<String?>((ref) => null);
