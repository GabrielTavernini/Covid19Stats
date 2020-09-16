import 'dart:io';
import 'package:covid19stats/chartsData.dart';
import 'package:covid19stats/counter.dart';
import 'package:covid19stats/countryData.dart';
import 'package:covid19stats/selectCountry.dart';
import 'package:covid19stats/parser.dart';
import 'package:intl/intl.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:math';

import 'dateRangeDialog.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Covid19 Stats',
      theme: ThemeData(primarySwatch: Colors.red),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  List<String> months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
  final GlobalKey _refreshIndicatorKey = GlobalKey();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  Map<String, CountryData> countryData = {
    "Global": new CountryData()
  };
  Map<String, ChartsData> chartsData = {};
  String country = "Global";

  int springAnimationDuration = 750;
  AnimationController _controller;

  ThemeData datePickerTheme = ThemeData(
    brightness: Brightness.dark,
    accentColor: Colors.red,
    dialogBackgroundColor: Color(0xff232d37),
    colorScheme: ColorScheme.dark(primary: Colors.red, surface: Colors.red)
  );
  DateTimeRange selectedDateRange;

  @override
  initState() {
    _controller = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    chartsData["Global"] = new ChartsData();

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      (_refreshIndicatorKey.currentState as dynamic)?.show();
    });
  }

  Future<void> refreshData() async {
    String localCountry = country.toString();
    var url = 'https://www.worldometers.info/coronavirus/';
    var response = await http.get(url);
    if (response.statusCode == 200) {
      countryData = Parser.getCountryData(response.body);

      setState(() {
        _controller.forward(from: 0.0);
      });

      if (chartsData[localCountry] != null) {
        if (localCountry != "Global") {
          url += countryData[localCountry].link;
          response = await http.get(url);
          if (response.statusCode != 200) return;
        }

        var data = Parser.getChartsData(response.body);
        setState(() {
          chartsData[localCountry] = data;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Color(0xff232d37),
      appBar: AppBar(
        title: Text("Covid19 Stats - " + country),
        leading: Theme(
          data: datePickerTheme,
          child: Builder(
            builder: (context) => IconButton(icon: Icon(Icons.calendar_today), color: Colors.white, onPressed: () async {
              showDateDialog(context);
            }),
          ),
        ),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.settings), color: Colors.white, onPressed: (){
            _scaffoldKey.currentState.showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.info_outline),
                    SizedBox(width: 15),
                    Text("Settings coming in the next updates!")
                  ],
                ),
                elevation: 6.0,
                behavior: SnackBarBehavior.floating,
              )
            );
          },),
        ],
      ),
      body: LiquidPullToRefresh(
        springAnimationDurationInMilliseconds: springAnimationDuration,
        key: _refreshIndicatorKey,
        showChildOpacityTransition: false,
        onRefresh: refreshData,
        child: ListView(
          padding: new EdgeInsets.symmetric(horizontal: 20),
          shrinkWrap: true,
          children: <Widget>[
            SizedBox(height: 20),
            if(countryData[country].totalTests != 0) ...[
              Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Total Tests:',
                  style: TextStyle(color: Colors.blue[200], fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Counter(
                  textStyle: TextStyle(color: Colors.blue[200], fontSize: 22, fontWeight: FontWeight.bold),
                  animation: new StepTween(
                    begin: 0, //prevTotalCases,
                    end: countryData[country].totalTests,
                  ).animate(_controller),
                ),
              ],
            ),
              Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Tests per Mln:',
                  style: TextStyle(color: Colors.blue[200], fontSize: 18),
                ),
                Counter(
                  textStyle: TextStyle(color: Colors.blue[200], fontSize: 18),
                  animation: new StepTween(
                    begin: 0, //prevTotalCases,
                    end: countryData[country].testsPerMln,
                  ).animate(_controller),
                ),
              ],
            ),
              SizedBox(height: 30)
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Total Cases:',
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Counter(
                  textStyle: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  animation: new StepTween(
                    begin: 0, //prevTotalCases,
                    end: countryData[country].totalCases,
                  ).animate(_controller),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Cases per Mln:',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                Counter(
                  textStyle: TextStyle(color: Colors.white, fontSize: 18),
                  animation: new StepTween(
                    begin: 0, //prevTotalCases,
                    end: countryData[country].casesPerMln.toInt(),
                  ).animate(_controller),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'New Cases:',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                Counter(
                  textStyle: TextStyle(color: Colors.white, fontSize: 18),
                  animation: new StepTween(
                    begin: 0, //prevTotalCases,
                    end: countryData[country].newCases,
                  ).animate(_controller),
                ),
              ],
            ),
            chartsData[country] != null ? createGraph(chartsData[country].total) : SizedBox(),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Total Recovered:',
                  style: TextStyle(color: Colors.green, fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Counter(
                  textStyle: TextStyle(color: Colors.green, fontSize: 22, fontWeight: FontWeight.bold),
                  animation: new StepTween(
                    begin: 0, //prevRecoveredCases,
                    end: countryData[country].totalRecovered,
                  ).animate(_controller),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Active Cases:',
                  style: TextStyle(color: Colors.green, fontSize: 18),
                ),
                Counter(
                  textStyle: TextStyle(color: Colors.green, fontSize: 18),
                  animation: new StepTween(
                    begin: 0, //prevTotalCases,
                    end: countryData[country].activeCases,
                  ).animate(_controller),
                ),
              ],
            ),
            chartsData[country] != null ? createGraph(chartsData[country].recovered) : SizedBox(),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Total Deaths:',
                  style: TextStyle(color: Colors.red, fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Counter(
                  textStyle: TextStyle(color: Colors.red, fontSize: 22, fontWeight: FontWeight.bold),
                  animation: new StepTween(
                    begin: 0, //prevDeathCases,
                    end: countryData[country].totalDeaths,
                  ).animate(_controller),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Deaths per Mln:',
                  style: TextStyle(color: Colors.red, fontSize: 18),
                ),
                Counter(
                  textStyle: TextStyle(color: Colors.red, fontSize: 18),
                  animation: new StepTween(
                    begin: 0, //prevTotalCases,
                    end: countryData[country].deathsPerMln.toInt(),
                  ).animate(_controller),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Critical Cases:',
                  style: TextStyle(color: Colors.red, fontSize: 18),
                ),
                Counter(
                  textStyle: TextStyle(color: Colors.red, fontSize: 18),
                  animation: new StepTween(
                    begin: 0, //prevTotalCases,
                    end: countryData[country].criticalCases,
                  ).animate(_controller),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'New Deaths:',
                  style: TextStyle(color: Colors.red, fontSize: 18),
                ),
                Counter(
                  textStyle: TextStyle(color: Colors.red, fontSize: 18),
                  animation: new StepTween(
                    begin: 0, //prevTotalCases,
                    end: countryData[country].newDeaths,
                  ).animate(_controller),
                ),
              ],
            ),
            chartsData[country] != null ? createGraph(chartsData[country].deaths) : SizedBox(),
            SizedBox(height: 50),
            chartsData[country] == null && countryData[country].link != null
                ? FlatButton(
                    child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(4)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text("Load Charts", style: TextStyle(color: Color(0xff232d37), fontSize: 18)),
                          ],
                        )),
                    onPressed: () {
                      setState(() {
                        chartsData[country] = new ChartsData();
                      });
                      (_refreshIndicatorKey.currentState as dynamic)?.show();
                    },
                  )
                : SizedBox(),
          ],
        ),
      ),
      floatingActionButton: AnimatedOpacity(
        opacity: countryData.length > 1 ? 1.0 : 0.0,
        duration: Duration(milliseconds: 500),
        child: FloatingActionButton(
          onPressed: () {
            navigateToSelection(context);
          },
          tooltip: 'Select Country',
          child: Icon(Icons.public),
        ),
      ),
    );
  }

  navigateToSelection(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => SelectionScreen(
                countries: countryData.keys.toList(),
                selectedCountry: country,
              )),
    );

    if (result != null) {
      setState(() {
        country = result;
        _controller.forward(from: 0.0);
      });
    }
  }

  Future<void> showDateDialog(context) async {
    if(chartsData[country] != null && chartsData[country].total.available) {
      int firstDay = int.parse(chartsData[country].total.labels.first.split(" ")[1]);
      int firstMonth = months.indexOf(chartsData[country].total.labels.first.split(" ")[0]) + 1;
      DateTime firstDate = new DateTime(2020, firstMonth, firstDay);

      int lastDay = int.parse(chartsData[country].total.labels.last.split(" ")[1]);
      int lastMonth = months.indexOf(chartsData[country].total.labels.last.split(" ")[0]) + 1;
      DateTime lastDate = new DateTime(2020, lastMonth, lastDay);

      selectedDateRange = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return new DateRangeDialog(
                DateTimeRange(start: firstDate, end: lastDate),
                selectedDateRange ?? DateTimeRange(start: firstDate, end: lastDate)
            );
          }
      ) ?? selectedDateRange;
      setState(() {});
    } else {
      _scaffoldKey.currentState.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.info_outline),
                SizedBox(width: 15),
                Text("Charts data is not yet available!")
              ],
            ),
            elevation: 6.0,
            behavior: SnackBarBehavior.floating,
          )
      );
    }
  }

  Widget createGraph(ChartData chartData) {
    if(selectedDateRange != null && selectedDateRange.start.compareTo(selectedDateRange.end) == 1)
      chartData = new ChartData.empty(chartData.gradientColors);
    var lineChartData = chartData.daily ? dailyData(chartData) : totalData(chartData);

    return Stack(
      children: <Widget>[
        AspectRatio(
          aspectRatio: 1.70,
          child: Container(
            child: Padding(
                padding: const EdgeInsets.only(right: 18.0, left: 12.0, top: 24, bottom: 12),
                child: new LineChart(lineChartData, swapAnimationDuration: Duration(seconds: 1))),
          ),
        ),
        Positioned.fill(
          child: Visibility(
            visible: !chartData.available,
            child: Align (
              alignment: Alignment.center,
              child: Container(
                margin: EdgeInsets.fromLTRB(40, 0, 0, 16),
                child: Text(
                  "Data Not Available",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: Align(
            alignment: Alignment.bottomRight,
            child: Container(
              margin: EdgeInsets.fromLTRB(0, 0, 4, 32),
              child: FlatButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onPressed: () {
                  setState(() {
                    chartData.daily = !chartData.daily;
                  });
                },
                child: Wrap(
                  children: <Widget>[
                    Icon(Icons.autorenew, color: Colors.white, size: 12),
                    Text(
                      chartData.daily ? ' Daily' : ' Total',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  LineChartData totalData(ChartData data) {
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
                barSpot.x.toString(),
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
          getTitles: (value) {
            var label;
            if(value >= 100000000)
              label = (value.toInt() / 1000000).toStringAsFixed(0) + "M";
            else if(value >= 10000000)
              label = (value.toInt() / 1000000).toStringAsFixed(1) + "M";
            else if(value >= 1000000)
              label = (value.toInt() / 1000000).toStringAsFixed(2) + "M";
            else if (value >= 1000)
              label = (value.toInt() ~/ 1000).toString() + "K";
            else
              label = value.toInt().toString();
            return label;
          },
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

  LineChartData dailyData(ChartData data) {
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
      maxValue = val > maxValue && i >= start && i < end ? val : maxValue;
    }
    maxValue = maxValue*0.05 + maxValue;
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
                barSpot.x.toString(),
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
          getTitles: (value) {
            var label;
            if (value >= 1000)
              label = (value.toInt() ~/ 1000).toString() + "K";
            else
              label = value.toInt().toString();
            return label;
          },
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
}