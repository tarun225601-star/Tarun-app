import 'package:flutter/material.dart';
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
        scaffoldBackgroundColor: const Color(0xFF2F343A),
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
  final _apiKeyController = TextEditingController();
  String _apiKey = '';
  bool _isProcessing = false;
  int _currentAgent = 0;
  List<String> _agents = [
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
  List<String> _agentDescriptions = [
    'Splitting video into frames for processing',
    'Removing noise and grain from the video',
    'Upscaling the video to 8K resolution',
    'Restoring and enhancing face details',
    'Applying cinematic color grading',
    'Enhancing HDR and lighting',
    'Interpolating frames for smooth 60fps',
    'Synchronizing audio and removing noise',
    'Optimizing compression and bitrate',
    'Rendering the final video and delivering to cloud',
  ];

  Future<void> _saveApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('apiKey', _apiKeyController.text);
    setState(() {
      _apiKey = _apiKeyController.text;
    });
  }

  Future<void> _loadApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _apiKey = prefs.getString('apiKey') ?? '';
    });
  }

  Future<void> _processVideo() async {
    if (_apiKey.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('API Key Missing'),
          content: const Text('Please enter a valid API key'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    for (int i = 0; i < _agents.length; i++) {
      setState(() {
        _currentAgent = i;
      });
      await Future.delayed(const Duration(seconds: 2));
    }

    setState(() {
      _isProcessing = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadApiKey();
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
                builder: (context) => AlertDialog(
                  title: const Text('API Key Settings'),
                  content: Form(
                    key: _formKey,
                    child: TextFormField(
                      controller: _apiKeyController,
                      decoration: const InputDecoration(
                        labelText: 'API Key',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a valid API key';
                        }
                        return null;
                      },
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _saveApiKey();
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00FFFF),
              ),
              onPressed: _isProcessing ? null : _processVideo,
              child: const Text('Start AI Processing'),
            ),
            const SizedBox(height: 20),
            _isProcessing
                ? Column(
                    children: [
                      Text(
                        _agents[_currentAgent],
                        style: const TextStyle(
                          fontSize: 18,
                          color: Color(0xFF00FFFF),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _agentDescriptions[_currentAgent],
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      LinearProgressIndicator(
                        value: _currentAgent / _agents.length,
                        backgroundColor: const Color(0xFF2F343A),
                        color: const Color(0xFF00FFFF),
                      ),
                    ],
                  )
                : const Text(
                    'Upload your video and start the AI processing',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}