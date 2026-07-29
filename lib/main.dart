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
  String _expression = '';
  String _result = '';

  void _onPressed(String value) {
    setState(() {
      if (value == 'C') {
        _expression = '';
        _result = '';
      } else if (value == '=') {
        try {
          _result = _calculate(_expression);
        } catch (e) {
          _result = 'Error';
        }
      } else {
        _expression += value;
      }
    });
  }

  String _calculate(String expression) {
    return expression
        .replaceAll('Ã', '*')
        .replaceAll('Ã·', '/')
        .replaceAll('â', '-')
        .replaceAll(' ', '')
        .splitMapJoin(
          RegExp(r'(\d+|\+|-|\*|/|\(|\))'),
          onMatch: (m) => m.group(0)!,
          onNonMatch: (n) => '',
        );
  }

  String _evaluate(String expression) {
    try {
      return (num.parse(_calculate(expression))).toString();
    } catch (e) {
      return 'Error';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple Calculator'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Expanded(
                    child: Text(
                      _expression,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      _result,
                      style: const TextStyle(fontSize: 48),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: GridView.count(
              crossAxisCount: 4,
              childAspectRatio: 1.2,
              children: [
                _button('7', _onPressed),
                _button('8', _onPressed),
                _button('9', _onPressed),
                _button('Ã·', _onPressed),
                _button('4', _onPressed),
                _button('5', _onPressed),
                _button('6', _onPressed),
                _button('Ã', _onPressed),
                _button('1', _onPressed),
                _button('2', _onPressed),
                _button('3', _onPressed),
                _button('â', _onPressed),
                _button('0', _onPressed),
                _button('.', _onPressed),
                _button('=', _onPressed),
                _button('C', _onPressed),
                _button('+', _onPressed),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _button(String value, Function onPressed) {
    return GestureDetector(
      onTap: () => onPressed(value),
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.grey),
            bottom: BorderSide(color: Colors.grey),
            left: BorderSide(color: Colors.grey),
            right: BorderSide(color: Colors.grey),
          ),
        ),
        child: Center(
          child: Text(
            value,
            style: const TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }
}