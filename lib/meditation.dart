import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/services.dart';

class MeditationPage extends StatefulWidget {
  const MeditationPage({super.key});

  @override
  State<MeditationPage> createState() => _MeditationPageState();
}

class _MeditationPageState extends State<MeditationPage>
    with TickerProviderStateMixin {
  int _selectedMinutes = 10;
  int _remainingSeconds = 0;
  bool _isMeditating = false;

  late AudioPlayer _audioPlayer;
  late FlutterLocalNotificationsPlugin _notificationsPlugin;
  late AnimationController _breathController;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initNotifications();
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
  }

  Future<void> _initNotifications() async {
    _notificationsPlugin = FlutterLocalNotificationsPlugin();
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _notificationsPlugin.initialize(initSettings);
  }

  Future<void> _showCompletionNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'meditation_channel',
      'Meditation Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
    const notificationDetails = NotificationDetails(android: androidDetails);
    await _notificationsPlugin.show(
      0,
      '🧘 Meditation Complete',
      'Great job finishing your session!',
      notificationDetails,
    );
  }

  void _startMeditation() {
    setState(() {
      _remainingSeconds = _selectedMinutes * 60;
      _isMeditating = true;
    });
    _countdown();
  }

  void _stopMeditation() {
    setState(() {
      _isMeditating = false;
      _remainingSeconds = 0;
    });
    _audioPlayer.stop();
  }

  void _countdown() async {
    while (_remainingSeconds > 0 && _isMeditating) {
      await Future.delayed(const Duration(seconds: 1));
      if (!_isMeditating) break;
      setState(() {
        _remainingSeconds--;
      });
    }
    if (_remainingSeconds == 0 && _isMeditating) {
      await _playCompletionSound();
      await _showCompletionNotification();
      HapticFeedback.mediumImpact();
      setState(() => _isMeditating = false);
    }
  }

  Future<void> _playCompletionSound() async {
    try {
      await _audioPlayer.play(AssetSource('chime.wav'));
    } catch (e) {
      debugPrint("Error playing sound: $e");
    }
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _breathController.dispose();
    super.dispose();
  }

  // Pastel gradient background (same as SleepPage) with floating background circles
  Widget _pastelBackground({required Widget child}) {
    return SizedBox.expand(
      child: Container(
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
            Positioned(
              top: 80,
              left: 40,
              child: _BlurryCircle(
                color: Colors.yellow.withOpacity(0.16),
                size: 100,
              ),
            ),
            Positioned(
              top: 180,
              right: 60,
              child: Icon(
                Icons.cloud,
                size: 90,
                color: Colors.white.withOpacity(0.18),
              ),
            ),
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
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                    iconSize: 30,
                    splashRadius: 24,
                  ),
                ),
              ),
            ),
            child,
          ],
        ),
      ),
    );
  }

  // --- Only text color has been updated to black below ---

  Widget _minutePillSelector() {
    final presets = [3, 5, 10, 15, 20, 30, 45];
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: presets.map((m) {
              final selected = _selectedMinutes == m;
              return GestureDetector(
                onTap: () => setState(() => _selectedMinutes = m),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 210),
                  margin: const EdgeInsets.symmetric(horizontal: 7),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    gradient: selected
                        ? const LinearGradient(
                            colors: [Color(0xFF7F53AC), Color(0xFF647DEE)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.10),
                              Colors.white.withOpacity(0.05)
                            ],
                          ),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                                color: Colors.purpleAccent.withOpacity(0.13),
                                blurRadius: 18,
                                offset: const Offset(0, 4))
                          ]
                        : [],
                    border: selected
                        ? Border.all(
                            color: Colors.white.withOpacity(0.7), width: 2)
                        : Border.all(color: Colors.white12, width: 1),
                  ),
                  child: Column(
                    children: [
                      Text('$m',
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          )),
                      Text('min',
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                Colors.black.withOpacity(selected ? 0.7 : 0.43),
                          )),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        _customMinuteField(),
      ],
    );
  }

  Widget _customMinuteField() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.timer_outlined, color: Colors.white54, size: 18),
        const SizedBox(width: 6),
        Container(
          width: 56,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(11),
          ),
          child: TextField(
            keyboardType: TextInputType.number,
            maxLength: 2,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(color: Colors.black, fontSize: 17),
            decoration: InputDecoration(
              border: InputBorder.none,
              counterText: '',
              hintText: '$_selectedMinutes',
              hintStyle: GoogleFonts.poppins(
                color: Colors.black54,
              ),
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
            onSubmitted: (v) {
              final input = int.tryParse(v);
              if (input != null && input > 0 && input <= 60) {
                setState(() => _selectedMinutes = input);
              }
            },
          ),
        ),
        const SizedBox(width: 8),
        Text(
          "minutes",
          style: GoogleFonts.poppins(
              color: Colors.black, fontSize: 15, fontWeight: FontWeight.w400),
        ),
      ],
    );
  }

  Widget _buildSetupScreen() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _glassCard(
              child: Text(
                "Select Meditation Length",
                style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 26),
            _minutePillSelector(),
            const SizedBox(height: 35),
            _purpleGradientButton(
              icon: Icons.spa_rounded,
              text: 'Start Meditation',
              onPressed: _startMeditation,
            ),
          ],
        ),
      ),
    );
  }

  Widget _glassCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: Colors.white12, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.09),
            blurRadius: 7,
            spreadRadius: 1,
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildMeditationScreen() {
    final progress =
        (_selectedMinutes * 60 - _remainingSeconds) / (_selectedMinutes * 60);
    final breath = (0.88 + 0.13 * _breathController.value);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _breathController,
            builder: (context, child) {
              return Transform.scale(scale: breath, child: child);
            },
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.purpleAccent
                        .withOpacity(0.18 + 0.12 * _breathController.value),
                    blurRadius: 44,
                    spreadRadius: 10,
                  ),
                ],
                gradient: RadialGradient(
                  colors: [
                    Colors.deepPurpleAccent.withOpacity(0.26),
                    Colors.transparent,
                  ],
                  radius: 0.99,
                ),
              ),
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 14,
                      backgroundColor: Colors.white12,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.purpleAccent),
                    ),
                    Text(
                      _formatTime(_remainingSeconds),
                      style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 38,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 35),
          Text(
            _breathController.value < 0.5 ? "Inhale..." : "Exhale...",
            style: GoogleFonts.poppins(
                color: Colors.black, fontSize: 22, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 45),
          _purpleGradientButton(
              icon: Icons.stop,
              text: "Stop",
              onPressed: _stopMeditation,
              gradientColors: [Colors.deepPurple, Colors.purple]),
        ],
      ),
    );
  }

  Widget _purpleGradientButton({
    required IconData icon,
    required String text,
    required VoidCallback onPressed,
    List<Color>? gradientColors,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 38, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: gradientColors ??
                [Colors.purpleAccent, Colors.deepPurpleAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
                color: (gradientColors?.first ?? Colors.purpleAccent)
                    .withOpacity(0.21),
                blurRadius: 14,
                spreadRadius: 2,
                offset: const Offset(0, 5))
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 25),
            const SizedBox(width: 11),
            Text(text,
                style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pastelBackground(
        child: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child:
                _isMeditating ? _buildMeditationScreen() : _buildSetupScreen(),
          ),
        ),
      ),
    );
  }
}

// Helper widget for blurry, colored circles background effect
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
