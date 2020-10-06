import 'package:covid19stats/main.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings {
  bool defaultDailyView = false;
  bool alwaysLoadCharts = false;
  bool loaded = false;

  Settings({this.alwaysLoadCharts, this.defaultDailyView, this.loaded});

  Future<void> load() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    this.alwaysLoadCharts = prefs.getBool('alwaysLoadCharts') ?? false;
    this.defaultDailyView = prefs.getBool('defaultDailyView') ?? false;
    this.loaded = true;
  }

  Future<bool> save() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('alwaysLoadCharts', this.alwaysLoadCharts);
    prefs.setBool('defaultDailyView', this.defaultDailyView);
    return true;
  }

  Settings clone() {
    return new Settings(
      alwaysLoadCharts: this.alwaysLoadCharts,
      defaultDailyView: this.defaultDailyView,
      loaded: true
    );
  }

  dynamic operator [](String key) {
    switch(key) {
      case 'alwaysLoadCharts': return this.alwaysLoadCharts;
      case 'defaultDailyView': return this.defaultDailyView;
    }
  }
}

class SettingsDialog extends StatefulWidget {
  SettingsDialog(this.settings, {Key key}) : super(key: key);
  final Settings settings;

  @override
  _SettingsDialogState createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  Settings newSettings;

  @override
  void initState() {
    super.initState();
    newSettings = widget.settings.clone();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Settings"),
      content: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.min,
        children: [
          getSwitchRow("Always load charts", newSettings.alwaysLoadCharts, (v){newSettings.alwaysLoadCharts = v;}),
          getSwitchRow("Default to daily view", newSettings.defaultDailyView, (v){newSettings.defaultDailyView = v;}),
        ],
      ),
      actions: <Widget>[
        FlatButton(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        FlatButton(
          color: Colors.red,
          child: Text('Save'),
          onPressed: () async {
            newSettings.save();
            Navigator.of(context).pop(newSettings);
          },
        ),
      ],
    );
  }

  Row getSwitchRow(String text, bool value, Function setValue) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(text),
        Switch(
          value: value,
          onChanged: (newValue) {
            setState(() {setValue(newValue);});
          },
          activeTrackColor: Colors.red[300],
          activeColor: Colors.red,
        ),
      ],
    );
  }
}