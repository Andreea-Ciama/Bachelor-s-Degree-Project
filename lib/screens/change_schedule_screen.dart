import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'app_drawer_doctor.dart';

class ChangeScheduleScreen extends StatefulWidget {
  @override
  _ChangeScheduleScreenState createState() => _ChangeScheduleScreenState();
}

class _ChangeScheduleScreenState extends State<ChangeScheduleScreen> {
  Map<String, bool> _workDays = {
    'Monday': false,
    'Tuesday': false,
    'Wednesday': false,
    'Thursday': false,
    'Friday': false,
    'Saturday': false,
    'Sunday': false,
  };
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _loadCurrentSchedule();
  }

  Future<void> _loadCurrentSchedule() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
      setState(() {
        _workDays = Map<String, bool>.from(userDoc['workDays']);
        _startTime = _parseTimeOfDay(userDoc['startTime']);
        _endTime = _parseTimeOfDay(userDoc['endTime']);
      });
    }
  }

  TimeOfDay _parseTimeOfDay(String time) {
    final timeParts = time.split(' ');
    final period = timeParts[1];
    final hourMinute = timeParts[0].split(':');
    int hour = int.parse(hourMinute[0]);
    int minute = int.parse(hourMinute[1]);

    if (period == 'PM' && hour != 12) {
      hour += 12;
    } else if (period == 'AM' && hour == 12) {
      hour = 0;
    }

    return TimeOfDay(hour: hour, minute: minute);
  }

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

  Future<void> _updateSchedule() async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'workDays': _workDays,
        'startTime': _startTime?.format(context) ?? '',
        'endTime': _endTime?.format(context) ?? '',
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Schedule updated successfully!')),
      );
    }
  }

  Future<void> _checkAndCancelDay(String day) async {
    User? user = _auth.currentUser;
    if (user != null) {
      DateTime now = DateTime.now();
      DateTime nextDate = now.add(Duration(days: (DateTime.monday - now.weekday + 7) % 7));
      while (nextDate.weekday.toString() != day) {
        nextDate = nextDate.add(Duration(days: 1));
      }
      QuerySnapshot appointments = await _firestore.collection('appointments')
          .where('date', isEqualTo: Timestamp.fromDate(nextDate))
          .where('doctorId', isEqualTo: user.uid)
          .get();

      if (appointments.docs.isEmpty) {
        setState(() {
          _workDays[day] = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cannot cancel this day as there are already scheduled appointments.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Change Schedule'),
      ),
      drawer: AppDrawerDoctor(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Select Working Days:'),
            Column(
              children: _workDays.keys.map((String key) {
                return CheckboxListTile(
                  title: Text(key),
                  value: _workDays[key],
                  onChanged: (bool? value) async {
                    if (value == false) {
                      await _checkAndCancelDay(key);
                    } else {
                      setState(() {
                        _workDays[key] = value!;
                      });
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 25.0),
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
              onPressed: _updateSchedule,
              child: const Text('Update Schedule'),
            ),
          ],
        ),
      ),
    );
  }
}
