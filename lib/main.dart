import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI-Powered Personal Finance & Crypto Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
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
  double _totalNetWorth = 0;
  double _monthlyIncome = 0;
  double _monthlyExpenses = 0;
  List<Transaction> _transactions = [];
  List<Crypto> _cryptos = [];

  Future<void> _loadTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final transactionsJson = prefs.getString('transactions');
    if (transactionsJson != null) {
      final transactions = jsonDecode(transactionsJson);
      setState(() {
        _transactions = transactions
            .map((transaction) => Transaction.fromJson(transaction))
            .toList();
        _calculateNetWorth();
      });
    }
  }

  Future<void> _saveTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final transactionsJson = jsonEncode(_transactions);
    await prefs.setString('transactions', transactionsJson);
  }

  void _calculateNetWorth() {
    _totalNetWorth = 0;
    _monthlyIncome = 0;
    _monthlyExpenses = 0;
    for (final transaction in _transactions) {
      if (transaction.type == 'income') {
        _totalNetWorth += transaction.amount;
        _monthlyIncome += transaction.amount;
      } else if (transaction.type == 'expense') {
        _totalNetWorth -= transaction.amount;
        _monthlyExpenses += transaction.amount;
      }
    }
    setState(() {});
  }

  Future<void> _fetchCryptos() async {
    try {
      final response = await http.get(Uri.parse('https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=10&page=1&sparkline=false'));
      if (response.statusCode == 200) {
        final cryptosJson = jsonDecode(response.body);
        setState(() {
          _cryptos = cryptosJson.map((cryptoJson) => Crypto.fromJson(cryptoJson)).toList();
        });
      } else {
        print('Failed to load cryptos');
      }
    } catch (e) {
      print('Failed to load cryptos: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _loadTransactions();
    _fetchCryptos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          Dashboard(
            totalNetWorth: _totalNetWorth,
            monthlyIncome: _monthlyIncome,
            monthlyExpenses: _monthlyExpenses,
          ),
          Transactions(
            transactions: _transactions,
            saveTransactions: _saveTransactions,
            calculateNetWorth: _calculateNetWorth,
          ),
          Cryptos(
            cryptos: _cryptos,
          ),
          BudgetAdvisor(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money),
            label: 'Transactions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.currency_bitcoin),
            label: 'Cryptos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate),
            label: 'Budget Advisor',
          ),
        ],
      ),
    );
  }
}

class Dashboard extends StatelessWidget {
  final double totalNetWorth;
  final double monthlyIncome;
  final double monthlyExpenses;

  const Dashboard({
    Key? key,
    required this.totalNetWorth,
    required this.monthlyIncome,
    required this.monthlyExpenses,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        CustomCard(
          title: 'Total Net Worth',
          value: totalNetWorth,
        ),
        CustomCard(
          title: 'Monthly Income',
          value: monthlyIncome,
        ),
        CustomCard(
          title: 'Monthly Expenses',
          value: monthlyExpenses,
        ),
      ],
    );
  }
}

class CustomCard extends StatelessWidget {
  final String title;
  final double value;

  const CustomCard({
    Key? key,
    required this.title,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18),
            ),
            const Spacer(),
            Text(
              '\$${value.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class Transactions extends StatefulWidget {
  final List<Transaction> transactions;
  final Function saveTransactions;
  final Function calculateNetWorth;

  const Transactions({
    Key? key,
    required this.transactions,
    required this.saveTransactions,
    required this.calculateNetWorth,
  }) : super(key: key);

  @override
  State<Transactions> createState() => _TransactionsState();
}

class _TransactionsState extends State<Transactions> {
  final _formKey = GlobalKey<FormState>();
  String _type = 'income';
  double _amount = 0;
  String _description = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Amount',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  return null;
                },
                onSaved: (value) {
                  _amount = double.parse(value!);
                },
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Description',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
                onSaved: (value) {
                  _description = value!;
                },
              ),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _type = 'income';
                      },
                      child: Text(
                        _type == 'income' ? 'Income' : 'Select Income',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _type = 'expense';
                      },
                      child: Text(
                        _type == 'expense' ? 'Expense' : 'Select Expense',
                      ),
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    widget.transactions.add(
                      Transaction(
                        type: _type,
                        amount: _amount,
                        description: _description,
                      ),
                    );
                    widget.saveTransactions();
                    widget.calculateNetWorth();
                    _formKey.currentState!.reset();
                  }
                },
                child: const Text('Add Transaction'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: ListView.builder(
            itemCount: widget.transactions.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(
                  '${widget.transactions[index].type} - ${widget.transactions[index].description}',
                ),
                subtitle: Text(
                  '\$${widget.transactions[index].amount.toStringAsFixed(2)}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    widget.transactions.removeAt(index);
                    widget.saveTransactions();
                    widget.calculateNetWorth();
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class Transaction {
  final String type;
  final double amount;
  final String description;

  Transaction({
    required this.type,
    required this.amount,
    required this.description,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      type: json['type'],
      amount: json['amount'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'amount': amount,
      'description': description,
    };
  }
}

class Cryptos extends StatelessWidget {
  final List<Crypto> cryptos;

  const Cryptos({
    Key? key,
    required this.cryptos,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: cryptos.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(
            cryptos[index].name,
          ),
          subtitle: Text(
            '\$${cryptos[index].price.toStringAsFixed(2)}',
          ),
        );
      },
    );
  }
}

class Crypto {
  final String name;
  final double price;

  Crypto({
    required this.name,
    required this.price,
  });

  factory Crypto.fromJson(Map<String, dynamic> json) {
    return Crypto(
      name: json['name'],
      price: json['current_price'],
    );
  }
}

class BudgetAdvisor extends StatefulWidget {
  @override
  State<BudgetAdvisor> createState() => _BudgetAdvisorState();
}

class _BudgetAdvisorState extends State<BudgetAdvisor> {
  final _formKey = GlobalKey<FormState>();
  double _monthlySalary = 0;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          const SizedBox(height: 20),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Monthly Salary',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a monthly salary';
              }
              return null;
            },
            onSaved: (value) {
              _monthlySalary = double.parse(value!);
            },
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                double savings = _monthlySalary * 0.2;
                double expenses = _monthlySalary * 0.5;
                double investments = _monthlySalary * 0.3;
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Budget Advice'),
                      content: Text(
                        'Based on your monthly salary of \$$monthlySalary, we recommend:\n'
                        'Savings: \$$savings\n'
                        'Expenses: \$$expenses\n'
                        'Investments: \$$investments',
                      ),
                      actions: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    );
                  },
                );
              }
            },
            child: const Text('Get Budget Advice'),
          ),
        ],
      ),
    );
  }
}