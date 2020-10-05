import 'dart:io';
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'chartsData.dart';

String generateYLabel(double value) {
  var label;
  if(value >= 100000000)
    label = (value.toInt() / 1000000).toStringAsFixed(0) + "M";
  else if(value >= 10000000)
    label = (value.toInt() / 1000000).toStringAsFixed(1) + "M";
  else if(value >= 1000000)
    label = (value.toInt() / 1000000).toStringAsFixed(2) + "M";
  else if (value >= 100000)
    label = (value.toInt() / 1000).toStringAsFixed(0) + "K";
  else if (value >= 10000)
    label = (value.toInt() / 1000).toStringAsFixed(1) + "K";
  else if (value >= 1000)
    label = (value.toInt() / 1000).toStringAsFixed(2) + "K";
  else
    label = value.toInt().toString();
  return label;
}

LineChartData totalData(ChartData data, DateTimeRange selectedDateRange) {
  var xLabels = data.labels;
  var values = data.values;
  int start = 0;
  int end = values.length - 1;

  if(selectedDateRange != null && data.available) {
    DateFormat dateFormat = DateFormat('MMM dd');
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

  FlLine gridLine = FlLine(
    color: Color(0xff37434d),
    strokeWidth: 1,
  );

  FlLine nullLine = FlLine(
    color: Colors.transparent,
    strokeWidth: 0,
  );

  return LineChartData(
    lineTouchData: LineTouchData(
      touchTooltipData: LineTouchTooltipData(
        getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
          return touchedBarSpots.map((barSpot) {
            if (barSpot.x < start || barSpot.x > end) return null;
            return LineTooltipItem(
                new NumberFormat.decimalPattern(Platform.localeName).format(barSpot.y.toInt()),
                TextStyle(
                    color: data.gradientColors[1],
                    fontWeight: FontWeight.bold,
                    fontSize: 14
                )
            );
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
        textStyle: TextStyle(color: const Color(0xff68737d), fontWeight: FontWeight.bold, fontSize: 12),
        getTitles: (value) {
          return xLabels[value.toInt()];
        },
        margin: 8,
      ),
      leftTitles: SideTitles(
        interval: vInterval,
        showTitles: true,
        textStyle: TextStyle(
          color: const Color(0xff67727d),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        getTitles: generateYLabel,
        reservedSize: 28,
        margin: 12,
      ),
    ),
    borderData: FlBorderData(show: true, border: Border.all(color: const Color(0xff37434d), width: 1)),
    minX: start.toDouble(),
    maxX: end.toDouble(),
    minY: 0,
    maxY: maxValue,
    lineBarsData: [
      LineChartBarData(
        spots: spots,
        isCurved: true,
        preventCurveOverShooting: true,
        colors: data.gradientColors,
        barWidth: 4,
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: false,
        ),
        belowBarData: BarAreaData(
          show: true,
          colors: data.gradientColors.map((color) => color.withOpacity(0.3)).toList(),
        ),
      ),
    ],
  );
}

LineChartData dailyData(ChartData data, DateTimeRange selectedDateRange) {
  //xLabels, List<int> values, List<Color> gradientColors) {
  var xLabels = data.labels;
  var values = data.values;
  var gradientColors = data.gradientColors;

  int start = 0;
  int end = values.length - 1;
  if(selectedDateRange != null && data.available) {
    DateFormat dateFormat = DateFormat('MMM dd');
    start = data.labels.indexOf(dateFormat.format(selectedDateRange.start));
    end = data.labels.indexOf(dateFormat.format(selectedDateRange.end));
  }

  double maxValue = 0;
  List<FlSpot> spots = [];
  for (int i = values.length - 1; i > 0; i--) {
    double val = max((values[i] - values[i - 1]).toDouble(), 0.0);
    spots.add(FlSpot(i.toDouble(), val));
    maxValue = val > maxValue && i >= start && i <= end ? val : maxValue;
  }
  if(data.available) maxValue = maxValue*0.05 + maxValue;
  spots.add(FlSpot(0.0, values[0].toDouble()));
  spots = new List.from(spots.reversed);

  double vInterval = maxValue / 4;
  double hInterval = xLabels.sublist(start, end + 1).length.toDouble() / 4;

  FlLine gridLine = FlLine(
    color: Color(0xff37434d),
    strokeWidth: 1,
  );

  FlLine nullLine = FlLine(
    color: Colors.transparent,
    strokeWidth: 0,
  );

  return LineChartData(
    lineTouchData: LineTouchData(
      touchTooltipData: LineTouchTooltipData(
        getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
          return touchedBarSpots.map((barSpot) {
            if (barSpot.x < start || barSpot.x > end) return null;
            return LineTooltipItem(
                new NumberFormat.decimalPattern(Platform.localeName).format(barSpot.y.toInt()),
                TextStyle(
                    color: data.gradientColors[1],
                    fontWeight: FontWeight.bold,
                    fontSize: 14
                )
            );
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
        textStyle: TextStyle(color: const Color(0xff68737d), fontWeight: FontWeight.bold, fontSize: 12),
        getTitles: (value) {
          return xLabels[value.toInt()];
        },
        margin: 8,
      ),
      leftTitles: SideTitles(
        interval: vInterval,
        showTitles: true,
        textStyle: TextStyle(
          color: const Color(0xff67727d),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        getTitles: generateYLabel,
        reservedSize: 28,
        margin: 12,
      ),
    ),
    borderData: FlBorderData(show: true, border: Border.all(color: const Color(0xff37434d), width: 1)),
    minX: start.toDouble(),
    maxX: end.toDouble(),
    minY: 0,
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