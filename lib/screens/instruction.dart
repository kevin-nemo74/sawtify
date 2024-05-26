import 'package:flutter/material.dart';
import 'package:sawtify/screens/test.dart';

class Instruction extends StatefulWidget {
  @override
  _InstructionState createState() => _InstructionState();
}

class _InstructionState extends State<Instruction>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 1.0, end: 1.1).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 50),
            Center(
              child: ScaleTransition(
                scale: _animation,
                child: Text(
                  ' Welcome to Sawtify! ',
                  style: const TextStyle(fontSize: 24, color: Color.fromARGB(255, 43, 104, 236),fontWeight:FontWeight.bold),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                'This app will guide you through a short assessment task designed to evaluate your speech patterns.',
                style: TextStyle(fontSize: 18,color:const Color.fromARGB(255, 104, 144, 229) ),
                textAlign: TextAlign.center,
              ),
            ),
            AnimatedInstructionCard(
              title: 'Find a quiet place',
              description:
                  'Ensure you\'re in a quiet environment with minimal background noise. This will help the app accurately capture your speech.',
              emoji: '🤫',
            ),
            AnimatedInstructionCard(
              title: 'Put on headphones',
              description:
                  'Using headphones will provide clearer audio and minimize any distractions from your surroundings.',
              emoji: '🎧',
            ),
            AnimatedInstructionCard(
              title: 'Listen carefully',
              description: 'Pay close attention to the audios.',
              emoji: '👂',
            ),
            AnimatedInstructionCard(
              title: 'Repeat accurately',
              description:
                  'Try your best to repeat the audios exactly as you hear them.',
              emoji: '🎤',
            ),
            AnimatedInstructionCard(
              title: 'Time-out',
              description:
                  'If you need to stop the task for any reason, you won\'t be able to resume it. However, you can try the task again after 3 days.',
              emoji: '⏰',
            ),
            SizedBox(height: 20),
  Center(
  child: ElevatedButton(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TestPage(),
        ),
      );
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF8EAEF1),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16), 
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '  Start Test',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(width: 8),
        ScaleTransition(
          scale: AnimationController(
            duration: Duration(milliseconds: 300),
            vsync: this,
          )..repeat(reverse: true),
          child: Icon(
            Icons.arrow_forward,
            color: Colors.white,
          ),
        ),
      ],
    ),
  ),
),



            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class AnimatedInstructionCard extends StatefulWidget {
  final String title;
  final String description;
  final String emoji;

  const AnimatedInstructionCard({
    Key? key,
    required this.title,
    required this.description,
    required this.emoji,
  }) : super(key: key);

  @override
  _AnimatedInstructionCardState createState() =>
      _AnimatedInstructionCardState();
}

class _AnimatedInstructionCardState extends State<AnimatedInstructionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Color.fromARGB(255, 104, 144, 229)),
              ),
              SizedBox(height: 10),
              Text(
                widget.description,
                style: TextStyle(fontSize: 16, color:Color.fromARGB(255, 104, 144, 229)),
              ),
              SizedBox(height: 10),
              Text(
                widget.emoji,
                style: TextStyle(fontSize: 24),
              ),
            ],
          ),
        ),
      ),
    );
  }
}