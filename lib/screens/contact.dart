import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class Doctor {
  final String name;
  final String specialization;
  final String phoneNumber;
  final bool isActive;

  Doctor({
    required this.name,
    required this.specialization,
    required this.phoneNumber,
    required this.isActive,
  });
}

List<Doctor> doctors = [
  Doctor(name: 'Dr. Boualleg Amira', specialization: 'Pathologists', phoneNumber: '067-670-5062', isActive: true),
  Doctor(name: 'Dr. Guenez Mohamed', specialization: 'Pathologists', phoneNumber: '055-554-4321', isActive: true),
  Doctor(name: 'Dr. John Doe', specialization: 'Pathologists', phoneNumber: '055-524-4321', isActive: false),
];

class Contact extends StatelessWidget {
  const Contact({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          ClipPath(
            clipper: TopCircularClipper(),
            child: Container(
              height: 380,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/Avatar/did.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 250),
            child: AnimationLimiter(
              child: ListView.builder(
                itemCount: doctors.length,
                itemBuilder: (context, index) {
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 375),
                    child: SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(
                        child: DoctorCard(doctor: doctors[index]),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DoctorCard extends StatelessWidget {
  final Doctor doctor;

  const DoctorCard({required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: AssetImage('assets/Avatar/amroune.jpg'),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctor.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 43, 104, 236),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Specialization: ${doctor.specialization}',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Phone: ${doctor.phoneNumber}',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
            Icon(
              doctor.isActive ? Icons.check_circle : Icons.cancel,
              color: doctor.isActive ? Colors.green : Colors.red,
              size: 30,
            ),
          ],
        ),
      ),
    );
  }
}

class TopCircularClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 50);
    path.quadraticBezierTo(
        size.width / 2, size.height + 50, size.width, size.height - 50);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
