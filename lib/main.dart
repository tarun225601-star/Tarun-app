import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personal Finance & Crypto Tracker',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
      ),
      home: const BudgetAdvisor(),
    );
  }
}

class BudgetAdvisor extends StatefulWidget {
  const BudgetAdvisor({Key? key}) : super(key: key);

  @override
  State<BudgetAdvisor> createState() => _BudgetAdvisorState();
}

class _BudgetAdvisorState extends State<BudgetAdvisor> {
  int _currentIndex = 0;
  double _monthlySalary = 0;
  double _monthlyIncome = 0;
  double _monthlyExpenses = 0;
  double _netWorth = 0;
  List<Map<String, dynamic>> _transactions = [];
  List<Map<String, dynamic>> _cryptoPrices = [];

  Future<void> _fetchCryptoPrices() async {
    final response = await http.get(Uri.parse('https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=10&page=1&sparkline=false'));
    if (response.statusCode == 200) {
      setState(() {
        _cryptoPrices = jsonDecode(response.body);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to fetch crypto prices')));
    }
  }

  Future<void> _saveTransaction(Map<String, dynamic> transaction) async {
    final prefs = await SharedPreferences.getInstance();
    final transactionsJson = prefs.getString('transactions');
    if (transactionsJson != null) {
      final transactions = jsonDecode(transactionsJson);
      transactions.add(transaction);
      await prefs.setString('transactions', jsonEncode(transactions));
    } else {
      await prefs.setString('transactions', jsonEncode([transaction]));
    }
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final transactionsJson = prefs.getString('transactions');
    if (transactionsJson != null) {
      setState(() {
        _transactions = jsonDecode(transactionsJson);
        _monthlyIncome = 0;
        _monthlyExpenses = 0;
        for (final transaction in _transactions) {
          if (transaction['type'] == 'income') {
            _monthlyIncome += transaction['amount'];
          } else {
            _monthlyExpenses += transaction['amount'];
          }
        }
        _netWorth = _monthlyIncome - _monthlyExpenses;
      });
    }
  }

  Future<void> _deleteTransaction(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final transactionsJson = prefs.getString('transactions');
    if (transactionsJson != null) {
      final transactions = jsonDecode(transactionsJson);
      transactions.removeAt(index);
      await prefs.setString('transactions', jsonEncode(transactions));
      _loadTransactions();
    }
  }

  void _showAddTransactionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final _formKey = GlobalKey<FormState>();
        final _amountController = TextEditingController();
        final _descriptionController = TextEditingController();
        String _type = 'income';
        return AlertDialog(
          title: const Text('Add Transaction'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(labelText: 'Amount'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                Row(
                  children: [
                    Radio(
                      value: 'income',
                      groupValue: _type,
                      onChanged: (value) {
                        setState(() {
                          _type = value as String;
                        });
                      },
                    ),
                    const Text('Income'),
                    Radio(
                      value: 'expense',
                      groupValue: _type,
                      onChanged: (value) {
                        setState(() {
                          _type = value as String;
                        });
                      },
                    ),
                    const Text('Expense'),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _saveTransaction({
                    'amount': double.parse(_amountController.text),
                    'description': _descriptionController.text,
                    'type': _type,
                  });
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showEditTransactionDialog(int index) {
    showDialog(
      context: context,
      builder: (context) {
        final _formKey = GlobalKey<FormState>();
        final _amountController = TextEditingController(text: _transactions[index]['amount'].toString());
        final _descriptionController = TextEditingController(text: _transactions[index]['description']);
        String _type = _transactions[index]['type'];
        return AlertDialog(
          title: const Text('Edit Transaction'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(labelText: 'Amount'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                Row(
                  children: [
                    Radio(
                      value: 'income',
                      groupValue: _type,
                      onChanged: (value) {
                        setState(() {
                          _type = value as String;
                        });
                      },
                    ),
                    const Text('Income'),
                    Radio(
                      value: 'expense',
                      groupValue: _type,
                      onChanged: (value) {
                        setState(() {
                          _type = value as String;
                        });
                      },
                    ),
                    const Text('Expense'),
                  ],
                ),
              ],
            ),
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
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final prefs = SharedPreferences.getInstance();
                  prefs.then((prefs) {
                    final transactionsJson = prefs.getString('transactions');
                    if (transactionsJson != null) {
                      final transactions = jsonDecode(transactionsJson);
                      transactions[index] = {
                        'amount': double.parse(_amountController.text),
                        'description': _descriptionController.text,
                        'type': _type,
                      };
                      prefs.setString('transactions', jsonEncode(transactions));
                      _loadTransactions();
                    }
                  });
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showBudgetAdvisorDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final _formKey = GlobalKey<FormState>();
        final _monthlySalaryController = TextEditingController();
        return AlertDialog(
          title: const Text('Budget Advisor'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _monthlySalaryController,
                  decoration: const InputDecoration(labelText: 'Monthly Salary'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a monthly salary';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Get Advice'),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  setState(() {
                    _monthlySalary = double.parse(_monthlySalaryController.text);
                  });
                  Navigator.of(context).pop();
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Budget Advice'),
                        content: Text('Based on your monthly salary of \$${_monthlySalary.toStringAsFixed(2)}, you should consider allocating 50% towards necessary expenses, 30% towards discretionary spending, and 20% towards saving and debt repayment.'),
                        actions: [
                          TextButton(
                            child: const Text('OK'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _loadTransactions();
    _fetchCryptoPrices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Finance & Crypto Tracker'),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          // Dashboard
          Column(
            children: [
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text('Total Net Worth'),
                      Text('\$${_netWorth.toStringAsFixed(2)}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text('Monthly Income'),
                      Text('\$${_monthlyIncome.toStringAsFixed(2)}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text('Monthly Expenses'),
                      Text('\$${_monthlyExpenses.toStringAsFixed(2)}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _showBudgetAdvisorDialog,
                child: const Text('Get Budget Advice'),
              ),
            ],
          ),
          // Transactions
          Column(
            children: [
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _showAddTransactionDialog,
                child: const Text('Add Transaction'),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: _transactions.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(_transactions[index]['description']),
                      subtitle: Text('\$${_transactions[index]['amount'].toStringAsFixed(2)} (${_transactions[index]['type']})'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              _showEditTransactionDialog(index);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              _deleteTransaction(index);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          // Crypto Prices
          Column(
            children: [
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: _cryptoPrices.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(_cryptoPrices[index]['name']),
                      subtitle: Text('Price: \$${_cryptoPrices[index]['current_price'].toStringAsFixed(2)}'),
                    );
                  },
                ),
              ),
            ],
          ),
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
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Transactions'),
          BottomNavigationBarItem(icon: Icon(Icons.currency_exchange), label: 'Crypto Prices'),
        ],
      ),
    );
  }
}