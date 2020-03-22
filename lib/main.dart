import 'package:covid19stats/selectCountry.dart';
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
  LineChartData chartDataTotal;
  LineChartData chartDataRecovered;
  LineChartData chartDataDeaths;
  var countryData = {
    "Global" : [0, 0, 0, 0, 0, 0, 0, 0.0]
  };
  String country = "Global";

  AnimationController _controller;
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

  @override
  initState() {
    _controller = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    chartDataTotal = mainData(["0", "1"], [0, 1], gradientColorsTotal);
    chartDataRecovered = mainData(["0", "1"], [0, 1], gradientColorsRecovered);
    chartDataDeaths = mainData(["0", "1"], [0, 1], gradientColorsDeaths);

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      (_refreshIndicatorKey.currentState as dynamic)?.show();
    });
  }

  List<num> parseRow(List<String> row, {int offset = 0}) {
    return [
      parseInteger(row[5 + offset]),
      parseInteger(row[7 + offset]),
      parseInteger(row[9 + offset]),
      parseInteger(row[11 + offset]),
      parseInteger(row[13 + offset]),
      parseInteger(row[15 + offset]),
      parseInteger(row[17 + offset]),
      parseDouble(row[19 + offset])
    ];
  }

  int parseInteger(String s) {
    try {
      return int.parse(s.split("<")[0].replaceAll(",", "").replaceAll("+", ""));
    } catch (e) {
      return 0;
    }
  }

  double parseDouble(String s) {
    try {
      return double.parse(
          s.split("<")[0].replaceAll(",", "").replaceAll("+", ""));
    } catch (e) {
      return 0;
    }
  }

  String getInnerString(String source, String a, String b) {
    return source.split(a)[1].split(b)[0];
  }

  String normalizeName(String n) {
    return n.replaceAll("&ccedil;", "ç").replaceAll("&eacute;", "é");
  }

  Future<void> refreshData() async {
    var url = 'https://www.worldometers.info/coronavirus';
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var row = response.body
          .split("<tr class=\"total_row\">")[1]
          .split("</tr>")[0]
          .split(">");

      countryData["Global"] = parseRow(row);

      var tbody = getInnerString(response.body, "<tbody>", "</tbody>");
      var rows = tbody.split("<tr style=\"\">");
      rows.skip(1).forEach((rawRow) {
        row = rawRow.split(">");
        bool withLink = rawRow.contains("</a>") || rawRow.contains("</span>");
        countryData[normalizeName(row[withLink ? 2 : 1].split("<")[0])] =
            parseRow(row, offset: withLink ? 0 : -2);
      });

      setState(() {
        _controller.forward(from: 0.0);
      });

      if (country == "Global") {
        var xLabels = response.body
            .split("categories: [")[4]
            .split("]")[0]
            .replaceAll("\"", "")
            .split(",");
        var values = response.body
            .split("data: [")[4]
            .split("]")[0]
            .split(",")
            .map(int.parse)
            .toList();

        var xLabels2 = response.body
            .split("categories: [")[1]
            .split("]")[0]
            .replaceAll("\"", "")
            .split(",");
        var values2 = response.body
            .split("data: [")[1]
            .split("]")[0]
            .split(",")
            .map(int.parse)
            .toList();

        var xLabels3 = response.body
            .split("categories: [")[6]
            .split("]")[0]
            .replaceAll("\"", "")
            .split(",");
        var values3 = response.body
            .split("data: [")[6]
            .split("]")[0]
            .split(",")
            .map(int.parse)
            .toList();

        var dataTotal = mainData(xLabels, values, gradientColorsTotal);
        values2.asMap().forEach((index, value) {
          values2[index] = values[index] - values3[index] - value;
        });
        var dataRecovered = mainData(xLabels2, values2, gradientColorsRecovered);
        var dataDeaths = mainData(xLabels3, values3, gradientColorsDeaths);

        setState(() {
          chartDataTotal = dataTotal;
          chartDataRecovered = dataRecovered;
          chartDataDeaths = dataDeaths;
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
                    end:  countryData[country][0],
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
                    end: countryData[country][7].toInt(),
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
            country == "Global" ? createGraph(chartDataTotal) : SizedBox(),
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
                    end:  countryData[country][4],
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
            country == "Global" ? createGraph(chartDataRecovered) : SizedBox(),
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
                    end:  countryData[country][2],
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
            country == "Global" ? createGraph(chartDataDeaths) : SizedBox(),
            SizedBox(height: 30),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (countryData != null) navigateToSelection(context);
        },
        tooltip: 'Select Country',
        child: Icon(Icons.public),
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

  AspectRatio createGraph(LineChartData lineChartData) {
    return AspectRatio(
      aspectRatio: 1.70,
      child: Container(
        child: Padding(
            padding: const EdgeInsets.only(
                right: 18.0, left: 12.0, top: 24, bottom: 12),
            child: new LineChart(lineChartData,
                swapAnimationDuration: Duration(seconds: 1))),
      ),
    );
  }

  LineChartData mainData(
      xLabels, List<int> values, List<Color> gradientColors) {
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
          textStyle: TextStyle(
              color: const Color(0xff68737d),
              fontWeight: FontWeight.bold,
              fontSize: 12),
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
            return (value.toInt() ~/ 1000).toString() + "K";
          },
          reservedSize: 28,
          margin: 12,
        ),
      ),
      borderData: FlBorderData(
          show: true,
          border: Border.all(color: const Color(0xff37434d), width: 1)),
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
            colors:
                gradientColors.map((color) => color.withOpacity(0.3)).toList(),
          ),
        ),
      ],
    );
  }
}

class Counter extends AnimatedWidget {
  Counter({Key key, this.animation, this.textStyle})
      : super(key: key, listenable: animation);
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
