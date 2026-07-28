import 'package:flutter/material.dart';
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
  int _currentIndex = 0;
  final _apps = [
    {'name': 'App 1', 'description': 'This is app 1', 'price': 9.99, 'category': 'Productivity'},
    {'name': 'App 2', 'description': 'This is app 2', 'price': 14.99, 'category': 'Gaming'},
    {'name': 'App 3', 'description': 'This is app 3', 'price': 19.99, 'category': 'Education'},
  ];
  final _purchases = [];
  final _uploadFormKey = GlobalKey<FormState>();
  final _uploadAppNameController = TextEditingController();
  final _uploadAppDescriptionController = TextEditingController();
  final _uploadAppPriceController = TextEditingController();
  final _uploadAppCategoryController = TextEditingController();

  void _uploadApp() {
    if (_uploadFormKey.currentState!.validate()) {
      final newApp = {
        'name': _uploadAppNameController.text,
        'description': _uploadAppDescriptionController.text,
        'price': double.parse(_uploadAppPriceController.text),
        'category': _uploadAppCategoryController.text,
      };
      setState(() {
        _apps.add(newApp);
      });
      _uploadAppNameController.clear();
      _uploadAppDescriptionController.clear();
      _uploadAppPriceController.clear();
      _uploadAppCategoryController.clear();
    }
  }

  void _buyApp(app) {
    setState(() {
      _purchases.add(app);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: [
        HomeDashboard(_apps, _buyApp),
        UploadAppScreen(
          _uploadFormKey,
          _uploadAppNameController,
          _uploadAppDescriptionController,
          _uploadAppPriceController,
          _uploadAppCategoryController,
          _uploadApp,
        ),
        MyPurchasesScreen(_purchases),
        const ProfileScreen(),
      ][_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.upload), label: 'Upload'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'My Purchases'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class HomeDashboard extends StatelessWidget {
  final List _apps;
  final Function _buyApp;

  const HomeDashboard(this._apps, this._buyApp, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vizia Global Studio'),
      ),
      body: ListView.builder(
        itemCount: _apps.length,
        itemBuilder: (context, index) {
          final app = _apps[index];
          return Card(
            child: ListTile(
              title: Text(app['name']),
              subtitle: Text(app['description']),
              trailing: Text('\$${app['price']}'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AppDetailsScreen(app, _buyApp),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class UploadAppScreen extends StatelessWidget {
  final _formKey;
  final _appNameController;
  final _appDescriptionController;
  final _appPriceController;
  final _appCategoryController;
  final Function _uploadApp;

  const UploadAppScreen(
    this._formKey,
    this._appNameController,
    this._appDescriptionController,
    this._appPriceController,
    this._appCategoryController,
    this._uploadApp, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _appNameController,
                decoration: const InputDecoration(
                  labelText: 'App Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter app name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _appDescriptionController,
                decoration: const InputDecoration(
                  labelText: 'App Description',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter app description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _appPriceController,
                decoration: const InputDecoration(
                  labelText: 'App Price',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter app price';
                  }
                  return null;
                },
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _appCategoryController,
                decoration: const InputDecoration(
                  labelText: 'App Category',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter app category';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _uploadApp,
                child: const Text('Upload App'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppDetailsScreen extends StatelessWidget {
  final _app;
  final Function _buyApp;

  const AppDetailsScreen(this._app, this._buyApp, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_app['name']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(_app['description']),
            const SizedBox(height: 20),
            Text('\$${_app['price']}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _buyApp(_app),
              child: const Text('Buy App'),
            ),
          ],
        ),
      ),
    );
  }
}

class MyPurchasesScreen extends StatelessWidget {
  final List _purchases;

  const MyPurchasesScreen(this._purchases, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Purchases'),
      ),
      body: ListView.builder(
        itemCount: _purchases.length,
        itemBuilder: (context, index) {
          final app = _purchases[index];
          return Card(
            child: ListTile(
              title: Text(app['name']),
              subtitle: Text(app['description']),
              trailing: Text('\$${app['price']}'),
            ),
          );
        },
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: const Center(
        child: Text('Profile Screen'),
      ),
    );
  }
}