import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/widgets/custom_scaffold.dart';
import '/theme/theme.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formSignupKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String _selectedRole = 'patient'; // Default role is 'patient'
  String? _selectedDoctor; // Selected doctor
  List<String> _doctorsList = []; // List of doctors

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

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'doctor').get();
    setState(() {
      _doctorsList = querySnapshot.docs.map((doc) => doc['name'] as String).toList();
    });
  }

  Future<void> signUpWithFirebase() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        Map<String, dynamic> userData = {
          'email': _emailController.text,
          'name': _nameController.text,
          'phone': _phoneController.text,
          'role': _selectedRole,
          'doctor': _selectedRole == 'patient' ? _selectedDoctor : '',
          'workDays': _selectedRole == 'doctor' ? _workDays : {},
          'startTime': _selectedRole == 'doctor' ? _startTime?.format(context) ?? '' : '',
          'endTime': _selectedRole == 'doctor' ? _endTime?.format(context) ?? '' : '',
        };

        await FirebaseFirestore.instance.collection('users').doc(user.uid).set(userData);

        checkUserTypeAndRedirect(user);
      }
    } catch (e) {
      String errorMessage = 'Failed to sign up. Please check your details.';
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'email-already-in-use':
            errorMessage = 'The email address is already in use.';
            break;
          case 'invalid-email':
            errorMessage = 'The email address is badly formatted.';
            break;
          default:
            errorMessage = 'An error occurred while signing up. Please try again later.';
            break;
        }
      }
      print("Error signing up: $errorMessage");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
        ),
      );
    }
  }

  void checkUserTypeAndRedirect(User user) {
    String userId = user.uid;

    FirebaseFirestore.instance.collection('users').doc(userId).get().then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
        String role = data['role'];
        if (role == 'doctor') {
          Navigator.pushReplacementNamed(context, '/doctorHome');
        } else if (role == 'patient') {
          Navigator.pushReplacementNamed(context, '/patientHome');
        }
      }
    }).catchError((error) {
      print('Error getting document: $error');
    });
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

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        children: [
          Expanded(flex: 1, child: SizedBox(height: 10)),
          Expanded(
            flex: 7,
            child: Container(
              padding: const EdgeInsets.fromLTRB(25.0, 50.0, 25.0, 20.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: _formSignupKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: 30.0,
                          fontWeight: FontWeight.w900,
                          color: lightColorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 40.0),
                      TextFormField(
                        controller: _emailController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Email';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          label: const Text('Email'),
                          hintText: 'Enter Email',
                          hintStyle: const TextStyle(color: Colors.black26),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25.0),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        obscuringCharacter: '*',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Password';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          label: const Text('Password'),
                          hintText: 'Enter Password',
                          hintStyle: const TextStyle(color: Colors.black26),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25.0),
                      TextFormField(
                        controller: _nameController,
                        obscureText: false,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          label: const Text('Name'),
                          hintText: 'Enter Name',
                          hintStyle: const TextStyle(color: Colors.black26),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25.0),
                      TextFormField(
                        controller: _phoneController,
                        obscureText: false,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your phone number';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          label: const Text('Phone Number'),
                          hintText: 'Enter Phone Number',
                          hintStyle: const TextStyle(color: Colors.black26),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25.0),
                      Column(
                        children: [
                          RadioListTile<String>(
                            title: const Text('Patient'),
                            value: 'patient',
                            groupValue: _selectedRole,
                            onChanged: (String? value) {
                              setState(() {
                                _selectedRole = value!;
                              });
                            },
                          ),
                          RadioListTile<String>(
                            title: const Text('Doctor'),
                            value: 'doctor',
                            groupValue: _selectedRole,
                            onChanged: (String? value) {
                              setState(() {
                                _selectedRole = value!;
                              });
                            },
                          ),
                        ],
                      ),
                      if (_selectedRole == 'patient') ...[
                        const SizedBox(height: 25.0),
                        DropdownButtonFormField<String>(
                          value: _selectedDoctor,
                          items: _doctorsList.map((String doctor) {
                            return DropdownMenuItem<String>(
                              value: doctor,
                              child: Text(doctor),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedDoctor = newValue;
                            });
                          },
                          decoration: InputDecoration(
                            label: const Text('Select Doctor'),
                            hintText: 'Choose your doctor',
                            border: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.black12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.black12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select a doctor';
                            }
                            return null;
                          },
                        ),
                      ],
                      if (_selectedRole == 'doctor') ...[
                        const SizedBox(height: 25.0),
                        Text('Select Working Days:'),
                        Column(
                          children: _workDays.keys.map((String key) {
                            return CheckboxListTile(
                              title: Text(key),
                              value: _workDays[key],
                              onChanged: (bool? value) {
                                setState(() {
                                  _workDays[key] = value!;
                                });
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
                      ],
                      const SizedBox(height: 25.0),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formSignupKey.currentState!.validate()) {
                              signUpWithFirebase();
                            } else {
                              print("Form validation failed");
                            }
                          },
                          child: const Text('Sign Up'),
                        ),
                      ),
                      const SizedBox(height: 25.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Already have an account? ',
                            style: TextStyle(color: Colors.black45),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, '/signin');
                            },
                            child: Text(
                              'Sign In',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: lightColorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
