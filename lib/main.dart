import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Vizia Global Studio',
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
  final _groqApiKeyController = TextEditingController();
  final _aiVideoUpscaleApiKeyController = TextEditingController();
  final _aiEnhancementApiKeyController = TextEditingController();
  String _selectedFilePath = '';
  double _progress = 0.0;
  String _activeAgentStatus = '';
  List<String> _logs = [];

  Future<void> _showSettingsDialog() async {
    await showDialog(
      context: context,
      builder: (context) {
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
              const SizedBox(height: 16),
              TextField(
                controller: _aiVideoUpscaleApiKeyController,
                decoration: const InputDecoration(
                  labelText: 'AI Video Upscale API Key',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _aiEnhancementApiKeyController,
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
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('groqApiKey', _groqApiKeyController.text);
                await prefs.setString('aiVideoUpscaleApiKey', _aiVideoUpscaleApiKeyController.text);
                await prefs.setString('aiEnhancementApiKey', _aiEnhancementApiKeyController.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _selectVideoFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp4', 'mkv', 'mov', 'avi'],
    );
    if (result != null) {
      setState(() {
        _selectedFilePath = result.files.first.path!;
      });
    }
  }

  Future<void> _startUpscalingProcess() async {
    final prefs = await SharedPreferences.getInstance();
    final groqApiKey = prefs.getString('groqApiKey');
    final aiVideoUpscaleApiKey = prefs.getString('aiVideoUpscaleApiKey');
    final aiEnhancementApiKey = prefs.getString('aiEnhancementApiKey');

    if (groqApiKey == null || aiVideoUpscaleApiKey == null || aiEnhancementApiKey == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please configure API keys in settings')),
      );
      return;
    }

    setState(() {
      _progress = 0.0;
      _activeAgentStatus = '';
      _logs = [];
    });

    for (int i = 1; i <= 10; i++) {
      setState(() {
        _activeAgentStatus = 'Agent $i is working on the video';
        _logs.add('Agent $i started working on the video');
      });
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        _progress += 10;
        _logs.add('Agent $i finished working on the video');
      });
    }
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
            Text(_selectedFilePath),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _startUpscalingProcess,
              child: const Text('Start Upscaling Process'),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: _progress / 100,
            ),
            const SizedBox(height: 16),
            Text(_activeAgentStatus),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _logs.length,
                itemBuilder: (context, index) {
                  return Text(_logs[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}