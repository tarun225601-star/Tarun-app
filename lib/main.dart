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
      title: 'Calculator App',
      home: CalculatorHome(),
    );
  }
}

class CalculatorHome extends StatefulWidget {
  const CalculatorHome({Key? key}) : super(key: key);

  @override
  State<CalculatorHome> createState() => _CalculatorHomeState();
}

class _CalculatorHomeState extends State<CalculatorHome> {
  String _expression = '';
  String _result = '';

  void _onButtonPress(String value) {
    setState(() {
      if (value == 'C') {
        _expression = '';
        _result = '';
      } else if (value == '=') {
        try {
          _result = _calculate(_expression).toString();
        } catch (e) {
          _result = 'Error';
        }
      } else {
        _expression += value;
      }
    });
  }

  double _calculate(String expression) {
    expression = expression.replaceAll('*', ' * ');
    expression = expression.replaceAll('/', ' / ');
    expression = expression.replaceAll('+', ' + ');
    expression = expression.replaceAll('-', ' - ');
    return Function.apply(
      (Function f) => f,
      [
        (List<String> parts) {
          double result = 0;
          String operator = '';
          for (var part in parts) {
            if (part == '+' || part == '-' || part == '*' || part == '/') {
              operator = part;
            } else {
              if (operator == '+') {
                result += double.parse(part);
              } else if (operator == '-') {
                result -= double.parse(part);
              } else if (operator == '*') {
                result *= double.parse(part);
              } else if (operator == '/') {
                result /= double.parse(part);
              } else {
                result = double.parse(part);
              }
            }
          }
          return result;
        },
        expression.split(' '),
      ],
    );
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
              child: Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  _expression,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  _result,
                  style: const TextStyle(fontSize: 48),
                ),
              ),
            ),
            const SizedBox(height: 32),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 4,
              childAspectRatio: 1.2,
              children: [
                _buildButton('7', _onButtonPress),
                _buildButton('8', _onButtonPress),
                _buildButton('9', _onButtonPress),
                _buildButton('/', _onButtonPress),
                _buildButton('4', _onButtonPress),
                _buildButton('5', _onButtonPress),
                _buildButton('6', _onButtonPress),
                _buildButton('*', _onButtonPress),
                _buildButton('1', _onButtonPress),
                _buildButton('2', _onButtonPress),
                _buildButton('3', _onButtonPress),
                _buildButton('-', _onButtonPress),
                _buildButton('0', _onButtonPress),
                _buildButton('.', _onButtonPress),
                _buildButton('=', _onButtonPress),
                _buildButton('+', _onButtonPress),
                _buildButton('C', _onButtonPress),
              ],
            ),
          ],
        ),
      ),
    );
  }

  ElevatedButton _buildButton(String value, Function onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(64, 64),
        maximumSize: const Size(64, 64),
      ),
      onPressed: () => onPressed(value),
      child: Text(
        value,
        style: const TextStyle(fontSize: 24),
      ),
    );
  }
}
```