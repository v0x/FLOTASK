import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:flotask/components/menu.dart';
import 'package:flotask/pages/userprofile.dart';
import 'dart:async';
import 'package:screenshot/screenshot.dart';

class HomePage extends StatefulWidget {
  final VoidCallback toggleTheme; // Add toggleTheme function
  final bool isDarkMode; // Add theme mode state
  final int completedGoals; // Track completed goals

  const HomePage({
    Key? key,
    required this.toggleTheme,
    required this.isDarkMode,
    required this.completedGoals,
  }) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScreenshotController _screenshotController = ScreenshotController();
  SMIInput<double>? growinput; // Input to control flower growth
  int _currentStage = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      updateFlowerStage();
    });
  }

  @override
  void didUpdateWidget(HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.completedGoals != widget.completedGoals) {
      _retryUpdateFlowerStage(); // Retry logic to ensure flower stage updates
    }
  }

  void _onRiveInit(Artboard artboard) async {
    final controller = StateMachineController.fromArtboard(artboard, 'State Machine 1');
    if (controller != null) {
      artboard.addController(controller);
      growinput = controller.findInput<double>('Grow');
      if (growinput != null) {
        print('Grow input initialized.');
        print('The completed goals on init are: ${widget.completedGoals}');
        for(double i=0; i<=widget.completedGoals;i++){
          ufs(growinput, i);
          print('Will wait for 1 seconds');
          await Future.delayed(Duration(milliseconds:500));
          print('1 seconds have passed');
        }
      } else {
        print('Error: grow input not found');
      }
    } else {
      print('Error: StateMachineController not found');
    }
  }

  void ufs(SMIInput<double>? growInput, double stage){
    try{
      if(growInput != null){
        growInput.value = stage;
        print('updated to stage $stage');
      } else {
        print('Error');
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  // Update flower stage based on completed goals
  void updateFlowerStage() {
    if (growinput != null) {
      setState(() {
        switch (widget.completedGoals) {
          case 1:
            growinput!.value = 1; // Stage 1
            _currentStage = 1;
            print('Flower at Stage 1');
            break;
          case 2:       
            growinput!.value = 2; // Stage 2
            _currentStage = 2;
            print('Flower at Stage 2');
            break;
          case 3:
            growinput!.value = 3; // Stage 3
            _currentStage = 3;
            print('Flower at Stage 3');
            break;
          default:
            growinput!.value = 0; // Initial stage
            _currentStage = 0;
            print('Flower at Initial Stage');
        }
      });
    } else {
      print('Grow input is null. Cannot update stage.');
    }
  }

  // Retry mechanism to ensure growInput is initialized
  void _retryUpdateFlowerStage() {
    if (growinput == null) {
      print('Grow input not initialized, retrying...');
      Future.delayed(const Duration(milliseconds: 500), () {
        if (growinput != null) {
          updateFlowerStage();
        } else {
          print('Grow input still not ready.');
        }
      });
    } else {
      updateFlowerStage();
    }
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: Menu(
        toggleTheme: widget.toggleTheme,
        isDarkMode: widget.isDarkMode,
        screenshotController: _screenshotController,
      ),
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
        controller: _screenshotController,
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
