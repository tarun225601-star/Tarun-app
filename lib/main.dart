import 'package:flutter/material.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Calculator',
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
  String _expression = '';
  String _result = '';

  void _onPressed(String value) {
    setState(() {
      if (value == '=') {
        try {
          _result = _calculate(_expression).toString();
        } catch (e) {
          _result = 'Error';
        }
      } else if (value == 'C') {
        _expression = '';
        _result = '';
      } else {
        _expression += value;
      }
    });
  }

  double _calculate(String expression) {
    return Function.apply(
      (String x) => double.parse(x),
      [expression.replaceAll('+', ' + ').replaceAll('-', ' - ').replaceAll('*', ' * ').replaceAll('/', ' / ').replaceAll(' ', '')],
    );
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
            Expanded(
              child: Container(
                alignment: Alignment.bottomRight,
                child: Text(
                  _expression,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                alignment: Alignment.bottomRight,
                child: Text(
                  _result,
                  style: const TextStyle(fontSize: 48),
                ),
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 4,
              children: [
                _buildButton('7', _onPressed),
                _buildButton('8', _onPressed),
                _buildButton('9', _onPressed),
                _buildButton('/', _onPressed),
                _buildButton('4', _onPressed),
                _buildButton('5', _onPressed),
                _buildButton('6', _onPressed),
                _buildButton('*', _onPressed),
                _buildButton('1', _onPressed),
                _buildButton('2', _onPressed),
                _buildButton('3', _onPressed),
                _buildButton('-', _onPressed),
                _buildButton('0', _onPressed),
                _buildButton('.', _onPressed),
                _buildButton('=', _onPressed),
                _buildButton('C', _onPressed),
                _buildButton('+', _onPressed),
              ],
            ),
          ],
        ),
      ),
    );
  }

  ElevatedButton _buildButton(String text, void Function(String) onPressed) {
    return ElevatedButton(
      onPressed: () => onPressed(text),
      child: Text(
        text,
        style: const TextStyle(fontSize: 24),
      ),
    );
  }
}