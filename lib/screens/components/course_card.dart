import 'package:flutter/material.dart';
import '../../../models/course.dart';

class CourseCard extends StatelessWidget {
  const CourseCard({
    Key? key,
    required this.course,
  }) : super(key: key);

  final Course course;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 10), // Adjusted margins
      padding: const EdgeInsets.all(16), // Uniform padding
      height: 270,
      width: 250,
      decoration: BoxDecoration(
        color: course.bgColor,
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 87, 86, 86).withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        
          const SizedBox(height: 12),
          Text(
            course.title,
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            course.description,
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w200,
            ),
          ),
          const Spacer(), // Pushes content to the top
   
        ],
      ),
    );
  }
}
