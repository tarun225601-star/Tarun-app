import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final _groqApiKeyController = TextEditingController();
  final _aiVideoUpscaleApiKeyController = TextEditingController();
  final _aiEnhancementDenoisingApiKeyController = TextEditingController();
  String? _selectedVideoPath;
  double _progress = 0;
  int _currentAgent = 0;
  bool _isProcessing = false;

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
        backgroundColor: const Color(0xFF1A1D23),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettingsDialog,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.cyan,
              ),
              onPressed: _selectVideo,
              child: const Text('Select Video from Device'),
            ),
            const SizedBox(height: 20),
            Text(
              _selectedVideoPath ?? 'No video selected',
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.cyan,
              ),
              onPressed: _isProcessing ? null : _startProcessing,
              child: const Text('Start AI Processing'),
            ),
            const SizedBox(height: 20),
            LinearProgressIndicator(
              value: _progress,
              color: Colors.cyan,
              backgroundColor: const Color(0xFF2F343A),
            ),
            const SizedBox(height: 20),
            Text(
              _isProcessing
                  ? _getAgentDescription(_currentAgent)
                  : 'Ready to start',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  void _loadApiKeys() async {
    final prefs = await SharedPreferences.getInstance();
    _groqApiKeyController.text = prefs.getString('groqApiKey') ?? '';
    _aiVideoUpscaleApiKeyController.text = prefs.getString('aiVideoUpscaleApiKey') ?? '';
    _aiEnhancementDenoisingApiKeyController.text = prefs.getString('aiEnhancementDenoisingApiKey') ?? '';
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('API Key Settings'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _groqApiKeyController,
                decoration: const InputDecoration(labelText: 'Groq API Key'),
              ),
              TextField(
                controller: _aiVideoUpscaleApiKeyController,
                decoration: const InputDecoration(labelText: 'AI Video Upscale API Key'),
              ),
              TextField(
                controller: _aiEnhancementDenoisingApiKeyController,
                decoration: const InputDecoration(labelText: 'AI Enhancement & Denoising API Key'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: _saveApiKeys,
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _saveApiKeys() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('groqApiKey', _groqApiKeyController.text);
    prefs.setString('aiVideoUpscaleApiKey', _aiVideoUpscaleApiKeyController.text);
    prefs.setString('aiEnhancementDenoisingApiKey', _aiEnhancementDenoisingApiKeyController.text);
    Navigator.of(context).pop();
  }

  void _selectVideo() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.video);
    if (result != null) {
      setState(() {
        _selectedVideoPath = result.files.first.path;
      });
    }
  }

  void _startProcessing() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString('groqApiKey') == null ||
        prefs.getString('aiVideoUpscaleApiKey') == null ||
        prefs.getString('aiEnhancementDenoisingApiKey') == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter all API keys')),
      );
      return;
    }
    setState(() {
      _isProcessing = true;
    });
    for (int i = 0; i < 10; i++) {
      setState(() {
        _currentAgent = i;
        _progress = (i + 1) / 10;
      });
      await Future.delayed(const Duration(milliseconds: 500));
    }
    setState(() {
      _isProcessing = false;
    });
  }

  String _getAgentDescription(int agent) {
    switch (agent) {
      case 0:
        return 'Ingestion & Frame Splitter';
      case 1:
        return 'Noise & Grain Remover';
      case 2:
        return 'Super-Resolution Upscaler (8K synthesis)';
      case 3:
        return 'Face Restoration & Details';
      case 4:
        return 'Cinematic Color Grader';
      case 5:
        return 'HDR & Lighting Enhancer';
      case 6:
        return 'Frame Interpolation (Fluid 60fps)';
      case 7:
        return 'Audio Sync & Noise Gate';
      case 8:
        return 'AI Compression & Bitrate Optimizer';
      case 9:
        return 'Final Rendering & Cloud Deliverer';
      default:
        return '';
    }
  }
}