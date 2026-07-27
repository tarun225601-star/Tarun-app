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
  final _textController = TextEditingController(text: '0');
  double _num1 = 0;
  double _num2 = 0;
  String _operator = '';
  bool _isNum1 = true;

  void _onButtonPressed(String value) {
    setState(() {
      if (value == '+' || value == '-' || value == '*' || value == '/') {
        _num1 = double.parse(_textController.text);
        _operator = value;
        _textController.text = '0';
        _isNum1 = false;
      } else if (value == '=') {
        _num2 = double.parse(_textController.text);
        switch (_operator) {
          case '+':
            _textController.text = (_num1 + _num2).toString();
            break;
          case '-':
            _textController.text = (_num1 - _num2).toString();
            break;
          case '*':
            _textController.text = (_num1 * _num2).toString();
            break;
          case '/':
            if (_num2 != 0) {
              _textController.text = (_num1 / _num2).toString();
            } else {
              _textController.text = 'Error';
            }
            break;
        }
        _isNum1 = true;
      } else if (value == 'C') {
        _textController.text = '0';
        _num1 = 0;
        _num2 = 0;
        _operator = '';
        _isNum1 = true;
      } else {
        if (_textController.text == '0') {
          _textController.text = value;
        } else {
          _textController.text += value;
        }
      }
    });
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
            TextField(
              controller: _textController,
              enabled: false,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _onButtonPressed('7'),
                  child: const Text('7', style: TextStyle(fontSize: 24)),
                ),
                ElevatedButton(
                  onPressed: () => _onButtonPressed('8'),
                  child: const Text('8', style: TextStyle(fontSize: 24)),
                ),
                ElevatedButton(
                  onPressed: () => _onButtonPressed('9'),
                  child: const Text('9', style: TextStyle(fontSize: 24)),
                ),
                ElevatedButton(
                  onPressed: () => _onButtonPressed('/'),
                  child: const Text('/', style: TextStyle(fontSize: 24)),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _onButtonPressed('4'),
                  child: const Text('4', style: TextStyle(fontSize: 24)),
                ),
                ElevatedButton(
                  onPressed: () => _onButtonPressed('5'),
                  child: const Text('5', style: TextStyle(fontSize: 24)),
                ),
                ElevatedButton(
                  onPressed: () => _onButtonPressed('6'),
                  child: const Text('6', style: TextStyle(fontSize: 24)),
                ),
                ElevatedButton(
                  onPressed: () => _onButtonPressed('*'),
                  child: const Text('*', style: TextStyle(fontSize: 24)),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _onButtonPressed('1'),
                  child: const Text('1', style: TextStyle(fontSize: 24)),
                ),
                ElevatedButton(
                  onPressed: () => _onButtonPressed('2'),
                  child: const Text('2', style: TextStyle(fontSize: 24)),
                ),
                ElevatedButton(
                  onPressed: () => _onButtonPressed('3'),
                  child: const Text('3', style: TextStyle(fontSize: 24)),
                ),
                ElevatedButton(
                  onPressed: () => _onButtonPressed('-'),
                  child: const Text('-', style: TextStyle(fontSize: 24)),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _onButtonPressed('0'),
                  child: const Text('0', style: TextStyle(fontSize: 24)),
                ),
                ElevatedButton(
                  onPressed: () => _onButtonPressed('.'),
                  child: const Text('.', style: TextStyle(fontSize: 24)),
                ),
                ElevatedButton(
                  onPressed: () => _onButtonPressed('='),
                  child: const Text('=', style: TextStyle(fontSize: 24)),
                ),
                ElevatedButton(
                  onPressed: () => _onButtonPressed('+'),
                  child: const Text('+', style: TextStyle(fontSize: 24)),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _onButtonPressed('C'),
                  child: const Text('C', style: TextStyle(fontSize: 24)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}