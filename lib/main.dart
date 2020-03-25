import 'package:covid19stats/selectCountry.dart';
import 'package:covid19stats/parser.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as dev;
import 'dart:math';

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
  final GlobalKey _refreshIndicatorKey = GlobalKey();
  var countryData = {
    "Global": [0, 0, 0, 0, 0, 0, 0, 0.0, true]
  };
  var chartsData = {};
  String country = "Global";

  int springAnimationDuration = 750;
  AnimationController _controller;

  @override
  initState() {
    _controller = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    chartsData["Global"] = Parser.getEmptyChart();

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
          url += countryData[localCountry][8];
          response = await http.get(url);
          if (response.statusCode != 200) return;
        }

        var data = Parser.getChartsData(response.body);
        setState(() {
          chartsData[localCountry][0] = data[0];
          chartsData[localCountry][1] = data[1];
          chartsData[localCountry][2] = data[2];
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
      backgroundColor: Color(0xff232d37),
      appBar: AppBar(
        title: Text("Covid19 Stats - " + country),
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
                    end: countryData[country][0],
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
                    end: (countryData[country][7] as double).toInt(),
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
                    end: countryData[country][1],
                  ).animate(_controller),
                ),
              ],
            ),
            chartsData[country] != null ? createGraph(1) : SizedBox(),
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
                    end: countryData[country][4],
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
                    end: countryData[country][5],
                  ).animate(_controller),
                ),
              ],
            ),
            chartsData[country] != null ? createGraph(2) : SizedBox(),
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
                    end: countryData[country][2],
                  ).animate(_controller),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Serious Cases:',
                  style: TextStyle(color: Colors.red, fontSize: 18),
                ),
                Counter(
                  textStyle: TextStyle(color: Colors.red, fontSize: 18),
                  animation: new StepTween(
                    begin: 0, //prevTotalCases,
                    end: countryData[country][6],
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
                    end: countryData[country][3],
                  ).animate(_controller),
                ),
              ],
            ),
            chartsData[country] != null ? createGraph(3) : SizedBox(),
            SizedBox(height: 50),
            chartsData[country] == null && countryData[country][8] != null
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
                        chartsData[country] = Parser.getEmptyChart();
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

  Widget createGraph(int type) {
    var daily = chartsData[country][2 + type];
    var lineChartData = daily ? dailyData(chartsData[country][type - 1]) : totalData(chartsData[country][type - 1]);
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
          child: Align(
            alignment: Alignment.bottomRight,
            child: Container(
              margin: EdgeInsets.fromLTRB(0, 0, 4, 32),
              child: FlatButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onPressed: () {
                  setState(() {
                    chartsData[country][2 + type] = !chartsData[country][2 + type];
                  });
                },
                child: Wrap(
                  children: <Widget>[
                    Icon(Icons.autorenew, color: Colors.white, size: 12),
                    Text(
                      chartsData[country][2 + type] ? ' Daily' : ' Total',
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

  LineChartData totalData(List data) {
    //xLabels, List<int> values, List<Color> gradientColors) {
    var xLabels = data[0] as List<String>;
    var values = data[1] as List<int>;
    var gradientColors = data[2] as List<Color>;
    double vInterval = values.reduce(max).toDouble() / 4;
    double hInterval = xLabels.length.toDouble() / 4;

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
      gridData: FlGridData(
        show: true,
        horizontalInterval: vInterval,
        verticalInterval: 5.0,
        drawVerticalLine: true,
        getDrawingHorizontalLine: (value) {
          return gridLine;
        },
        getDrawingVerticalLine: (value) {
          if (value % hInterval < 5) return gridLine;
          return nullLine;
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
      minX: 0,
      maxX: (values.length - 1).toDouble(),
      minY: 0,
      maxY: values.reduce(max).toDouble(),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          colors: gradientColors,
          barWidth: 4,
          isStrokeCapRound: true,
          dotData: const FlDotData(
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

  LineChartData dailyData(List data) {
    //xLabels, List<int> values, List<Color> gradientColors) {
    var xLabels = data[0] as List<String>;
    var values = data[1] as List<int>;
    var gradientColors = data[2] as List<Color>;

    double maxValue = 0;
    List<FlSpot> spots = [];
    for (int i = values.length - 1; i > 0; i--) {
      double val = (values[i] - values[i - 1]).toDouble();
      spots.add(FlSpot(i.toDouble(), val));
      maxValue = val > maxValue ? val : maxValue;
    }
    spots.add(FlSpot(0.0, values[0].toDouble()));
    spots = new List.from(spots.reversed);

    double vInterval = maxValue / 4;
    double hInterval = xLabels.length.toDouble() / 4;

    FlLine gridLine = FlLine(
      color: Color(0xff37434d),
      strokeWidth: 1,
    );

    FlLine nullLine = FlLine(
      color: Colors.transparent,
      strokeWidth: 0,
    );

    return LineChartData(
      gridData: FlGridData(
        show: true,
        horizontalInterval: vInterval,
        verticalInterval: 5.0,
        drawVerticalLine: true,
        getDrawingHorizontalLine: (value) {
          return gridLine;
        },
        getDrawingVerticalLine: (value) {
          if (value % hInterval < 5) return gridLine;
          return nullLine;
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
      minX: 0,
      maxX: (values.length - 1).toDouble(),
      minY: 0,
      maxY: maxValue,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          colors: gradientColors,
          barWidth: 4,
          isStrokeCapRound: true,
          dotData: const FlDotData(
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

class Counter extends AnimatedWidget {
  Counter({Key key, this.animation, this.textStyle}) : super(key: key, listenable: animation);
  final Animation<int> animation;
  final TextStyle textStyle;

  @override
  build(BuildContext context) {
    return new Text(
      animation.value.toString(),
      style: textStyle,
    );
  }
}
