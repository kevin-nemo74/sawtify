import 'package:flutter/material.dart';
import 'package:sawtify/screens/contact.dart';
import 'package:sawtify/screens/entry_point.dart';

class PronunciationTestResults extends StatefulWidget {
  final int score;
  final String testName;
  final String feedback;

  PronunciationTestResults({
    required this.score,
    required this.testName,
    required this.feedback,
  });

  @override
  _PronunciationTestResultsState createState() =>
      _PronunciationTestResultsState();
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
              ' Results',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 50, 50, 50),
                shadows: [
                  Shadow(
                    blurRadius: 10,
                    color: Colors.grey.withOpacity(0.3),
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        AnimatedGradientCircularProgressIndicator(
                            value: widget.score),
                        Text(
                          '${widget.score}%',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    getFeedbackMessage(widget.score),
                  ],
                ),
              ),
            ),
            resultCard(widget.testName, widget.score, widget.feedback),
          ],
        ),
      ),
    );
  }

  Widget getFeedbackMessage(int score) {
    String message;
    Color color;

    if (score < 30) {
      message = 'High probability of having a speech impediment. Please consult a doctor.';
      color = Colors.red;
    } else if (score < 60) {
      message = 'Medium probability of having a speech impediment. Consider consulting a doctor.';
      color = Colors.yellow[700]!;
    } else {
      message = 'Low probability of having a speech impediment.';
      color = Colors.green;
    }

    return Text(
      message,
      style: TextStyle(
        color: color,
        fontSize: 16,
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(
            blurRadius: 5,
            color: color.withOpacity(0.5),
            offset: Offset(0, 2),
          ),
        ],
      ),
      textAlign: TextAlign.center,
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
                  color: Colors.black,
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
                  SizedBox(height: 5),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BottomNavigationBarWidget(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Color.fromARGB(255, 143, 197, 241),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      padding: EdgeInsets.symmetric(
                          vertical: 10, horizontal: 18),
                      elevation: 5, // Elevation
                    ),
                    child: Text('Back to Home Page'),
                  ),
                  SizedBox(height: 5),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Contact(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Color.fromARGB(255, 143, 197, 241),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      padding: EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      elevation: 5, // Elevation
                    ),
                    child: Text(' Doctors Contact     '),
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

  const AnimatedGradientCircularProgressIndicator(
      {Key? key, required this.value})
      : super(key: key);

  @override
  _AnimatedGradientCircularProgressIndicatorState createState() =>
      _AnimatedGradientCircularProgressIndicatorState();
}

class _AnimatedGradientCircularProgressIndicatorState
    extends State<AnimatedGradientCircularProgressIndicator>
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
        colors: [
          Color.fromARGB(170, 2, 139, 252),
          Color.fromARGB(6, 145, 212, 245)
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromCircle(
          center: Offset(size.width / 2, size.height / 2),
          radius: size.width / 2))
      ..strokeWidth = 16
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    double radius = size.width / 2;
    Offset center = Offset(size.width / 2, size.height / 2);

    canvas.drawCircle(center, radius, backgroundPaint);

    double angle = 2 * 3.141592653589793 * (value / 100);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
        -3.141592653589793 / 2, angle, false, foregroundPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
