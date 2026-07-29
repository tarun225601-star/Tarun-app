```dart
import 'package:flutter/material.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: CalculatorPage(),
    );
  }
}

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({Key? key}) : super(key: key);

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  final _textController = TextEditingController(text: '0');
  double _firstNumber = 0;
  double _secondNumber = 0;
  String _operator = '';
  bool _isFirstNumber = true;

  void _onNumberPressed(String number) {
    if (_isFirstNumber) {
      if (_textController.text == '0') {
        _textController.text = number;
        _firstNumber = double.parse(number);
      } else {
        _textController.text += number;
        _firstNumber = double.parse(_textController.text);
      }
    } else {
      if (_textController.text == '0') {
        _textController.text = number;
        _secondNumber = double.parse(number);
      } else {
        _textController.text += number;
        _secondNumber = double.parse(_textController.text);
      }
    }
  }

  void _onOperatorPressed(String operator) {
    _operator = operator;
    _isFirstNumber = false;
    _textController.text = '0';
  }

  void _onClearPressed() {
    _textController.text = '0';
    _firstNumber = 0;
    _secondNumber = 0;
    _operator = '';
    _isFirstNumber = true;
  }

  void _onEqualsPressed() {
    if (_operator == '+') {
      _textController.text = (_firstNumber + _secondNumber).toString();
    } else if (_operator == '-') {
      _textController.text = (_firstNumber - _secondNumber).toString();
    } else if (_operator == '*') {
      _textController.text = (_firstNumber * _secondNumber).toString();
    } else if (_operator == '/') {
      if (_secondNumber != 0) {
        _textController.text = (_firstNumber / _secondNumber).toString();
      } else {
        _textController.text = 'Error';
      }
    }
    _firstNumber = double.parse(_textController.text);
    _secondNumber = 0;
    _operator = '';
    _isFirstNumber = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _textController,
              readOnly: true,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => _onNumberPressed('7'),
                  child: const Text('7'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _onNumberPressed('8'),
                  child: const Text('8'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _onNumberPressed('9'),
                  child: const Text('9'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _onOperatorPressed('/'),
                  child: const Text('/'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => _onNumberPressed('4'),
                  child: const Text('4'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _onNumberPressed('5'),
                  child: const Text('5'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _onNumberPressed('6'),
                  child: const Text('6'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _onOperatorPressed('*'),
                  child: const Text('*'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => _onNumberPressed('1'),
                  child: const Text('1'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _onNumberPressed('2'),
                  child: const Text('2'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _onNumberPressed('3'),
                  child: const Text('3'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _onOperatorPressed('-'),
                  child: const Text('-'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => _onNumberPressed('0'),
                  child: const Text('0'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _onClearPressed,
                  child: const Text('C'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _onEqualsPressed,
                  child: const Text('='),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _onOperatorPressed('+'),
                  child: const Text('+'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```