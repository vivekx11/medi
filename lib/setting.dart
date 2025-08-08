import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  Future<void> _launchUrl(Uri url, BuildContext context) async {
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not launch ${url.toString()}',
            style: GoogleFonts.poppins(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF191933), // Match focus.dart background
      appBar: AppBar(
        title: Text('Settings',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFF9C27B0),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Blurry background circles (same style as focus.dart)
            Positioned(
              top: -80,
              left: -80,
              child: _BlurryCircle(
                color: Colors.purpleAccent.withOpacity(0.18),
                size: 170,
              ),
            ),
            Positioned(
              bottom: -50,
              right: -50,
              child: _BlurryCircle(
                color: Colors.blueAccent.withOpacity(0.14),
                size: 140,
              ),
            ),

            // Main ListView content scrolls over background
            ListView(
              padding: const EdgeInsets.all(24),
              children: [
                // About Section
                ListTile(
                  leading: const Icon(Icons.info_outline,
                      color: Colors.purpleAccent),
                  title: Text('About',
                      style: GoogleFonts.poppins(color: Colors.white)),
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: "Medtion",
                      applicationVersion: "2.0.0",
                      applicationLegalese:
                          "©2025 Medtion Team\nBreathe. Relax. Transform.",
                      applicationIcon: const Icon(Icons.self_improvement,
                          size: 40, color: Colors.purpleAccent),
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Text(
                            'Medtion helps you find focus, calm and mindfulness through guided meditation sessions and tools. Your journey to inner peace starts here.',
                            style: GoogleFonts.poppins(),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20),
                Divider(color: Colors.grey.shade800),
                const SizedBox(height: 20),

                // Footer with Socials
                Column(
                  children: [
                    Text(
                      '© 2025 Medtion',
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.email,
                              color: Colors.purpleAccent),
                          tooltip: 'Email',
                          onPressed: () => _launchUrl(
                              Uri.parse("mailto:hello@medtion.app"), context),
                        ),
                        IconButton(
                          icon: const Icon(Icons.camera_alt,
                              color: Colors.purpleAccent),
                          tooltip: 'Instagram',
                          onPressed: () => _launchUrl(
                              Uri.parse("https://instagram.com/yourmedtion"),
                              context),
                        ),
                        IconButton(
                          icon: const Icon(Icons.alternate_email,
                              color: Colors.purpleAccent),
                          tooltip: 'X',
                          onPressed: () => _launchUrl(
                              Uri.parse("https://x.com/yourmedtion"), context),
                        ),
                        IconButton(
                          icon: const Icon(Icons.code,
                              color: Colors.purpleAccent),
                          tooltip: 'GitHub',
                          onPressed: () => _launchUrl(
                              Uri.parse("https://github.com/medtion"), context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Blurry background circle widget (same as used in focus.dart, main.dart)
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
