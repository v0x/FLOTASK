import 'dart:async';
import 'package:flutter/material.dart';

class PomodoroTimer extends StatefulWidget {
  final int workTime;
  final int breakTime;
  final Color taskColor;

  const PomodoroTimer({
    required this.workTime,
    required this.breakTime,
    required this.taskColor,
  });

  @override
  State<PomodoroTimer> createState() => _PomodoroTimerState();
}

class _PomodoroTimerState extends State<PomodoroTimer> {
  bool _isRunning = false;
  bool _workSession = false;
  bool _breakTime = false;
  Timer? _timer;
  late Duration _timeSpecified;

  @override
  void initState() {
    _initialize();
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant PomodoroTimer prev) {
    super.didUpdateWidget(prev);
    if (prev.workTime != widget.workTime ||
        prev.breakTime != widget.breakTime) {
      setState(() {
        _initialize();
      });
    }
  }

  void _initialize() {
    _workSession = false;
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _breakTime = false;
    });
    _workTimer();
  }

  double _currProgress() {
    int total = _workSession ? widget.workTime * 60 : widget.breakTime * 60;
    return (total - _timeSpecified.inSeconds) / total;
  }

  String get currMinutes {
    return '${(_timeSpecified.inSeconds ~/ 60).toString().padLeft(2, '0')}';
  }

  String get currSeconds {
    return '${(_timeSpecified.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  void _workTimer() {
    setState(() {
      _breakTime = false;
    });
    _timeSpecified = Duration(minutes: widget.workTime);
  }

  void _breakTimer() {
    setState(() {
      _breakTime = true;
    });
    _timeSpecified = Duration(minutes: widget.breakTime);
  }

  void start() {
    setState(() {
      _isRunning = true;
    });
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeSpecified.inSeconds > 0) {
          _timeSpecified -= Duration(seconds: 1);
        } else {
          setState(() {
            _isRunning = false;
          });
          _timer?.cancel();
          if (_breakTime) {
            reset();
          } else {
            _breakTimer();
          }
        }
      });
    });
  }

  void pause() {
    setState(() {
      _isRunning = false;
    });
    _timer?.cancel();
  }

  void buttonPressed() {
    _timer?.cancel();
    if (!_isRunning) {
      start();
    } else {
      pause();
    }
  }

  void reset() {
    setState(() {
      setState(() {
        _isRunning = false;
        _breakTime = false;
      });
      _timer?.cancel();
      _workTimer();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shadowColor: Colors.transparent,
      //elevation: 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 200,
                height: 200,
                child: CircularProgressIndicator(
                  value: _currProgress(),
                  strokeWidth: 8,
                  color: widget.taskColor,
                  backgroundColor: widget.taskColor.withOpacity(0.5),
                ),
              ),
              Column(
                children: <Widget>[
                  if (_breakTime)
                    Text("Break Time!",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: widget.taskColor)),
                  Text(
                    '$currMinutes:$currSeconds',
                    style: TextStyle(
                      fontSize: 48,
                      color: widget.taskColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: buttonPressed,
            child: Icon(
              _isRunning ? Icons.pause : Icons.play_arrow,
              color: widget.taskColor,
              size: 55,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.taskColor.withOpacity(0.3),
              elevation: 0,
              shape: CircleBorder(),
              minimumSize: Size(90, 90),
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: reset,
            child: Icon(
              Icons.replay,
              color: widget.taskColor,
              size: 30,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.taskColor.withOpacity(0.3),
              elevation: 0,
              shape: CircleBorder(),
              minimumSize: Size(60, 60),
            ),
          ),
        ],
      ),
    );
  }
}