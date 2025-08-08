import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:typed_data';

class FocusModePage extends StatefulWidget {
  const FocusModePage({super.key});

  @override
  State<FocusModePage> createState() => _FocusModePageState();
}

class _FocusModePageState extends State<FocusModePage> {
  int _workDuration = 25 * 60;
  int _breakDuration = 5 * 60;
  int _secondsRemaining = 25 * 60;
  bool _isWorking = true;
  bool _isRunning = false;
  Timer? _timer;
  late FlutterLocalNotificationsPlugin _notificationsPlugin;
  bool _showSettings = false;

  static final Int64List _vibrationPattern =
      Int64List.fromList([0, 1000, 500, 1000]);

  @override
  void initState() {
    super.initState();

    _notificationsPlugin = FlutterLocalNotificationsPlugin();
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettings =
        InitializationSettings(android: androidSettings);
    _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (response) {
        if (response.payload == 'start_next') {
          setState(() {
            _isRunning = false;
            _isWorking = !_isWorking;
            _secondsRemaining = _isWorking ? _workDuration : _breakDuration;
          });
          _startTimer();
        }
      },
    );

    _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _showNotification(String title, String body,
      {String? payload}) async {
    final androidDetails = AndroidNotificationDetails(
      'pomodoro_channel',
      'Pomodoro Notifications',
      channelDescription: 'Pomodoro Timer Alerts',
      importance: Importance.max,
      priority: Priority.high,
      vibrationPattern: _vibrationPattern,
      playSound: true,
    );
    final notificationDetails = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(0, title, body, notificationDetails,
        payload: payload);
  }

  void _startTimer() {
    if (_isRunning) return;

    setState(() {
      _isRunning = true;
    });

    _showNotification(
      _isWorking ? 'Focus Mode Started' : 'Break Started',
      _isWorking
          ? 'Stay focused! Pomodoro timer started 🎯'
          : 'Time for a break 😊',
      payload: 'start_next',
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _timer?.cancel();
          _isRunning = false;

          _showNotification(
            _isWorking ? 'Great job!' : 'Break Over!',
            _isWorking
                ? 'Focus session complete. Time for a break!'
                : 'Break is over! Ready for another session?',
            payload: 'start_next',
          );

          _isWorking = !_isWorking;
          _secondsRemaining = _isWorking ? _workDuration : _breakDuration;
        }
      });
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });

    _showNotification(
      'Timer Paused',
      'Paused at ${_formatTime(_secondsRemaining)}. Resume when ready.',
    );
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _secondsRemaining = _isWorking ? _workDuration : _breakDuration;
    });

    _showNotification(
      'Timer Reset',
      'Reset to ${_formatTime(_secondsRemaining)}.',
    );
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _updateDurations(int workMinutes, int breakMinutes) {
    setState(() {
      _workDuration = workMinutes * 60;
      _breakDuration = breakMinutes * 60;
      if (!_isRunning) {
        _secondsRemaining = _isWorking ? _workDuration : _breakDuration;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Remove appBar - use custom floating back button and pastel background
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFE0BBE4), // pastel purple
              Color(0xFFB5EAD7), // pastel green
              Color(0xFFFFDAC1), // peach
              Color(0xFFF3E1DD), // blush
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // Sun (blurry circle)
            Positioned(
              top: 80,
              left: 40,
              child: _BlurryCircle(
                color: Colors.yellow.withOpacity(0.16),
                size: 100,
              ),
            ),
            // Cloud icon
            Positioned(
              top: 180,
              right: 60,
              child: Icon(
                Icons.cloud,
                size: 90,
                color: Colors.white.withOpacity(0.18),
              ),
            ),
            // Grass/leaf (pastel semi-circle)
            Positioned(
              bottom: 120,
              left: 40,
              child: Container(
                width: 110,
                height: 55,
                decoration: BoxDecoration(
                  color: Colors.lightGreenAccent.withOpacity(0.14),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(60),
                    topRight: Radius.circular(60),
                  ),
                ),
              ),
            ),
            // Extra blurry circles
            Positioned(
              top: -70,
              left: -60,
              child: _BlurryCircle(
                color: Colors.purpleAccent.withOpacity(0.15),
                size: 160,
              ),
            ),
            Positioned(
              bottom: -50,
              right: -50,
              child: _BlurryCircle(
                color: Colors.blueAccent.withOpacity(0.13),
                size: 140,
              ),
            ),
            // Floating back button
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                    tooltip: 'Back',
                    iconSize: 30,
                    splashRadius: 24,
                  ),
                ),
              ),
            ),
            // Main UI content
            Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Card(
                      color: Colors.grey[900],
                      elevation: 8,
                      shape: const CircleBorder(),
                      child: Container(
                        width: 220,
                        height: 220,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Colors.black, Colors.grey],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: 1 -
                                  (_secondsRemaining /
                                      (_isWorking
                                          ? _workDuration
                                          : _breakDuration)),
                              strokeWidth: 10,
                              backgroundColor: Colors.grey[800],
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.tealAccent),
                            ),
                            Text(
                              _formatTime(_secondsRemaining),
                              style: const TextStyle(
                                fontSize: 48,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _isWorking
                          ? 'Stay productive and focused! 🎯'
                          : 'Relax and recharge! 😊',
                      style: const TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 36),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _isRunning ? null : _startTimer,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 22, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon:
                              const Icon(Icons.play_arrow, color: Colors.white),
                          label: const Text('Start',
                              style:
                                  TextStyle(fontSize: 20, color: Colors.white)),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          onPressed: _isRunning ? _pauseTimer : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 22, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.pause, color: Colors.white),
                          label: const Text('Pause',
                              style:
                                  TextStyle(fontSize: 20, color: Colors.white)),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          onPressed: _resetTimer,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 22, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.refresh, color: Colors.white),
                          label: const Text('Reset',
                              style:
                                  TextStyle(fontSize: 20, color: Colors.white)),
                        ),
                      ],
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: _showSettings ? 170 : 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                      child: _showSettings
                          ? Column(
                              children: [
                                TextField(
                                  style: const TextStyle(color: Colors.white),
                                  decoration: const InputDecoration(
                                    labelText: 'Work Duration (minutes)',
                                    labelStyle: TextStyle(color: Colors.white),
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    final minutes = int.tryParse(value) ?? 25;
                                    _updateDurations(
                                        minutes, _breakDuration ~/ 60);
                                  },
                                ),
                                const SizedBox(height: 10),
                                TextField(
                                  style: const TextStyle(color: Colors.white),
                                  decoration: const InputDecoration(
                                    labelText: 'Break Duration (minutes)',
                                    labelStyle: TextStyle(color: Colors.white),
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    final minutes = int.tryParse(value) ?? 5;
                                    _updateDurations(
                                        _workDuration ~/ 60, minutes);
                                  },
                                ),
                              ],
                            )
                          : const SizedBox.shrink(),
                    ),
                    if (_showSettings) const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            // Floating settings toggle button at top right
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: Icon(
                      _showSettings ? Icons.close : Icons.settings,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: () {
                      setState(() {
                        _showSettings = !_showSettings;
                      });
                    },
                    tooltip: 'Settings',
                    splashRadius: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper widget for blurry colored circles
class _BlurryCircle extends StatelessWidget {
  final Color color;
  final double size;

  const _BlurryCircle({required this.color, required this.size, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(color: color, blurRadius: 40, spreadRadius: 10),
        ],
      ),
    );
  }
}
