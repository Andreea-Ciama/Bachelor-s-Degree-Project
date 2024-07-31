import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'homepagePatient.dart';
import 'appointment_screen.dart';
import 'documents_screen.dart';
import 'analysis_screen.dart';
import 'welcome_screen.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Color(0xFF416FDF),
            ),
            child: Text(
              'Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          SizedBox(height: 5),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home Page'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomePagePatient()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.calendar_today),
            title: Text('Make an Appointment'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => AppointmentScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.folder),
            title: Text('Documents'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => DocumentsScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.analytics),
            title: Text('Medical tests'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => AnalysisScreen()),
              );
            },
          ),
          Divider(), // Separator vizual pentru Logout
          ListTile( 
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => WelcomeScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
