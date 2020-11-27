import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class Counter extends AnimatedWidget {
  Counter({Key key, this.animation, this.textStyle}) : super(key: key, listenable: animation);
  final Animation<int> animation;
  final TextStyle textStyle;

  @override
  build(BuildContext context) {
    return new Text(
      animation.value >= 0 ? new NumberFormat.decimalPattern(Platform.localeName).format(animation.value) : "N/A",
      style: textStyle,
    );
  }
}