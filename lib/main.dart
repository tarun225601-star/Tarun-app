```dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Media Editor',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SettingsScreen(),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _apiKeyController = TextEditingController();

  Future<void> _saveApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('apiKey', _apiKeyController.text);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const PromptScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _apiKeyController,
              decoration: const InputDecoration(
                labelText: 'Replicate API Token',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveApiKey,
              child: const Text('Save API Key'),
            ),
          ],
        ),
      ),
    );
  }
}

class PromptScreen extends StatefulWidget {
  const PromptScreen({Key? key}) : super(key: key);

  @override
  State<PromptScreen> createState() => _PromptScreenState();
}

class _PromptScreenState extends State<PromptScreen> {
  final _promptController = TextEditingController();
  File? _imageFile;
  String _imageUrl = '';

  Future<void> _uploadImage() async {
    final pickedFile = await FilePicker.platform.pickFile();
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path!);
        _imageUrl = _imageFile!.path;
      });
    }
  }

  Future<void> _sendPrompt() async {
    final prefs = await SharedPreferences.getInstance();
    final apiKey = prefs.getString('apiKey');
    if (apiKey != null) {
      final response = await http.post(
        Uri.parse('https://api.replicate.com/v1/predictions'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'version': 'latest',
          'input': {
            'prompt': _promptController.text,
            'negative_prompt': '',
            'image': _imageUrl,
          },
        }),
      );
      if (response.statusCode == 201) {
        final predictionId = response.json()['id'];
        _pollPrediction(predictionId);
      } else {
        _showErrorDialog(response.statusCode);
      }
    }
  }

  Future<void> _pollPrediction(String predictionId) async {
    final prefs = await SharedPreferences.getInstance();
    final apiKey = prefs.getString('apiKey');
    if (apiKey != null) {
      while (true) {
        final response = await http.get(
          Uri.parse('https://api.replicate.com/v1/predictions/$predictionId'),
          headers: {
            'Authorization': 'Bearer $apiKey',
          },
        );
        if (response.statusCode == 200) {
          final status = response.json()['status'];
          if (status == 'succeeded') {
            final output = response.json()['output'];
            _showOutputDialog(output);
            break;
          } else if (status == 'failed') {
            _showErrorDialog(response.statusCode);
            break;
          }
        } else {
          _showErrorDialog(response.statusCode);
          break;
        }
        await Future.delayed(const Duration(seconds: 1));
      }
    }
  }

  Future<void> _showErrorDialog(int statusCode) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text('Error $statusCode'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showOutputDialog(String output) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Output'),
          content: Text(output),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prompt'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _promptController,
              decoration: const InputDecoration(
                labelText: 'Prompt',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _uploadImage,
              child: const Text('Upload Image'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _sendPrompt,
              child: const Text('Send Prompt'),
            ),
          ],
        ),
      ),
    );
  }
}
```