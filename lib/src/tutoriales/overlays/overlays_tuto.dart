import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
      content: const VideoTutorialesListView(),
      onClose: widget.onClose,
    );
  }
}
