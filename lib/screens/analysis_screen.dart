import 'package:flutter/material.dart';
import '../models/medicalAnalysis.dart';
import 'analysisDetailScreen.dart';
import 'app_drawer.dart';

class AnalysisScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Medical tests'),
      ),
      drawer: AppDrawer(), // Use the reusable drawer here
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: analyses.length,
          itemBuilder: (context, index) {
            final analysis = analyses[index];
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              elevation: 5,
              child: ListTile(
                leading: Icon(
                  Icons.analytics,
                  color: Colors.blue,
                  size: 40,
                ),
                title: Text(
                  analysis.name,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  analysis.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Icon(Icons.arrow_forward),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AnalysisDetailScreen(analysis: analysis),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
