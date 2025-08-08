import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AssistantPage extends StatefulWidget {
  const AssistantPage({super.key});

  @override
  State<AssistantPage> createState() => _AssistantPageState();
}

class _AssistantPageState extends State<AssistantPage> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, String>> messages = [];
  bool _isLoading = false;

  // Replace with your actual Perplexity API key
  final String perplexityApiKey = "YOUR_PERPLEXITY_API_KEY";

  Future<void> getAssistantReply(String userInput) async {
    setState(() {
      _isLoading = true;
      messages.add({"role": "user", "content": userInput});
    });

    const model = "sonar-small-online";
    final url = Uri.parse("https://api.perplexity.ai/chat/completions");
    final headers = {
      "Authorization": "Bearer $perplexityApiKey",
      "Content-Type": "application/json",
    };
    final body = jsonEncode({
      "model": model,
      "messages": messages,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply = data['choices'][0]['message']['content'];
        setState(() {
          messages.add({"role": "assistant", "content": reply});
        });
      } else {
        setState(() {
          messages.add({
            "role": "assistant",
            "content":
                "⚠️ Error: ${jsonDecode(response.body)['error']['message']}"
          });
        });
      }
    } catch (e) {
      setState(() {
        messages.add({
          "role": "assistant",
          "content": "❗ An error occurred. Please try again later."
        });
      });
    } finally {
      _controller.clear();
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Fullscreen background with floating back button
      body: SizedBox.expand(
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
              // Background blurry circles for ambiance
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

              // Floating back button - safe area & padding to avoid notches
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(24),
                        splashColor: Colors.white24,
                        onTap: () {
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          } else {
                            // Optional: show a toast/snackbar or do nothing
                          }
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(6),
                          child: Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Main content area
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: ListView.builder(
                            reverse: false,
                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                              final msg = messages[index];
                              return Align(
                                alignment: msg['role'] == 'user'
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: msg['role'] == 'user'
                                        ? Colors.deepPurple[100]
                                        : Colors.grey[200],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    msg['content'] ?? '',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              enabled: !_isLoading,
                              decoration: InputDecoration(
                                hintText: 'Ask your assistant...',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onSubmitted: (value) {
                                final input = value.trim();
                                if (input.isNotEmpty && !_isLoading) {
                                  getAssistantReply(input);
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : const Icon(Icons.send,
                                    color: Colors.deepPurple),
                            onPressed: _isLoading
                                ? null
                                : () {
                                    final input = _controller.text.trim();
                                    if (input.isNotEmpty) {
                                      getAssistantReply(input);
                                    }
                                  },
                          ),
                        ],
                      ),
                    ],
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

// Blurry circle widget from SleepPage for consistency
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
