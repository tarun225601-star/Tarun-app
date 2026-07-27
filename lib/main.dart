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
      title: 'Colors Serials Hub',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        brightness: Brightness.dark,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _serials = [
    {'name': 'Balika Vadhu', 'image': 'https://via.placeholder.com/100'},
    {'name': 'Naagin', 'image': 'https://via.placeholder.com/100'},
    {'name': 'Bigg Boss', 'image': 'https://via.placeholder.com/100'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Colors Serials Hub'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Popular Hindi Serials',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1,
                ),
                itemCount: _serials.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SerialDetailsScreen(
                              serial: _serials[index],
                            ),
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          Image.network(_serials[index]['image']!),
                          Text(_serials[index]['name']!),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SerialDetailsScreen extends StatefulWidget {
  final Map<String, String> serial;

  const SerialDetailsScreen({Key? key, required this.serial}) : super(key: key);

  @override
  State<SerialDetailsScreen> createState() => _SerialDetailsScreenState();
}

class _SerialDetailsScreenState extends State<SerialDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.serial['name']!),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Character List',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: const [
                  ListTile(
                    title: Text('Character 1'),
                    subtitle: Text('Actor Name'),
                  ),
                  ListTile(
                    title: Text('Character 2'),
                    subtitle: Text('Actor Name'),
                  ),
                  ListTile(
                    title: Text('Character 3'),
                    subtitle: Text('Actor Name'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const QuizAndPollsScreen(),
                  ),
                );
              },
              child: const Text('Quiz & Polls'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Redirect to JioCinema
                final url = 'https://www.jiocinema.com/';
                // Use url_launcher package or http package to launch the URL
                // For simplicity, we will use http package to make a GET request
                http.get(Uri.parse(url));
              },
              child: const Text('Watch Now on JioCinema'),
            ),
          ],
        ),
      ),
    );
  }
}

class QuizAndPollsScreen extends StatefulWidget {
  const QuizAndPollsScreen({Key? key}) : super(key: key);

  @override
  State<QuizAndPollsScreen> createState() => _QuizAndPollsScreenState();
}

class _QuizAndPollsScreenState extends State<QuizAndPollsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz & Polls'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Daily Show Twists',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Show quiz or poll
              },
              child: const Text('Vote Now'),
            ),
            const SizedBox(height: 16),
            const Text(
              'Serial Trivia Quizzes',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Show quiz or poll
              },
              child: const Text('Take Quiz'),
            ),
          ],
        ),
      ),
    );
  }
}