import 'package:flutter/material.dart';

class Course {
  final String title, description;
  final Color bgColor;

  Course({
    required this.title,
    this.description = "Your Gateway to Clear Communication",
    this.bgColor = const  Color(0xFF8EAEF1),

  });
}

List<Course> courses = [
  Course(title: "Test Your Pronunciation Health with Sawtify"),
  Course(
    title: "Evaluate Your Pronunciation Skills with Sawtfy",
    bgColor:const Color(0xFF8EAEF1).withOpacity(0.5),

  ),
];

