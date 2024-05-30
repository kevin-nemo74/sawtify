import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ionicons/ionicons.dart';
import 'package:sawtify/screens/entry_point.dart';
import 'package:sawtify/utils/helper_functions.dart';
import '../../../utils/constants.dart';
import '../animations/change_screen_animation.dart';
import 'bottom_text.dart';
import 'top_text.dart';

enum Screens {
  createAccount,
  welcomeBack,
}

class LoginContent extends StatefulWidget {
  const LoginContent({super.key});

  @override
  State<LoginContent> createState() => _LoginContentState();
}

class _LoginContentState extends State<LoginContent> with TickerProviderStateMixin {
  late final List<Widget> createAccountContent;
  late final List<Widget> loginContent;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String name = '';
  String email = '';
  String password = '';

  Widget inputField(String hint, IconData iconData, bool isPassword) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 8),
      child: SizedBox(
        height: 50,
        child: Material(
          elevation: 8,
          shadowColor: Colors.black87,
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          child: TextField(
            onChanged: (value) {
              if (hint == 'Email') {
                email = value;
              } else if (hint == 'Password') {
                password = value;
              } else if (hint == 'Name') {
                name = value;
              }
            },
            obscureText: isPassword,
            textAlignVertical: TextAlignVertical.bottom,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
              hintText: hint,
              prefixIcon: Icon(iconData),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> signUp() async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user?.uid).set({
        'name': name,
        'email': email,
        'password': password,

      });
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => BottomNavigationBarWidget()),
      );
    } on FirebaseAuthException catch (e) {
      print(e.message);
    }
  }

  Future<void> signIn() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
          await _updatePasswordInFirestore(email);

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => BottomNavigationBarWidget()),
      );
    } on FirebaseAuthException catch (e) {
      print(e.message);
    }
  }
  Future<void> resetPassword() async {
  try {
    await _auth.sendPasswordResetEmail(email: email);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Password Reset"),
          content: Text("Password reset link has been sent to your email."),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  } catch (e) {
    print("Error sending password reset email: $e");
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Error"),
          content: Text("Failed to send password reset email."),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }
}
Future<void> _updatePasswordInFirestore(String email) async {
  try {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('users').where('email', isEqualTo: email).get();
    
    if (querySnapshot.docs.isNotEmpty) {
      DocumentSnapshot userDoc = querySnapshot.docs.first;
      await userDoc.reference.update({
        'password': password, 
      });
      print('Password updated in Firestore for user: $email');
    } else {
      print('No user found with email: $email');
    }
  } catch (e) {
    print('Error updating password in Firestore: $e');
  }
}


  Widget loginButton(String title, bool isSignUp) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 4),
      child: ElevatedButton(
        onPressed: () {
          if (isSignUp) {
            signUp();
          } else {
            signIn();
          }
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: const StadiumBorder(),
          elevation: 8,
          shadowColor: Colors.black87,
          
        ),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget forgotPassword() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 110),
   child: TextButton(
      onPressed: resetPassword,
      child: const Text(
        'Forgot Password?',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: kSecondaryColor,
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    createAccountContent = [
      inputField('Name', Ionicons.person_outline, false),
      inputField('Email', Ionicons.mail_outline, false),
      inputField('Password', Ionicons.lock_closed_outline, true),
      loginButton('Sign Up', true),
    ];

    loginContent = [
      inputField('Email', Ionicons.mail_outline, false),
      inputField('Password', Ionicons.lock_closed_outline, true),
      loginButton('Log In', false),
      forgotPassword(),
    ];

    ChangeScreenAnimation.initialize(
      vsync: this,
      createAccountItems: createAccountContent.length,
      loginItems: loginContent.length,
    );

    for (var i = 0; i < createAccountContent.length; i++) {
      createAccountContent[i] = HelperFunctions.wrapWithAnimatedBuilder(
        animation: ChangeScreenAnimation.createAccountAnimations[i],
        child: createAccountContent[i],
      );
    }

    for (var i = 0; i < loginContent.length; i++) {
      loginContent[i] = HelperFunctions.wrapWithAnimatedBuilder(
        animation: ChangeScreenAnimation.loginAnimations[i],
        child: loginContent[i],
      );
    }

    super.initState();
  }

  @override
  void dispose() {
    ChangeScreenAnimation.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned(
          top: 136,
          left: 24,
          child: TopText(),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 100),
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: createAccountContent,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: loginContent,
              ),
            ],
          ),
        ),
        const Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.only(bottom: 50),
            child: BottomText(),
          ),
        ),
      ],
    );
  }
}