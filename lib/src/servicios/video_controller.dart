import 'package:video_player/video_player.dart';

class GlobalVideoControllerManager {
  static final GlobalVideoControllerManager _instance =
      GlobalVideoControllerManager._internal();

  bool _isInitializing = false;
  VideoPlayerController? _videoController;
  String? _activeMacAddress; // Asocia el video al macAddress

  GlobalVideoControllerManager._internal();

  static GlobalVideoControllerManager get instance => _instance;

  bool get isInitializing => _isInitializing;

  VideoPlayerController? get videoController => _videoController;

  String? get activeMacAddress => _activeMacAddress;

  Future<void> initializeVideo(String videoUrl, String macAddress) async {
    if (_isInitializing || _videoController != null) {
      throw Exception("Ya hay un video en inicialización o activo.");
    }

    if (videoUrl.isEmpty) {
      throw Exception("No se proporcionó una URL de video válida.");
    }

    _isInitializing = true;

    try {
      // Crear un nuevo controlador de video
      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(videoUrl),
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );

      _activeMacAddress = macAddress; // Asociar el macAddress al controlador

      // Inicializar el controlador
      await _videoController!.initialize();
    } catch (e) {
      _videoController = null;
      _activeMacAddress = null; // Limpiar el macAddress en caso de error
      throw Exception("Error al inicializar el video: $e");
    } finally {
      _isInitializing = false;
    }
  }

  Future<void> cancelVideo(String macAddress) async {
    if (_videoController == null || _activeMacAddress != macAddress) {
      throw Exception(
          "No hay un video activo o el video no pertenece a este macAddress.");
    }

    try {
      await _videoController!.pause();
      await _videoController!.dispose();
      _videoController = null;
      _activeMacAddress = null;
    } catch (e) {
      throw Exception("Error al cancelar el video: $e");
    }
  }
}
