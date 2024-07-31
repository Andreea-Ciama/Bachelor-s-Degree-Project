import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PatientDetailsScreen extends StatelessWidget {
  final String patientId;

  PatientDetailsScreen({required this.patientId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Patient Details'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(patientId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final patient = snapshot.data!;
          return Column(
            children: [
              ListTile(
                title: Text(patient['name'] ?? 'No name'),
                subtitle: Text(patient['email'] ?? 'No email'),
                trailing: Text(patient['phone'] ?? 'No phone'), // Adăugat pentru a afișa numărul de telefon
              ),
              Expanded(child: _buildAppointmentsList(patientId)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppointmentsList(String patientId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('appointments').where('userId', isEqualTo: patientId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        final appointments = snapshot.data!.docs;
        return ListView.builder(
          itemCount: appointments.length,
          itemBuilder: (context, index) {
            final appointment = appointments[index];
            final Timestamp timestamp = appointment['date'] ?? Timestamp.now();
            final DateTime date = timestamp.toDate();
            final String time = appointment['time'] ?? 'No time';
            final String notes = appointment['notes'] ?? 'No notes';
            final String appointmentType = appointment['appointmentType'] ?? 'No type';

            return ListTile(
              title: Text('$date - $time'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Type: $appointmentType'),
                  Text('Notes: $notes'),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
