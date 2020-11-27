import 'package:flutter/material.dart';

class SelectionScreen extends StatefulWidget {
  SelectionScreen({this.countries, this.selectedCountry}) : super();
  final List countries;
  final String selectedCountry;

  @override
  _SelectionScreenState createState() => _SelectionScreenState();
}

class _SelectionScreenState extends State<SelectionScreen> {
  final scrollController = ScrollController();
  final GlobalKey key = new GlobalKey();

  var countryFlags = {
    "Diamond Princess": "🛳",
    "Ascension Island": "🇦🇨",
    "Andorra": "🇦🇩",
    "UAE": "🇦🇪",
    "Afghanistan": "🇦🇫",
    "Antigua and Barbuda": "🇦🇬",
    "Anguilla": "🇦🇮",
    "Albania": "🇦🇱",
    "Armenia": "🇦🇲",
    "Angola": "🇦🇴",
    "Antarctica": "🇦🇶",
    "Argentina": "🇦🇷",
    "American Samoa": "🇦🇸",
    "Austria": "🇦🇹",
    "Australia": "🇦🇺",
    "Aruba": "🇦🇼",
    "Åland Islands": "🇦🇽",
    "Azerbaijan": "🇦🇿",
    "Bosnia and Herzegovina": "🇧🇦",
    "Barbados": "🇧🇧",
    "Bangladesh": "🇧🇩",
    "Belgium": "🇧🇪",
    "Burkina Faso": "🇧🇫",
    "Bulgaria": "🇧🇬",
    "Bahrain": "🇧🇭",
    "Burundi": "🇧🇮",
    "Benin": "🇧🇯",
    "St. Barth": "🇧🇱",
    "Bermuda": "🇧🇲",
    "Brunei": "🇧🇳",
    "Bolivia": "🇧🇴",
    "Caribbean Netherlands": "🇧🇶",
    "Brazil": "🇧🇷",
    "Bahamas": "🇧🇸",
    "Bhutan": "🇧🇹",
    "Bouvet Island": "🇧🇻",
    "Botswana": "🇧🇼",
    "Belarus": "🇧🇾",
    "Belize": "🇧🇿",
    "Canada": "🇨🇦",
    "Cocos (Keeling) Islands": "🇨🇨",
    "DRC": "🇨🇩",
    "CAR": "🇨🇫",
    "Congo": "🇨🇬",
    "Switzerland": "🇨🇭",
    "Côte d’Ivoire": "🇨🇮",
    "Cook Islands": "🇨🇰",
    "Chile": "🇨🇱",
    "Cameroon": "🇨🇲",
    "China": "🇨🇳",
    "Colombia": "🇨🇴",
    "Clipperton Island": "🇨🇵",
    "Costa Rica": "🇨🇷",
    "Cuba": "🇨🇺",
    "Cabo Verde": "🇨🇻",
    "Curaçao": "🇨🇼",
    "Christmas Island": "🇨🇽",
    "Cyprus": "🇨🇾",
    "Czechia": "🇨🇿",
    "Germany": "🇩🇪",
    "Diego Garcia": "🇩🇬",
    "Djibouti": "🇩🇯",
    "Denmark": "🇩🇰",
    "Dominica": "🇩🇲",
    "Dominican Republic": "🇩🇴",
    "Algeria": "🇩🇿",
    "Ceuta & Melilla": "🇪🇦",
    "Ecuador": "🇪🇨",
    "Estonia": "🇪🇪",
    "Egypt": "🇪🇬",
    "Western Sahara": "🇪🇭",
    "Eritrea": "🇪🇷",
    "Spain": "🇪🇸",
    "Ethiopia": "🇪🇹",
    "European Union": "🇪🇺",
    "Finland": "🇫🇮",
    "Fiji": "🇫🇯",
    "Falkland Islands": "🇫🇰",
    "Micronesia": "🇫🇲",
    "Faeroe Islands": "🇫🇴",
    "France": "🇫🇷",
    "Gabon": "🇬🇦",
    "UK": "🇬🇧",
    "Grenada": "🇬🇩",
    "Georgia": "🇬🇪",
    "French Guiana": "🇬🇫",
    "Guernsey": "🇬🇬",
    "Ghana": "🇬🇭",
    "Gibraltar": "🇬🇮",
    "Greenland": "🇬🇱",
    "Gambia": "🇬🇲",
    "Guinea": "🇬🇳",
    "Guadeloupe": "🇬🇵",
    "Equatorial Guinea": "🇬🇶",
    "Greece": "🇬🇷",
    "South Georgia & South Sandwich Islands": "🇬🇸",
    "Guatemala": "🇬🇹",
    "Guam": "🇬🇺",
    "Guinea-Bissau": "🇬🇼",
    "Guyana": "🇬🇾",
    "Hong Kong": "🇭🇰",
    "Heard & McDonald Islands": "🇭🇲",
    "Honduras": "🇭🇳",
    "Croatia": "🇭🇷",
    "Haiti": "🇭🇹",
    "Hungary": "🇭🇺",
    "Canary Islands": "🇮🇨",
    "Indonesia": "🇮🇩",
    "Ireland": "🇮🇪",
    "Israel": "🇮🇱",
    "Isle of Man": "🇮🇲",
    "India": "🇮🇳",
    "British Indian Ocean Territory": "🇮🇴",
    "Iraq": "🇮🇶",
    "Iran": "🇮🇷",
    "Iceland": "🇮🇸",
    "Italy": "🇮🇹",
    "Jersey": "🇯🇪",
    "Jamaica": "🇯🇲",
    "Jordan": "🇯🇴",
    "Japan": "🇯🇵",
    "Kenya": "🇰🇪",
    "Kyrgyzstan": "🇰🇬",
    "Cambodia": "🇰🇭",
    "Kiribati": "🇰🇮",
    "Comoros": "🇰🇲",
    "St. Kitts & Nevis": "🇰🇳",
    "North Korea": "🇰🇵",
    "S. Korea": "🇰🇷",
    "Kuwait": "🇰🇼",
    "Cayman Islands": "🇰🇾",
    "Kazakhstan": "🇰🇿",
    "Laos": "🇱🇦",
    "Lebanon": "🇱🇧",
    "Saint Lucia": "🇱🇨",
    "Liechtenstein": "🇱🇮",
    "Sri Lanka": "🇱🇰",
    "Liberia": "🇱🇷",
    "Lesotho": "🇱🇸",
    "Lithuania": "🇱🇹",
    "Luxembourg": "🇱🇺",
    "Latvia": "🇱🇻",
    "Libya": "🇱🇾",
    "Morocco": "🇲🇦",
    "Monaco": "🇲🇨",
    "Moldova": "🇲🇩",
    "Montenegro": "🇲🇪",
    "Saint Martin": "🇲🇫",
    "Madagascar": "🇲🇬",
    "Marshall Islands": "🇲🇭",
    "North Macedonia": "🇲🇰",
    "Mali": "🇲🇱",
    "Myanmar (Burma)": "🇲🇲",
    "Mongolia": "🇲🇳",
    "Macao": "🇲🇴",
    "Northern Mariana Islands": "🇲🇵",
    "Martinique": "🇲🇶",
    "Mauritania": "🇲🇷",
    "Montserrat": "🇲🇸",
    "Malta": "🇲🇹",
    "Mauritius": "🇲🇺",
    "Maldives": "🇲🇻",
    "Malawi": "🇲🇼",
    "Mexico": "🇲🇽",
    "Malaysia": "🇲🇾",
    "Mozambique": "🇲🇿",
    "Namibia": "🇳🇦",
    "New Caledonia": "🇳🇨",
    "Niger": "🇳🇪",
    "Norfolk Island": "🇳🇫",
    "Nigeria": "🇳🇬",
    "Nicaragua": "🇳🇮",
    "Netherlands": "🇳🇱",
    "Norway": "🇳🇴",
    "Nepal": "🇳🇵",
    "Nauru": "🇳🇷",
    "Niue": "🇳🇺",
    "New Zealand": "🇳🇿",
    "Oman": "🇴🇲",
    "Panama": "🇵🇦",
    "Peru": "🇵🇪",
    "French Polynesia": "🇵🇫",
    "Papua New Guinea": "🇵🇬",
    "Philippines": "🇵🇭",
    "Pakistan": "🇵🇰",
    "Poland": "🇵🇱",
    "St. Pierre & Miquelon": "🇵🇲",
    "Pitcairn Islands": "🇵🇳",
    "Puerto Rico": "🇵🇷",
    "Palestine": "🇵🇸",
    "Portugal": "🇵🇹",
    "Palau": "🇵🇼",
    "Paraguay": "🇵🇾",
    "Qatar": "🇶🇦",
    "Réunion": "🇷🇪",
    "Romania": "🇷🇴",
    "Serbia": "🇷🇸",
    "Russia": "🇷🇺",
    "Rwanda": "🇷🇼",
    "Saudi Arabia": "🇸🇦",
    "Solomon Islands": "🇸🇧",
    "Seychelles": "🇸🇨",
    "Sudan": "🇸🇩",
    "Sweden": "🇸🇪",
    "Singapore": "🇸🇬",
    "St. Helena": "🇸🇭",
    "Slovenia": "🇸🇮",
    "Svalbard & Jan Mayen": "🇸🇯",
    "Slovakia": "🇸🇰",
    "Sierra Leone": "🇸🇱",
    "San Marino": "🇸🇲",
    "Senegal": "🇸🇳",
    "Somalia": "🇸🇴",
    "Suriname": "🇸🇷",
    "South Sudan": "🇸🇸",
    "São Tomé & Príncipe": "🇸🇹",
    "El Salvador": "🇸🇻",
    "Sint Maarten": "🇸🇽",
    "Syria": "🇸🇾",
    "Eswatini": "🇸🇿",
    "Tristan Da Cunha": "🇹🇦",
    "Turks & Caicos Islands": "🇹🇨",
    "Chad": "🇹🇩",
    "French Southern Territories": "🇹🇫",
    "Togo": "🇹🇬",
    "Thailand": "🇹🇭",
    "Tajikistan": "🇹🇯",
    "Tokelau": "🇹🇰",
    "Timor-Leste": "🇹🇱",
    "Turkmenistan": "🇹🇲",
    "Tunisia": "🇹🇳",
    "Tonga": "🇹🇴",
    "Turkey": "🇹🇷",
    "Trinidad and Tobago": "🇹🇹",
    "Tuvalu": "🇹🇻",
    "Taiwan": "🇹🇼",
    "Tanzania": "🇹🇿",
    "Ukraine": "🇺🇦",
    "Uganda": "🇺🇬",
    "U.S. Outlying Islands": "🇺🇲",
    "United Nations": "🇺🇳",
    "USA": "🇺🇸",
    "Uruguay": "🇺🇾",
    "Uzbekistan": "🇺🇿",
    "Vatican City": "🇻🇦",
    "St. Vincent Grenadines": "🇻🇨",
    "Venezuela": "🇻🇪",
    "British Virgin Islands": "🇻🇬",
    "U.S. Virgin Islands": "🇻🇮",
    "Vietnam": "🇻🇳",
    "Vanuatu": "🇻🇺",
    "Wallis & Futuna": "🇼🇫",
    "Samoa": "🇼🇸",
    "Kosovo": "🇽🇰",
    "Yemen": "🇾🇪",
    "Mayotte": "🇾🇹",
    "South Africa": "🇿🇦",
    "Zambia": "🇿🇲",
    "Zimbabwe": "🇿🇼",
    "England": "🏴󠁧",
    "Scotland": "🏴󠁧",
    "Wales": "🏴󠁧",
  };

  final TextEditingController _controller = new TextEditingController();
  FocusNode textFieldFocusNode;
  bool searchFieldVisible = false;
  List filteredCountries;
  bool newSearch = true;

  @override
  void initState() {
    super.initState();

    filteredCountries = widget.countries;
    textFieldFocusNode = new FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 50), () {
        var index = widget.countries.indexOf(widget.selectedCountry);
        double height = MediaQuery.of(context).size.height - (4 * 56);
        double scrollTo = (56 * (index).toDouble() - height);
        if (scrollTo > 0)
          scrollController.animateTo(scrollTo,
              duration:
                  Duration(milliseconds: (678 * (1 + (index / 30))).toInt()),
              curve: Curves.ease);
      });
    });
  }

  @override
  void dispose() {
    textFieldFocusNode.dispose();
    super.dispose();
  }

  void toggleSearchField() {
    setState(() {
      searchFieldVisible = !searchFieldVisible;
      filteredCountries = widget.countries;
      newSearch = true;
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xff232d37),
        appBar: AppBar(
          title: Text('Select a country'),
          actions: <Widget>[
            IconButton(onPressed: toggleSearchField, icon: Icon(Icons.search)),
          ],
        ),
        body: Stack(
          children: <Widget>[
            Scrollbar(
              child: ListView.builder(
                key: key,
                controller: scrollController,
                shrinkWrap: true,
                itemCount: filteredCountries.length,
                itemBuilder: (context, i) {
                  return getListTile(context, i,
                      firstInSearch: searchFieldVisible && i == 0,
                      animated: newSearch && i == 0);
                },
              ),
            ),
            new AnimatedContainer(
              duration: Duration(milliseconds: 250),
              height: searchFieldVisible ? 80 : 0,
              onEnd: () {
                if (searchFieldVisible) textFieldFocusNode.requestFocus();
              },
              child: new Padding(
                padding: const EdgeInsets.all(8.0),
                child: ClipRect(
                  clipBehavior: Clip.hardEdge,
                  child: new Card(
                    child: new ListTile(
                      leading: new Icon(Icons.search),
                      title: new TextField(
                        focusNode: textFieldFocusNode,
                        enabled: searchFieldVisible,
                        controller: _controller,
                        decoration: new InputDecoration(
                            hintText: 'Search', border: InputBorder.none),
                        onTap: () {
                          if (newSearch = true) newSearch = false;
                        },
                        onChanged: (String value) {
                          setState(() {
                            newSearch = false;
                            filteredCountries = widget.countries
                                .where((s) => s
                                    .toLowerCase()
                                    .contains(value.toLowerCase()))
                                .toList();
                          });
                        },
                      ),
                      trailing: new IconButton(
                        icon: new Icon(Icons.cancel),
                        onPressed: toggleSearchField,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ));
  }

  Widget getListTile(context, i,
      {bool firstInSearch = false, bool animated = false}) {
    return InkWell(
      onTap: () {
        Navigator.pop(context, filteredCountries[i]);
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: animated ? 250 : 0),
        height: 56,
        margin: EdgeInsets.only(top: firstInSearch ? 72 : 0),
        padding: EdgeInsets.symmetric(horizontal: 20),
        decoration: new BoxDecoration(
            color: i % 2 == 0
                ? Colors.transparent
                : Color.fromARGB(10, 255, 255, 255)),
        child: ListTile(
          title: filteredCountries[i] != "Global"
              ? Container(
                  width: filteredCountries[i] == widget.selectedCountry
                      ? MediaQuery.of(context).size.width - 120
                      : MediaQuery.of(context).size.width - 80,
                  child: Text(
                    filteredCountries[i] +
                        (countryFlags.containsKey(filteredCountries[i])
                            ? "  " + countryFlags[filteredCountries[i]]
                            : ""),
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.white, fontSize: 22),
                  ),
                )
              : Row(
                  children: [
                    Text(
                      "Global",
                      style: TextStyle(color: Colors.white, fontSize: 22),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    Icon(
                      Icons.public,
                      color: Colors.white,
                    )
                  ],
                ),
          trailing: filteredCountries[i] == widget.selectedCountry
              ? Icon(
                  Icons.check,
                  size: 30,
                  color: Colors.white,
                )
              : null,
        ),
      ),
    );
  }
}
