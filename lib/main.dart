import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

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
  final _videoUrlController = TextEditingController();
  final _groqApiKeyController = TextEditingController();
  final _aiVideoUpscaleApiKeyController = TextEditingController();
  final _aiEnhancementDenoisingApiKeyController = TextEditingController();
  bool _isLoading = false;
  int _progress = 0;
  String _activeAgent = '';
  String _log = '';

  Future<void> _saveApiKeys() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('groqApiKey', _groqApiKeyController.text);
    await prefs.setString('aiVideoUpscaleApiKey', _aiVideoUpscaleApiKeyController.text);
    await prefs.setString('aiEnhancementDenoisingApiKey', _aiEnhancementDenoisingApiKeyController.text);
  }

  Future<void> _loadApiKeys() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _groqApiKeyController.text = prefs.getString('groqApiKey') ?? '';
      _aiVideoUpscaleApiKeyController.text = prefs.getString('aiVideoUpscaleApiKey') ?? '';
      _aiEnhancementDenoisingApiKeyController.text = prefs.getString('aiEnhancementDenoisingApiKey') ?? '';
    });
  }

  Future<void> _processVideo() async {
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
      _isLoading = true;
      _progress = 0;
      _activeAgent = '';
      _log = '';
    });

    for (int i = 1; i <= 10; i++) {
      setState(() {
        _activeAgent = 'Agent $i';
        _log += 'Agent $i started\n';
      });

      // Simulate AI agent work
      await Future.delayed(const Duration(milliseconds: 500));

      setState(() {
        _progress = (i / 10 * 100).toInt();
        _log += 'Agent $i finished\n';
      });
    }

    setState(() {
      _isLoading = false;
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
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('API Key Settings'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: _groqApiKeyController,
                          decoration: const InputDecoration(
                            labelText: 'Groq API Key',
                          ),
                        ),
                        TextField(
                          controller: _aiVideoUpscaleApiKeyController,
                          decoration: const InputDecoration(
                            labelText: 'AI Video Upscale API Key',
                          ),
                        ),
                        TextField(
                          controller: _aiEnhancementDenoisingApiKeyController,
                          decoration: const InputDecoration(
                            labelText: 'AI Enhancement & Denoising API Key',
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        child: const Text('Save'),
                        onPressed: () {
                          _saveApiKeys().then((_) {
                            Navigator.of(context).pop();
                          });
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
            TextField(
              controller: _videoUrlController,
              decoration: const InputDecoration(
                labelText: 'Enter Video Cloud URL / S3 Link',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _processVideo,
              child: const Text('Process Video'),
            ),
            const SizedBox(height: 16),
            _isLoading
                ? Column(
                    children: [
                      LinearProgressIndicator(
                        value: _progress / 100,
                      ),
                      const SizedBox(height: 8),
                      Text('Active Agent: $_activeAgent'),
                      const SizedBox(height: 8),
                      Text('Progress: $_progress%'),
                      const SizedBox(height: 8),
                      Text(_log),
                    ],
                  )
                : const Text(''),
          ],
        ),
      ),
    );
  }
}