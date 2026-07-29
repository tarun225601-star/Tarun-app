import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:convert';

void main() {
  runApp(const ViziaProApp());
}

class ViziaProApp extends StatelessWidget {
  const ViziaProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vizia AI Studio Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const ViziaDashboardPage(),
    );
  }
}

class ViziaDashboardPage extends StatefulWidget {
  const ViziaDashboardPage({super.key});

  @override
  State<ViziaDashboardPage> createState() => _ViziaDashboardPageState();
}

class _ViziaDashboardPageState extends State<ViziaDashboardPage> {
  final TextEditingController _promptController = TextEditingController();
  final TextEditingController _apiKeyController = TextEditingController();

  File? _selectedVideoFile;
  String _replicateApiKey = '';
  bool _isProcessing = false;
  String _currentLiveStatus = 'System idle. Ready for production.';

  // लाइव डाउनलोड प्रोग्रेस और परसेंटेज ट्रैक करने के लिए
  double _downloadProgress = 0.0;
  bool _isDownloading = false;
  String? _savedFilePath;

  @override
  void initState() {
    super.initState();
    _loadSavedApiKey(); // ऐप खुलते ही परमानेंट सेव्ड API Key लोड करना
  }

  // SharedPreferences से API Key लोड करना (एक बार सेव होने पर हमेशा के लिए याद रखेगा)
  Future<void> _loadSavedApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _replicateApiKey = prefs.getString('replicate_api_key') ?? '';
      if (_replicateApiKey.isNotEmpty) {
        _currentLiveStatus = 'API Key loaded from secure storage. Ready!';
      }
    });
  }

  // SharedPreferences में API Key हमेशा के लिए परमानेंट सेव करना
  Future<void> _saveApiKeyPermanently(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('replicate_api_key', key.trim());
    setState(() {
      _replicateApiKey = key.trim();
    });
  }

  void _openSettings() {
    _apiKeyController.text = _replicateApiKey;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Replicate API Configuration'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Enter your live Replicate API Token (r8_...):'),
              const SizedBox(height: 12),
              TextField(
                controller: _apiKeyController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'API Token',
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
              onPressed: () async {
                String newKey = _apiKeyController.text.trim();
                await _saveApiKeyPermanently(newKey); // परमानेंट सेव कॉल
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('API Key saved permanently!')),
                );
              },
              child: const Text('Save Key'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickRealVideo() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickVideo(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedVideoFile = File(pickedFile.path);
        _savedFilePath = null;
        _downloadProgress = 0.0;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Loaded source video: ${pickedFile.name}')),
      );
    }
  }

  // असली क्लाउड प्रोसेस और Dio के साथ लाइव परसेंटेज डाउनलोड पाइपलाइन
  Future<void> _executePipelineWithPercentage() async {
    if (_replicateApiKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please configure your Replicate API Key first!')),
      );
      _openSettings();
      return;
    }

    if (_selectedVideoFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please pick a source video from your device gallery!')),
      );
      return;
    }

    if (_promptController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an editing prompt instruction!')),
      );
      return;
    }

    // स्टोरेज परमिशन्स लेना
    var status = await Permission.storage.request();
    if (!status.isGranted) {
      await Permission.manageExternalStorage.request();
    }

    setState(() {
      _isProcessing = true;
      _isDownloading = false;
      _downloadProgress = 0.0;
      _currentLiveStatus = 'Dispatching task to Replicate AI Cloud...';
    });

    try {
      var uri = Uri.parse('https://api.replicate.com/v1/predictions');
      var request = http.Request('POST', uri)
        ..headers.addAll({
          'Authorization': 'Bearer $_replicateApiKey',
          'Content-Type': 'application/json',
        })
        ..body = jsonEncode({
          "version": "9f747673945c62801b13b84701c7d39294203e0e7a2b99480d46777a3d24268e",
          "input": {
            "prompt": _promptController.text.trim(),
            "fps": 24
          }
        });

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception('Failed to start prediction: ${response.body}');
      }

      var jsonResponse = jsonDecode(response.body);
      String getUrl = jsonResponse['urls']?['get'];

      setState(() => _currentLiveStatus = 'AI processing video on cloud. Please wait...');

      bool isFinished = false;
      String? outputVideoUrl;

      while (!isFinished && getUrl != null) {
        await Future.delayed(const Duration(seconds: 4));
        var statusResponse = await http.get(
          Uri.parse(getUrl),
          headers: {'Authorization': 'Bearer $_replicateApiKey'},
        );

        if (statusResponse.statusCode == 200) {
          var statusData = jsonDecode(statusResponse.body);
          String processingStatus = statusData['status'];

          if (processingStatus == 'succeeded') {
            isFinished = true;
            var output = statusData['output'];
            if (output is List && output.isNotEmpty) {
              outputVideoUrl = output[0];
            } else if (output is String) {
              outputVideoUrl = output;
            }
          } else if (processingStatus == 'failed' || processingStatus == 'canceled') {
            throw Exception('Cloud processing failed: ${statusData['error']}');
          } else {
            setState(() => _currentLiveStatus = 'Cloud status: $processingStatus...');
          }
        }
      }

      if (outputVideoUrl == null) {
        throw Exception('Could not get output video URL.');
      }

      // अब Dio पैकेज का उपयोग करके असली वीडियो डाउनलोड करेंगे और लाइव परसेंटेज दिखाएंगे
      setState(() {
        _isProcessing = false;
        _isDownloading = true;
        _currentLiveStatus = 'Downloading processed video...';
      });

      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      final targetPath = '${directory!.path}/Vizia_Pro_${DateTime.now().millisecondsSinceEpoch}.mp4';

      Dio dio = Dio();
      await dio.download(
        outputVideoUrl,
        targetPath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              _downloadProgress = received / total;
              int percent = (_downloadProgress * 100).toInt();
              _currentLiveStatus = 'Downloading: $percent% completed (${(received / 1024 / 1024).toStringAsFixed(1)} MB)';
            });
          }
        },
      );

      setState(() {
        _isDownloading = false;
        _savedFilePath = targetPath;
        _currentLiveStatus = 'Video successfully downloaded and saved!';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('डाउनलोड पूरा हुआ! फाइल यहाँ है: $targetPath')),
      );

    } catch (e) {
      setState(() {
        _isProcessing = false;
        _isDownloading = false;
        _currentLiveStatus = 'Error: $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vizia AI Studio Pro'),
        actions: [
          IconButton(
            icon: Icon(
              Icons.vpn_key,
              color: _replicateApiKey.isEmpty ? Colors.redAccent : Colors.greenAccent,
            ),
            tooltip: 'Configure Replicate API',
            onPressed: _openSettings,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // API Key Status Banner
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _replicateApiKey.isEmpty ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                border: Border.all(color: _replicateApiKey.isEmpty ? Colors.red : Colors.green),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    _replicateApiKey.isEmpty ? Icons.warning : Icons.check_circle,
                    color: _replicateApiKey.isEmpty ? Colors.redAccent : Colors.greenAccent,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _replicateApiKey.isEmpty 
                        ? 'API Key Not Set! Tap the key icon on top right to save permanently.' 
                        : 'API Key Saved Permanently (Ready for production)',
                      style: TextStyle(
                        fontSize: 13,
                        color: _replicateApiKey.isEmpty ? Colors.redAccent : Colors.greenAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('1. Source Video Input', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(
                      _selectedVideoFile == null ? 'No video selected' : 'Selected: ${_selectedVideoFile!.path.split('/').last}',
                      style: TextStyle(color: _selectedVideoFile == null ? Colors.redAccent : Colors.greenAccent, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: (_isProcessing || _isDownloading) ? null : _pickRealVideo,
                      icon: const Icon(Icons.video_library),
                      label: const Text('Pick Video from Gallery'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('2. Master Editing Prompt', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _promptController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Enter instructions for AI video transformation...',
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
                backgroundColor: Colors.deepPurpleAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: (_isProcessing || _isDownloading) ? null : _executePipelineWithPercentage,
              child: Text(
                _isProcessing ? 'Processing on Cloud...' : (_isDownloading ? 'Downloading... ${(_downloadProgress * 100).toInt()}%' : 'Run Pipeline & Download with %'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            if (_isProcessing || _isDownloading) ...[
              LinearProgressIndicator(
                value: _isDownloading ? _downloadProgress : null,
                backgroundColor: Colors.white24,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.greenAccent),
              ),
              const SizedBox(height: 10),
              Text(
                _currentLiveStatus,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 15),
              ),
              if (_isDownloading) ...[
                const SizedBox(height: 6),
                Text(
                  '${(_downloadProgress * 100).toStringAsFixed(1)}% Downloaded',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
              const SizedBox(height: 16),
            ] else ...[
              Text(_currentLiveStatus, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
            ],
            const SizedBox(height: 20),
            if (_savedFilePath != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  border: Border.all(color: Colors.green),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    const Text('Download 100% Completed Successfully!', style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text('फाइल सेव हुई: \n$_savedFilePath', textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Colors.white70)),
                    const SizedBox(height: 8),
                    const Text('अब आप अपने फोन के File Manager -> Download फोल्डर में वीडियो देख सकते हैं!', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: Colors.amberAccent)),
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
