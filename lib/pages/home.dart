import 'package:flutter/material.dart';
import 'package:flotask/components/menu.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  bool _taskCompleted = true; // Placeholder for task status
  int _growthStage = 0; // Represents the current growth stage

  // Growth stages, can be adjusted or replaced with actual images if available
  final List<IconData> _growthIcons = [
    Icons.bubble_chart, // Seed
    Icons.spa, // Sprout
    Icons.local_florist, // Small Flower
    Icons.flare, // Full Bloom
  ];

  // Controls the growth stage on task completion or miss
  void _updateGrowthStage() {
    setState(() {
      if (_taskCompleted) {
        if (_growthStage < _growthIcons.length - 1) {
          _growthStage++; // Advance to the next stage if task is completed
        }
      } else {
        if (_growthStage > 0) {
          _growthStage--; // Regress to the previous stage if task is missed
        }
      }
      _taskCompleted = !_taskCompleted; // Toggle task status for demonstration
    });
  }

  // Builds the flower graphic based on the current growth stage
  Widget _buildFlowerGraphic() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedSwitcher(
            duration: const Duration(seconds: 1),
            child: Icon(
              _growthIcons[_growthStage],
              key: ValueKey<int>(_growthStage), // Unique key for each stage
              size: 100 + (_growthStage * 20).toDouble(), // Gradually increases size
              color: _growthStage == _growthIcons.length - 1
                  ? Colors.green // Full bloom color
                  : Colors.brown, // Seed and sprout colors
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _growthStage == _growthIcons.length - 1
                ? 'The flower is in full bloom!'
                : 'The flower is growing!',
            style: TextStyle(
              fontSize: 18,
              color: Colors.green.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
          ElevatedButton(
            onPressed: _updateGrowthStage,
            child: Text(_taskCompleted ? 'Miss a Task' : 'Complete a Task'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: GlobalKey<ScaffoldState>(),
      drawer: Menu(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.more_vert, color: Colors.black.withOpacity(0.9), size: 32),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.person_outline_rounded, size: 36, color: Colors.black.withOpacity(0.7)),
            onPressed: () => print('Profile clicked'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildFlowerGraphic(), // Display the animated growth stages
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: FloatingActionButton(
          onPressed: _updateGrowthStage,
          child: const Icon(Icons.add, size: 36),
          backgroundColor: const Color(0xFFD2B48C),
          tooltip: 'Simulate Task',
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }
}
