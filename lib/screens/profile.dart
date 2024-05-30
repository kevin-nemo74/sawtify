import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sawtify/screens/animations/change_screen_animation.dart';
import 'package:sawtify/screens/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;

  const ProfileScreen({required this.userId});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with TickerProviderStateMixin {
  String _userName = '';
  String _userEmail = '';
  final _auth = FirebaseAuth.instance;



  @override
  void initState() {
     super.initState();
    _fetchUserData();

  
  }


  

  Future<void> _fetchUserData() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();
      print('Fetched user data: ${userDoc.data()}'); // Debug print statement
      if (userDoc.exists) {
        setState(() {
          _userName = userDoc['name'] ?? 'No Name'; // Use 'No Name' if the field is null
          _userEmail = userDoc['email'] ?? 'No Email'; // Use 'No Email' if the field is null
        });
      } else {
        print('User document does not exist');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  


  @override
  Widget build(BuildContext context) {
  
    return Scaffold(
    /* appBar: AppBar(
        title: Text('Logout'), 
      ),*/
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          ClipPath(
            clipper: TopCircularClipper(),
            child: Container(
              height: 250,
              color: const Color.fromRGBO(142, 174, 241, 1), 
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 155, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Animate(
                        effects: [const FadeEffect(), const ScaleEffect()],
                        child: const CircleAvatar(
                          radius: 50,
                          backgroundImage: AssetImage('assets/Backgrounds/Avata.gif'),
                        ),
                      ),
                      Positioned(
                        bottom: 1,
                        right: -3,
                        child: IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Column(
                  children: [
                    Animate(
                      effects: [const FadeEffect(), const SlideEffect()],
                      child: Text(
                        _userName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Animate(
                      effects: [const FadeEffect(), const SlideEffect()],
                      child: Text(
                        _userEmail,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                  child: ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text('Settings'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                  child: ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('Logout'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                         onTap: () async {
                      await _auth.signOut();
                      await ChangeScreenAnimation.reset(vsync: this, createAccountItems: 3, loginItems: 3);
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                    },
                

      
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TopCircularClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 50);
    path.quadraticBezierTo(size.width / 2, size.height, size.width, size.height - 50);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
