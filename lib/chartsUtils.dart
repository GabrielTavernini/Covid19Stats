import 'dart:io';
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'chartsData.dart';

List<String> months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
DateTimeRange getChartRange(ChartsData data) {
  int firstDay = int.parse(data.total.labels.first.split(" ")[1].split(",")[0]);
  int firstMonth = months.indexOf(data.total.labels.first.split(" ")[0]) + 1;
  int firstYear = int.parse(data.total.labels.first.split(",")[1]);
  DateTime firstDate = new DateTime(firstYear, firstMonth, firstDay);

  int lastDay = int.parse(data.total.labels.last.split(" ")[1].split(",")[0]);
  int lastMonth = months.indexOf(data.total.labels.last.split(" ")[0]) + 1;
  int lastYear = int.parse(data.total.labels.last.split(",")[1]);
  DateTime lastDate = new DateTime(lastYear, lastMonth, lastDay);

  return new DateTimeRange(start: firstDate, end: lastDate);
}

String generateYLabel(double value) {
  var label = value < 0 ? "-" : "";
  var offset = value < 0 ? 1 : 0;
  value *= value < 0 ? -1 : 1;

  if (value >= 100000000)
    label += (value.toInt() / 1000000).toStringAsFixed(0 - offset) + "M";
  else if (value >= 10000000)
    label += (value.toInt() / 1000000).toStringAsFixed(1 - offset) + "M";
  else if (value >= 1000000)
    label += (value.toInt() / 1000000).toStringAsFixed(2 - offset) + "M";
  else if (value >= 100000)
    label += (value.toInt() / 1000).toStringAsFixed(0 - offset) + "K";
  else if (value >= 10000)
    label += (value.toInt() / 1000).toStringAsFixed(1 - offset) + "K";
  else if (value >= 1000)
    label += (value.toInt() / 1000).toStringAsFixed(2 - offset) + "K";
  else
    label += value.toInt().toString();
  return label;
}

LineChartData totalData(ChartData data, DateTimeRange selectedDateRange) {
  var xLabels = data.labels;
  var values = data.values;
  int start = 0;
  int end = values.length - 1;

  if (selectedDateRange != null && data.available) {
    DateFormat dateFormat = DateFormat('MMM dd, yyyy');
    start = data.labels.indexOf(dateFormat.format(selectedDateRange.start));
    end = data.labels.indexOf(dateFormat.format(selectedDateRange.end));
  }

  double maxValue = values.sublist(start, end + 1).reduce(max).toDouble();
  double vInterval = maxValue / 4;
  double hInterval = xLabels.sublist(start, end + 1).length.toDouble() / 4;

  List<FlSpot> spots = [];
  for (int i = 0; i < values.length; i++) {
    spots.add(FlSpot(i.toDouble(), values[i].toDouble()));
  }

  return generateLineChart(start, end, xLabels, spots, 0, maxValue, vInterval, hInterval, data.gradientColors);
}

LineChartData dailyData(ChartData data, DateTimeRange selectedDateRange) {
  var xLabels = data.labels;
  var values = data.values;

  int start = 0;
  int end = values.length - 1;
  if (selectedDateRange != null && data.available) {
    DateFormat dateFormat = DateFormat('MMM dd, yyyy');
    start = data.labels.indexOf(dateFormat.format(selectedDateRange.start));
    end = data.labels.indexOf(dateFormat.format(selectedDateRange.end));
  }

  double maxValue = 0;
  double minValue = 0;
  List<FlSpot> spots = [];
  for (int i = values.length - 1; i > 0; i--) {
    double val = (values[i] - values[i - 1]).toDouble();
    spots.add(FlSpot(i.toDouble(), val));
    maxValue = val > maxValue && i >= start && i <= end ? val : maxValue;
    minValue = val < minValue && i >= start && i <= end ? val : minValue;
  }
  if (data.available) maxValue = maxValue * 0.05 + maxValue;
  spots.add(FlSpot(0.0, values[0].toDouble()));
  spots = new List.from(spots.reversed);

  double vInterval = (maxValue - minValue) / 4;
  double hInterval = xLabels.sublist(start, end + 1).length.toDouble() / 4;

  return generateLineChart(start, end, xLabels, spots, minValue, maxValue, vInterval, hInterval, data.gradientColors);
}

LineChartData generateLineChart(int start, int end, List<String> labels, List<FlSpot> spots, double minValue,
    double maxValue, double vInterval, double hInterval, List<Color> gradientColors) {
  FlLine gridLine = FlLine(
    color: Color(0xff37434d),
    strokeWidth: 1,
  );

  return LineChartData(
    lineTouchData: LineTouchData(
      touchTooltipData: LineTouchTooltipData(
        getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
          return touchedBarSpots.map((barSpot) {
            if (barSpot.x < start || barSpot.x > end) return null;
            return LineTooltipItem(new NumberFormat.decimalPattern(Platform.localeName).format(barSpot.y.toInt()),
                TextStyle(color: gradientColors[1], fontWeight: FontWeight.bold, fontSize: 14));
          }).toList();
        },
      ),
    ),
    clipData: FlClipData.horizontal(),
    gridData: FlGridData(
      show: true,
      horizontalInterval: vInterval,
      verticalInterval: hInterval,
      drawVerticalLine: true,
      getDrawingHorizontalLine: (value) {
        return gridLine;
      },
      getDrawingVerticalLine: (value) {
        return gridLine;
      },
    ),
    titlesData: FlTitlesData(
      show: true,
      bottomTitles: SideTitles(
        interval: hInterval,
        showTitles: true,
        reservedSize: 22,
        getTextStyles: (value) {
          return TextStyle(
            color: Color(0xff67727d),
            fontWeight: FontWeight.bold,
            fontSize: 12,
          );
        },
        getTitles: (value) {
          return labels[value.toInt()].split(",")[0];
        },
        margin: 8,
      ),
      leftTitles: SideTitles(
        interval: vInterval,
        showTitles: true,
        getTextStyles: (value) {
          return TextStyle(
            color: Color(0xff67727d),
            fontWeight: FontWeight.bold,
            fontSize: 12,
          );
        },
        getTitles: generateYLabel,
        reservedSize: 28,
        margin: 12,
      ),
    ),
    borderData: FlBorderData(show: true, border: Border.all(color: Color(0xff37434d), width: 1)),
    minX: start.toDouble(),
    maxX: end.toDouble(),
    minY: minValue,
    maxY: maxValue,
    lineBarsData: [
      LineChartBarData(
        spots: spots,
        isCurved: true,
        preventCurveOverShooting: true,
        colors: gradientColors,
        barWidth: 4,
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: false,
        ),
        belowBarData: BarAreaData(
          show: true,
          colors: gradientColors.map((color) => color.withOpacity(0.3)).toList(),
        ),
      ),
    ],
  );
}
