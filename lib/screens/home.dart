import 'package:flutter/material.dart';
//import 'package:sawtify/screens/test.dart';
import '../../models/course.dart';
import 'components/course_card.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  "Welcome to Sawtify",
                  style: TextStyle(
                    fontSize: 20, 
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
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ...courses.map((course) => Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: CourseCard(course: course),
                    )).toList(),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(6),
              ),
              Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        "Test Your Skills",
                        style: TextStyle(
                          fontSize: 20, // 
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 50, 50, 50), // 
                          shadows: [
                            Shadow(
                              blurRadius: 10,
                              color: Colors.grey.withOpacity(0.3),
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Center(
                      child: Container(
                        width: 200,
                        height: 180, // Smaller square size
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16), // Rounded corners
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              blurRadius: 10,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
        child: Padding(
  padding: const EdgeInsets.all(16),
  child: Column( // Changed from Row to Column
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisAlignment: MainAxisAlignment.spaceBetween, // Added space between elements
    children: [
    
      Expanded(
        child: Image.asset(
          'assets/Backgrounds/mic.gif',
          height: 100, 
          width: 100, 
        ),
      ), // 


      Text(
        'Start ..',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color.fromARGB(255, 140, 164, 236), // Adjust text color as needed
        ),
      ), 
    ], 
  ), 
), 
              ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

    );
  }
}

        