import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sawtify/screens/instruction.dart';
import 'package:sawtify/screens/time.dart';

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
                    ...courses
                        .map((course) => Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: CourseCard(course: course),
                            ))
                        .toList(),
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
                    GestureDetector(
                      onTap: () async {
                        final user = FirebaseAuth.instance.currentUser;
                        if (await _canUserTakeTest(user!.uid)) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Instruction()));
                        } else {
                          final _firestore = FirebaseFirestore.instance;
                          final userDoc = await _firestore
                              .collection('users')
                              .doc(user.uid)
                              .get();

                          if (userDoc.exists) {
                            final data = userDoc.data();
                            final score = data?['score'];
                            final testName = data?['testName'] ?? '';
                            final feedback = data?['feedback'] ?? '';

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PronunciationTestResults(
                                  score: score,
                                  testName: testName,
                                  feedback: feedback,
                                ),
                              ),
                            );
                          } else {
                            // Handle case where user document does not exist
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PronunciationTestResults(
                                  score: 0,
                                  testName: '',
                                  feedback: '',
                                ),
                              ),
                            );
                          }
                          _showTestLimitExceededDialog();
                        }
                      },
                      child: Center(
                        child: Container(
                          width: 200,
                          height: 180, // Smaller square size
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.circular(16), // Rounded corners
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
                            child: Column(
                              // Changed from Row to Column
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment
                                  .spaceBetween, // Added space between elements
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
                                    color: Color.fromARGB(255, 140, 164,
                                        236), // Adjust text color as needed
                                  ),
                                ),
                              ],
                            ),
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

  Future<bool> _canUserTakeTest(String uid) async {
    final snapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (snapshot.exists) {
      final data = snapshot.data();
      if (data != null && data['lastTestDate'] != null) {
        final lastTestDate = (data['lastTestDate'] as Timestamp).toDate();
        final now = DateTime.now();
        final difference = now.difference(lastTestDate).inDays;

        return difference >= 3;
      }
    }

    return true;
  }

  void _showTestLimitExceededDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0)), // Rounded corners
          title: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red), // Adding an icon
              SizedBox(width: 10), // Space between icon and text
              Expanded(child: Text('Test Limit Exceeded')),
            ],
          ),
          content: Text(
            'You can only take the test once every 3 days.',
            style:
                TextStyle(height: 1.5), // Line spacing for better readability
          ),
          actions: [
            TextButton(
              child: Text(
                'OK',
                style: TextStyle(
                    color:
                        Colors.deepPurple), // Custom color for the button text
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
