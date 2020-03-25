import 'package:flutter/material.dart';

class Parser {
  static List parseRow(List<String> row, bool hasInnerTag, String link) {
    int offset = hasInnerTag ? 0 : -2;
    return [
      parseInteger(row[5 + offset]),
      parseInteger(row[7 + offset]),
      parseInteger(row[9 + offset]),
      parseInteger(row[11 + offset]),
      parseInteger(row[13 + offset]),
      parseInteger(row[15 + offset]),
      parseInteger(row[17 + offset]),
      parseDouble(row[19 + offset]),
      link
    ];
  }

  static int parseInteger(String s) {
    try {
      return int.parse(s.split("<")[0].replaceAll(",", "").replaceAll("+", ""));
    } catch (e) {
      return 0;
    }
  }

  static double parseDouble(String s) {
    try {
      return double.parse(s.split("<")[0].replaceAll(",", "").replaceAll("+", ""));
    } catch (e) {
      return 0;
    }
  }

  static String getInnerString(String source, String a, String b) {
    return source.split(a)[1].split(b)[0];
  }

  static String normalizeName(String n) {
    return n.replaceAll("&ccedil;", "ç").replaceAll("&eacute;", "é").split("<")[0];
  }

  static Map<String, List> getCountryData(String body) {
    Map<String, List> countryData = {};
    var row = body.split("<tr class=\"total_row\">")[1].split("</tr>")[0].split(">");

    countryData["Global"] = parseRow(row, true, "");

    var tbody = getInnerString(body, "<tbody>", "</tbody>");
    var rows = tbody.split("<tr style=\"\">");
    rows.skip(1).forEach((rawRow) {
      row = rawRow.split(">");
      bool hasInnerTag = rawRow.contains("</a>") || rawRow.contains("</span>");
      countryData[normalizeName(row[hasInnerTag ? 2 : 1])] =
          parseRow(row, hasInnerTag, rawRow.contains("</a>") ? getInnerString(rawRow, "href=\"", "\"") : null);
    });
    return countryData;
  }

  static List<String> getCategories(String s) {
    return s.split("categories: [")[1].split("]")[0].replaceAll("\"", "").split(",");
  }

  static List<int> getDataPoints(String s) {
    return s.split("data: [")[1].split("]")[0].split(",").map(int.parse).toList();
  }

  static List<Color> gradientColorsTotal = [
    Colors.grey[600],
    Colors.grey[800],
  ];
  static List<Color> gradientColorsRecovered = [
    Colors.lightGreen,
    Colors.green[800],
  ];
  static List<Color> gradientColorsDeaths = [
    Colors.orange[800],
    Colors.red,
  ];

  static List getChartsData(String body) {
    var textToParse = body.split("text: 'Total Cases'")[1];
    var xLabels = getCategories(textToParse);
    var values = getDataPoints(textToParse);

    textToParse = body.split("text: '(Number of Infected People)")[1];
    var xLabels2 = getCategories(textToParse);
    var values2 = getDataPoints(textToParse);

    textToParse = body.split("text: 'Total Deaths'")[1];
    var xLabels3 = getCategories(textToParse);
    var values3 = getDataPoints(textToParse);

    values2.asMap().forEach((index, value) {
      values2[index] = values[index] - values3[index] - value;
    });

    return [
      [xLabels, values, gradientColorsTotal],
      [xLabels2, values2, gradientColorsRecovered],
      [xLabels3, values3, gradientColorsDeaths],
    ];
  }

  static List getEmptyChart() {
    return [
      [
        ["0", "1"],
        [0, 1],
        gradientColorsTotal
      ],
      [
        ["0", "1"],
        [0, 1],
        gradientColorsRecovered
      ],
      [
        ["0", "1"],
        [0, 1],
        gradientColorsDeaths
      ],
      false,
      false,
      false
    ];
  }
}
