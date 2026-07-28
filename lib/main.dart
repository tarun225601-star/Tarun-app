import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _promptController = TextEditingController();
  final _priceController = TextEditingController();
  final _ghTokenController = TextEditingController();
  final _ghOwnerController = TextEditingController();
  final _repoNameController = TextEditingController();
  final _groqKeyController = TextEditingController();
  String _workflowStatus = '';
  String _apkUrl = '';
  List<App> _publishedApps = [];

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('standalone_gh_token', _ghTokenController.text);
    prefs.setString('standalone_gh_owner', _ghOwnerController.text);
    prefs.setString('standalone_repo_name', _repoNameController.text);
    prefs.setString('standalone_groq_key', _groqKeyController.text);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Settings saved')));
  }

  Future<void> _buildApp() async {
    if (_formKey.currentState!.validate()) {
      final response = await http.post(
        Uri.parse('https://api.groq.com/v1/generate'),
        headers: {
          'Authorization': 'Bearer ${_groqKeyController.text}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'llama-3.3-70b-versatile',
          'prompt': _promptController.text,
        }),
      );
      if (response.statusCode == 200) {
        final code = response.body;
        final workflowResponse = await http.post(
          Uri.parse('https://api.github.com/repos/${_ghOwnerController.text}/${_repoNameController.text}/actions/workflows'),
          headers: {
            'Authorization': 'Bearer ${_ghTokenController.text}',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'name': 'build.yml',
            'path': '.github/workflows/build.yml',
            'contents': 'name: Build\non: push\njobs: build:\n  runs-on: ubuntu-latest\n  steps:\n  - name: Checkout code\n    uses: actions/checkout@v2\n  - name: Build and deploy\n    run: | \n      flutter pub get\n      flutter build apk',
          }),
        );
        if (workflowResponse.statusCode == 201) {
          final workflowId = jsonDecode(workflowResponse.body)['id'];
          final workflowStatusResponse = await http.get(
            Uri.parse('https://api.github.com/repos/${_ghOwnerController.text}/${_repoNameController.text}/actions/workflows/$workflowId'),
            headers: {
              'Authorization': 'Bearer ${_ghTokenController.text}',
              'Content-Type': 'application/json',
            },
          );
          if (workflowStatusResponse.statusCode == 200) {
            final workflowStatus = jsonDecode(workflowStatusResponse.body)['status'];
            while (workflowStatus != 'success') {
              await Future.delayed(const Duration(seconds: 10));
              final workflowStatusResponse = await http.get(
                Uri.parse('https://api.github.com/repos/${_ghOwnerController.text}/${_repoNameController.text}/actions/workflows/$workflowId'),
                headers: {
                  'Authorization': 'Bearer ${_ghTokenController.text}',
                  'Content-Type': 'application/json',
                },
              );
              workflowStatus = jsonDecode(workflowStatusResponse.body)['status'];
            }
            final apkResponse = await http.get(
              Uri.parse('https://api.github.com/repos/${_ghOwnerController.text}/${_repoNameController.text}/actions/artifacts'),
              headers: {
                'Authorization': 'Bearer ${_ghTokenController.text}',
                'Content-Type': 'application/json',
              },
            );
            if (apkResponse.statusCode == 200) {
              final apkUrl = jsonDecode(apkResponse.body)[0]['archive_download_url'];
              setState(() {
                _apkUrl = apkUrl;
              });
              _publishedApps.add(App(
                title: _titleController.text,
                description: _promptController.text,
                price: _priceController.text,
                apkUrl: apkUrl,
              ));
            }
          }
        }
      }
    }
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _ghTokenController.text = prefs.getString('standalone_gh_token') ?? '';
    _ghOwnerController.text = prefs.getString('standalone_gh_owner') ?? '';
    _repoNameController.text = prefs.getString('standalone_repo_name') ?? '';
    _groqKeyController.text = prefs.getString('standalone_groq_key') ?? '';
  }

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tarun Independent App Store & Studio',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: const Color(0xFF2F4F7F),
      ),
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          body: TabBarView(
            children: [
              SettingsScreen(
                ghTokenController: _ghTokenController,
                ghOwnerController: _ghOwnerController,
                repoNameController: _repoNameController,
                groqKeyController: _groqKeyController,
                saveSettings: _saveSettings,
              ),
              AppStudioScreen(
                titleController: _titleController,
                promptController: _promptController,
                priceController: _priceController,
                ghTokenController: _ghTokenController,
                ghOwnerController: _ghOwnerController,
                repoNameController: _repoNameController,
                groqKeyController: _groqKeyController,
                buildApp: _buildApp,
              ),
              AppMarketplaceScreen(
                publishedApps: _publishedApps,
              ),
            ],
          ),
          bottomNavigationBar: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.settings), text: 'Settings'),
              Tab(icon: Icon(Icons.build), text: 'App Studio'),
              Tab(icon: Icon(Icons.shopping_basket), text: 'App Marketplace'),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  final TextEditingController ghTokenController;
  final TextEditingController ghOwnerController;
  final TextEditingController repoNameController;
  final TextEditingController groqKeyController;
  final Function saveSettings;

  const SettingsScreen({
    Key? key,
    required this.ghTokenController,
    required this.ghOwnerController,
    required this.repoNameController,
    required this.groqKeyController,
    required this.saveSettings,
  }) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Form(
        child: Column(
          children: [
            TextFormField(
              controller: widget.ghTokenController,
              decoration: const InputDecoration(
                labelText: 'GitHub Personal Access Token',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: widget.ghOwnerController,
              decoration: const InputDecoration(
                labelText: 'GitHub Owner Username',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: widget.repoNameController,
              decoration: const InputDecoration(
                labelText: 'Repository Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: widget.groqKeyController,
              decoration: const InputDecoration(
                labelText: 'Groq Cloud API Key',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                widget.saveSettings();
              },
              child: const Text('Save Settings'),
            ),
          ],
        ),
      ),
    );
  }
}

class AppStudioScreen extends StatefulWidget {
  final TextEditingController titleController;
  final TextEditingController promptController;
  final TextEditingController priceController;
  final TextEditingController ghTokenController;
  final TextEditingController ghOwnerController;
  final TextEditingController repoNameController;
  final TextEditingController groqKeyController;
  final Function buildApp;

  const AppStudioScreen({
    Key? key,
    required this.titleController,
    required this.promptController,
    required this.priceController,
    required this.ghTokenController,
    required this.ghOwnerController,
    required this.repoNameController,
    required this.groqKeyController,
    required this.buildApp,
  }) : super(key: key);

  @override
  State<AppStudioScreen> createState() => _AppStudioScreenState();
}

class _AppStudioScreenState extends State<AppStudioScreen> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Form(
        child: Column(
          children: [
            TextFormField(
              controller: widget.titleController,
              decoration: const InputDecoration(
                labelText: 'App Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: widget.promptController,
              decoration: const InputDecoration(
                labelText: 'App Prompt',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: widget.priceController,
              decoration: const InputDecoration(
                labelText: 'App Price (INR)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                widget.buildApp();
              },
              child: const Text('Build App'),
            ),
          ],
        ),
      ),
    );
  }
}

class AppMarketplaceScreen extends StatefulWidget {
  final List<App> publishedApps;

  const AppMarketplaceScreen({
    Key? key,
    required this.publishedApps,
  }) : super(key: key);

  @override
  State<AppMarketplaceScreen> createState() => _AppMarketplaceScreenState();
}

class _AppMarketplaceScreenState extends State<AppMarketplaceScreen> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.publishedApps.length,
      itemBuilder: (context, index) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Text(
                  widget.publishedApps[index].title,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.publishedApps[index].description,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),
                Text(
                  'Price: ${widget.publishedApps[index].price}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    // Launch external URL to download or purchase the app
                  },
                  child: const Text('Download'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class App {
  final String title;
  final String description;
  final String price;
  final String apkUrl;

  App({
    required this.title,
    required this.description,
    required this.price,
    required this.apkUrl,
  });
}