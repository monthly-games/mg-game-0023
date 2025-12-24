import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SpriteClipper extends StatefulWidget {
  final String assetPath;
  final int hFrames;
  final int vFrames;
  final int frameIndex; // 0..h*v-1
  final double size;

  const SpriteClipper({
    super.key,
    required this.assetPath,
    this.hFrames = 1,
    this.vFrames = 1,
    this.frameIndex = 0,
    this.size = 64,
  });

  @override
  State<SpriteClipper> createState() => _SpriteClipperState();
}

class _SpriteClipperState extends State<SpriteClipper> {
  ui.Image? _image;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    final data = await rootBundle.load(widget.assetPath);
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    if (mounted) {
      setState(() {
        _image = frame.image;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_image == null) {
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: const CircularProgressIndicator(),
      );
    }

    return CustomPaint(
      painter: _SpritePainter(
        image: _image!,
        hFrames: widget.hFrames,
        vFrames: widget.vFrames,
        frameIndex: widget.frameIndex,
      ),
      size: Size(widget.size, widget.size),
    );
  }
}

class _SpritePainter extends CustomPainter {
  final ui.Image image;
  final int hFrames;
  final int vFrames;
  final int frameIndex;

  _SpritePainter({
    required this.image,
    required this.hFrames,
    required this.vFrames,
    required this.frameIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final frameWidth = image.width / hFrames;
    final frameHeight = image.height / vFrames;

    final col = frameIndex % hFrames;
    final row = frameIndex ~/ hFrames;

    final src = Rect.fromLTWH(
      col * frameWidth,
      row * frameHeight,
      frameWidth,
      frameHeight,
    );
    final dst = Rect.fromLTWH(0, 0, size.width, size.height);

    canvas.drawImageRect(image, src, dst, Paint());
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
