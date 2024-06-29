import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PomodoroTimer(),
    );
  }
}

class PomodoroTimer extends StatefulWidget {
  @override
  _PomodoroTimerState createState() => _PomodoroTimerState();
}

class _PomodoroTimerState extends State<PomodoroTimer> {
  Timer? timer;
  Duration remainingTime = Duration(minutes: 10);
  bool isRunning = false;
  String taskDescription = "Study";
  final motivationalQuote = "Keep pushing forward!";
  int selectedDuration = 10;
  double angle = 0;

  void startTimer() {
    setState(() {
      isRunning = true;
    });
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      setState(() {
        if (remainingTime.inSeconds > 0) {
          remainingTime = remainingTime - Duration(seconds: 1);
        } else {
          t.cancel();
          isRunning = false;
        }
      });
    });
  }

  void stopTimer() {
    setState(() {
      isRunning = false;
    });
    timer?.cancel();
  }

  void resetTimer() {
    setState(() {
      remainingTime = Duration(minutes: selectedDuration);
    });
  }

  void selectDuration(double angle) {
    setState(() {
      int newDuration = ((angle / (2 * math.pi)) * 12).round() * 5 + 10;
      newDuration = newDuration.clamp(10, 60);
      selectedDuration = newDuration;
      remainingTime = Duration(minutes: selectedDuration);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF50A387),
      appBar: AppBar(
        title: Text('Pomodoro Timer',
        style: TextStyle(
          color: Colors.white,
        ))
        ,
        backgroundColor: Color(0xFF50A387),
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              motivationalQuote,
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.normal, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            GestureDetector(
              onPanUpdate: (details) {
                if (!isRunning) {
                  double newAngle = (math.atan2(details.localPosition.dy - 150, details.localPosition.dx - 150) - math.pi / 2) % (2 * math.pi);
                  newAngle = newAngle < 0 ? newAngle + 2 * math.pi : newAngle;
                  selectDuration(newAngle);
                  setState(() {
                    angle = newAngle;
                  });
                }
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 300,
                    height: 300,
                    child: CustomPaint(
                      painter: TimerPainter(
                        angle: angle,
                        progress: remainingTime.inSeconds / (selectedDuration * 60),
                        isRunning: isRunning,
                      ),
                    ),
                  ),
                  Image.asset(
                    'assets/foto.png',
                    width: 100,
                    height: 100,
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () async {
                String? newTask = await showDialog<String>(
                  context: context,
                  builder: (BuildContext context) {
                    return SimpleDialog(
                      title: Text('Enter Task Description', style: TextStyle(color: Colors.white)),
                      backgroundColor: Color(0xFF50A387),
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            onSubmitted: (value) {
                              Navigator.pop(context, value);
                            },
                            style: TextStyle(color: Colors.white),
                            cursorColor: Colors.white,
                            decoration: InputDecoration(
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
                if (newTask != null && newTask.isNotEmpty) {
                  setState(() {
                    taskDescription = newTask;
                  });
                }
              },
              child: Text(
                taskDescription,
                style: TextStyle(fontSize: 18.0, color: Colors.white),
              ),
            ),
            SizedBox(height: 20),
            Text(
              '${remainingTime.inMinutes}:${(remainingTime.inSeconds % 60).toString().padLeft(2, '0')}',
              style: TextStyle(fontSize: 18.0, color: Colors.white),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isRunning ? stopTimer : startTimer,
              child: Text(isRunning ? 'Break' : 'Start'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF8CC923),
                foregroundColor: Colors.white
              ),
            ),
          ],
        )
      ),
    );
  }
}

class TimerPainter extends CustomPainter {
  final double angle;
  final double progress;
  final bool isRunning;

  TimerPainter({required this.angle, required this.progress, required this.isRunning});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Color(0xFFE4E5A3)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke;

    Paint progressPaint = Paint()
      ..color = Color(0xFF8CC923)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke;

    Paint fillPaint = Paint()
      ..color = Color(0xFFE4E5A3)
      ..style = PaintingStyle.fill;

    double radius = size.width / 2;
    Offset center = Offset(size.width / 2, size.height / 2);

    canvas.drawCircle(center, radius, fillPaint);
    canvas.drawCircle(center, radius, paint);

    if (!isRunning) {
      double sweepAngle = angle;
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -math.pi / 2, sweepAngle, false, progressPaint);
    } else {
      double sweepAngle = 2 * math.pi * progress;
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -math.pi / 2, sweepAngle, false, progressPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
