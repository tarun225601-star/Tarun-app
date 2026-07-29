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
  final TextEditingController _textController = TextEditingController();
  final List<String> _history = [];
  String _currentExpression = '';

  void _onButtonPressed(String value) {
    setState(() {
      if (value == 'C') {
        _currentExpression = '';
        _textController.clear();
      } else if (value == '=') {
        try {
          final result = _calculate(_currentExpression);
          _history.add('$_currentExpression = $result');
          _currentExpression = result.toString();
          _textController.text = _currentExpression;
        } catch (e) {
          _textController.text = 'Error';
        }
      } else {
        _currentExpression += value;
        _textController.text = _currentExpression;
      }
    });
  }

  double _calculate(String expression) {
    return Function.apply(
      (String exp) => double.parse(
        exp
            .replaceAll('+', ' + ')
            .replaceAll('-', ' - ')
            .replaceAll('*', ' * ')
            .replaceAll('/', ' / ')
            .replaceAll(' ', ' '),
      ),
      [expression],
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
            TextField(
              controller: _textController,
              readOnly: true,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 4,
              childAspectRatio: 1,
              children: [
                CalculatorButton(
                  onPressed: _onButtonPressed,
                  value: '7',
                ),
                CalculatorButton(
                  onPressed: _onButtonPressed,
                  value: '8',
                ),
                CalculatorButton(
                  onPressed: _onButtonPressed,
                  value: '9',
                ),
                CalculatorButton(
                  onPressed: _onButtonPressed,
                  value: '/',
                ),
                CalculatorButton(
                  onPressed: _onButtonPressed,
                  value: '4',
                ),
                CalculatorButton(
                  onPressed: _onButtonPressed,
                  value: '5',
                ),
                CalculatorButton(
                  onPressed: _onButtonPressed,
                  value: '6',
                ),
                CalculatorButton(
                  onPressed: _onButtonPressed,
                  value: '*',
                ),
                CalculatorButton(
                  onPressed: _onButtonPressed,
                  value: '1',
                ),
                CalculatorButton(
                  onPressed: _onButtonPressed,
                  value: '2',
                ),
                CalculatorButton(
                  onPressed: _onButtonPressed,
                  value: '3',
                ),
                CalculatorButton(
                  onPressed: _onButtonPressed,
                  value: '-',
                ),
                CalculatorButton(
                  onPressed: _onButtonPressed,
                  value: '0',
                ),
                CalculatorButton(
                  onPressed: _onButtonPressed,
                  value: '.',
                ),
                CalculatorButton(
                  onPressed: _onButtonPressed,
                  value: 'C',
                ),
                CalculatorButton(
                  onPressed: _onButtonPressed,
                  value: '+',
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _history.add(_textController.text);
                  _textController.clear();
                  _currentExpression = '';
                });
              },
              child: const Text('Clear History'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _history.length,
                itemBuilder: (context, index) {
                  return Text(_history[_history.length - 1 - index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CalculatorButton extends StatelessWidget {
  final Function(String) onPressed;
  final String value;

  const CalculatorButton({
    Key? key,
    required this.onPressed,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => onPressed(value),
      child: Text(
        value,
        style: const TextStyle(fontSize: 24),
      ),
    );
  }
}