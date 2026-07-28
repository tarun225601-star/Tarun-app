import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vizia Global Studio',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _groqApiKeyController = TextEditingController();
  final _aiVideoUpscaleApiKeyController = TextEditingController();
  final _aiEnhancementDenoisingApiKeyController = TextEditingController();
  final _videoUrlController = TextEditingController();
  String _activeAgent = '';
  String _log = '';
  double _progress = 0;
  bool _isRunning = false;

  Future<void> _showSettingsDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Settings'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _groqApiKeyController,
                decoration: const InputDecoration(
                  labelText: 'Groq API Key',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _aiVideoUpscaleApiKeyController,
                decoration: const InputDecoration(
                  labelText: 'AI Video Upscale API Key',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _aiEnhancementDenoisingApiKeyController,
                decoration: const InputDecoration(
                  labelText: 'AI Enhancement & Denoising API Key',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                prefs.setString('groqApiKey', _groqApiKeyController.text);
                prefs.setString('aiVideoUpscaleApiKey', _aiVideoUpscaleApiKeyController.text);
                prefs.setString('aiEnhancementDenoisingApiKey', _aiEnhancementDenoisingApiKeyController.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _groqApiKeyController.text = prefs.getString('groqApiKey') ?? '';
    _aiVideoUpscaleApiKeyController.text = prefs.getString('aiVideoUpscaleApiKey') ?? '';
    _aiEnhancementDenoisingApiKeyController.text = prefs.getString('aiEnhancementDenoisingApiKey') ?? '';
  }

  Future<void> _runUpscaling() async {
    if (_groqApiKeyController.text.isEmpty ||
        _aiVideoUpscaleApiKeyController.text.isEmpty ||
        _aiEnhancementDenoisingApiKeyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill in all API keys')));
      return;
    }
    if (_videoUrlController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a video URL')));
      return;
    }
    setState(() {
      _isRunning = true;
      _progress = 0;
      _log = '';
    });
    for (int i = 0; i < 10; i++) {
      setState(() {
        _activeAgent = 'Agent $i';
        _log += 'Starting agent $i\n';
      });
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        _log += 'Agent $i finished\n';
        _progress += 10;
      });
    }
    setState(() {
      _isRunning = false;
      _activeAgent = '';
    });
  }

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vizia Global Studio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettingsDialog,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _videoUrlController,
              decoration: const InputDecoration(
                labelText: 'Enter Video Cloud URL / S3 Link',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _runUpscaling,
              child: const Text('Run Upscaling'),
            ),
            const SizedBox(height: 20),
            LinearProgressIndicator(
              value: _progress / 100,
            ),
            const SizedBox(height: 20),
            Text('Active Agent: $_activeAgent'),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Text(_log),
              ),
            ),
          ],
        ),
      ),
    );
  }
}