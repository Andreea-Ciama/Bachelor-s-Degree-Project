import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'app_drawer_doctor.dart';
import 'patient_details_screen.dart'; // Importă fișierul corect

class SeePatientsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('See Patients'),
      ),
      drawer: AppDrawerDoctor(),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'patient').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final patients = snapshot.data!.docs;
          return ListView.builder(
            itemCount: patients.length,
            itemBuilder: (context, index) {
              final patient = patients[index];
              return ListTile(
                title: Text(patient['name']),
                subtitle: Text(patient['email']),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PatientDetailsScreen(patientId: patient.id),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
