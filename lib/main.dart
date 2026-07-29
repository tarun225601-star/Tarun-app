import 'package:flutter/material.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Calculator App',
      home: CalculatorHomePage(),
    );
  }
}

class CalculatorHomePage extends StatefulWidget {
  const CalculatorHomePage({Key? key}) : super(key: key);

  @override
  State<CalculatorHomePage> createState() => _CalculatorHomePageState();
}

class _CalculatorHomePageState extends State<CalculatorHomePage> {
  String _currentNumber = '';
  String _history = '';
  double? _currentResult;

  void _onButtonPressed(String value) {
    setState(() {
      if (value == 'C') {
        _currentNumber = '';
        _history = '';
        _currentResult = null;
      } else if (value == '=') {
        try {
          _currentResult = _calculateResult(_currentNumber);
          _history = _currentNumber + ' = ' + _currentResult.toString();
          _currentNumber = _currentResult.toString();
        } catch (e) {
          _history = 'Error: ' + e.toString();
          _currentNumber = '';
        }
      } else {
        _currentNumber += value;
        _history = _currentNumber;
      }
    });
  }

  double? _calculateResult(String equation) {
    try {
      return _parseEquation(equation);
    } catch (e) {
      throw Exception('Error parsing equation: $e');
    }
  }

  double _parseEquation(String equation) {
    equation = equation.replaceAll(' ', '');
    if (equation.contains('+')) {
      final parts = equation.split('+');
      return _parseEquation(parts[0]) + _parseEquation(parts[1]);
    } else if (equation.contains('-')) {
      final parts = equation.split('-');
      return _parseEquation(parts[0]) - _parseEquation(parts[1]);
    } else if (equation.contains('*')) {
      final parts = equation.split('*');
      return _parseEquation(parts[0]) * _parseEquation(parts[1]);
    } else if (equation.contains('/')) {
      final parts = equation.split('/');
      return _parseEquation(parts[0]) / _parseEquation(parts[1]);
    } else {
      return double.parse(equation);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculator App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: TextField(
                readOnly: true,
                controller: TextEditingController(text: _currentNumber),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter a number',
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(_history),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 4,
              childAspectRatio: 1.5,
              children: [
                ElevatedButton(
                  onPressed: () => _onButtonPressed('7'),
                  child: const Text('7'),
                ),
                ElevatedButton(
                  onPressed: () => _onButtonPressed('8'),
                  child: const Text('8'),
                ),
                ElevatedButton(
                  onPressed: () => _onButtonPressed('9'),
                  child: const Text('9'),
                ),
                ElevatedButton(
                  onPressed: () => _onButtonPressed('/'),
                  child: const Text('/'),
                ),
                ElevatedButton(
                  onPressed: () => _onButtonPressed('4'),
                  child: const Text('4'),
                ),
                ElevatedButton(
                  onPressed: () => _onButtonPressed('5'),
                  child: const Text('5'),
                ),
                ElevatedButton(
                  onPressed: () => _onButtonPressed('6'),
                  child: const Text('6'),
                ),
                ElevatedButton(
                  onPressed: () => _onButtonPressed('*'),
                  child: const Text('*'),
                ),
                ElevatedButton(
                  onPressed: () => _onButtonPressed('1'),
                  child: const Text('1'),
                ),
                ElevatedButton(
                  onPressed: () => _onButtonPressed('2'),
                  child: const Text('2'),
                ),
                ElevatedButton(
                  onPressed: () => _onButtonPressed('3'),
                  child: const Text('3'),
                ),
                ElevatedButton(
                  onPressed: () => _onButtonPressed('-'),
                  child: const Text('-'),
                ),
                ElevatedButton(
                  onPressed: () => _onButtonPressed('0'),
                  child: const Text('0'),
                ),
                ElevatedButton(
                  onPressed: () => _onButtonPressed('.'),
                  child: const Text('.'),
                ),
                ElevatedButton(
                  onPressed: () => _onButtonPressed('='),
                  child: const Text('='),
                ),
                ElevatedButton(
                  onPressed: () => _onButtonPressed('+'),
                  child: const Text('+'),
                ),
                ElevatedButton(
                  onPressed: () => _onButtonPressed('C'),
                  child: const Text('C'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}