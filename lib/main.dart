import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Workflow Status Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String workflowStatus = 'init';

  void _updateStatus() {
    workflowStatus = 'in_progress';
    setState(() {});
  }

  void _completeWorkflow() {
    workflowStatus = 'completed';
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workflow Status Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              workflowStatus,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateStatus,
              child: const Text('Start Workflow'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _completeWorkflow,
              child: const Text('Complete Workflow'),
            ),
          ],
        ),
      ),
    );
  }
}