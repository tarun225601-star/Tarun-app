import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

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
        primarySwatch: Colors.cyan,
        scaffoldBackgroundColor: const Color(0xFF1A1D23),
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
  String _groqApiKey = '';
  String _aiVideoUpscaleApiKey = '';
  String _aiEnhancementDenoisingApiKey = '';
  String _selectedVideoFilePath = '';
  bool _isProcessing = false;
  double _progress = 0;
  int _currentAgent = 0;
  final List<String> _agents = [
    'Ingestion & Frame Splitter',
    'Noise & Grain Remover',
    'Super-Resolution Upscaler (8K synthesis)',
    'Face Restoration & Details',
    'Cinematic Color Grader',
    'HDR & Lighting Enhancer',
    'Frame Interpolation (Fluid 60fps)',
    'Audio Sync & Noise Gate',
    'AI Compression & Bitrate Optimizer',
    'Final Rendering & Cloud Deliverer',
  ];

  Future<void> _showSettingsDialog() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final TextEditingController groqApiKeyController = TextEditingController(text: _groqApiKey);
    final TextEditingController aiVideoUpscaleApiKeyController = TextEditingController(text: _aiVideoUpscaleApiKey);
    final TextEditingController aiEnhancementDenoisingApiKeyController = TextEditingController(text: _aiEnhancementDenoisingApiKey);

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('API Key Settings'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: groqApiKeyController,
                decoration: const InputDecoration(
                  labelText: 'Groq API Key',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: aiVideoUpscaleApiKeyController,
                decoration: const InputDecoration(
                  labelText: 'AI Video Upscale API Key',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: aiEnhancementDenoisingApiKeyController,
                decoration: const InputDecoration(
                  labelText: 'AI Enhancement & Denoising API Key',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                _groqApiKey = groqApiKeyController.text;
                _aiVideoUpscaleApiKey = aiVideoUpscaleApiKeyController.text;
                _aiEnhancementDenoisingApiKey = aiEnhancementDenoisingApiKeyController.text;
                await prefs.setString('groqApiKey', _groqApiKey);
                await prefs.setString('aiVideoUpscaleApiKey', _aiVideoUpscaleApiKey);
                await prefs.setString('aiEnhancementDenoisingApiKey', _aiEnhancementDenoisingApiKey);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _selectVideoFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp4', 'mkv', 'mov', 'avi'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedVideoFilePath = result.files.single.path!;
      });
    }
  }

  Future<void> _startProcessing() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _groqApiKey = (await prefs.getString('groqApiKey')) ?? '';
    _aiVideoUpscaleApiKey = (await prefs.getString('aiVideoUpscaleApiKey')) ?? '';
    _aiEnhancementDenoisingApiKey = (await prefs.getString('aiEnhancementDenoisingApiKey')) ?? '';

    if (_groqApiKey.isEmpty || _aiVideoUpscaleApiKey.isEmpty || _aiEnhancementDenoisingApiKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('API keys are missing. Please set them in the settings.')),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    for (int i = 0; i < _agents.length; i++) {
      setState(() {
        _currentAgent = i;
        _progress = (i + 1) / _agents.length * 100;
      });

      await Future.delayed(const Duration(milliseconds: 500));
    }

    setState(() {
      _isProcessing = false;
    });
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _selectVideoFile,
              child: const Text('Select Video from Device'),
            ),
            const SizedBox(height: 16),
            Text(_selectedVideoFilePath),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _startProcessing,
              child: const Text('Start Processing'),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: _progress / 100,
              backgroundColor: Colors.cyan[100],
              color: Colors.cyan,
            ),
            const SizedBox(height: 16),
            Text(_isProcessing ? '${_agents[_currentAgent]} (${_progress}%)' : 'Not processing'),
          ],
        ),
      ),
    );
  }
}