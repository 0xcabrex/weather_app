// ignore_for_file: prefer_const_constructors, import_of_legacy_library_into_null_safe

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

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
  String temperatureString = "Search";
  bool _isShowPlace = false;

  String searchApiUrl = "https://api.openweathermap.org/data/2.5/weather?q=";
  String searchApiKey = "&appid=e123ba1f3d29d1d6a315ca8d589a8605";

  void _temperatureString(temperature) {
    _isShowPlace = true;
    temperatureString = temperature.toString() + ' °C';
  }

  void fetchSearch(String input) async {
    var searchResult = await http.get(searchApiUrl + input + searchApiKey);
    var result = json.decode(searchResult.body);

    print(result['cod']);

    if (result['cod'] == 200) {
      if (kDebugMode) {
        print(result['name']);
        print((result['main']['temp'] - 273.0).toStringAsFixed(2));
        print(result['weather'][0]['main'].replaceAll(' ', '').toLowerCase());
        //print("Latitude: ${position.latitude}\nLongitude: ${position.longitude}");
      }

      setState(() {
        temperature =
            int.parse((result['main']['temp'] - 273.0).toStringAsFixed(0));
        _temperatureString(temperature);
        city = result['name'];
        weather = result['weather'][0]['main'];
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

  // Future<Position> fetchLocation() async {
  //   LocationPermission permission;
  //   permission = await Geolocator.checkPermission();
  //   if (permission == LocationPermission.denied) {
  //     permission = await Geolocator.requestPermission();
  //   } else {
  //     if (kDebugMode) {
  //       print("Location Not Available");
  //     }
  //   }

  //   return await Geolocator.getCurrentPosition();
  // }

  // void _getLocation() async {
  //   Position? position = await fetchLocation();
  //   if (kDebugMode) {
  //     print("Latitude: ${position.latitude}, Longitude: ${position.longitude}");
  //   }
  // }

  void onTextFieldSubmitted(String input) {
    // final position = fetchLocation();
    //fetchSearch(input, position);
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
                    Center(
                      child: Text(
                        temperatureString,
                        style: TextStyle(fontSize: 60, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
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
