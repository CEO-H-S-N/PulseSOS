import 'dart:io';
import 'package:camera/camera.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:logger/logger.dart';

/// Service managing camera and audio evidence capture on SOS trigger
class EvidenceRecorder {
  final Logger _logger = Logger();
  final AudioRecorder _audioRecorder = AudioRecorder();
  
  CameraController? _cameraController;
  bool _isAudioRecording = false;
  bool _isVideoRecording = false;
  String? _audioPath;
  String? _videoPath;

  /// Starts silent audio recording in background
  Future<void> startAudioRecording() async {
    try {
      if (_isAudioRecording) return;

      if (await _audioRecorder.hasPermission()) {
        final tempDir = await getTemporaryDirectory();
        final path = '${tempDir.path}/evidence_${DateTime.now().millisecondsSinceEpoch}.m4a';

        await _audioRecorder.start(
          const RecordConfig(encoder: AudioEncoder.aacLc),
          path: path,
        );

        _audioPath = path;
        _isAudioRecording = true;
        _logger.i('🎙️ Audio evidence buffer started successfully at: $path');
      }
    } catch (e) {
      _logger.e('❌ Failed to start audio evidence capture:', e);
    }
  }

  /// Stops audio recording and returns file path
  Future<String?> stopAudioRecording() async {
    try {
      if (!_isAudioRecording) return null;

      final path = await _audioRecorder.stop();
      _isAudioRecording = false;
      _logger.i('🎙️ Audio evidence buffer saved successfully: $path');
      return path;
    } catch (e) {
      _logger.e('❌ Failed to stop audio recording:', e);
      return null;
    }
  }

  /// Initializes and starts video stream recording (e.g. front camera)
  Future<void> startVideoRecording() async {
    try {
      if (_isVideoRecording) return;

      final cameras = await availableCameras();
      if (cameras.isEmpty) return;

      // Select front camera if available, fallback to primary
      final frontCamera = cameras.firstWhere(
        (cam) => cam.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: true,
      );

      await _cameraController!.initialize();
      await _cameraController!.startVideoRecording();

      _isVideoRecording = true;
      _logger.i('📹 Front camera video evidence stream successfully active');
    } catch (e) {
      _logger.e('❌ Failed to start video evidence capture:', e);
    }
  }

  /// Stops video recording and returns file
  Future<File?> stopVideoRecording() async {
    try {
      if (!_isVideoRecording || _cameraController == null) return null;

      final xFile = await _cameraController!.stopVideoRecording();
      _isVideoRecording = false;

      _videoPath = xFile.path;
      _logger.i('📹 Video evidence stream saved: $_videoPath');

      // Dispose controller cleanly
      await _cameraController!.dispose();
      _cameraController = null;

      return File(_videoPath!);
    } catch (e) {
      _logger.e('❌ Failed to stop video recording:', e);
      return null;
    }
  }

  /// Clears cache evidence records
  Future<void> cleanCache() async {
    try {
      if (_audioPath != null) {
        final audioFile = File(_audioPath!);
        if (await audioFile.exists()) await audioFile.delete();
      }
      if (_videoPath != null) {
        final videoFile = File(_videoPath!);
        if (await videoFile.exists()) await videoFile.delete();
      }
    } catch (e) {
      _logger.w('⚠️ Evidence cache cleaning failed:', e);
    }
  }
}
