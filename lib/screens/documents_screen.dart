import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'app_drawer.dart';

class DocumentsScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _downloadFile(String url, String fileName) async {
  try {
    final ref = FirebaseStorage.instance.refFromURL(url);
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$fileName';
    
    // Descarcă fișierul într-un obiect de tip File
    final file = File(filePath);
    await ref.writeToFile(file);

    // Verifică dacă fișierul a fost descărcat cu succes
    if (await file.exists()) {
      // Deschide fișierul descărcat
      OpenFile.open(filePath);
    } else {
      print('Failed to download file: File does not exist');
    }
  } catch (e) {
    print('Failed to download file: $e');
  }
}


  Future<String> _getDoctorEmail(String doctorId) async {
    try {
      DocumentSnapshot doctorDoc = await _firestore.collection('users').doc(doctorId).get();
      if (doctorDoc.exists) {
        return doctorDoc['email'] ?? 'Email not available';
      } else {
        return 'Doctor email not found';
      }
    } catch (e) {
      print('Error fetching doctor email: $e');
      return 'Error fetching doctor email';
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: Text('Documents'),
      ),
      drawer: AppDrawer(),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('documents')
            .where('patientId', isEqualTo: user?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final documents = snapshot.data!.docs;
          if (documents.isEmpty) {
            return FutureBuilder<String>(
              future: _getDoctorEmail(user!.uid), // Assuming doctorId is the same as userId
              builder: (context, doctorSnapshot) {
                if (!doctorSnapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('No documents received.'),
                      SizedBox(height: 20),
                      Text('Request document from your doctor:'),
                      SizedBox(height: 10),
                      Text('Send an email to: ${doctorSnapshot.data}'),
                    ],
                  ),
                );
              },
            );
          }
          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (context, index) {
              final doc = documents[index];
              return ListTile(
                title: Text(doc['fileName']),
                subtitle: Text('Uploaded on: ${doc['uploadDate'].toDate().toLocal().toString().split(' ')[0]}'),
                trailing: IconButton(
                  icon: Icon(Icons.download),
                  onPressed: () {
                    _downloadFile(doc['fileURL'], doc['fileName']);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
