import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'change_schedule_screen.dart'; // Importăm ecranele corect
import 'change_day_schedule_screen.dart';
import 'homepageDoctor.dart';
import 'calendar_screen.dart';
import 'send_documents_screen.dart';
import 'see_patients_screen.dart';
import 'welcome_screen.dart';

class AppDrawerDoctor extends StatelessWidget {
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
                MaterialPageRoute(builder: (context) => HomePageDoctor()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.calendar_today),
            title: Text('See Calendar'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => CalendarScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.send),
            title: Text('Send Documents'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => SendDocumentsScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.people),
            title: Text('See Patients'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => SeePatientsScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.schedule),
            title: Text('Change General Schedule'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ChangeScheduleScreen()),
              );
            },
          ),
          
          Divider(),
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
