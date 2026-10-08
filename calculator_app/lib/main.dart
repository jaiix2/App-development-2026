import 'package:flutter/material.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatefulWidget {
  const CalculatorApp({super.key});

  @override
  State<CalculatorApp> createState() => _CalculatorAppState();
}

class _CalculatorAppState extends State<CalculatorApp> {
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calculator',

      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.light,
        useMaterial3: true,
      ),

      darkTheme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),

      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,

      home: CalculatorScreen(
        isDarkMode: _isDarkMode,
        onThemeChanged: (value) {
          setState(() {
            _isDarkMode = value;
          });
        },
      ),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;

  const CalculatorScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _display = '0';

  double? _firstOperand;
  String? _operator;
  bool _waitingForSecondNumber = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculator'),
        actions: [
          Row(
            children: [
              const Icon(Icons.light_mode),
              Switch(
                value: widget.isDarkMode,
                onChanged: widget.onThemeChanged,
              ),
              const Icon(Icons.dark_mode),
              const SizedBox(width: 8),
            ],
          ),
        ],
      ),

      body: Column(
        children: [
          // Calculator display
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              alignment: Alignment.bottomRight,
              padding: const EdgeInsets.all(24),
              child: Text(
                _display,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Calculator buttons
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(child: _calculatorButton('7')),
                        const SizedBox(width: 8),
                        Expanded(child: _calculatorButton('8')),
                        const SizedBox(width: 8),
                        Expanded(child: _calculatorButton('9')),
                        const SizedBox(width: 8),
                        Expanded(child: _calculatorButton('÷')),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  Expanded(
                    child: Row(
                      children: [
                        Expanded(child: _calculatorButton('4')),
                        const SizedBox(width: 8),
                        Expanded(child: _calculatorButton('5')),
                        const SizedBox(width: 8),
                        Expanded(child: _calculatorButton('6')),
                        const SizedBox(width: 8),
                        Expanded(child: _calculatorButton('×')),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  Expanded(
                    child: Row(
                      children: [
                        Expanded(child: _calculatorButton('1')),
                        const SizedBox(width: 8),
                        Expanded(child: _calculatorButton('2')),
                        const SizedBox(width: 8),
                        Expanded(child: _calculatorButton('3')),
                        const SizedBox(width: 8),
                        Expanded(child: _calculatorButton('−')),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  Expanded(
                    child: Row(
                      children: [
                        Expanded(child: _calculatorButton('0')),
                        const SizedBox(width: 8),
                        Expanded(child: _calculatorButton('AC')),
                        const SizedBox(width: 8),
                        Expanded(child: _calculatorButton('±')),
                        const SizedBox(width: 8),
                        Expanded(child: _calculatorButton('+')),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  Expanded(
                    child: _calculatorButton('='),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _calculatorButton(String text) {
    return ElevatedButton(
      onPressed: () {
        _buttonPressed(text);
      },
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 24,
        ),
      ),
    );
  }

  void _buttonPressed(String text) {
    setState(() {
      // Clear / All Clear
      if (text == 'AC') {
        _display = '0';
        _firstOperand = null;
        _operator = null;
        _waitingForSecondNumber = false;
        return;
      }

      // Positive / Negative
      if (text == '±') {
        if (_display != '0' && _display.isNotEmpty) {
          if (_display.startsWith('-')) {
            _display = _display.substring(1);
          } else {
            _display = '-$_display';
          }
        }
        return;
      }

      // Number buttons
      if (text == '0' ||
          text == '1' ||
          text == '2' ||
          text == '3' ||
          text == '4' ||
          text == '5' ||
          text == '6' ||
          text == '7' ||
          text == '8' ||
          text == '9') {
        if (_display == '0' || _waitingForSecondNumber) {
          _display = text;
          _waitingForSecondNumber = false;
        } else {
          _display += text;
        }
        return;
      }

      // Operators
      if (text == '+' ||
          text == '−' ||
          text == '×' ||
          text == '÷') {
        _firstOperand = double.tryParse(_display);
        _operator = text;
        _waitingForSecondNumber = true;
        return;
      }

      // Equals
      if (text == '=') {
        if (_firstOperand == null || _operator == null) {
          return;
        }

        final secondOperand = double.tryParse(_display);

        if (secondOperand == null) {
          return;
        }

        double result;

        switch (_operator) {
          case '+':
            result = _firstOperand! + secondOperand;
            break;

          case '−':
            result = _firstOperand! - secondOperand;
            break;

          case '×':
            result = _firstOperand! * secondOperand;
            break;

          case '÷':
            // Division by zero will be handled later.
            result = _firstOperand! / secondOperand;
            break;

          default:
            return;
        }

        _display = _formatResult(result);
        _firstOperand = null;
        _operator = null;
        _waitingForSecondNumber = true;
      }
    });
  }

  String _formatResult(double value) {
    if (value == value.toInt()) {
      return value.toInt().toString();
    }

    return value.toString();
  }
}