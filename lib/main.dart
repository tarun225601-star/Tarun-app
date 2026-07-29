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
  String _equation = '';
  String _result = '';

  void _onButtonPressed(String value) {
    setState(() {
      if (value == 'C') {
        _equation = '';
        _result = '';
      } else if (value == '=') {
        try {
          _result = _calculate(_equation).toString();
        } catch (e) {
          _result = 'Error';
        }
      } else {
        _equation += value;
      }
    });
  }

  double _calculate(String equation) {
    try {
      return double.parse(equation);
    } catch (e) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculator App'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    _equation,
                    style: const TextStyle(fontSize: 24),
                  ),
                  Text(
                    _result,
                    style: const TextStyle(fontSize: 48),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: GridView.count(
              primary: false,
              crossAxisCount: 4,
              childAspectRatio: 1.2,
              children: [
                _buildButton('7', _onButtonPressed),
                _buildButton('8', _onButtonPressed),
                _buildButton('9', _onButtonPressed),
                _buildButton('/', _onButtonPressed),
                _buildButton('4', _onButtonPressed),
                _buildButton('5', _onButtonPressed),
                _buildButton('6', _onButtonPressed),
                _buildButton('*', _onButtonPressed),
                _buildButton('1', _onButtonPressed),
                _buildButton('2', _onButtonPressed),
                _buildButton('3', _onButtonPressed),
                _buildButton('-', _onButtonPressed),
                _buildButton('0', _onButtonPressed),
                _buildButton('.', _onButtonPressed),
                _buildButton('=', _onButtonPressed),
                _buildButton('+', _onButtonPressed),
                _buildButton('C', _onButtonPressed),
              ],
            ),
          ),
        ],
      ),
    );
  }

  ElevatedButton _buildButton(String label, void Function(String) onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(80, 80),
      ),
      onPressed: () => onPressed(label),
      child: Text(
        label,
        style: const TextStyle(fontSize: 24),
      ),
    );
  }
}