import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';

class NearbyPharmacyPage extends StatefulWidget {
  const NearbyPharmacyPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _NearbyPharmacyPageState createState() => _NearbyPharmacyPageState();
}

class _NearbyPharmacyPageState extends State<NearbyPharmacyPage> {
  final String apiKey = 'AIzaSyAqMSLOYFQU2sc-08e9kiP8Dg4S7gUtimo';
  List<dynamic> places = [];
  bool isLoading = true;
  String loadingMessage = "Loading...";
  Position? _currentPosition;
  StreamSubscription<Position>? _positionStreamSubscription;
  bool showPharmacies = true;  

  @override
  void initState() {
    super.initState();
    _startMonitoringLocation();
  }

  void _startMonitoringLocation() async {
    await _checkPermissionAndStartListening();
    if (_currentPosition != null) {
      fetchPlaces(_currentPosition!.latitude, _currentPosition!.longitude);
    }
  }

  Future<void> _checkPermissionAndStartListening() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showError('Location services are disabled. Please enable them in your device settings.');
      return;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever || permission == LocationPermission.denied) {
        _showError('Location permissions are denied. Please allow access in your device settings.');
        return;
      }
    }
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    _currentPosition = position;
  }

  void fetchPlaces(double latitude, double longitude) async {
    setState(() {
      isLoading = true;
      loadingMessage = "Fetching ${showPharmacies ? 'pharmacies' : 'Clinics/Hospitals'}...";
    });
    var types = showPharmacies ? ["pharmacy", "drugstore"] : ["hospital", "dental_clinic"];
    var requestBody = json.encode({
      "locationRestriction": {
        "circle": {
          "center": {"latitude": latitude, "longitude": longitude},
          "radius": 3000
        }
      },
      "includedTypes": types,
      "maxResultCount": 15,
    });

    var headers = {
      'Content-Type': 'application/json',
      'X-Goog-Api-Key': apiKey,
      'X-Goog-FieldMask': 'places.displayName,places.location,places.types'
    };

    var response = await http.post(
      Uri.parse('https://places.googleapis.com/v1/places:searchNearby'),
      headers: headers,
      body: requestBody,
    );

    if (response.statusCode == 200) {
      var allPlaces = json.decode(response.body)['places'];
      setState(() {
        if (showPharmacies) {
          places = allPlaces.where((place) {
            String displayName = place['displayName']['text'];
            return displayName.toLowerCase().endsWith('pharmacy');
          }).toList();
        } else {
          places = allPlaces;
        }
        isLoading = false;
      });
    } else {
      _showError('Failed to fetch places: ${response.body}');
      setState(() => isLoading = false);
    }
  }

  void _launchMapsUrl(double lat, double lng) async {
    var url = 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.redAccent));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      title: const Text(
        'Nearby Pharmacies/Hospitals',
         style: TextStyle(
            fontWeight: FontWeight.bold, 
          ),
        ),
        backgroundColor: Colors.teal[800],
      ),
      body: Container(
        color: Colors.teal[800],  
        child: Column(
        children: [
          ToggleButtons(
            // ignore: sort_child_properties_last
            children: const <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                'Pharmacies',
                style: TextStyle(
                  fontWeight: FontWeight.bold, 
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Clinics/Hospitals',
                style: TextStyle(
                  fontWeight: FontWeight.bold, 
                  ),
                ),
              ),
            ],
            isSelected: [showPharmacies, !showPharmacies],
            onPressed: (int index) {
              setState(() {
                showPharmacies = index == 0;
                if (_currentPosition != null) {
                  fetchPlaces(_currentPosition!.latitude, _currentPosition!.longitude);
                }
              });
            },
            color: Colors.white,
              selectedColor: Colors.white,
              fillColor: Colors.teal[300],
              borderColor: Colors.white,
              selectedBorderColor: Colors.white,
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator(semanticsLabel: loadingMessage))
                : ListView.builder(
                    itemCount: places.length,
                    itemBuilder: (context, index) {
                      var place = places[index];
                      var lat = place['location']['latitude'];
                      var lng = place['location']['longitude'];
                      var distance = _currentPosition != null
                          ? Geolocator.distanceBetween(
                              _currentPosition!.latitude, _currentPosition!.longitude, lat, lng) / 1609.34
                          : 0;
                      return ListTile(
                        leading: Icon(showPharmacies ? Icons.local_pharmacy : Icons.local_hospital, color: Colors.white),
                        title: Text(place['displayName']['text'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        subtitle: Text('${distance.toStringAsFixed(2)} miles away', style: const TextStyle(color: Colors.white)),
                        trailing: IconButton(
                          icon: const Icon(Icons.directions, color: Colors.white),
                          onPressed: () => _launchMapsUrl(lat, lng),
                        ),
                        onTap: () {},
                      );
                    },
                  ),
          ),
        ],
      ),
      ),
    );
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }
}
















