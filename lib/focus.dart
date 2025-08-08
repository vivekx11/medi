import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

import 'sleep_page.dart';
import 'stress_page.dart';
import 'focus_mode_page.dart';
import 'calm_page.dart';
import 'user_streaks.dart';
import 'meditation.dart';
import 'guid_meditation.dart';
import 'assistant.dart';
import 'setting.dart';

class FocusPage extends StatefulWidget {
  const FocusPage({Key? key}) : super(key: key);

  @override
  State<FocusPage> createState() => _FocusPageState();
}

class _FocusPageState extends State<FocusPage> {
  int _selectedIndex = 0;

  final List<_FocusOption> allOptions = const [
    _FocusOption(
      label: "Sleep",
      description: "Improve your rest",
      icon: Icons.nightlight_round,
      color: Color(0xFF8A88FF),
      page: SleepPage(),
    ),
    _FocusOption(
      label: "Daily Feels",
      description: "Track your feelings",
      icon: Icons.emoji_emotions_outlined,
      color: Color(0xFFF691C7),
      page: StressPage(),
    ),
    _FocusOption(
      label: "Focus",
      description: "Boost productivity",
      icon: Icons.center_focus_strong,
      color: Color(0xFFF691C7),
      page: FocusModePage(),
    ),
    _FocusOption(
      label: "Daily Task",
      description: "Achieve your goals",
      icon: Icons.checklist_rtl_sharp,
      color: Color(0xFF8A88FF),
      page: CalmPage(),
    ),
    _FocusOption(
      label: "Meditation",
      description: "Calm your mind",
      icon: Icons.self_improvement,
      color: Color(0xFF8A88FF),
      page: MeditationPage(),
    ),
    _FocusOption(
      label: "AI Assistant",
      description: "Get help instantly",
      icon: Icons.smart_toy_outlined,
      color: Color(0xFFF691C7),
      page: AssistantPage(),
    ),
  ];

  void _onNavTap(int index) {
    setState(() => _selectedIndex = index);
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const UserStreaksPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF191933),
      body: SafeArea(
        child: Stack(
          children: [
            // Decorative blurred circles
            Positioned(
              top: -80,
              left: -80,
              child: _BlurryCircle(
                  color: Colors.purpleAccent.withOpacity(0.18), size: 170),
            ),
            Positioned(
              bottom: -50,
              right: -50,
              child: _BlurryCircle(
                  color: Colors.blueAccent.withOpacity(0.14), size: 140),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: Column(
                children: [
                  const SizedBox(height: 14),
                  // Top Navigation Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "InnerWave",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 27,
                          letterSpacing: 0.5,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings, color: Colors.white70),
                        tooltip: 'Settings',
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const SettingsPage()));
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Guided Meditation Card with Lottie
                  _GuidedMeditationCard(),
                  const SizedBox(height: 22),
                  // 2x3 Grid for main element cards
                  Expanded(
                    child: GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: allOptions.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 18,
                        crossAxisSpacing: 18,
                        childAspectRatio: 1.00,
                      ),
                      itemBuilder: (context, index) =>
                          _FocusGlassCard(option: allOptions[index]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _BottomNavBar(
        selectedIndex: _selectedIndex,
        onTap: _onNavTap,
      ),
    );
  }
}

// Guided Meditation Card with Lottie animation
class _GuidedMeditationCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => GuidedMeditationPage())),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF9C27B0).withOpacity(0.19),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
              color: const Color(0xFF9C27B0).withOpacity(0.5), width: 2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF9C27B0).withOpacity(0.13),
              blurRadius: 12,
            )
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Lottie Animation
            Lottie.asset(
              'assets/animations/meditation1.json', // <-- Your lottie file asset
              width: 60,
              height: 60,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Guided Meditation",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Start your journey to mindfulness",
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  )
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                color: Colors.white38, size: 17)
          ],
        ),
      ),
    );
  }
}

// Focus tool card: icon centered at top, text below (centered)
class _FocusGlassCard extends StatelessWidget {
  final _FocusOption option;
  const _FocusGlassCard({required this.option, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => option.page)),
        child: Container(
          decoration: BoxDecoration(
            color: option.color.withOpacity(0.14),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: option.color.withOpacity(0.5), width: 2),
            boxShadow: [
              BoxShadow(color: option.color.withOpacity(0.12), blurRadius: 8)
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: option.color.withOpacity(0.21),
                child: Icon(option.icon, color: Colors.white, size: 30),
              ),
              const SizedBox(height: 12),
              Text(
                option.label,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16.4,
                ),
              ),
              if (option.description != null) ...[
                const SizedBox(height: 4),
                Text(
                  option.description!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 12.2,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// Bottom navigation bar
class _BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const _BottomNavBar(
      {required this.selectedIndex, required this.onTap, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final icons = [Icons.home_rounded, Icons.person_rounded];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 36, vertical: 13),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
        border: Border.all(color: Colors.white30, width: 1.05),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: icons.asMap().entries.map((entry) {
          final idx = entry.key;
          final icon = entry.value;
          final active = idx == selectedIndex;

          return GestureDetector(
            onTap: () => onTap(idx),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 210),
              decoration: BoxDecoration(
                color: active
                    ? Colors.purpleAccent.withOpacity(0.31)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(8),
              child: Icon(icon,
                  color: active ? Colors.white : Colors.white60, size: 26),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// Option data class
class _FocusOption {
  final String label;
  final String? description;
  final IconData icon;
  final Color color;
  final Widget page;

  const _FocusOption({
    required this.label,
    this.description,
    required this.icon,
    required this.color,
    required this.page,
  });
}

// Blurry background circle for decoration
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
