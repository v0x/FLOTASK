import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../models/task_model.dart';
import '../components/task_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../components/goal_service.dart';
import '../models/goal_model.dart';
import 'package:intl/intl.dart';

final GoalService goalService = GoalService();
final TaskService taskService = TaskService();
List<Task> tasks = [];

Color getColor(String colorString) {
  try {
    String hex = colorString.replaceAll("#", "");
    if (hex.length == 6) {
      hex = "FF$hex"; // Add alpha if missing
    }
    return Color(int.parse(hex, radix: 16));
  } catch (e) {
    return Colors.white; // Default color on error
  }
}

Set<Marker> _markers = {};

class MapPage extends StatefulWidget {
  @override
  _MapPage createState() => _MapPage();
}

class _MapPage extends State<MapPage> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  late final String userId;
  late final CollectionReference goalsCollection;
  GoogleMapController? _mapController;
  CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(37.7700913, -122.4704359), //Setting Default Location to SF Japanese Tea Garden if can't fetch user location
    zoom: 10.0,
  );

  LatLng? _currPos;
  @override
  void initState() {
    super.initState();
    if (currentUser != null) {
      userId = currentUser!.uid;
      goalsCollection = FirebaseFirestore.instance.collection('users').doc(userId).collection('goals');
    }
    _checkForApiKey();
    _determinePosition();
    _loadMarkers();
    if(tasks.isEmpty){_fetchGoalsAndTasks();}
  }

  Future<void> _fetchGoalsAndTasks() async {
      try {
        QuerySnapshot goalSnapshot = await goalsCollection.get();
        List<Goal> fetchedGoals = goalSnapshot.docs.map((doc) => Goal.fromDocument(doc)).toList();
        //tasks.add(Task(id: "9999", taskName: "Select Task", repeatInterval: 9999, startDate: DateTime.now(), endDate: DateTime.now(), workTime: 0, breakTime: 0, taskColor: "#FFFFFF", status: "status", totalRecurrences: 999, totalCompletedRecurrences: 999));
        for (var goal in fetchedGoals) {
          QuerySnapshot taskSnapshot = await goalsCollection.doc(goal.id).collection('tasks').get();
          List<Task> fetchedTasks = taskSnapshot.docs.map((doc) => Task.fromDocument(doc)).toList();
          for (var task in fetchedTasks) {
            tasks.add(task);
          }
        }
      } catch (e) {
        print('Error fetching tasks: $e');
      }
    }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    //Checking if there's locational service perms
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print("Location Services Disabled");
      return;
    }

    //Check perms for geolocator & location
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print("Locational Permissions Denied");
        return;
      }
    }

    //(try to) grab user pos
    try
    {
      Position user_pos = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
    );

        //set up pos and set camera to user's pos
        setState(() {
          _currPos = LatLng(user_pos.latitude, user_pos.longitude);
          _initialCameraPosition = CameraPosition(
            target: LatLng(user_pos.latitude, user_pos.longitude),
            zoom: 10.0,
          );
        });
        if (_mapController != null) {
          _mapController!.animateCamera(
            CameraUpdate.newCameraPosition(_initialCameraPosition),
          );
        }
    }
    catch (e) {
      print("Position Fetching Error");
    }
    }

    //update initial position as needed (ideally w/more accurate pos if try mthd works)
    void _onMapCreated(GoogleMapController controller) {
      _mapController = controller;
      if (_currPos != null) {
        controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(
                _currPos!.latitude,
                _currPos!.longitude,
              ),
              zoom: 10.0,
            ),
          ),
        );
      }
    }

    //pretty much the method in charge of helping changing the color of the markers
    double _colorToHue(Color color) {
      final hsl = HSLColor.fromColor(color);
      return hsl.hue;
    }

    Future<void> _loadMarkersFB() async {
      try {
        final markersCollection = FirebaseFirestore.instance.collection('markers');
        final snapshot = await markersCollection.get();
        Set<Marker> loadedMarkers = snapshot.docs.map((doc) {
          final data = doc.data();
          final lat = data['lat'] as double;
          final lng = data['lng'] as double;
          final name = data['name'] as String;
          final taskName = data['task'] as String;
          final task = tasks.firstWhere(
            (t) => t.taskName == taskName,
            orElse: () => tasks.first,
          );
          return Marker(
            markerId: MarkerId("$lat,$lng"),
            position: LatLng(lat, lng),
            infoWindow: InfoWindow(title: name),
            icon: BitmapDescriptor.defaultMarkerWithHue(_colorToHue(getColor(task.taskColor))),
            onTap: () => _confirmDeleteMarker("$lat,$lng"),
          );
        }).toSet();
        setState(() {
          _markers.clear();
          _markers.addAll(loadedMarkers);
        });
        print("Markers loaded from Firestore successfully.");
      } catch (e) {
        print("Error loading markers from Firestore: $e");
      }
    }


    void _restartApp() {
      WidgetsBinding.instance.performReassemble();
    }

    Future<void> _saveMarkersFB() async {
      try {
        final markerList = _markers.map((m) {
          final task = tasks.firstWhere(
            (t) => m.infoWindow.title!.contains(t.taskName),
            orElse: () => tasks.first,
          );
          return {
            'lat': m.position.latitude,
            'lng': m.position.longitude,
            'name': m.infoWindow.title ?? "Unnamed Location",
            'task': task.taskName,
          };
        }).toList();

        final markersCollection = FirebaseFirestore.instance.collection('markers');

        final snapshot = await markersCollection.get();
        for (var doc in snapshot.docs) {
          await markersCollection.doc(doc.id).delete();
        }
        for (var marker in markerList) {
          await markersCollection.add(marker);
        }

        print("Markers saved to Firestore successfully.");
      } catch (e) {
        print("Error saving markers to Firestore: $e");
      }
    }

    Future<void> _saveMarkers() async {
      final prefs = await SharedPreferences.getInstance();
      final markerList = _markers.map((m) {
        final task = tasks.firstWhere((t) => m.infoWindow.title!.contains(t.taskName), orElse: () => tasks.first);
        return {
          'lat': m.position.latitude,
          'lng': m.position.longitude,
          'name': m.infoWindow.title ?? "Unnamed Location",
          'task': task.taskName,
        };
      }).toList();
      prefs.setString('markers', jsonEncode(markerList));
      _saveMarkersFB();
    }

    Future<void> _checkForApiKey() async {
      final apiKey = await _getApiKey();
      if (apiKey == null || apiKey.isEmpty) {
        _promptForApiKey(context);
      }
      _restartApp();
    }

    Future<void> _updateAndroidApiKey(String apiKey) async {
      try {
        final manifestPath = 'android/app/src/main/AndroidManifest.xml';
        final manifestFile = File(manifestPath);

        if (await manifestFile.exists()) {
          String content = await manifestFile.readAsString();

          //Replace the old API key/empty string with the new key
          final updatedContent = content.replaceAll(
            RegExp(r'<meta-data android:name="com.google.android.geo.API_KEY" android:value=".*?" />'),
            '<meta-data android:name="com.google.android.geo.API_KEY" android:value="$apiKey" />',
          );

          await manifestFile.writeAsString(updatedContent);
          print("API key updated in AndroidManifest.xml.");
        }
      } catch (e) {
        print("Error updating AndroidManifest.xml: $e");
      }
    }

    Future<void> _saveApiKey(String apiKey) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('google_maps_api_key', apiKey);
    }

    Future<String?> _getApiKey() async {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('google_maps_api_key');
    }

    Future<void> _promptForApiKey(BuildContext context) async {
      TextEditingController _apiKeyController = TextEditingController();

      return showDialog<void>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Enter API Key', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
            content: TextField(
              controller: _apiKeyController,
              decoration: InputDecoration(hintText: "Google Maps API Key"),
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
            ),
            actions: [
              TextButton(
                child: Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: Text('Save', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
                onPressed: () async {
                  final apiKey = _apiKeyController.text.trim();
                  if (apiKey.isNotEmpty) {
                    await _saveApiKey(apiKey); // Save the API key locally
                    await _updateAndroidApiKey(apiKey); // Update the Android API key
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          );
        },
      );
    }

    void _confirmDeleteMarker(String markerId) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Delete Marker',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            content: Text('Are you sure you want to delete this bookmark?',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
            ),
            actions: [
              TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text('Delete'),
                onPressed: () async {
                  setState(() {
                    _markers.removeWhere((marker) => marker.markerId.value == markerId);
                  });
                  await _deleteMarkerFromFirestore(markerId);
                  _saveMarkers();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    Future<void> _deleteMarkerFromFirestore(String markerId) async {
      try {
        final markersCollection = FirebaseFirestore.instance.collection('markers');
        final snapshot = await markersCollection.get();

        for (var doc in snapshot.docs) {
          final data = doc.data();
          final lat = data['lat'];
          final lng = data['lng'];
          if ("$lat,$lng" == markerId) {
            await markersCollection.doc(doc.id).delete();
            break;
          }
        }
        print("Marker deleted from Firestore successfully.");
      } catch (e) {
        print("Error deleting marker from Firestore: $e");
      }
    }

    Future<void> _loadMarkers() async {
      _loadMarkersFB();
      final prefs = await SharedPreferences.getInstance();
      String? markerJson = prefs.getString('markers');
      if (markerJson != null) {
        List decoded = jsonDecode(markerJson);
        Set<Marker> loadedMarkers = decoded.map((item) {
          final lat = item['lat'];
          final lng = item['lng'];
          final name = item['name'];
          final taskName = item['task'];
          final task = tasks.firstWhere((t) => t.taskName == taskName, orElse: () => tasks.first);

          return Marker(
            markerId: MarkerId("$lat,$lng"),
            position: LatLng(lat, lng),
            infoWindow: InfoWindow(title: name),
            icon: BitmapDescriptor.defaultMarkerWithHue(_colorToHue(getColor(task.taskColor))),
            onTap: () => _confirmDeleteMarker("$lat,$lng"),
          );
        }).toSet();
        setState(() {
          _markers = loadedMarkers;
        });
      }
    }

    Future<Map<String, dynamic>?> _showMarkerDialog(BuildContext context, LatLng position) async {
      TextEditingController _textFieldController = TextEditingController();
      Task? selectedTask;

      return showDialog<Map<String, dynamic>>(
        context: context,
        builder: (context) {
          return SizedBox.expand(
            child: SingleChildScrollView(
              child: AlertDialog(
            title: Text('Add Bookmark', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _textFieldController,
                  decoration: InputDecoration(hintText: "Enter bookmark name"),
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
                ),
                SizedBox(height: 10),
                DropdownButtonFormField<Task>(
                  value: selectedTask,
                  items: tasks.map((task) {
                    return DropdownMenuItem<Task>(
                      value: task,
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            color: getColor(task.taskColor),
                            margin: EdgeInsets.only(right: 8),
                          ),
                          Text(task.taskName, style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    selectedTask = value as Task?;
                  },
                  hint: Text("Select Task", style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),),
                ),
              ],
            ),
            actions: [
              TextButton(
                child: Text('Cancel', style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),),
                onPressed: () {
                  Navigator.of(context).pop(null);
                },
              ),
              TextButton(
                child: Text('Save', style: TextStyle(color: Colors.black, fontWeight: FontWeight.normal),),
                onPressed: () {
                  Navigator.of(context).pop({
                    'name': _textFieldController.text,
                    'task': selectedTask,
                  });
                },
              ),
            ],
          ),
            ),
          );
        },
      );
    }

    void _addMarker(LatLng position) async {
      final result = await _showMarkerDialog(context, position);
      if (result != null) {
        final markerName = result['name'];
        final task = result['task'] as Task;
        setState(() {
          _markers.add(
            Marker(
              markerId: MarkerId(position.toString()),
              position: position,
              infoWindow: InfoWindow(title: task.taskName + ": " + markerName),
              icon: BitmapDescriptor.defaultMarkerWithHue(_colorToHue(getColor(task.taskColor))),
              onTap: () => _confirmDeleteMarker(position.toString()),
            ),
          );
        });
      }
      _saveMarkers();
    }

    @override
    Widget build(BuildContext context) {
      if (_currPos == null) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Map'),
          ),
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      }
      return Scaffold(
        appBar: AppBar(
          title: Text('Map'),
        ),
        body: Builder(
          builder: (context) {
            try {
              return GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: _initialCameraPosition,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                markers: _markers,
                onLongPress: (LatLng tappedPosition) {
                  _addMarker(tappedPosition);
                },
              );
            } catch (e) {
              print("Error rendering GoogleMap: $e");
              return Center(
                child: Text(
                  "Error loading map. Please restart the app.",
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              );
            }
          },
        ),
      );
    }
}