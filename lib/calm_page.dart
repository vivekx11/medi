import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'dart:async';

import 'user_streaks.dart';

class CalmPage extends StatefulWidget {
  const CalmPage({super.key});

  @override
  State<CalmPage> createState() => _CalmPageState();
}

class _CalmPageState extends State<CalmPage> {
  final TextEditingController _taskController = TextEditingController();
  TimeOfDay? _selectedTime;
  String? _task;
  bool _isTaskSet = false;
  Timer? _timer;

  late FlutterLocalNotificationsPlugin _notificationsPlugin;

  @override
  void initState() {
    super.initState();
    _initNotifications();
    _startTimeCheck();
  }

  Future<void> _initNotifications() async {
    _notificationsPlugin = FlutterLocalNotificationsPlugin();
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _notificationsPlugin.initialize(initSettings);
  }

  Future<void> _showTaskNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'task_channel',
      'Task Reminder',
      importance: Importance.max,
      priority: Priority.high,
    );
    const notificationDetails = NotificationDetails(android: androidDetails);
    await _notificationsPlugin.show(
      0,
      '📋 Task Reminder',
      'Time to work on: $_task',
      notificationDetails,
    );
  }

  Future<void> _saveCompletedTask(String taskName) async {
    final box = Hive.box('tasksBox');
    final today = DateTime.now();
    final taskData = {
      "task": taskName,
      "date": today.toIso8601String(),
    };
    List completed = box.get('completedTasks', defaultValue: []);
    completed.add(taskData);
    await box.put('completedTasks', completed);
  }

  void _startTimeCheck() {
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      if (_selectedTime != null && _isTaskSet) {
        final now = TimeOfDay.now();
        if (now.hour == _selectedTime!.hour &&
            now.minute == _selectedTime!.minute) {
          await _showTaskNotification();
          HapticFeedback.lightImpact();
          await _saveCompletedTask(_task ?? "");
          setState(() {
            _isTaskSet = false;
            _task = null;
            _selectedTime = null;
            _taskController.clear();
          });
        }
      }
    });
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.tealAccent,
              surface: Color(0xFF20223A),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.tealAccent,
              ),
            ),
            dialogBackgroundColor: Colors.blueGrey[900],
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _setTask() {
    if (_taskController.text.isNotEmpty && _selectedTime != null) {
      setState(() {
        _task = _taskController.text;
        _isTaskSet = true;
      });
    }
  }

  void _cancelTask() {
    setState(() {
      _isTaskSet = false;
      _task = null;
      _selectedTime = null;
      _taskController.clear();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _taskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            // Sun element
            Positioned(
              top: 80,
              left: 40,
              child: _BlurryCircle(
                color: Colors.yellow.withOpacity(0.16),
                size: 100,
              ),
            ),
            // Cloud element
            Positioned(
              top: 180,
              right: 60,
              child: Icon(
                Icons.cloud,
                size: 90,
                color: Colors.white.withOpacity(0.18),
              ),
            ),
            // Grass/leaf element
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
            // Floating back button ONLY (no AppBar)
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
            // Your main UI overlays
            SafeArea(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: _isTaskSet
                    ? _buildTaskScreen(context)
                    : _buildSetupScreen(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSetupScreen(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 26),
      child: Center(
        child: SingleChildScrollView(
          child: Card(
            elevation: 12,
            color: Colors.black.withOpacity(0.23), // Dark violet with opacity

            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 42.0, horizontal: 26),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    " Set Your Daily Task🎯",
                    style: GoogleFonts.poppins(
                      color: Colors.tealAccent,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 38),
                  TextField(
                    controller: _taskController,
                    style:
                        GoogleFonts.poppins(color: Colors.white, fontSize: 17),
                    decoration: InputDecoration(
                      hintText: "What will you accomplish?",
                      hintStyle: GoogleFonts.poppins(
                          color: Colors.white54, fontSize: 15),
                      prefixIcon: Icon(
                        Icons.edit_note,
                        color: Colors.black.withOpacity(0.23),
                      ),
                      filled: true,
                      fillColor: Colors.white10,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 23),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.teal.withOpacity(0.85),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      side: BorderSide.none,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 15),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.alarm, color: Colors.white),
                    label: Text(
                      _selectedTime == null
                          ? "Pick Time"
                          : _selectedTime!.format(context),
                      style: GoogleFonts.poppins(
                          fontSize: 16, color: Colors.white),
                    ),
                    onPressed: () => _selectTime(context),
                  ),
                  const SizedBox(height: 18),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 36, vertical: 16),
                      elevation: 10,
                    ),
                    icon: const Icon(Icons.check),
                    label: Text(
                      "Set Task",
                      style: GoogleFonts.poppins(
                          fontSize: 17, color: Colors.white),
                    ),
                    onPressed: _setTask,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskScreen(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 26),
      child: Center(
        child: Card(
          elevation: 20,
          color: Colors.deepPurpleAccent.withOpacity(0.1),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.flag_rounded, color: Colors.tealAccent, size: 48),
                const SizedBox(height: 18),
                Text(
                  "Your Task Is Set!",
                  style: GoogleFonts.poppins(
                    color: Colors.tealAccent,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  _task ?? '',
                  style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 6, horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.tealAccent.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _selectedTime != null
                        ? "Scheduled at: ${_selectedTime!.format(context)}"
                        : "",
                    style: GoogleFonts.poppins(
                        color: Colors.teal[200],
                        fontSize: 16,
                        fontWeight: FontWeight.normal),
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  icon: const Icon(Icons.cancel),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 36, vertical: 14),
                    elevation: 8,
                  ),
                  label: Text(
                    "Cancel Task",
                    style:
                        GoogleFonts.poppins(color: Colors.white, fontSize: 16),
                  ),
                  onPressed: _cancelTask,
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Helper widget for blurry, colored circles
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
          BoxShadow(
            color: color,
            blurRadius: 40,
            spreadRadius: 10,
          ),
        ],
      ),
    );
  }
}
