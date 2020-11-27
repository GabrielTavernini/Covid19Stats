import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings {
  bool defaultDailyView = false;
  bool alwaysLoadCharts = false;
  int rangeSetting = 2;
  bool loaded = false;

  Settings({this.alwaysLoadCharts, this.defaultDailyView, this.rangeSetting, this.loaded});

  Future<void> load() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    this.alwaysLoadCharts = prefs.getBool('alwaysLoadCharts') ?? false;
    this.defaultDailyView = prefs.getBool('defaultDailyView') ?? false;
    this.rangeSetting = prefs.getInt('rangeSetting') ?? 2;
    this.loaded = true;
  }

  Future<bool> save() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('alwaysLoadCharts', this.alwaysLoadCharts);
    prefs.setBool('defaultDailyView', this.defaultDailyView);
    prefs.setInt('rangeSetting', this.rangeSetting);
    return true;
  }

  Settings clone() {
    return new Settings(alwaysLoadCharts: this.alwaysLoadCharts, defaultDailyView: this.defaultDailyView, rangeSetting: this.rangeSetting, loaded: true);
  }

  dynamic operator [](String key) {
    switch (key) {
      case 'alwaysLoadCharts':
        return this.alwaysLoadCharts;
      case 'defaultDailyView':
        return this.defaultDailyView;
      case 'rangeSetting':
        return this.rangeSetting;
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text("Default range")),
              Expanded(
                child: DropdownButtonFormField(
                  dropdownColor: Color(0xff232d37),
                  decoration: InputDecoration(border: InputBorder.none),
                  value: newSettings.rangeSetting,
                  items: [
                    DropdownMenuItem(child: Text("Last 7 days"), value: 0),
                    DropdownMenuItem(child: Text("Last 28 days"), value: 1),
                    DropdownMenuItem(child: Text("Everything"), value: 2)
                  ],
                  onChanged: (value){
                    setState(() {
                      newSettings.rangeSetting = value;
                    });
                  },
                ),
              ),
            ],
          ),
          getSwitchRow("Always load charts", newSettings.alwaysLoadCharts, (v) {
            newSettings.alwaysLoadCharts = v;
          }),
          getSwitchRow("Default to daily view", newSettings.defaultDailyView, (v) {
            newSettings.defaultDailyView = v;
          }),
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
            setState(() {
              setValue(newValue);
            });
          },
          activeTrackColor: Colors.red[300],
          activeColor: Colors.red,
        ),
      ],
    );
  }
}
