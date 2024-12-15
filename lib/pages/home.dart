import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:flotask/components/menu.dart';
import 'package:flotask/pages/userprofile.dart'; // Import UserProfilePage
import 'dart:async';
import 'package:screenshot/screenshot.dart';

class HomePage extends StatefulWidget {
  final VoidCallback toggleTheme; // Add toggleTheme function
  final bool isDarkMode; // Add theme mode state

  const HomePage({Key? key, required this.toggleTheme, required this.isDarkMode}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScreenshotController _screenshotController = ScreenshotController(); // Screenshot controller
  late Timer _timer;
  int _currentStage = 0;
  SMIInput<double>? _growInput;

  @override
  void initState() {
    super.initState();
    _startLoop();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _onRiveInit(Artboard artboard) {
    final controller = StateMachineController.fromArtboard(artboard, 'State Machine 1');
    if (controller != null) {
      artboard.addController(controller);
      _growInput = controller.findInput<double>('Grow');

      if (_growInput != null) {
        _growInput!.value = 0; // Start at Level Null
        print('grow input initialized');
      } else {
        print('Error: grow input not found');
      }
    } else {
      print('Error: StateMachineController not found');
    }
  }

  void _startLoop() {
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      setState(() {
        if (_growInput != null) {
          if (_currentStage < 3) {
            _currentStage += 1;
            _growInput!.value = _currentStage.toDouble();
            print('Animation updated to: Stage $_currentStage');
          } else {
            _growInput!.value = 0;
            _currentStage = 0;
            print('Animation reset to: Level Null');
          }
        } else {
          print('grow input is null');
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: Menu(
        toggleTheme: widget.toggleTheme,
        isDarkMode: widget.isDarkMode,
        screenshotController: _screenshotController, // Pass ScreenshotController
      ),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFE6E6), // Set the color to match the pink background
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.more_vert, color: Colors.black.withOpacity(0.9), size: 32),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.person_outline_rounded, size: 36, color: Colors.black.withOpacity(0.7)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserProfilePage(),
                ),
              );
            },
          ),
        ],
      ),
      body: Screenshot(
        controller: _screenshotController, // Wrap content with Screenshot widget
        child: RiveAnimation.asset(
          'assets/growing_plant.riv',
          fit: BoxFit.cover,
          onInit: _onRiveInit,
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: FloatingActionButton(
          onPressed: _showAddTaskDialog,
          child: const Icon(Icons.add, size: 36),
          backgroundColor: const Color(0xFFD2B48C),
          tooltip: 'Add Task',
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }

  void _showAddTaskDialog() {
    final TextEditingController _taskController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          backgroundColor: Colors.white.withOpacity(0.9),
          title: Text('Add New Task', style: TextStyle(color: Colors.black.withOpacity(0.7))),
          content: TextField(
            controller: _taskController,
            decoration: InputDecoration(
              hintText: 'Enter task description',
              filled: true,
              fillColor: Colors.white.withOpacity(0.5),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                final task = _taskController.text;
                if (task.isNotEmpty) {
                  print('Task added: $task');
                  Navigator.pop(context);
                }
              },
              child: Text('Add', style: TextStyle(color: Colors.black.withOpacity(0.7))),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: Colors.black.withOpacity(0.7))),
            ),
          ],
        );
      },
    );
  }
}
