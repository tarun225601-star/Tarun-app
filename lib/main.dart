import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

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
        scaffoldBackgroundColor: const Color(0xFF2F2F2F),
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
  final _formKey = GlobalKey<FormState>();
  String _groqApiKey = '';
  String _aiVideoUpscaleApiKey = '';
  String _aiEnhancementDenoisingApiKey = '';
  String _selectedVideoPath = '';
  double _progress = 0;
  bool _isProcessing = false;
  String _activeAgent = '';
  String _activeAgentDescription = '';

  Future<void> _saveApiKeys() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('groqApiKey', _groqApiKey);
    await prefs.setString('aiVideoUpscaleApiKey', _aiVideoUpscaleApiKey);
    await prefs.setString('aiEnhancementDenoisingApiKey', _aiEnhancementDenoisingApiKey);
  }

  Future<void> _loadApiKeys() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _groqApiKey = prefs.getString('groqApiKey') ?? '';
      _aiVideoUpscaleApiKey = prefs.getString('aiVideoUpscaleApiKey') ?? '';
      _aiEnhancementDenoisingApiKey = prefs.getString('aiEnhancementDenoisingApiKey') ?? '';
    });
  }

  Future<void> _selectVideo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp4', 'mov', 'avi', 'mkv'],
    );
    if (result != null) {
      setState(() {
        _selectedVideoPath = result.files.single.path ?? '';
      });
    }
  }

  Future<void> _startProcessing() async {
    if (_groqApiKey.isEmpty || _aiVideoUpscaleApiKey.isEmpty || _aiEnhancementDenoisingApiKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter all API keys')),
      );
      return;
    }
    if (_selectedVideoPath.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a video file')),
      );
      return;
    }
    setState(() {
      _isProcessing = true;
      _progress = 0;
      _activeAgent = '';
      _activeAgentDescription = '';
    });
    final agents = [
      {'name': 'Ingestion & Frame Splitter', 'description': 'Splitting video into frames'},
      {'name': 'Noise & Grain Remover', 'description': 'Removing noise and grain from frames'},
      {'name': 'Super-Resolution Upscaler', 'description': 'Upscaling frames to 8K'},
      {'name': 'Face Restoration & Details', 'description': 'Restoring face details'},
      {'name': 'Cinematic Color Grader', 'description': 'Applying cinematic color grade'},
      {'name': 'HDR & Lighting Enhancer', 'description': 'Enhancing HDR and lighting'},
      {'name': 'Frame Interpolation', 'description': 'Interpolating frames for smooth playback'},
      {'name': 'Audio Sync & Noise Gate', 'description': 'Synchronizing audio and removing noise'},
      {'name': 'AI Compression & Bitrate Optimizer', 'description': 'Optimizing compression and bitrate'},
      {'name': 'Final Rendering & Cloud Deliverer', 'description': 'Rendering final video and delivering to cloud'},
    ];
    for (var i = 0; i < agents.length; i++) {
      setState(() {
        _activeAgent = agents[i]['name'] ?? '';
        _activeAgentDescription = agents[i]['description'] ?? '';
        _progress = (i + 1) / agents.length;
      });
      await Future.delayed(const Duration(milliseconds: 500));
    }
    setState(() {
      _isProcessing = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadApiKeys();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vizia Global Studio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('API Key Settings'),
                    content: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            initialValue: _groqApiKey,
                            decoration: const InputDecoration(
                              labelText: 'Groq API Key',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter Groq API Key';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _groqApiKey = value ?? '';
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            initialValue: _aiVideoUpscaleApiKey,
                            decoration: const InputDecoration(
                              labelText: 'AI Video Upscale API Key',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter AI Video Upscale API Key';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _aiVideoUpscaleApiKey = value ?? '';
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            initialValue: _aiEnhancementDenoisingApiKey,
                            decoration: const InputDecoration(
                              labelText: 'AI Enhancement & Denoising API Key',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter AI Enhancement & Denoising API Key';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _aiEnhancementDenoisingApiKey = value ?? '';
                            },
                          ),
                        ],
                      ),
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
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            _saveApiKeys();
                            Navigator.of(context).pop();
                          }
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _selectVideo,
              child: Text(_selectedVideoPath.isEmpty ? 'Select Video from Device' : _selectedVideoPath),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _startProcessing,
              child: const Text('Start Processing'),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: _progress,
            ),
            const SizedBox(height: 16),
            Text(
              _activeAgent,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _activeAgentDescription,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}