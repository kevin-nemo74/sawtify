import 'package:flutter/material.dart';

class PronunciationTestResults extends StatefulWidget {
  @override
  _PronunciationTestResultsState createState() => _PronunciationTestResultsState();
}

class _PronunciationTestResultsState extends State<PronunciationTestResults> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 40),
            Text(
              ' Results', // Title displayed in the interface
              style: TextStyle(
                    fontSize: 24, // Increased font size for more emphasis
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 50, 50, 50), // Slightly darker shade for better contrast
                    shadows: [
                      Shadow(
                        blurRadius: 10,
                        color: Colors.grey.withOpacity(0.3),
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),),
            SizedBox(height: 10),
            Expanded(
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedGradientCircularProgressIndicator(value: 85),
                    Text(
                      '85%',
                      style: TextStyle(
                        color: Colors.black, 
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            resultCard('Vowel Sounds', 85, 'Good clarity!'),
          ],
        ),
      ),
    );
  }

  Widget resultCard(String testName, int score, String feedback) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: const Color.fromRGBO(194, 202, 242, 0.56),
              child: Text(
                score.toString(),
                style: TextStyle(
                  color: Colors.black, // Changed color to black for better visibility
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    testName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black, 
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    feedback,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black, 
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AnimatedGradientCircularProgressIndicator extends StatefulWidget {
  final int value;

  const AnimatedGradientCircularProgressIndicator({Key? key, required this.value}) : super(key: key);

  @override
  _AnimatedGradientCircularProgressIndicatorState createState() => _AnimatedGradientCircularProgressIndicatorState();
}

class _AnimatedGradientCircularProgressIndicatorState extends State<AnimatedGradientCircularProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );

    _animation = Tween<double>(
      begin: 0,
      end: widget.value.toDouble(),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          size: Size(200, 200),
          painter: GradientCircularProgressPainter(_animation.value),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class GradientCircularProgressPainter extends CustomPainter {
  final double value;

  GradientCircularProgressPainter(this.value);

  @override
  void paint(Canvas canvas, Size size) {
    Paint backgroundPaint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 16
      ..style = PaintingStyle.stroke;

    Paint foregroundPaint = Paint()
      ..shader = LinearGradient(
        colors: [Color.fromARGB(170, 2, 139, 252), Color.fromARGB(6, 145, 212, 245)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromCircle(center: Offset(size.width / 2, size.height / 2), radius: size.width / 2))
      ..strokeWidth = 16
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    double radius = size.width / 2;
    Offset center = Offset(size.width / 2, size.height / 2);

    canvas.drawCircle(center, radius, backgroundPaint);

    double angle = 2 * 3.141592653589793 * (value / 100);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -3.141592653589793 / 2, angle, false, foregroundPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
