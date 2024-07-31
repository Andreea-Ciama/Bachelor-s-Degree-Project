import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'app_drawer.dart';
import 'see_appointments.dart';

class AppointmentScreen extends StatefulWidget {
  @override
  _AppointmentScreenState createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  DateTime? _selectedDate;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _selectedTime;
  String? _appointmentType;
  String? _notes;
  Map<String, dynamic> _doctorWorkDays = {};
  TimeOfDay? _doctorStartTime;
  TimeOfDay? _doctorEndTime;
  List<Map<String, dynamic>> _availableTimes = [];

  @override
  void initState() {
    super.initState();
    _loadDoctorAvailability();
  }

  Future<void> _loadDoctorAvailability() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
      String doctorName = userDoc['doctor'] ?? '';

      QuerySnapshot doctorQuery = await _firestore.collection('users').where('name', isEqualTo: doctorName).get();
      if (doctorQuery.docs.isNotEmpty) {
        DocumentSnapshot doctorDoc = doctorQuery.docs.first;
        setState(() {
          _doctorWorkDays = Map<String, bool>.from(doctorDoc['workDays'] ?? {});
          _doctorStartTime = _parseTimeOfDay(doctorDoc['startTime'] ?? '12:00 AM');
          _doctorEndTime = _parseTimeOfDay(doctorDoc['endTime'] ?? '12:00 AM');
        });
      }
    }
  }

  TimeOfDay _parseTimeOfDay(String time) {
    final timeParts = time.split(' ');
    final period = timeParts.length > 1 ? timeParts[1] : 'AM';
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

  bool _isDoctorAvailable(DateTime date) {
    List<String> weekDays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    String day = weekDays[date.weekday - 1];
    return _doctorWorkDays[day] ?? false;
  }

  int toMinutes(TimeOfDay time) {
    return time.hour * 60 + time.minute;
  }

  Future<void> _getAvailableTimes() async {
    List<Map<String, dynamic>> times = [];
    if (_doctorStartTime != null && _doctorEndTime != null) {
      if (_doctorStartTime == _doctorEndTime) {
        return; // Return empty list if start time and end time are equal
      }

      int startMinutes = toMinutes(_doctorStartTime!);
      int endMinutes = toMinutes(_doctorEndTime!) - 30; // Subtract 30 minutes from end time

      for (int minutes = startMinutes; minutes <= endMinutes; minutes += 30) {
        int hour = minutes ~/ 60;
        int minute = minutes % 60;
        TimeOfDay time = TimeOfDay(hour: hour, minute: minute);
        String formattedTime = time.format(context);
        bool isAvailable = await _checkAvailability(_selectedDate!, formattedTime);
        times.add({
          'time': formattedTime,
          'isAvailable': isAvailable,
        });
      }
    }
    setState(() {
      _availableTimes = times;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Make an Appointment'),
      ),
      drawer: AppDrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TableCalendar(
                firstDay: DateTime.utc(2020, 10, 16),
                lastDay: DateTime.utc(2030, 3, 14),
                focusedDay: DateTime.now(),
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDate, day);
                },
                enabledDayPredicate: (day) {
                  return _isDoctorAvailable(day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  if (_isDoctorAvailable(selectedDay)) {
                    setState(() {
                      _selectedDate = selectedDay;
                    });
                    _getAvailableTimes();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Doctor is not available on this day.'),
                      ),
                    );
                  }
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AppointmentsScreen()),
                  );
                },
                child: Text('See your appointments'),
              ),
              if (_selectedDate != null) ...[
                SizedBox(height: 20),
                Text(
                  'Select Time',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                DropdownButton<String>(
                  hint: Text('Select Time'),
                  value: _selectedTime,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedTime = newValue;
                    });
                  },
                  items: _availableTimes.map((timeMap) {
                    return DropdownMenuItem<String>(
                      value: timeMap['time'],
                      child: Text(
                        timeMap['time'],
                        style: TextStyle(
                          color: timeMap['isAvailable'] ? Colors.black : Colors.red,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 20),
                TextField(
                  decoration: InputDecoration(labelText: 'Appointment Type'),
                  onChanged: (value) {
                    _appointmentType = value;
                  },
                ),
                SizedBox(height: 20),
                TextField(
                  decoration: InputDecoration(labelText: 'Notes'),
                  onChanged: (value) {
                    _notes = value;
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (_selectedDate != null && _selectedTime != null) {
                      bool isAvailable = await _checkAvailability(_selectedDate!, _selectedTime!);
                      if (isAvailable) {
                        _bookAppointment(_selectedDate!, _selectedTime!, _appointmentType, _notes);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Selected time is already booked. Please choose another time.'),
                          ),
                        );
                      }
                    }
                  },
                  child: Text('Book Appointment'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _checkAvailability(DateTime date, String time) async {
    Timestamp dateTimestamp = Timestamp.fromDate(DateTime(date.year, date.month, date.day));
    QuerySnapshot querySnapshot = await _firestore.collection('appointments')
        .where('date', isEqualTo: dateTimestamp)
        .where('time', isEqualTo: time)
        .get();

    return querySnapshot.docs.isEmpty;
  }

  void _bookAppointment(DateTime date, String time, String? appointmentType, String? notes) async {
    String userId = _auth.currentUser!.uid;
    Timestamp dateTimestamp = Timestamp.fromDate(DateTime(date.year, date.month, date.day));

    await _firestore.collection('appointments').add({
      'date': dateTimestamp,
      'time': time,
      'userId': userId,
      'appointmentType': appointmentType ?? '',
      'notes': notes ?? '',
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Appointment booked successfully!'),
      ),
    );
  }
}
