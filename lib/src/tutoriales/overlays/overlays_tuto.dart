import 'package:flutter/material.dart';

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
  Widget build(BuildContext context) {
    return MainOverlay(
      title: const Text(
        "PRIMEROS PASOS",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2be4f3),
        ),
      ),
      content: const VideoTutorialesListView(),
      onClose: widget.onClose,
    );
  }
}
