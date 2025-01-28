import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';

import '../../db/db_helper.dart';

class VideoTutorialesListView extends StatefulWidget {
  const VideoTutorialesListView({Key? key}) : super(key: key);

  @override
  _VideoTutorialesListViewState createState() =>
      _VideoTutorialesListViewState();
}

class _VideoTutorialesListViewState extends State<VideoTutorialesListView> {
  List<Map<String, dynamic>> allTuto = []; // Lista de tutoriales
  bool isOverlayVisible = false;
  String currentVideoPath = '';
  String currentVideoName = '';

  void toggleOverlay(String videoPath, String videoName) {
    setState(() {
      isOverlayVisible = !isOverlayVisible;
      currentVideoPath = isOverlayVisible ? videoPath : '';
      currentVideoName = isOverlayVisible ? videoName : '';
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchTuto();
  }
  @override
  void dispose() {
    super.dispose();
  }


  Future<void> _fetchTuto() async {
    var db = await DatabaseHelper().database;
    try {
      final tutoData = await DatabaseHelper().getTutoriales();
      setState(() {
        allTuto = tutoData;
      });
    } catch (e) {
      print('Error fetching programs: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(30.0),
          child: Container(
            width: screenWidth,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 46, 46, 46),
              borderRadius: BorderRadius.circular(7.0),
            ),
            child: Column(
              children: [
                _buildRowView(),
              ],
            ),
          ),
        ),
        if (isOverlayVisible)
          Positioned.fill(
            child: _OverlayVideos(
              videoPath: currentVideoPath,
              videoName: currentVideoName,
              onClose: () => toggleOverlay('', ''),
            ),
          ),
      ],
    );
  }

  Widget _buildRowView() {
    List<List<Map<String, dynamic>>> rows = [];
    for (int i = 0; i < allTuto.length; i += 4) {
      rows.add(
          allTuto.sublist(i, i + 4 > allTuto.length ? allTuto.length : i + 4));
    }

    return Expanded(
      child: ListView.builder(
        itemCount: rows.length,
        itemBuilder: (context, rowIndex) {
          List<Map<String, dynamic>> row = rows[rowIndex];

          return Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: row.map((tuto) {
                String nombre = tuto['nombre'] ?? 'Sin nombre';
                String imagen = tuto['imagen'] ?? 'assets/default_image.png';
                String video = tuto['video'] ?? 'assets/default_video.mp4';

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: GestureDetector(
                    onTap: () {
                      toggleOverlay(video, nombre);
                    },
                    child: Column(
                      children: [
                        Text(
                          nombre,
                          textAlign: TextAlign.center,
                          style:  TextStyle(
                            color: const Color(0xFF2be4f3),
                            fontWeight: FontWeight.bold,
                            fontSize: 20.sp,
                          ),
                        ),
                        Image.asset(
                          imagen,
                          width: MediaQuery.of(context).size.width * 0.15,
                          height: MediaQuery.of(context).size.height * 0.15,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}

class _OverlayVideos extends StatefulWidget {
  final String videoPath;
  final String videoName;
  final VoidCallback onClose;

  const _OverlayVideos({
    Key? key,
    required this.videoPath,
    required this.onClose,
    required this.videoName,
  }) : super(key: key);

  @override
  _OverlayVideosState createState() => _OverlayVideosState();
}

class _OverlayVideosState extends State<_OverlayVideos> {
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
