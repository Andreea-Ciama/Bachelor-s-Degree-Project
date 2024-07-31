import 'package:cloud_firestore/cloud_firestore.dart';

class MedicalAnalysis {
  final String name;
  final String description;
  final String unit;
  final double minValue;
  final double maxValue;

  MedicalAnalysis({
    required this.name,
    required this.description,
    required this.unit,
    required this.minValue,
    required this.maxValue,
  });

  bool isWithinNormalRange(double value) {
    return value >= minValue && value <= maxValue;
  }

  static Future<List<Map<String, dynamic>>> getAnalysisHistory(String analysisName, String patientName) async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('analysis')
        .where('analysis_name', isEqualTo: analysisName)
        .where('name_patient', isEqualTo: patientName)
        .get();
    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  static Future<void> addAnalysisEntry(String patientName, String analysisName, double value, DateTime date) async {
    await FirebaseFirestore.instance.collection('analysis').add({
      'name_patient': patientName,
      'analysis_name': analysisName,
      'value': value.toString(),
      'date': date.toIso8601String(),
    });
  }
}

final List<MedicalAnalysis> analyses = [
  MedicalAnalysis(
    name: 'TGP',
    description: 'TGP is an enzyme that helps break down proteins and is used to diagnose liver damage.',
    unit: 'U/L',
    minValue: 7.0,
    maxValue: 56.0,
  ),
  MedicalAnalysis(
    name: 'TGO',
    description: 'TGO is an enzyme found in various tissues, including the liver and heart, and is used to diagnose liver or heart damage.',
    unit: 'U/L',
    minValue: 10.0,
    maxValue: 40.0,
  ),
  MedicalAnalysis(
    name: 'Cholesterol',
    description: 'Cholesterol is a type of fat found in your blood. Too much cholesterol can lead to heart disease.',
    unit: 'mg/dL',
    minValue: 125.0,
    maxValue: 200.0,
  ),
  MedicalAnalysis(
    name: 'Serum Creatinine',
    description: 'Creatinine is a waste product that is produced by muscles and excreted by the kidneys. It is used to assess kidney function.',
    unit: 'mg/dL',
    minValue: 0.50,
    maxValue: 1.20,
  ),
  MedicalAnalysis(
    name: 'Serum Glucose (Glycemia)',
    description: 'Serum glucose is a measure of the amount of glucose (sugar) in your blood and is used to diagnose and manage diabetes.',
    unit: 'mg/dL',
    minValue: 70.0,
    maxValue: 99.0,
  ),
  MedicalAnalysis(
    name: 'Hb',
    description: 'Hemoglobin (Hb) is a protein in red blood cells that carries oxygen throughout the body.',
    unit: 'g/dL',
    minValue: 13.8,
    maxValue: 17.2,
  ),
  MedicalAnalysis(
    name: 'Ht',
    description: 'Hematocrit (Ht) is the proportion of blood that consists of red blood cells.',
    unit: '%',
    minValue: 38.3,
    maxValue: 48.6,
  ),
  MedicalAnalysis(
    name: 'Triglycerides',
    description: 'Triglycerides are a type of fat found in your blood. High levels can increase the risk of heart disease.',
    unit: 'mg/dL',
    minValue: 0.0,
    maxValue: 150.0,
  ),
  MedicalAnalysis(
    name: 'Serum Urea',
    description: 'Serum urea is a waste product formed in the liver and carried by the blood to the kidneys for excretion.',
    unit: 'mg/dL',
    minValue: 7.0,
    maxValue: 20.0,
  ),
  MedicalAnalysis(
    name: 'VSH',
    description: 'Erythrocyte sedimentation rate (ESR) measures how quickly red blood cells settle at the bottom of a test tube, indicating inflammation.',
    unit: 'mm/hr',
    minValue: 0.0,
    maxValue: 20.0,
  ),
];
