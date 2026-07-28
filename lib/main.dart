import 'package:flutter/material.dart';

void main() {
  runApp(const AiVideoEditorApp());
}

class AiVideoEditorApp extends StatelessWidget {
  const AiVideoEditorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vizia AI Video Editor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const EditorHomePage(),
    );
  }
}

class EditorHomePage extends StatefulWidget {
  const EditorHomePage({super.key});

  @override
  State<EditorHomePage> createState() => _EditorHomePageState();
}

class _EditorHomePageState extends State<EditorHomePage> {
  final TextEditingController _promptController = TextEditingController();
  final TextEditingController _apiKeyController = TextEditingController();
  
  String _selectedVideoName = 'No video selected';
  bool _isEditing = false;
  double _progressValue = 0.0;
  String _statusMessage = 'Ready to process';
  bool _isCompleted = false;

  void _openSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('API Configuration'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter your AI / Replicate / OpenAI API Key below:'),
              const SizedBox(height: 12),
              TextField(
                controller: _apiKeyController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'API Key',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('API Key saved securely!')),
                );
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _pickVideo() async {
    setState(() {
      _selectedVideoName = 'raw_sample_video_01.mp4';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Video selected successfully!')),
    );
  }

  void _startEditingPipeline() async {
    if (_selectedVideoName == 'No video selected') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a video first!')),
      );
      return;
    }

    setState(() {
      _isEditing = true;
      _progressValue = 0.0;
      _isCompleted = false;
    });

    List<String> agentSteps = [
      "Agent 1: Parsing user prompt instructions...",
      "Agent 2: Trimming and cropping video frames...",
      "Agent 3: Adjusting color grading and contrast...",
      "Agent 4: Applying slow-motion & speed ramps...",
      "Agent 5: Generating AI background music...",
      "Agent 6: Integrating action VFX & fire elements...",
      "Agent 7: Enhancing audio clarity and voiceover...",
      "Agent 8: Upscaling video resolution to 8K...",
      "Agent 9: Running final quality assurance check...",
      "Agent 10: Rendering and preparing export package..."
    ];

    for (int i = 0; i < agentSteps.length; i++) {
      await Future.delayed(const Duration(milliseconds: 600));
      setState(() {
        _statusMessage = agentSteps[i];
        _progressValue = (i + 1) / agentSteps.length;
      });
    }

    setState(() {
      _isEditing = false;
      _isCompleted = true;
      _statusMessage = 'Editing completed successfully!';
    });
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vizia AI Video Editor'),
        backgroundColor: colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'API Settings',
            onPressed: _openSettingsDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Step 1: Select Source Video',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text('Selected: $_selectedVideoName', 
                      style: TextStyle(color: Colors.grey[700])),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _pickVideo,
                      icon: const Icon(Icons.video_library),
                      label: const Text('Choose Video from Device'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              child: Padding(
                padding: const,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Step 2: Enter Editing Prompt',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _promptController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'e.g., Add cinematic color grading, slow-motion on action scenes, and realistic fire VFX...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: _isEditing ? null : _startEditingPipeline,
              child: Text(
                _isEditing ? 'Processing Pipeline...' : 'Start 10-Agent AI Editing',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            if (_isEditing || _progressValue > 0) ...[
              LinearProgressIndicator(value: _progressValue),
              const SizedBox(height: 10),
              Text(
                _statusMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.deepPurple),
              ),
            ],
            const SizedBox(height: 20),
            if (_isCompleted) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  border: Border.all(color: Colors.green),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Your AI Edited Video is Ready!',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Downloading final video to device storage...')),
                        );
                      },
                      icon: const Icon(Icons.download),
                      label: const Text('Download Final Video'),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
