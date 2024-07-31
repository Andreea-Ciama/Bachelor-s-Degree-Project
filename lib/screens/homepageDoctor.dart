import 'package:flutter/material.dart';
import 'app_drawer_doctor.dart';
import 'calendar_screen.dart';
import 'see_patients_screen.dart';
import 'send_documents_screen.dart';
import 'change_schedule_screen.dart';
//import 'change_day_schedule_screen.dart'; // Importăm ecranul ChangeDayScheduleScreen

class HomePageDoctor extends StatefulWidget {
  @override
  _HomePageDoctorState createState() => _HomePageDoctorState();
}

class _HomePageDoctorState extends State<HomePageDoctor> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Doctor Home'),
      ),
      drawer: AppDrawerDoctor(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  _buildOptionCard(
                    context,
                    title: 'See Calendar',
                    icon: Icons.calendar_today,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CalendarScreen()),
                    ),
                  ),
                  _buildOptionCard(
                    context,
                    title: 'Send Documents',
                    icon: Icons.send,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SendDocumentsScreen()),
                    ),
                  ),
                  _buildOptionCard(
                    context,
                    title: 'See Patients',
                    icon: Icons.people,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SeePatientsScreen()),
                    ),
                  ),
                  _buildOptionCard(
                    context,
                    title: 'Change General Schedule',
                    icon: Icons.schedule,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ChangeScheduleScreen()),
                    ),
                  ),
                ],
              ),
            ),
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
