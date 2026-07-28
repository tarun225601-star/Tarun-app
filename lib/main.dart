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
  final List<Widget> _children = [
    const HomeDashboard(),
    const UploadAppScreen(),
    const MyPurchases(),
    const Profile(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.upload), label: 'Upload'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Purchases'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({Key? key}) : super(key: key);

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  final List<App> _apps = [
    App(
      id: 1,
      name: 'App 1',
      description: 'Description 1',
      price: 9.99,
      category: 'Category 1',
    ),
    App(
      id: 2,
      name: 'App 2',
      description: 'Description 2',
      price: 19.99,
      category: 'Category 2',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Dashboard'),
      ),
      body: ListView.builder(
        itemCount: _apps.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text(_apps[index].name),
              subtitle: Text(_apps[index].description),
              trailing: Text('\$${_apps[index].price}'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AppDetails(app: _apps[index]),
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

class App {
  final int id;
  final String name;
  final String description;
  final double price;
  final String category;

  App({required this.id, required this.name, required this.description, required this.price, required this.category});
}

class AppDetails extends StatelessWidget {
  final App app;

  const AppDetails({Key? key, required this.app}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(app.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(app.description),
            const SizedBox(height: 16),
            Text('Price: \$${app.price}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Simulate purchase
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('App purchased successfully')));
              },
              child: const Text('Buy Now'),
            ),
          ],
        ),
      ),
    );
  }
}

class UploadAppScreen extends StatefulWidget {
  const UploadAppScreen({Key? key}) : super(key: key);

  @override
  State<UploadAppScreen> createState() => _UploadAppScreenState();
}

class _UploadAppScreenState extends State<UploadAppScreen> {
  final _formKey = GlobalKey<FormState>();
  final _appNameController = TextEditingController();
  final _appDescriptionController = TextEditingController();
  final _appPriceController = TextEditingController();
  final _appCategoryController = TextEditingController();

  @override
  void dispose() {
    _appNameController.dispose();
    _appDescriptionController.dispose();
    _appPriceController.dispose();
    _appCategoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _appNameController,
                decoration: const InputDecoration(labelText: 'App Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter app name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _appDescriptionController,
                decoration: const InputDecoration(labelText: 'App Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter app description';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _appPriceController,
                decoration: const InputDecoration(labelText: 'App Price'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter app price';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _appCategoryController,
                decoration: const InputDecoration(labelText: 'App Category'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter app category';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Upload app to server
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('App uploaded successfully')));
                  }
                },
                child: const Text('Upload App'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyPurchases extends StatelessWidget {
  const MyPurchases({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Purchases'),
      ),
      body: const Center(
        child: Text('No purchases yet'),
      ),
    );
  }
}

class Profile extends StatelessWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: const Center(
        child: Text('Profile page'),
      ),
    );
  }
}