import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';

import '../../../utils/translation_utils.dart';
import '../../clients/overlays/main_overlay.dart';
import '../info/videos_tutoriales.dart';

class OverlayPP extends StatefulWidget {
  final VoidCallback onClose;

  const OverlayPP({super.key, required this.onClose});

  @override
  _OverlayPPState createState() => _OverlayPPState();
}

class _OverlayPPState extends State<OverlayPP>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }
  @override
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return MainOverlay(
      title:  Text(
        tr(context,'Primeros pasos').toUpperCase(),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 34.sp,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF2be4f3),
        ),
      ),
      content: const VideoTutorialesPPListView(),
      onClose: widget.onClose,
    );
  }
}

class OverlaySw extends StatefulWidget {
  final VoidCallback onClose;

  const OverlaySw({super.key, required this.onClose});

  @override
  _OverlaySwState createState() => _OverlaySwState();
}

class _OverlaySwState extends State<OverlaySw>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }
  @override
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return MainOverlay(
      title:  Text(
        tr(context,'Software').toUpperCase(),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 34.sp,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF2be4f3),
        ),
      ),
      content: const VideoTutorialesSwListView(),
      onClose: widget.onClose,
    );
  }
}


class OverlayIncidencias extends StatefulWidget {
  final VoidCallback onClose;

  const OverlayIncidencias({super.key, required this.onClose});

  @override
  _OverlayIncidenciasState createState() => _OverlayIncidenciasState();
}

class _OverlayIncidenciasState extends State<OverlayIncidencias>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }
  @override
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return MainOverlay(
      title:  Text(
        tr(context,'Incidencias comunes').toUpperCase(),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 34.sp,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF2be4f3),
        ),
      ),
      content: const VideoTutorialesIncidenciasListView(),
      onClose: widget.onClose,
    );
  }
}


class OverlayVideos extends StatefulWidget {
  final String videoPath;
  final String videoName;
  final VoidCallback onClose;

  const OverlayVideos({
    Key? key,
    required this.videoPath,
    required this.onClose,
    required this.videoName,
  }) : super(key: key);

  @override
  _OverlayVideosState createState() => _OverlayVideosState();
}

class _OverlayVideosState extends State<OverlayVideos> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.videoPath)
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      }).catchError((e) {
        print("Error al inicializar el video: $e");
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.1),
      child: Center(
        child: Stack(
          children: [
            // Video player inside a container
            Container(
              width: MediaQuery.of(context).size.width * 0.6,
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: _controller.value.isInitialized
                        ? AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    )
                        : const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  // Control bar
                  Container(
                    color: Colors.black,
                    padding: const EdgeInsets.symmetric(
                        vertical: 1.0, horizontal: 10.0),
                    child: Column(
                      children: [
                        VideoProgressIndicator(
                          _controller,
                          allowScrubbing: true,
                          colors: const VideoProgressColors(
                            playedColor: Color(0xFF2be4f3),
                            bufferedColor: Colors.grey,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDuration(_controller.value.position),
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 15),
                            ),
                            Text(
                              _formatDuration(_controller.value.duration),
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 15),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.fast_rewind,
                                  color: Colors.white, size: 40),
                              onPressed: () => _controller.seekTo(
                                _controller.value.position -
                                    const Duration(seconds: 5),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                _controller.value.isPlaying
                                    ? Icons.pause_circle
                                    : Icons.play_circle,
                                color: Colors.white,
                                size: 60,
                              ),
                              onPressed: () {
                                setState(() {
                                  _controller.value.isPlaying
                                      ? _controller.pause()
                                      : _controller.play();
                                });
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.fast_forward,
                                  color: Colors.white, size: 40),
                              onPressed: () => _controller.seekTo(
                                _controller.value.position +
                                    const Duration(seconds: 5),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                ],
              ),
            ),
            // Close button positioned on the top-right corner
            Positioned(
              right: 0,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 40),
                onPressed: widget.onClose,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}