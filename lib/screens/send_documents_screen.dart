import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class SendDocumentsScreen extends StatefulWidget {
  @override
  _SendDocumentsScreenState createState() => _SendDocumentsScreenState();
}

class _SendDocumentsScreenState extends State<SendDocumentsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  File? _file;
  String? _selectedPatientId;
  List<DocumentSnapshot> _patients = [];
  String _doctorName = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _getDoctorName();
  }

  Future<void> _getDoctorName() async {
    setState(() {
      _isLoading = true;
    });
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
      setState(() {
        _doctorName = userDoc['name'] ?? '';
      });
      await _loadPatients();
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadPatients() async {
    QuerySnapshot querySnapshot = await _firestore.collection('users')
        .where('role', isEqualTo: 'patient')
        .where('doctor', isEqualTo: _doctorName)
        .get();
    setState(() {
      _patients = querySnapshot.docs;
    });
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result != null) {
      setState(() {
        _file = File(result.files.single.path!);
      });
    }
  }

  Future<void> _uploadFile() async {
    if (_file == null || _selectedPatientId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a file and a patient.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    String fileName = _file!.path.split('/').last;
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        UploadTask uploadTask = FirebaseStorage.instance
            .ref('documents/${user.uid}/$fileName')
            .putFile(_file!);

        TaskSnapshot taskSnapshot = await uploadTask;
        String downloadURL = await taskSnapshot.ref.getDownloadURL();

        await _firestore.collection('documents').add({
          'patientId': _selectedPatientId,
          'doctorId': user.uid,
          'fileName': fileName,
          'fileURL': downloadURL,
          'uploadDate': Timestamp.now(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Document uploaded successfully!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload document: $e')),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Send Documents'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    hint: Text('Select Patient'),
                    value: _selectedPatientId,
                    onChanged: (value) {
                      setState(() {
                        _selectedPatientId = value;
                      });
                    },
                    items: _patients.map((patient) {
                      return DropdownMenuItem<String>(
                        value: patient.id,
                        child: Text(patient['name']),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _pickFile,
                    child: Text('Upload PDF'),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _uploadFile,
                    child: Text('Send PDF'),
                  ),
                ],
              ),
            ),
    );
  }
}
