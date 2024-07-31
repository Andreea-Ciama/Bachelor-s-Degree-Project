import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'app_drawer.dart';

class AppointmentsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Appointments'),
      ),
      drawer: AppDrawer(),
      body: AppointmentsList(),
    );
  }
}


class AppointmentsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('appointments').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        List<QueryDocumentSnapshot> appointments = snapshot.data!.docs;
        return ListView.builder(
          itemCount: appointments.length,
          itemBuilder: (context, index) {
            // Extrageți datele fiecărei programări din snapshot
            Timestamp dateTimestamp = appointments[index]['date'];
            String date = dateTimestamp.toDate().toString();
            String time = appointments[index]['time'];
            String appointmentType = appointments[index]['appointmentType'].toString();
            String notes = appointments[index]['notes'].toString();
            String appointmentId = appointments[index].id; // ID-ul documentului pentru ștergere
            // Afișați datele într-un element de listă
            return ListTile(
              title: Text('$date - $time'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Type: $appointmentType'),
                  Text('Notes: $notes'),
                ],
              ),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  _deleteAppointment(context, appointmentId);
                },
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _deleteAppointment(BuildContext context, String appointmentId) async {
    try {
      await FirebaseFirestore.instance.collection('appointments').doc(appointmentId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Appointment deleted successfully!'),
        ),
      );
    } catch (e) {
      print('Error deleting appointment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete appointment. Please try again later.'),
        ),
      );
    }
  }
}
