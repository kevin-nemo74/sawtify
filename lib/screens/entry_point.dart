import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sawtify/screens/profile.dart';
//import 'package:sawtify/screens/time.dart';
import 'package:sawtify/screens/home.dart';
//import 'package:sawtify/screens/test.dart';
import 'package:line_icons/line_icons.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

import 'contact.dart';

class BottomNavigationBarWidget extends StatefulWidget {
  const BottomNavigationBarWidget({super.key});

  @override
  State<BottomNavigationBarWidget> createState() =>
      _BottomNavigationBarWidgetState();
}

class _BottomNavigationBarWidgetState extends State<BottomNavigationBarWidget> {
  int selectedIndex = 0;
  User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      Home(),
      Contact(),
      if (user != null) ProfileScreen(userId: user!.uid),
    ];
    return Scaffold(
        body: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          child: _pages[selectedIndex],
        ),
        bottomNavigationBar: Padding(
            padding:
                const EdgeInsets.fromLTRB(16, 0, 16, 16), // Add margin bottom
            child: ClipRRect(
              borderRadius:
                  BorderRadius.circular(60.0), // Adjust this value as needed
              child: Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 142, 174, 241),
                  boxShadow: [
                    BoxShadow(
                      spreadRadius: -10,
                      blurRadius: 60,
                      color: Colors.black.withOpacity(.20),
                      offset: Offset(0, 15),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 12.0), // Decreased padding
                  child: GNav(
                    gap: 8,
                    color: const Color.fromARGB(255, 249, 248, 248),
                    activeColor: Color.fromARGB(255, 255, 255, 255),
                    tabBorderRadius: 20,
                    iconSize: 20,
                    // Decreased icon size
                    tabBackgroundColor:
                        Color.fromARGB(255, 249, 249, 249).withOpacity(0.1),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    // Decreased padding
                    duration: Duration(milliseconds: 1000),
                    tabs: [
                      GButton(
                        icon: LineIcons.home,
                        text: 'Home',
                      ),
                      GButton(
                        icon: LineIcons.phone,
                        text: 'Contact',
                      ),
                      GButton(
                        icon: LineIcons.userCircle,
                        text: 'Profile',
                      ),
                    ],
                    selectedIndex: selectedIndex,
                    onTabChange: (index) {
                      setState(() {
                        selectedIndex = index;
                      });
                    },
                  ),
                ),
              ),
            )));
  }
}
