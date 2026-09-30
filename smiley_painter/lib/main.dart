// In-Class Activity 06 — Drawing with Flutter
// Student: Jalen Artis
// Date: September 26, 2026

import 'package:flutter/material.dart';
import 'dart:math' show pi;

void main() => runApp(const SmileyApp());

class SmileyApp extends StatelessWidget {
  const SmileyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smiley Painter Lab',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
          scaffoldBackgroundColor: const Color.fromARGB(255, 104, 102, 102),
        useMaterial3: true,
      ),
      home: const DrawingPlayground(),
    );
  }
}

class DrawingPlayground extends StatefulWidget {
  const DrawingPlayground({super.key});

  @override
  State<DrawingPlayground> createState() => _DrawingPlaygroundState();
}

class _DrawingPlaygroundState extends State<DrawingPlayground> {
  // Drawing "state" — changing these + setState() triggers shouldRepaint
  double mood = 0.8; // 0.0 sad → 1.0 happy
  FaceType selectedFace = FaceType.classic;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CustomPainter Smiley Lab')),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: CustomPaint(
                size: const Size(300, 300),
                painter: SmileyPainter(
                  mood: mood,
                  faceType: selectedFace,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text('Mood: ${mood.toStringAsFixed(2)}'),

                Slider(
                  value: mood,
                  onChanged: (double v) {
                    setState(() {
                      mood = v;
                    });
                  },
                ),

                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedFace = FaceType.classic;
                        });
                      },
                      child: const Text('Classic'),
                    ),

                    const SizedBox(width: 8),

                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedFace = FaceType.sleepy;
                        });
                      },
                      child: const Text('Sleepy'),
                    ),

                    const SizedBox(width: 8),

                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedFace = FaceType.surprised;
                        });
                      },
                      child: const Text('Surprised'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum FaceType {
  classic,
  sleepy,
  surprised,
}

class SmileyPainter extends CustomPainter {
  SmileyPainter({
    required this.mood,
    required this.faceType,
  });

  final double mood;
  final FaceType faceType;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide * 0.4;

    // Face color based on mood
    Color faceColor;

    if (mood < 0.35) {
      faceColor = Colors.lightBlue;
    } else if (mood <= 0.7) {
      faceColor = Colors.yellow;
    } else {
      faceColor = Colors.orange;
    }

    // Face
    final facePaint = Paint()
      ..color = faceColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, facePaint);

    // Face border
    final borderPaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    canvas.drawCircle(center, radius, borderPaint);

    // Eyes
    final eyePaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.fill;

    final eyeY = center.dy - radius * 0.18;
    final eyeDx = radius * 0.35;

    if (faceType == FaceType.classic) {
      // Classic eyes
      final eyeRadius = radius * 0.10;

      canvas.drawCircle(
        Offset(center.dx - eyeDx, eyeY),
        eyeRadius,
        eyePaint,
      );

      canvas.drawCircle(
        Offset(center.dx + eyeDx, eyeY),
        eyeRadius,
        eyePaint,
      );
    } else if (faceType == FaceType.sleepy) {
      // Sleepy closed eyes
      final sleepyEyePaint = Paint()
        ..color = Colors.black87
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(
        Offset(
          center.dx - eyeDx - radius * 0.08,
          eyeY,
        ),
        Offset(
          center.dx - eyeDx + radius * 0.08,
          eyeY,
        ),
        sleepyEyePaint,
      );

      canvas.drawLine(
        Offset(
          center.dx + eyeDx - radius * 0.08,
          eyeY,
        ),
        Offset(
          center.dx + eyeDx + radius * 0.08,
          eyeY,
        ),
        sleepyEyePaint,
      );
    } else if (faceType == FaceType.surprised) {
      // Bigger surprised eyes
      final eyeRadius = radius * 0.15;

      canvas.drawCircle(
        Offset(center.dx - eyeDx, eyeY),
        eyeRadius,
        eyePaint,
      );

      canvas.drawCircle(
        Offset(center.dx + eyeDx, eyeY),
        eyeRadius,
        eyePaint,
      );
    }

    // Mouth
    final mouthPaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    if (faceType == FaceType.classic) {
      // Classic smile/frown based on mood
      final mouthRect = Rect.fromCenter(
        center: Offset(
          center.dx,
          center.dy + radius * 0.15,
        ),
        width: radius * 1.0,
        height: radius * (0.4 + mood * 0.5),
      );

      if (mood < 0.35) {
        // Frown
        canvas.drawArc(
          mouthRect,
          1.15 * pi,
          0.70 * pi,
          false,
          mouthPaint,
        );
      } else if (mood <= 0.7) {
        // Soft smile
        canvas.drawArc(
          mouthRect,
          0.15 * pi,
          0.70 * pi,
          false,
          mouthPaint,
        );
      } else {
        // Big smile
        canvas.drawArc(
          mouthRect,
          0.15 * pi,
          0.90 * pi,
          false,
          mouthPaint,
        );
      }
    } else if (faceType == FaceType.sleepy) {
      // Soft sleepy mouth
      final mouthRect = Rect.fromCenter(
        center: Offset(
          center.dx,
          center.dy + radius * 0.15,
        ),
        width: radius * 0.8,
        height: radius * 0.5,
      );

      canvas.drawArc(
        mouthRect,
        0.15 * pi,
        0.50 * pi,
        false,
        mouthPaint,
      );
    } else if (faceType == FaceType.surprised) {
      // Open surprised mouth
      final surprisedMouthPaint = Paint()
        ..color = Colors.black87
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(
          center.dx,
          center.dy + radius * 0.20,
        ),
        radius * 0.18,
        surprisedMouthPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant SmileyPainter oldDelegate) {
    return oldDelegate.mood != mood ||
        oldDelegate.faceType != faceType;
  }
}