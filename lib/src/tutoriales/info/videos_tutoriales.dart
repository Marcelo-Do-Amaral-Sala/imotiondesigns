import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';

import '../../db/db_helper.dart';
import '../overlays/overlays_tuto.dart';

class VideoTutorialesPPListView extends StatefulWidget {
  const VideoTutorialesPPListView({Key? key}) : super(key: key);

  @override
  _VideoTutorialesPPListViewState createState() =>
      _VideoTutorialesPPListViewState();
}

class _VideoTutorialesPPListViewState extends State<VideoTutorialesPPListView> {
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
            child: OverlayVideos(
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


class VideoTutorialesSwListView extends StatefulWidget {
  const VideoTutorialesSwListView({Key? key}) : super(key: key);

  @override
  _VideoTutorialesSwListViewState createState() =>
      _VideoTutorialesSwListViewState();
}

class _VideoTutorialesSwListViewState extends State<VideoTutorialesSwListView> {
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
            child: OverlayVideos(
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



class VideoTutorialesIncidenciasListView extends StatefulWidget {
  const VideoTutorialesIncidenciasListView({Key? key}) : super(key: key);

  @override
  _VideoTutorialesIncidenciasListViewState createState() =>
      _VideoTutorialesIncidenciasListViewState();
}

class _VideoTutorialesIncidenciasListViewState extends State<VideoTutorialesIncidenciasListView> {
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
            child: OverlayVideos(
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