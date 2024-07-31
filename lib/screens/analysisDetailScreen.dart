import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../models/medicalAnalysis.dart';
import 'analysis_graph_screen.dart';

class AnalysisDetailScreen extends StatefulWidget {
  final MedicalAnalysis analysis;

  AnalysisDetailScreen({required this.analysis});

  @override
  _AnalysisDetailScreenState createState() => _AnalysisDetailScreenState();
}

class _AnalysisDetailScreenState extends State<AnalysisDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _valueController = TextEditingController();
  DateTime? _selectedDate;
  String? _patientName;
  List<Map<String, dynamic>> _analysisHistory = [];

  @override
  void initState() {
    super.initState();
    _loadPatientNameAndHistory();
  }

  Future<void> _loadPatientNameAndHistory() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      String patientName = userDoc['name'];
      setState(() {
        _patientName = patientName;
      });
      List<Map<String, dynamic>> history = await MedicalAnalysis.getAnalysisHistory(widget.analysis.name, patientName);
      setState(() {
        _analysisHistory = history;
      });
    }
  }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _addAnalysisEntry() async {
  if (_formKey.currentState!.validate() && _selectedDate != null && _patientName != null) {
    final value = double.parse(_valueController.text);
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('analysis').add({
        'name_patient': user.email,
        'analysis_name': widget.analysis.name,
        'value': value.toString(),
        'date': DateFormat('yyyy-MM-dd').format(_selectedDate!),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Medical test entry added successfully!')),
      );
      _loadAnalysisHistory(); // Reload history after adding new entry
      _valueController.clear();
      setState(() {
        _selectedDate = null;
      });
    }
  }
}


  Future<void> _loadAnalysisHistory() async {
    if (_patientName != null) {
      List<Map<String, dynamic>> history = await MedicalAnalysis.getAnalysisHistory(widget.analysis.name, _patientName!);
      setState(() {
        _analysisHistory = history;
      });
    }
  }

  void _navigateToGraphScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnalysisGraphScreen(
          analysis: widget.analysis,
          analysisHistory: _analysisHistory,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.analysis.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.analysis.description),
              SizedBox(height: 16.0),
              Text('Normal range: ${widget.analysis.minValue}-${widget.analysis.maxValue} ${widget.analysis.unit}'),
              SizedBox(height: 16.0),
              Text('Your medical tests history:'),
              SizedBox(height: 8.0),
              Container(
                height: 200, // Adjust height as needed
                child: ListView.builder(
                  itemCount: _analysisHistory.length,
                  itemBuilder: (context, index) {
                    final entry = _analysisHistory[index];
                    final double value = double.parse(entry['value']);
                    final isNormal = widget.analysis.isWithinNormalRange(value);
                    return ListTile(
                      title: Row(
                        children: [
                          Text('Value: ${entry['value']} ${widget.analysis.unit}'),
                          SizedBox(width: 8.0),
                          Icon(
                            isNormal ? Icons.check_circle : Icons.cancel,
                            color: isNormal ? Colors.green : Colors.red,
                          ),
                        ],
                      ),
                      subtitle: Text('Date: ${entry['date']}'),
                    );
                  },
                ),
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _valueController,
                decoration: InputDecoration(
                  labelText: 'Enter value (${widget.analysis.unit})',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a value';
                  }
                  final doubleValue = double.tryParse(value);
                  if (doubleValue == null) {
                    return 'Please enter a valid number';
                  }
                  return null; // Allow any value
                },
              ),
              SizedBox(height: 16.0),
              Row(
                children: [
                  Text(
                    _selectedDate == null
                        ? 'No date chosen!'
                        : 'Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate!)}',
                  ),
                  Spacer(),
                  ElevatedButton(
                    onPressed: () => _selectDate(context),
                    child: Text('Choose Date'),
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              Center(
                child: ElevatedButton(
                  onPressed: _addAnalysisEntry,
                  child: Text('Save'),
                ),
              ),
              SizedBox(height: 16.0),
              Center(
                child: ElevatedButton(
                  onPressed: _navigateToGraphScreen,
                  child: Text('View Evolution'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
