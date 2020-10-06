import 'package:flutter/material.dart';

List<Color> gradientColorsTotal = [
  Colors.grey[600],
  Colors.grey[800],
];
List<Color> gradientColorsRecovered = [
  Colors.lightGreen,
  Colors.green[800],
];
List<Color> gradientColorsDeaths = [
  Colors.orange[800],
  Colors.red,
];

class ChartsData {
  ChartData total = new ChartData.empty(gradientColorsTotal);
  ChartData recovered = new ChartData.empty(gradientColorsRecovered);
  ChartData deaths = new ChartData.empty(gradientColorsDeaths);

  ChartsData({bool daily = false}) {
    total.daily = recovered.daily = deaths.daily = daily;
  }
}

class ChartData {
  bool daily = false;
  bool available = false;
  List<String> labels = ["0", "1"];
  List<int> values = [0, 1];
  List<Color> gradientColors;

  ChartData(this.labels, this.values, this.gradientColors, {this.daily = false, this.available = true});

  ChartData.empty(this.gradientColors, {this.daily = false});
}
