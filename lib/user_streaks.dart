import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

class UserStreaksPage extends StatefulWidget {
  const UserStreaksPage({Key? key}) : super(key: key);

  @override
  State<UserStreaksPage> createState() => _UserStreaksPageState();
}

class _UserStreaksPageState extends State<UserStreaksPage> {
  late Box _box;
  List<Map<dynamic, dynamic>> _completedTasks = [];
  bool _loading = true;

  int totalTasks = 0;
  int currentStreak = 0;
  int bestStreak = 0;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    _box = Hive.box('tasksBox');
    List tasks = _box.get('completedTasks', defaultValue: []);
    _completedTasks = List<Map<dynamic, dynamic>>.from(tasks);
    totalTasks = _completedTasks.length;

    _calculateStreaks();
    setState(() => _loading = false);
  }

  void _calculateStreaks() {
    final Set<String> uniqueDates = _completedTasks.map((task) {
      final date = DateTime.parse(task['date']);
      return DateFormat('yyyy-MM-dd').format(date);
    }).toSet();

    final List<DateTime> sortedDates = uniqueDates
        .map((d) => DateTime.parse(d))
        .toList()
      ..sort((a, b) => b.compareTo(a)); // descending

    int streak = 0;
    int best = 0;
    DateTime today = DateTime.now();
    DateTime previousDate = today;

    for (final date in sortedDates) {
      if (date.difference(previousDate).inDays == -1 ||
          date.isAtSameMomentAs(today)) {
        streak++;
        previousDate = date;
      } else {
        best = best < streak ? streak : best;
        streak = 1;
        previousDate = date;
      }
    }

    bestStreak = best < streak ? streak : best;
    currentStreak = streak;
  }

  Widget _buildStatCard(String title, int value, Color color) {
    return Card(
      color: color.withOpacity(0.15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(title,
                style:
                    GoogleFonts.poppins(fontSize: 16, color: Colors.white70)),
            const SizedBox(height: 10),
            Text(value.toString(),
                style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.tealAccent)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFF191933), // Matched with focus.dart background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "User Dashboard",
          style: GoogleFonts.poppins(
            color: Colors.tealAccent,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Decorative blurry circles for background
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

            // Main scrollable content
            _loading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Your Stats",
                            style: GoogleFonts.poppins(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                                child: _buildStatCard(
                                    "Total Tasks", totalTasks, Colors.green)),
                            const SizedBox(width: 10),
                            Expanded(
                                child: _buildStatCard("Current Streak",
                                    currentStreak, Colors.orange)),
                            const SizedBox(width: 10),
                            Expanded(
                                child: _buildStatCard(
                                    "Best Streak", bestStreak, Colors.purple)),
                          ],
                        ),
                        const SizedBox(height: 25),
                        Text("Completed Tasks",
                            style: GoogleFonts.poppins(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 10),
                        _completedTasks.isEmpty
                            ? Center(
                                child: Text(
                                  "No tasks completed yet.",
                                  style: GoogleFonts.poppins(
                                    color: Colors.white70,
                                    fontSize: 18,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                itemCount: _completedTasks.length,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  final revIndex =
                                      _completedTasks.length - index - 1;
                                  final task = _completedTasks[revIndex];
                                  final formattedDate = task['date'] == null
                                      ? ''
                                      : DateFormat('MMM d, y – hh:mm a')
                                          .format(DateTime.parse(task['date']));
                                  return Card(
                                    elevation: 8,
                                    color: Colors.blueGrey.shade800
                                        .withOpacity(0.7),
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 4),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: Colors.tealAccent,
                                        child: Icon(Icons.check,
                                            color: Colors.blueGrey.shade900),
                                      ),
                                      title: Text(
                                        task['task'] ?? '',
                                        style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      subtitle: Text(
                                        formattedDate,
                                        style: GoogleFonts.poppins(
                                            color: Colors.teal[100],
                                            fontSize: 14),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ],
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

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
          BoxShadow(color: color, blurRadius: 40, spreadRadius: 8),
        ],
      ),
    );
  }
}
