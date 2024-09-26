import 'package:flutter/material.dart';
import 'package:flotask/pages/calendar.dart';
import 'package:flotask/pages/home.dart';
import 'package:flotask/pages/pomodoro.dart';
import 'package:flotask/pages/task.dart';
import 'package:flotask/pages/progress.dart';

// RootLayout class manages the main layout and bottom navigation bar
class RootLayout extends StatefulWidget {
  @override
  _RootLayoutState createState() => _RootLayoutState();
}

// State for RootLayout, handles bottom navigation and gesture detection
class _RootLayoutState extends State<RootLayout> with SingleTickerProviderStateMixin {
  int currentPageIndex = 0; // Tracks the currently selected page
  bool isBarVisible = true; // Tracks if the bottom navigation bar is visible

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Detects vertical swipe gestures to show/hide the bottom bar
      body: GestureDetector(
        onVerticalDragUpdate: (details) {
          if (details.primaryDelta! > 10) {
            // Swipe down: Hide the navigation bar
            setState(() {
              isBarVisible = false;
            });
          } else if (details.primaryDelta! < -10) {
            // Swipe up: Show the navigation bar
            setState(() {
              isBarVisible = true;
            });
          }
        },
        child: [
          HomePage(),       // Index 0: Home Page
          TaskPage(),       // Index 1: Task Page
          CalendarPage(),   // Index 2: Calendar Page
          PomodoroPage(),   // Index 3: Pomodoro Page
          ProgressPage(),   // Index 4: Progress Page
        ][currentPageIndex], // Displays the currently selected page
      ),

      // Bottom navigation bar with animation for hiding/showing
      bottomNavigationBar: AnimatedContainer(
        duration: Duration(milliseconds: 300), // Smooth animation for hiding/showing the bar
        height: isBarVisible ? 80 : 0, // Set height to 0 when hidden
        child: isBarVisible
            ? Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200, // Soft, neutral background color
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(60),  // Dome-like rounding at the top
                    topRight: Radius.circular(60),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2), // Shadow for depth
                      spreadRadius: 5,
                      blurRadius: 15,
                      offset: Offset(0, -2), // Slight elevation effect
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(60), // Consistent rounding with the container
                    topRight: Radius.circular(60),
                  ),
                  child: BottomNavigationBar(
                    currentIndex: currentPageIndex, // Highlights the current page
                    onTap: (index) {
                      setState(() {
                        currentPageIndex = index; // Changes the selected page
                      });
                    },
                    backgroundColor: Colors.white, // Clean, white background for the navigation bar
                    type: BottomNavigationBarType.fixed, // Fixes the layout of the bar
                    elevation: 0, // Removes default shadow
                    selectedItemColor: Colors.brown.shade700, // Brown for selected icons
                    unselectedItemColor: Colors.brown.shade300, // Lighter brown for unselected icons
                    showSelectedLabels: false, // Hides labels for a cleaner look
                    showUnselectedLabels: false, // Hides unselected labels too
                    items: [
                      // Navigation icons with padding for spacing above
                      BottomNavigationBarItem(
                        icon: Padding(
                          padding: const EdgeInsets.only(top: 12.0), // Adds space above the icon
                          child: buildIcon(Icons.home, 0),
                        ),
                        label: '',
                      ),
                      BottomNavigationBarItem(
                        icon: Padding(
                          padding: const EdgeInsets.only(top: 12.0), // Adds space above the icon
                          child: buildIcon(Icons.task, 1),
                        ),
                        label: '',
                      ),
                      BottomNavigationBarItem(
                        icon: Padding(
                          padding: const EdgeInsets.only(top: 12.0), // Adds space above the icon
                          child: buildIcon(Icons.calendar_today, 2),
                        ),
                        label: '',
                      ),
                      BottomNavigationBarItem(
                        icon: Padding(
                          padding: const EdgeInsets.only(top: 12.0), // Adds space above the icon
                          child: buildIcon(Icons.alarm, 3),
                        ),
                        label: '',
                      ),
                      BottomNavigationBarItem(
                        icon: Padding(
                          padding: const EdgeInsets.only(top: 12.0), // Adds space above the icon
                          child: buildIcon(Icons.checklist_rtl_rounded, 4),
                        ),
                        label: '',
                      ),
                    ],
                  ),
                ),
              )
            : null, // If the bar is hidden, nothing is displayed
      ),
    );
  }

  // Builds icons with scaling animation when selected
  Widget buildIcon(IconData iconData, int index) {
    return AnimatedScale(
      scale: currentPageIndex == index ? 1.2 : 1.0, // Increases icon size when selected
      duration: const Duration(milliseconds: 200), // Animation duration
      child: Icon(
        iconData,
        color: currentPageIndex == index
            ? Colors.brown.shade700  // Darker brown for selected icons
            : Colors.brown.shade300, // Lighter brown for unselected icons
        size: 30, // Icon size
      ),
    );
  }
}
