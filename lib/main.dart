```dart
import 'package:flutter/material.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Calculator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const CalculatorPage(),
    );
  }
}

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({Key? key}) : super(key: key);

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  final _textController = TextEditingController();
  double _num1 = 0;
  double _num2 = 0;
  String _operator = '';
  String _result = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple Calculator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _textController,
              readOnly: true,
              style: const TextStyle(fontSize: 24),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _textController.text += '7';
                    });
                  },
                  child: const Text('7'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _textController.text += '8';
                    });
                  },
                  child: const Text('8'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _textController.text += '9';
                    });
                  },
                  child: const Text('9'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _textController.text += '/';
                    });
                  },
                  child: const Text('/'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _textController.text += '4';
                    });
                  },
                  child: const Text('4'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _textController.text += '5';
                    });
                  },
                  child: const Text('5'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _textController.text += '6';
                    });
                  },
                  child: const Text('6'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _textController.text += '*';
                    });
                  },
                  child: const Text('*'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _textController.text += '1';
                    });
                  },
                  child: const Text('1'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _textController.text += '2';
                    });
                  },
                  child: const Text('2'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _textController.text += '3';
                    });
                  },
                  child: const Text('3'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _textController.text += '-';
                    });
                  },
                  child: const Text('-'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _textController.text += '0';
                    });
                  },
                  child: const Text('0'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _textController.text += '.';
                    });
                  },
                  child: const Text('.'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _textController.text += '+';
                    });
                  },
                  child: const Text('+'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _calculateResult();
                    });
                  },
                  child: const Text('='),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _textController.clear();
                  _result = '';
                });
              },
              child: const Text('Clear'),
            ),
            const SizedBox(height: 16),
            Text(
              _result,
              style: const TextStyle(fontSize: 24),
            ),
          ],
        ),
      ),
    );
  }

  void _calculateResult() {
    try {
      _result = _calculate(_textController.text);
      _textController.text = _result;
    } catch (e) {
      _result = 'Error';
    }
  }

  String _calculate(String equation) {
    final List<String> parts = equation.split(RegExp(r'([+*/-])'));
    _num1 = double.parse(parts[0]);
    _operator = parts[1];
    _num2 = double.parse(parts[2]);

    switch (_operator) {
      case '+':
        return (_num1 + _num2).toString();
      case '-':
        return (_num1 - _num2).toString();
      case '*':
        return (_num1 * _num2).toString();
      case '/':
        if (_num2 != 0) {
          return (_num1 / _num2).toString();
        } else {
          throw Exception('Cannot divide by zero');
        }
      default:
        throw Exception('Invalid operator');
    }
  }
}
```