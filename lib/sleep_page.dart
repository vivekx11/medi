import 'package:flutter/material.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

class SleepPage extends StatefulWidget {
  const SleepPage({super.key});

  @override
  State<SleepPage> createState() => _SleepPageState();
}

class _SleepPageState extends State<SleepPage>
    with SingleTickerProviderStateMixin {
  int _sleepDuration = 6 * 60 * 60; // default 6 hours in seconds
  int _secondsRemaining = 6 * 60 * 60;
  bool _isRunning = false;
  bool _showPositiveMessage = false;
  Timer? _timer;
  final TextEditingController _controller = TextEditingController(text: "6");

  final AudioPlayer _audioPlayer = AudioPlayer();

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // AnimationController drives the scale animation from 0.95 to 1.05
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    _audioPlayer.dispose();
    _animationController.dispose();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final h = (seconds ~/ 3600).toString().padLeft(2, '0');
    final m = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return "$h:$m:$s";
  }

  void _startTimer() {
    if (_isRunning) return;
    if (_secondsRemaining <= 0) return;

    setState(() {
      _isRunning = true;
      _showPositiveMessage = false; // hide message on start
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _timer?.cancel();
          _isRunning = false;
          _showPositiveMessage = true;
          _playEndSound();
        }
      });
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _showPositiveMessage = false;
      _secondsRemaining = _sleepDuration;
    });
  }

  void _updateDuration() {
    final inputHours = int.tryParse(_controller.text);
    if (inputHours == null || inputHours <= 0) return;
    setState(() {
      _sleepDuration = inputHours * 60 * 60;
      _secondsRemaining = _sleepDuration;
      _showPositiveMessage = false;
    });
  }

  Future<void> _playEndSound() async {
    // Ensure meditation_end.mp3 is placed in assets/sounds/ and declared in pubspec.yaml
    await _audioPlayer.play(AssetSource('sounds/meditation_end.mp3'),
        volume: 0.7);
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    final isEnabled = onPressed != null;

    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon,
          size: 18, color: isEnabled ? Colors.white : Colors.white38),
      label: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          color: isEnabled ? Colors.white : Colors.white38,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: isEnabled ? Colors.teal : Colors.teal.shade700,
        elevation: isEnabled ? 6 : 2,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        minimumSize: const Size(80, 40),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        // Full screen container
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
              // Background blurry circles and shapes
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

              // Floating back button - SafeArea ensures not to be under status bar
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon:
                          const Icon(Icons.arrow_back_ios, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                      tooltip: 'Back',
                      iconSize: 30,
                      splashRadius: 24,
                    ),
                  ),
                ),
              ),

              // Main Content
              Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "How many hours do you want to sleep?",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _controller,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Hours',
                            labelStyle: const TextStyle(color: Colors.white70),
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                                  const BorderSide(color: Colors.tealAccent),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.tealAccent, width: 2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.1),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 14),
                          ),
                          enabled: !_isRunning,
                          onSubmitted: (_) => _updateDuration(),
                        ),
                        const SizedBox(height: 48),
                        ScaleTransition(
                          scale: _scaleAnimation,
                          child: Text(
                            _formatTime(_secondsRemaining),
                            style: const TextStyle(
                              fontSize: 70,
                              fontWeight: FontWeight.bold,
                              color: Colors.tealAccent,
                              shadows: [
                                Shadow(
                                  color: Colors.black54,
                                  offset: Offset(2, 2),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 48),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildActionButton(
                              label: "Start",
                              icon: Icons.play_arrow_rounded,
                              onPressed: _isRunning
                                  ? null
                                  : () {
                                      _updateDuration();
                                      _startTimer();
                                    },
                            ),
                            const SizedBox(width: 12),
                            _buildActionButton(
                              label: "Pause",
                              icon: Icons.pause_rounded,
                              onPressed: _isRunning ? _pauseTimer : null,
                            ),
                            const SizedBox(width: 12),
                            _buildActionButton(
                              label: "Reset",
                              icon: Icons.restart_alt_rounded,
                              onPressed: _resetTimer,
                            ),
                          ],
                        ),
                        const SizedBox(height: 60),
                        if (_showPositiveMessage)
                          Card(
                            color: Colors.teal.shade700.withOpacity(0.9),
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 20),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(
                                    Icons.celebration_rounded,
                                    color: Colors.amberAccent,
                                    size: 32,
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      "🎉 Great job! Hope you had a restful sleep! 😊",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
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
