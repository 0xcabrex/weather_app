// ignore_for_file: prefer_const_constructors, import_of_legacy_library_into_null_safe

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
// import '';

void main() {
  runApp(WeatherApp());
}

class WeatherApp extends StatefulWidget {
  WeatherApp({Key? key}) : super(key: key);

  @override
  _WeatherAppState createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
  int temperature = 0;
  String city = "Bengaluru";
  String weather = "clear";
  String icon = "03d";
  String temperatureString = "Search";
  String description = "";
  int high = 0;
  int low = 0;
  bool _isShowPlace = false;
  bool _isShowIcon = false;

  String searchApiUrl = "https://api.openweathermap.org/data/2.5/weather?q=";
  String searchApiKey = "&appid=e123ba1f3d29d1d6a315ca8d589a8605";
  // String iconApiUrl1 = "https://openweathermap.org/img/wn/";
  // String iconApiUrl2 = "@2x.png";
  String finalIconApiUrl = "https://openweathermap.org/img/wn/03d@2x.png";

  void _temperatureString(temperature) {
    _isShowPlace = true;
    temperatureString = temperature.toString() + ' °C';
  }

  void fetchSearch(String input) async {
    var searchResult = await http.get(searchApiUrl + input + searchApiKey);
    var result = json.decode(searchResult.body);

    if (kDebugMode) {
      print(result['cod']);
    }

    if (result['cod'] == 200) {
      if (kDebugMode) {
        print(result['name']);
        print((result['main']['temp'] - 273.0).toStringAsFixed(2));
        print(result['weather'][0]['main'].replaceAll(' ', '').toLowerCase());
        print(result['weather'][0]['icon']);
      }

      setState(() {
        temperature =
            int.parse((result['main']['temp'] - 273.0).toStringAsFixed(0));
        _temperatureString(temperature);
        city = result['name'];
        weather = result['weather'][0]['main'];
        icon = result['weather'][0]['icon'];
        finalIconApiUrl = "https://openweathermap.org/img/wn/${icon}@2x.png";
        _isShowIcon = true;
        description = result['weather'][0]['description'];
        //high = ;
        high =
            int.parse((result['main']['temp_max'] - 273.0).toStringAsFixed(0));
        low =
            int.parse((result['main']['temp_min'] - 273.0).toStringAsFixed(0));
      });
    } else if (result['cod'] == "404") {
      if (kDebugMode) {
        print(result['message']);
      }

      setState(() {
        temperatureString = "Place not found";
        _isShowPlace = false;
      });
    }
  }

  void onTextFieldSubmitted(String input) {
    fetchSearch(input);
  }

  // Widget definition
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
          image: AssetImage('images/${weather.toLowerCase()}.png'),
          opacity: 0.8,
          fit: BoxFit.fill,
        )),
        child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                // Temperature
                Column(
                  children: <Widget>[
                    // icon For every weather
                    Visibility(
                      visible: _isShowIcon,
                      child: Center(
                        child: Image.network(finalIconApiUrl.toString()),
                      ),
                    ),

                    // Temperature showing thing
                    Center(
                      child: Text(
                        temperatureString,
                        style: TextStyle(fontSize: 60, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    // Place showing thing
                    Visibility(
                      visible: _isShowPlace,
                      maintainSize: true,
                      maintainAnimation: true,
                      maintainState: true,
                      child: Text(
                        city,
                        style: TextStyle(color: Colors.white, fontSize: 40),
                      ),
                    ),

                    // Other information
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Visibility(
                        visible: _isShowPlace,
                        child: Column(
                          children: <Widget>[
                            Text(description,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 15)),
                            Text("High: $high °C\t\t\t\tLow: $low °C",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 15)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                // Location name
                Column(
                  children: <Widget>[
                    Container(
                      width: 300,
                      child: TextField(
                        onSubmitted: (String input) {
                          onTextFieldSubmitted(input);
                        },
                        style: TextStyle(color: Colors.white, fontSize: 25),
                        decoration: InputDecoration(
                            hintText: "Enter city name",
                            hintStyle:
                                TextStyle(color: Colors.white, fontSize: 18),
                            prefixIcon:
                                Icon(Icons.search, color: Colors.white)),
                      ),
                    )
                  ],
                )
              ],
            )),
      ),
    );
  }
}
