import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'focus.dart'; // Your FocusPage
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('tasksBox');

  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Kolkata')); // Set to IST (India)

  runApp(const MeditationApp());
}

class MeditationApp extends StatelessWidget {
  const MeditationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meditation App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF191933),
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurpleAccent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(40),
            ),
            elevation: 8,
            shadowColor: Colors.deepPurple.withOpacity(0.5),
          ),
        ),
      ),
      home: const WelcomePage(),
    );
  }
}

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(duration: const Duration(seconds: 2), vsync: this)
          ..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.0, end: 10.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startFocusPage() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const FocusPage(),
        transitionsBuilder: (_, animation, __, child) => ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ),
          ),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        ),
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF191933), // match focus.dart background
      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Blurry purple circle top-left
            Positioned(
              top: -80,
              left: -80,
              child: _BlurryCircle(
                  color: Colors.purpleAccent.withOpacity(0.18), size: 170),
            ),
            // Blurry blue circle bottom-right
            Positioned(
              bottom: -50,
              right: -50,
              child: _BlurryCircle(
                  color: Colors.blueAccent.withOpacity(0.14), size: 140),
            ),

            // Main content with Lottie, text, button
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Lottie animation with scale effect
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1.0 + _controller.value * 0.05,
                      child: Lottie.asset(
                        'assets/animations/meditation.json',
                        height: 320,
                        fit: BoxFit.contain,
                      ),
                    );
                  },
                ),

                const SizedBox(height: 40),

                // Title text with fade-in animation
                FadeInText(
                  text: 'Find Your Inner Peace',
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.deepPurpleAccent.withOpacity(0.4),
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Subtitle text with fade-in animation and delay
                FadeInText(
                  text:
                      'Take a deep breath and begin your journey to calmness.',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    color: Colors.grey[200]!.withOpacity(0.9),
                    height: 1.5,
                  ),
                  delay: const Duration(milliseconds: 300),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 50),

                // Glowing Get Started Button with animation
                AnimatedBuilder(
                  animation: _glowAnimation,
                  builder: (context, child) {
                    return Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.deepPurpleAccent.withOpacity(0.4),
                            blurRadius: _glowAnimation.value,
                            spreadRadius: _glowAnimation.value / 2,
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _startFocusPage,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                          ),
                          elevation: 8,
                          shadowColor: Colors.deepPurple.withOpacity(0.5),
                        ),
                        child: Text(
                          'Get Started',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),

                // Created by text with subtle fade-in
                FadeInText(
                  text: 'Developed & Designed by VivekSawji',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[400],
                    fontStyle: FontStyle.italic,
                  ),
                  delay: const Duration(milliseconds: 600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Blurry background circle matching focus.dart style
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
        boxShadow: [BoxShadow(color: color, blurRadius: 40, spreadRadius: 8)],
      ),
    );
  }
}

// FadeInText widget reused from your existing code
class FadeInText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Duration delay;
  final TextAlign? textAlign;

  const FadeInText({
    super.key,
    required this.text,
    required this.style,
    this.delay = Duration.zero,
    this.textAlign,
  });

  @override
  _FadeInTextState createState() => _FadeInTextState();
}

class _FadeInTextState extends State<FadeInText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Text(
          widget.text,
          style: widget.style,
          textAlign: widget.textAlign,
        ),
      ),
    );
  }
}
