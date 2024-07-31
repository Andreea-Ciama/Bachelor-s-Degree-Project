import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:table_calendar/table_calendar.dart';
import 'app_drawer_doctor.dart';

class ChangeDayScheduleScreen extends StatefulWidget {
  @override
  _ChangeDayScheduleScreenState createState() => _ChangeDayScheduleScreenState();
}

class _ChangeDayScheduleScreenState extends State<ChangeDayScheduleScreen> {
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _hasAppointments = false;

  Future<void> _selectTime(BuildContext context, {required bool isStartTime}) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _startTime ?? TimeOfDay.now() : _endTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  Future<void> _checkAppointments(DateTime date) async {
    User? user = _auth.currentUser;
    if (user != null) {
      // Obține detaliile utilizatorului curent
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
      String doctorName = userDoc['name'];

      // Verifică dacă există programări pentru data selectată și numele doctorului
      QuerySnapshot appointments = await _firestore.collection('appointments')
          .where('date', isEqualTo: Timestamp.fromDate(date))
          .where('doctor', isEqualTo: doctorName)
          .get();

      setState(() {
        _hasAppointments = appointments.docs.isNotEmpty;
      });
    }
  }

  Future<void> _updateDaySchedule() async {
    if (_selectedDate != null && _startTime != null && _endTime != null) {
      User? user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).collection('specialSchedules').doc(_selectedDate!.toIso8601String()).set({
          'date': _selectedDate,
          'startTime': _startTime?.format(context) ?? '',
          'endTime': _endTime?.format(context) ?? '',
          'isCancelled': false,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Day schedule updated successfully!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Change a Day Schedule'),
      ),
      drawer: AppDrawerDoctor(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Select a day to update:'),
            TableCalendar(
              firstDay: DateTime.utc(2020, 10, 16),
              lastDay: DateTime.utc(2030, 3, 14),
              focusedDay: DateTime.now(),
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDate, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDate = selectedDay;
                });
                _checkAppointments(selectedDay);
              },
            ),
            const SizedBox(height: 25.0),
            if (_selectedDate != null) ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _selectTime(context, isStartTime: true),
                      child: Text(_startTime != null ? _startTime!.format(context) : 'Start Time'),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _selectTime(context, isStartTime: false),
                      child: Text(_endTime != null ? _endTime!.format(context) : 'End Time'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25.0),
              ElevatedButton(
                onPressed: _updateDaySchedule,
                child: const Text('Update Day Schedule'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
