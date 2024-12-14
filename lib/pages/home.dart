import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:flotask/components/menu.dart';
import 'dart:async';
import 'package:screenshot/screenshot.dart';

class HomePage extends StatefulWidget {
  final VoidCallback toggleTheme; // Add toggleTheme function
  final bool isDarkMode; // Add theme mode state

  const HomePage({Key? key, required this.toggleTheme, required this.isDarkMode}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late Timer _timer;
  int _currentStage = 0;
  SMIInput<double>? _growInput;
  final ScreenshotController _screenshotController = ScreenshotController(); // Screenshot controller
class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>(); 

  @override
  void initState() {
    super.initState();
    _startLoop();
  }

  void _onRiveInit(Artboard artboard) {
    final controller = StateMachineController.fromArtboard(artboard, 'State Machine 1');
    if (controller != null) {
      artboard.addController(controller);
      _growInput = controller.findInput<double>('Grow');

      if (_growInput == null) {
        print('Error: grow input not found');
      } else {
        print('grow input initialized');
        _growInput!.value = 0; // Start at Level Null
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
            // Move to the next stage
            _currentStage += 1;
            _growInput!.value = _currentStage.toDouble();
            print('Animation updated to: Stage $_currentStage');
          } else {
            // After reaching Stage 3, reset to "Level Null"
            _growInput!.value = 0;
            _currentStage = 0;
            print('Animation reset to: Level Null');
          }
        } else {
          print('grow input is null');
        }
      });
    });
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: const Offset(0, -0.1),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _timer.cancel();
=======
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: Menu(screenshotController: _screenshotController), // Pass ScreenshotController
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFE6E6),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.more_vert, color: Colors.black.withOpacity(0.9), size: 32),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.person_outline_rounded, size: 36, color: Colors.black.withOpacity(0.7)),
            onPressed: () => print('Profile clicked'),
          ),
        ],
      drawer: Menu(toggleTheme: widget.toggleTheme, isDarkMode: widget.isDarkMode), 
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0, 
        leading: IconButton(
          icon: Icon(Icons.more_vert, color: Colors.black.withOpacity(0.9), size: 32), 
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
      ),
      body: Screenshot(
        controller: _screenshotController, // Wrap content with Screenshot widget
        child: Stack(
          children: [
            RiveAnimation.asset(
              'assets/growing_plant.riv',
              fit: BoxFit.cover,
              onInit: _onRiveInit,
            ),
          ],
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
            const SizedBox(height: 20), 
            SlideTransition(position: _slideAnimation, child: _buildMessageCard()),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageCard() {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: const Color(0xFFFBE9E7).withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        'Hello',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 18,
          color: Colors.black.withOpacity(0.7),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
