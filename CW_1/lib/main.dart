import 'package:flutter/material.dart';

void main() {
  runApp(const CounterImageToggleApp());
}

class CounterImageToggleApp extends StatelessWidget {
  const CounterImageToggleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CW1 Counter & Toggle',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _counter = 0;
  int _target = 20;
  bool _isDark = false;
  bool _isFirstImage = true;
  


  void _incrementCounter() {
    setState(() => _counter++);
  }

  void _decrementCounter() {
    setState(() {
      if (_counter > 0) _counter--;
    });
  }

  void _toggleTheme() {
    setState(() => _isDark = !_isDark);
  }

  void _resetCounter() {
    setState(() {
      _counter = 0;
    });
  }

  void _toggleImage() {
    setState(() => _isFirstImage = !_isFirstImage);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: _toggleTheme,
          child: Icon(_isDark ? Icons.light_mode : Icons.dark_mode),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
        appBar: AppBar(
          title: const Text('CW1 Counter & Toggle'),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Counter: $_counter',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _incrementCounter,
                child: const Text('Increment'),
              ),
              const SizedBox(height: 20),
              Text('Goal: $_counter / $_target'),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: (_counter / _target).clamp(0.0, 1.0),
                minHeight: 12,
              ),

              const SizedBox(height: 8),
              Text(
                _counter >= _target ? '🎉 Goal Reached!' : 'Keep going!',
              ), // goal reached display
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _decrementCounter,
                child: const Text('Decrement'),
              ),

              ElevatedButton(
                onPressed: _counter > 0 ? _resetCounter : null,
                child: const Text('Reset'),
              ),
              
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: Image.asset(
                  _isFirstImage ? 'assets/image1.png' : 'assets/image2.png',
                  key: ValueKey(_isFirstImage),
                  width: 180,
                  height: 180,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _toggleImage,
                child: const Text('Toggle Image'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}