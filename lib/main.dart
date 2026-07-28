import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Video Editor',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? _selectedFile;
  String _prompt = '';
  double _progress = 0;
  String _status = '';
  String _apiConfigStatus = '';

  Future<void> _selectFile() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.video,
    );
    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.first.path!);
      });
    }
  }

  Future<void> _startEditing() async {
    if (_selectedFile != null && _prompt.isNotEmpty) {
      setState(() {
        _progress = 0;
        _status = 'Starting editing process...';
      });
      // Simulate the 10-Agent pipeline
      for (int i = 1; i <= 10; i++) {
        setState(() {
          _progress = (i / 10) * 100;
          _status = 'Agent $i: Working...';
        });
        await Future.delayed(Duration(milliseconds: 500));
      }
      setState(() {
        _status = 'Editing completed!';
      });
    }
  }

  Future<void> _setupApiConfig() async {
    // Simulate API configuration setup
    setState(() {
      _apiConfigStatus = 'API configuration setup in progress...';
    });
    await Future.delayed(Duration(milliseconds: 1000));
    setState(() {
      _apiConfigStatus = 'API configuration setup completed!';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AI Video Editor'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _selectFile,
              child: Text('Select Raw Video'),
            ),
            Text(_selectedFile != null ? _selectedFile!.path : 'No file selected'),
            TextField(
              decoration: InputDecoration(
                labelText: 'Prompt',
                border: OutlineInputBorder(),
              ),
              onChanged: (text) {
                setState(() {
                  _prompt = text;
                });
              },
            ),
            ElevatedButton(
              onPressed: _startEditing,
              child: Text('Start Editing'),
            ),
            LinearProgressIndicator(
              value: _progress / 100,
            ),
            Text(_status),
            ElevatedButton(
              onPressed: _setupApiConfig,
              child: Text('Setup API Configuration'),
            ),
            Text(_apiConfigStatus),
          ],
        ),
      ),
    );
  }
}