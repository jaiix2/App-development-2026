import 'package:flutter/material.dart';

// ============================================================================
// 1. MAIN ENTRY POINT
// ============================================================================
// Summary: Every Flutter app starts here. runApp() takes your root widget and
// attaches it to the screen, kicking off the framework's build-and-render pipeline.
// Reference: https://api.flutter.dev/flutter/widgets/runApp.html
void main() {
  runApp(const TactileDeckApp());
}

// ============================================================================
// 2. ROOT APPLICATION WIDGET (Manages Global Theme State)
// ============================================================================
// Summary: A StatefulWidget that owns the single source of truth for light/dark
// mode. MaterialApp reads isDarkMode to pick a theme, and onToggleTheme lets the
// child screen flip it via a callback — no need to pass data back up manually.
// Reference: https://docs.flutter.dev/cookbook/design/themes
class TactileDeckApp extends StatefulWidget {
  const TactileDeckApp({super.key});

  @override
  State<TactileDeckApp> createState() => _TactileDeckAppState();
}

class _TactileDeckAppState extends State<TactileDeckApp> {
  // Global theme toggle variable (carried over from Activity 02!)
  bool isDarkMode = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cyber-Tactile Control Studio',
      debugShowCheckedModeBanner: false,
      // Apply Material 3 Dark or Light theme based on state
      theme: isDarkMode
          ? ThemeData.dark(useMaterial3: true)
          : ThemeData.light(useMaterial3: true),
      home: ControlDeckScreen(
        isDark: isDarkMode,
        // Callback function to toggle theme mode from child widget
        onToggleTheme: () => setState(() => isDarkMode = !isDarkMode),
      ),
    );
  }
}

// ============================================================================
// 3. MAIN DASHBOARD SCREEN (Stateful Controller)
// ============================================================================
// Summary: The screen users actually see. Its State object holds totalTaps,
// powerLevel, and systemStatus, and rebuilds the metrics card, status banner,
// buttons, and slider every time setState() runs.
// Reference: https://api.flutter.dev/flutter/material/Scaffold-class.html
class ControlDeckScreen extends StatefulWidget {
  final bool isDark;
  final VoidCallback onToggleTheme;
  const ControlDeckScreen({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
  });

  @override
  State<ControlDeckScreen> createState() => _ControlDeckScreenState();
}

class _ControlDeckScreenState extends State<ControlDeckScreen> {
  // --- Mutable State Variables (Day 3 Core Concept!) ---
  int totalTaps = 0;             // Increments on every button press
  double powerLevel = 65.0;      // Controlled by the interactive slider
  String systemStatus = "READY"; // Displays latest activated command

  // Helper method to update dashboard state upon button press
  void _triggerAction(String actionName) {
    setState(() {
      totalTaps++;
      systemStatus = "$actionName ACTIVATED";
    });
  }

  @override
  Widget build(BuildContext context) {
  bool isOverload = powerLevel > 80;
  final screenBg = isOverload
      ? const Color.fromARGB(255, 216, 48, 6)
      : widget.isDark
          ? const Color(0xFF1E1F29)
          : const Color(0xFFE0E5EC);
  final cardBg = widget.isDark
      ? const Color(0xFF282A36)
      : Colors.white;

    return Scaffold(
      backgroundColor: screenBg,
      appBar: AppBar(
        title: const Text(
          "TACTILE CONTROL STUDIO",
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2, fontSize: 18),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // Theme Toggle Button in the AppBar
          IconButton(
            icon: Icon(widget.isDark ? Icons.light_mode : Icons.dark_mode),
            tooltip: 'Toggle Theme',
            onPressed: widget.onToggleTheme,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // --- TOP STATUS METRICS CARD ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(widget.isDark ? 0.3 : 0.08),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Total Taps Counter
                  Column(
                    children: [
                      const Text("TOTAL TAPS", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                      const SizedBox(height: 4),
                      Text("$totalTaps", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  // Vertical Divider Line
                  Container(width: 1, height: 40, color: Colors.grey.withOpacity(0.3)),
                  // Energy / Power Level Indicator
                  Column(
                    children: [
                      const Text("ENERGY LEVEL", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                      const SizedBox(height: 4),
                      Text("${powerLevel.toInt()}%", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Live System Status Banner
            Text(
              "STATUS: $systemStatus",
              style: TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.w600,
                color: widget.isDark ? Colors.tealAccent : Colors.teal.shade700,
              ),
            ),
            const SizedBox(height: 28),

            // --- 2x2 GRID OF TACTILE 3D BUTTONS ---
            Wrap(
              spacing: 20,
              runSpacing: 20,
              alignment: WrapAlignment.center,
              children: [
                TactileButton(
                  icon: Icons.lightbulb,
                  label: "LIGHTS",
                  accentColor: Colors.amber,
                  isDark: widget.isDark,
                  onPressed: () => _triggerAction("LAMP"),
                ),
                TactileButton(
                  icon: Icons.air,
                  label: "AC",
                  accentColor: Colors.tealAccent,
                  isDark: widget.isDark,
                  onPressed: () => _triggerAction("AIR CONTROL"),
                ),
                TactileButton(
                  icon: Icons.waves,
                  label: "Ambiance",
                  accentColor: Colors.purpleAccent,
                  isDark: widget.isDark,
                  onPressed: () => _triggerAction("AMBIENT GLOW"),
                ),
                TactileButton(
                  icon: Icons.fire_extinguisher,
                  label: "HEAT",
                  accentColor: Colors.redAccent,
                  isDark: widget.isDark,
                  onPressed: () => _triggerAction("HEAT"),
                ),
              ],
            ),
            const SizedBox(height: 36),

            // --- INTERACTIVE CALIBRATION SLIDER ---
            Text(
              "Power Calibration: ${powerLevel.toInt()}%",
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            Slider(
              value: powerLevel,
              min: 0,
              max: 100,
              activeColor: Colors.blueAccent,
              inactiveColor: Colors.grey.withOpacity(0.3),
              // setState updates powerLevel immediately during slider drag
              onChanged: (newVal) => setState(() => powerLevel = newVal),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 4. REUSABLE TACTILE 3D BUTTON WIDGET
// ============================================================================
// Summary: A self-contained StatefulWidget that tracks its own isPressed flag
// and uses GestureDetector + two opposing BoxShadows to fake a physical
// push-button depress-and-release effect — no external packages required.
// Reference: https://api.flutter.dev/flutter/widgets/GestureDetector-class.html
class TactileButton extends StatefulWidget {
  final IconData icon;          // Icon to display in center
  final String label;           // Button title text
  final Color accentColor;      // Active glow color
  final bool isDark;            // Light or Dark theme mode
  final VoidCallback onPressed; // Action callback triggered on tap

  const TactileButton({
    super.key,
    required this.icon,
    required this.label,
    required this.accentColor,
    required this.isDark,
    required this.onPressed,
  });

  @override
  State<TactileButton> createState() => _TactileButtonState();
}

class _TactileButtonState extends State<TactileButton> {
  // Local boolean state tracking whether button is currently being held down
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    // Determine dynamic background and shadow colors
    final baseColor = widget.isDark ? const Color(0xFF222430) : const Color(0xFFE0E5EC);
    final darkShadow = widget.isDark ? Colors.black87 : const Color(0xFFA3B1C6);
    final lightShadow = widget.isDark ? const Color(0xFF2F3244) : Colors.white;

    return GestureDetector(
      // 1. User touches button -> depress button
      onTapDown: (_) => setState(() => isPressed = true),
      // 2. User releases button -> restore position and fire callback
      onTapUp: (_) {
        setState(() => isPressed = false);
        widget.onPressed();
      },
      // 3. User cancels touch -> restore position safely
      onTapCancel: () => setState(() => isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100), // Smooth 100ms spring transition
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(24),
          // Dual opposing BoxShadows create the 3D Neomorphic depth effect
          boxShadow: isPressed
              ? [
                  // Pressed (Sunken) Shadow Offsets
                  BoxShadow(color: darkShadow.withOpacity(0.5), offset: const Offset(2, 2), blurRadius: 4),
                  BoxShadow(color: lightShadow.withOpacity(0.5), offset: const Offset(-2, -2), blurRadius: 4),
                ]
              : [
                  // Unpressed (Elevated) Shadow Offsets
                  BoxShadow(color: darkShadow.withOpacity(0.7), offset: const Offset(8, 8), blurRadius: 16),
                  BoxShadow(color: lightShadow.withOpacity(0.9), offset: const Offset(-8, -8), blurRadius: 16),
                ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Dynamic Icon that changes size and glows on press
            Icon(
              widget.icon,
              size: isPressed ? 40 : 46,
              color: isPressed ? widget.accentColor : (widget.isDark ? Colors.white70 : Colors.black87),
            ),
            const SizedBox(height: 8),
            // Button Label
            Text(
              widget.label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 1.1,
                color: isPressed ? widget.accentColor : (widget.isDark ? Colors.white54 : Colors.black54),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
          