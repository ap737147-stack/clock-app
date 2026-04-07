// lib/screens/select_from_storage_screen.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

import '../models/alarm_model.dart';
import '../providers/alarm_provider.dart';
import '../utils/app_theme.dart';

class SelectFromStorageScreen extends ConsumerStatefulWidget {
  const SelectFromStorageScreen({super.key});

  @override
  ConsumerState<SelectFromStorageScreen> createState() =>
      _SelectFromStorageScreenState();
}

class _SelectFromStorageScreenState
    extends ConsumerState<SelectFromStorageScreen> {
  final _player = AudioPlayer();
  String? _selectedFilePath;
  String? _selectedFileName;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _isPlaying = false);
    });
    _player.onDurationChanged.listen((d) {
      setState(() => _duration = d);
    });
    _player.onPositionChanged.listen((p) {
      setState(() => _position = p);
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<bool> _ensureStoragePermission() async {
    if (!Platform.isAndroid) return true;

    // Try audio permission first (works on Android 13+)
    final audioStatus = await Permission.audio.status;
    if (audioStatus.isGranted) return true;

    final audioResult = await Permission.audio.request();
    if (audioResult.isGranted) return true;

    // Fallback to photos permission for broader media access
    final photosStatus = await Permission.photos.status;
    if (photosStatus.isGranted) return true;

    final photosResult = await Permission.photos.request();
    if (photosResult.isGranted) return true;

    // Final fallback to storage permission (for older Android versions)
    final storageStatus = await Permission.storage.status;
    if (storageStatus.isGranted) return true;

    final storageResult = await Permission.storage.request();
    if (storageResult.isGranted) return true;

    // If all permissions are denied, check if permanently denied and offer to open settings
    if (audioResult.isPermanentlyDenied ||
        photosResult.isPermanentlyDenied ||
        storageResult.isPermanentlyDenied) {
      await _showPermissionSettingsDialog();
      return false;
    }

    return false;
  }

  Future<void> _showPermissionSettingsDialog() async {
    if (!mounted) return;

    final shouldOpenSettings = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Storage Permission Required'),
        content: const Text(
          'This app needs access to your storage to select audio files. '
          'Please grant storage permission in app settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );

    if (shouldOpenSettings == true) {
      await openAppSettings();
    }
  }

  Future<void> _showSnackBar(String message) async {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _pickFile() async {
    if (!await _ensureStoragePermission()) {
      await _showSnackBar('Storage permission is required to pick files.');
      return;
    }

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav', 'm4a', 'aac', 'ogg'],
      allowMultiple: false,
      withData: true,
    );

    if (result == null || result.files.isEmpty) {
      return;
    }

    final pickedFile = result.files.single;
    String? path = pickedFile.path;

    if (path == null && pickedFile.bytes != null) {
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/${pickedFile.name}');
      await tempFile.writeAsBytes(pickedFile.bytes!);
      path = tempFile.path;
    }

    if (path == null) {
      await _showSnackBar('Unable to access the selected file.');
      return;
    }

    final name = pickedFile.name;
    setState(() {
      _selectedFilePath = path;
      _selectedFileName = name;
      _isPlaying = false;
      _position = Duration.zero;
    });

    await _player.setSource(DeviceFileSource(path));
  }

  Future<void> _togglePlay() async {
    if (_selectedFilePath == null) return;
    if (_isPlaying) {
      await _player.pause();
      setState(() => _isPlaying = false);
    } else {
      await _player.resume();
      setState(() => _isPlaying = true);
    }
  }

  Future<void> _seekTo(Duration position) async {
    await _player.seek(position);
  }

  void _saveAlarm(AlarmModel draft) {
    if (_selectedFilePath == null) return;
    final alarm = draft.copyWith(
      voiceFilePath: _selectedFilePath,
      voiceLabel: _selectedFileName ?? 'Selected Audio',
    );
    ref.read(alarmProvider.notifier).addAlarm(alarm);
    Navigator.popUntil(context, (r) => r.isFirst);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final draft = ModalRoute.of(context)!.settings.arguments as AlarmModel;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Select from Storage'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 32),
              const Text(
                'Choose an audio file',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _selectedFilePath == null
                    ? 'Select an audio file from your device storage'
                    : 'Selected: ${_selectedFileName ?? 'Audio file'}',
                style: const TextStyle(fontSize: 14, color: AppColors.textGrey),
                textAlign: TextAlign.center,
              ),
              const Spacer(),

              // File selection button
              if (_selectedFilePath == null) ...[
                Material(
                  color: AppColors.primary,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: _pickFile,
                    child: SizedBox(
                      width: 120,
                      height: 120,
                      child: const Center(
                        child: Icon(
                          Icons.library_music,
                          color: Colors.white,
                          size: 48,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Tap to browse files',
                  style: TextStyle(fontSize: 16, color: AppColors.textGrey),
                ),
              ] else ...[
                // Audio player controls
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: _togglePlay,
                            icon: Icon(
                              _isPlaying
                                  ? Icons.pause_circle_filled
                                  : Icons.play_circle_fill,
                              size: 48,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Slider(
                        value: _position.inSeconds.toDouble(),
                        max: _duration.inSeconds.toDouble(),
                        onChanged: (value) {
                          _seekTo(Duration(seconds: value.toInt()));
                        },
                        activeColor: AppColors.primary,
                        inactiveColor: AppColors.disabled,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDuration(_position),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textGrey,
                            ),
                          ),
                          Text(
                            _formatDuration(_duration),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textGrey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _pickFile,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.primary),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Choose Different File',
                          style: TextStyle(color: AppColors.primary),
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              const Spacer(),

              // Save button
              if (_selectedFilePath != null) ...[
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
                const SizedBox(height: 32),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
