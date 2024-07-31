import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'analysis_screen.dart';
import 'app_drawer.dart';
import 'appointment_screen.dart';
import 'documents_screen.dart';

class HomePagePatient extends StatefulWidget {
  @override
  _HomePagePatientState createState() => _HomePagePatientState();
}

class _HomePagePatientState extends State<HomePagePatient> {
  @override
  void initState() {
    super.initState();
    saveFcmToken();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Handle foreground messages
      print('Received message: ${message.notification?.title}, ${message.notification?.body}');
    });
  }

  Future<void> saveFcmToken() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String? token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'fcmToken': token,
        });
      }
    }
  }

  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp();
    print('Handling a background message: ${message.messageId}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome'),
      ),
      drawer: AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 40), // Add space at the top
            Expanded(
              child: ListView(
                children: [
                  _buildOptionCard(
                    context,
                    title: 'Make an Appointment',
                    icon: Icons.calendar_today,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AppointmentScreen()),
                    ),
                  ),
                  _buildOptionCard(
                    context,
                    title: 'Documents',
                    icon: Icons.folder,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DocumentsScreen()),
                    ),
                  ),
                  _buildOptionCard(
                    context,
                    title: 'Medical tests',
                    icon: Icons.analytics,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AnalysisScreen()),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 40), // Add more space at the bottom
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard(BuildContext context, {required String title, required IconData icon, required VoidCallback onTap}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: Icon(icon, size: 40.0),
        title: Text(title, style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
        trailing: Icon(Icons.arrow_forward),
        onTap: onTap,
      ),
    );
  }
}
