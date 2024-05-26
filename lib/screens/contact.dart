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
  Doctor(name: 'Dr. Boualleg Amira', specialization: 'Pathlogists', phoneNumber: '067-670-5062', isActive: true),
  Doctor(name: 'Dr. Guenez Mohamed', specialization: 'Pathlogists', phoneNumber: '055-554-4321', isActive: true),
    Doctor(name: 'Dr. John Doe', specialization: 'Pathlogists', phoneNumber: '055-524-4321', isActive: false),

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
              height: 400, 
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
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 25,
              backgroundImage: AssetImage('assets/Avatar/amroune.jpg'), 
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctor.name,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 118, 156, 237)),
                  ),
                  const SizedBox(height: 5),
                  Text('Specialization: ${doctor.specialization}'),
                  const SizedBox(height: 5),
                  Text('Phone: ${doctor.phoneNumber}'),
                ],
              ),
            ),
            Icon(
              doctor.isActive ? Icons.check_circle : Icons.cancel,
              color: doctor.isActive ? Colors.green : Colors.red,
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
    path.quadraticBezierTo(size.width / 2, size.height, size.width, size.height - 50);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
