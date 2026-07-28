import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Demo',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String workflowStatus = ''; // Removed final keyword

  void updateWorkflowStatus() {
    for (var i = 0; i < 10; i++) {
      workflowStatus = 'Status $i'; // Now this line won't cause a compilation error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(workflowStatus),
            ElevatedButton(
              onPressed: updateWorkflowStatus,
              child: const Text('Update Workflow Status'),
            ),
          ],
        ),
      ),
    );
  }
}