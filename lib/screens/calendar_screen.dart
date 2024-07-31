import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:table_calendar/table_calendar.dart';
import 'app_drawer.dart';
import 'app_drawer_doctor.dart';

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _doctorName = '';

  @override
  void initState() {
    super.initState();
    _getDoctorName();
  }

  Future<void> _getDoctorName() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      setState(() {
        _doctorName = doc['name'] ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendar'),
      ),
      drawer: AppDrawerDoctor(),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 10, 16),
            lastDay: DateTime.utc(2030, 3, 14),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
          ),
          const SizedBox(height: 8.0),
          Expanded(child: _buildAppointmentsList()),
        ],
      ),
    );
  }

  Widget _buildAppointmentsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('appointments').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        final appointments = snapshot.data!.docs;

        final filteredAppointments = appointments.where((appointment) {
          final Timestamp timestamp = appointment['date'];
          final DateTime date = timestamp.toDate();
          return _selectedDay != null && isSameDay(date, _selectedDay!);
        }).toList();

        if (filteredAppointments.isEmpty) {
          return Center(child: Text('No appointments for the selected day.'));
        }

        return ListView.builder(
          itemCount: filteredAppointments.length,
          itemBuilder: (context, index) {
            final appointment = filteredAppointments[index];
            final Timestamp timestamp = appointment['date'];
            final DateTime date = timestamp.toDate();
            final String time = appointment['time'] ?? '';
            final String patientId = appointment['userId'] ?? '';
            final String notes = appointment['notes'] ?? '';
            final String appointmentType = appointment['appointmentType'] ?? '';

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('users').doc(patientId).get(),
              builder: (context, userSnapshot) {
                if (!userSnapshot.hasData) {
                  return ListTile(title: Text('Loading...'));
                }
                final patientName = userSnapshot.data!['name'] ?? '';
                final doctorName = userSnapshot.data!['doctor'] ?? '';
                if (doctorName != _doctorName) {
                  return Container();
                }
                return ExpansionTile(
                  title: Text('$date - $time'),
                  subtitle: Text('Patient: $patientName'),
                  children: [
                    ListTile(
                      title: Text('Appointment Details'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Time: $time'),
                          Text('Patient: $patientName'),
                          Text('Appointment Type: $appointmentType'),
                          Text('Notes: $notes'),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}
