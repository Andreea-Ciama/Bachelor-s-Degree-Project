import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/medicalAnalysis.dart';

class AnalysisGraphScreen extends StatelessWidget {
  final MedicalAnalysis analysis;
  final List<Map<String, dynamic>> analysisHistory;

  AnalysisGraphScreen({required this.analysis, required this.analysisHistory});

  List<FlSpot> _createSpots() {
    List<FlSpot> spots = analysisHistory.asMap().entries.map((entry) {
      int index = entry.key;
      double value = double.parse(entry.value['value']);
      return FlSpot(index.toDouble(), value);
    }).toList();
    return spots;
  }

  List<String> _getFormattedDates() {
    return analysisHistory.map((entry) {
      DateTime date = DateTime.parse(entry['date']);
      return '${date.year}-${date.month}-${date.day}';
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    List<String> formattedDates = _getFormattedDates();

    return Scaffold(
      appBar: AppBar(
        title: Text('Evolution'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LineChart(
          LineChartData(
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: true),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    String text = '';
                    if (value.toInt() >= 0 && value.toInt() < formattedDates.length) {
                      text = formattedDates[value.toInt()];
                    }
                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      space: 10,
                      child: Text(
                        text,
                        style: const TextStyle(fontSize: 10),
                      ),
                    );
                  },
                  interval: 1,
                ),
              ),
            ),
            borderData: FlBorderData(show: true),
            lineBarsData: [
              LineChartBarData(
                spots: _createSpots(),
                isCurved: true,
                color: Colors.blue, // Correct usage
                barWidth: 4,
                isStrokeCapRound: true,
                dotData: FlDotData(show: false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
