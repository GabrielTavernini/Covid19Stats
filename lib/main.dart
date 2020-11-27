import 'package:covid19stats/chartsData.dart';
import 'package:covid19stats/counter.dart';
import 'package:covid19stats/countryData.dart';
import 'package:covid19stats/selectCountry.dart';
import 'package:covid19stats/parser.dart';
import 'package:covid19stats/settingsDialog.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'dart:math';
import 'chartsUtils.dart';
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
  Map<String, CountryData> countryData = {"Global": new CountryData()};
  Map<String, ChartsData> chartsData = {};
  String country = "Global";

  int springAnimationDuration = 750;
  AnimationController _controller;

  ThemeData datePickerTheme = ThemeData(
      brightness: Brightness.dark,
      accentColor: Colors.red,
      dialogBackgroundColor: Color(0xff232d37),
      colorScheme: ColorScheme.dark(primary: Colors.red, surface: Colors.red));
  DateTimeRange selectedDateRange;
  Settings settings = new Settings();

  @override
  initState() {
    _controller = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    chartsData["Global"] = new ChartsData();
    settings.load();

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _triggerLiquidPullRefresh();
    });
  }

  void _triggerLiquidPullRefresh() {
    (_refreshIndicatorKey.currentState as dynamic)?.show();
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

        var data = Parser.getChartsData(response.body, settings.defaultDailyView);
        checkRangeSetting();
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
        title: Text(country, textAlign: TextAlign.center),
        leading: Theme(
          data: datePickerTheme,
          child: Builder(
            builder: (context) => IconButton(
                icon: Icon(Icons.calendar_today),
                color: Colors.white,
                onPressed: () {
                  showDateDialog(context);
                }),
          ),
        ),
        actions: <Widget>[
          Theme(
            data: datePickerTheme,
            child: Builder(
              builder: (context) => IconButton(
                  icon: Icon(Icons.settings),
                  color: Colors.white,
                  onPressed: () {
                    showSettingsDialog(context);
                  }),
            ),
          ),
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
            if (countryData[country].totalTests > 0) ...[
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
                    begin: min(countryData[country].totalCases, 0), //prevTotalCases,
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
                    begin: min(countryData[country].casesPerMln.toInt(), 0), //prevTotalCases,
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
                    begin: min(countryData[country].newCases, 0), //prevTotalCases,
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
                  'Active Cases:',
                  style: TextStyle(color: Colors.green, fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Counter(
                  textStyle: TextStyle(color: Colors.green, fontSize: 22, fontWeight: FontWeight.bold),
                  animation: new StepTween(
                    begin: min(countryData[country].activeCases, 0), //prevRecoveredCases,
                    end: countryData[country].activeCases,
                  ).animate(_controller),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Recovered:',
                  style: TextStyle(color: Colors.green, fontSize: 18),
                ),
                Counter(
                  textStyle: TextStyle(color: Colors.green, fontSize: 18),
                  animation: new StepTween(
                    begin: min(countryData[country].totalRecovered, 0), //prevTotalCases,
                    end: countryData[country].totalRecovered,
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
                    begin: min(countryData[country].totalDeaths, 0), //prevDeathCases,
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
                    begin: min(countryData[country].deathsPerMln.toInt(), 0), //prevTotalCases,
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
                    begin: min(countryData[country].criticalCases, 0), //prevTotalCases,
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
                    begin: min(countryData[country].newDeaths, 0), //prevTotalCases,
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
                        chartsData[country] = new ChartsData(daily: settings.defaultDailyView);
                      });
                      _triggerLiquidPullRefresh();
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
        if (!settings.alwaysLoadCharts)
          _controller.forward(from: 0.0);
        else if (chartsData[country] == null) {
          chartsData[country] = new ChartsData(daily: settings.defaultDailyView);
          _triggerLiquidPullRefresh();
        }
      });
    }
  }

  Future<void> showDateDialog(context) async {
    if (chartsData[country] != null && chartsData[country].total.available) {
      int firstDay = int.parse(chartsData[country].total.labels.first.split(" ")[1]);
      int firstMonth = months.indexOf(chartsData[country].total.labels.first.split(" ")[0]) + 1;
      DateTime firstDate = new DateTime(2020, firstMonth, firstDay);

      int lastDay = int.parse(chartsData[country].total.labels.last.split(" ")[1]);
      int lastMonth = months.indexOf(chartsData[country].total.labels.last.split(" ")[0]) + 1;
      DateTime lastDate = new DateTime(2020, lastMonth, lastDay);

      selectedDateRange = await showDialog(
              context: context,
              builder: (BuildContext context) {
                return new DateRangeDialog(DateTimeRange(start: firstDate, end: lastDate),
                    selectedDateRange ?? DateTimeRange(start: firstDate, end: lastDate));
              }) ??
          selectedDateRange;
      setState(() {});
    } else {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Row(
          children: [Icon(Icons.info_outline), SizedBox(width: 15), Text("Charts data is not yet available!")],
        ),
        elevation: 6.0,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  Future<void> showSettingsDialog(context) async {
    if (settings.loaded) {
      int prevRange = settings.rangeSetting;
      settings = await showDialog(
              context: context,
              builder: (BuildContext context) {
                return new SettingsDialog(settings);
              }) ?? settings;

      setState(() {
        if(prevRange != settings.rangeSetting)
          checkRangeSetting();
      });
    } else {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Row(
          children: [Icon(Icons.info_outline), SizedBox(width: 15), Text("Settings are still loading!")],
        ),
        elevation: 6.0,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  void checkRangeSetting() {
    if (chartsData[country] != null && chartsData[country].total.available) {
      int firstDay = int.parse(chartsData[country].total.labels.first.split(" ")[1]);
      int firstMonth = months.indexOf(chartsData[country].total.labels.first.split(" ")[0]) + 1;
      DateTime firstDate = new DateTime(2020, firstMonth, firstDay);

      int lastDay = int.parse(chartsData[country].total.labels.last.split(" ")[1]);
      int lastMonth = months.indexOf(chartsData[country].total.labels.last.split(" ")[0]) + 1;
      DateTime lastDate = new DateTime(2020, lastMonth, lastDay);

      switch(settings.rangeSetting) {
        case 0:
          selectedDateRange = DateTimeRange(
              start: lastDate.subtract(Duration(days: 7)),
              end: lastDate
          );
          break;
        case 1:
          selectedDateRange = DateTimeRange(
              start: lastDate.subtract(Duration(days: 28)),
              end: lastDate
          );
          break;
        case 2:
          selectedDateRange = null;
          break;
      }
    }
  }

  Widget createGraph(ChartData chartData) {
    if (selectedDateRange != null && selectedDateRange.start.compareTo(selectedDateRange.end) >= 0)
      chartData = new ChartData.empty(chartData.gradientColors, daily: settings.defaultDailyView);
    var lineChartData = chartData.daily ? dailyData(chartData, selectedDateRange) : totalData(chartData, selectedDateRange);

    return Stack(
      children: <Widget>[
        AspectRatio(
          aspectRatio: 1.70,
          child: Container(
            child: Padding(
                padding: const EdgeInsets.only(right: 18.0, left: 12.0, top: 24, bottom: 12),
                child: new LineChart(lineChartData,
                    swapAnimationDuration: Duration(seconds: chartData.available ? 1 : 0))),
          ),
        ),
        Positioned.fill(
          child: Visibility(
            visible: !chartData.available,
            child: Align(
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
}
