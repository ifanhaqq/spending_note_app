// import 'dart:convert';

import 'package:flutter/material.dart';
import '../services/file_storage.dart';
import '../models/transaction.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FileStorage _fileStorage = FileStorage();
  // List<Map<String, dynamic>> _datas = [];
  final TextEditingController _valueController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  String? _selectedType;
  List<Transaction> transactions = [];
  int _totalExpenses = 0;
  int _totalIncome = 0;
  int get _totalBalance => _totalIncome - _totalExpenses;

  @override
  void initState() {
    super.initState();

    _loadData();
  }

  Future<void> _loadData() async {
    final data = await _fileStorage.readData();
    print(data);
    List<Transaction> transactionsFromJson = [];

    for (var entry in data) {
      Transaction transaction = Transaction(
          entry['type'], entry['value'], entry['name'], entry['timestamp']);
      transactionsFromJson.add(transaction);
    }

    setState(() {
      transactions = transactionsFromJson;
    });

    _calculateInformation();
  }

  Future<void> _saveData(BuildContext context) async {
    final data = {
      "type": int.parse(_selectedType!),
      "name": _nameController.text,
      "value": int.parse(_valueController.text),
      "timestamp": DateTime.now().toIso8601String()
    };

    await _fileStorage.addData(data);
    _loadData();
    _valueController.clear();
    _nameController.clear();
    _selectedType = null;
  }

  void _calculateInformation() {
    setState(() {
      _totalExpenses = 0;
      _totalIncome = 0;
    });
    for (var transaction in transactions) {
      if (transaction.transactionType == 1) {
        _totalIncome += transaction.value;
      } else {
        _totalExpenses += transaction.value;
      }
    }
  }

  void _openModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allow the modal to have a custom height
      builder: (BuildContext context) {
        String? selectedType = _selectedType; // Local copy to manage state

        return Container(
          padding: const EdgeInsets.all(16.0),
          color: Color(0XFF1E201E),
          child: SingleChildScrollView(
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setModalState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Add new note',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xffECDFCC)),
                    ),
                    SizedBox(height: 20),
                    Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              'So is it in or out?',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xffECDFCC)),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Radio<String>(
                              value: '1',
                              groupValue: selectedType,
                              onChanged: (String? value) {
                                setModalState(() {
                                  selectedType = value; // Update local state
                                });
                                setState(() {
                                  _selectedType =
                                      value; // Sync with parent state
                                });
                              },
                            ),
                            Text(
                              'Income',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xffECDFCC)),
                            )
                          ],
                        ),
                        Row(
                          children: [
                            Radio<String>(
                              value: '0',
                              groupValue: selectedType,
                              onChanged: (String? value) {
                                setModalState(() {
                                  selectedType = value; // Update local state
                                });
                                setState(() {
                                  _selectedType =
                                      value; // Sync with parent state
                                });
                              },
                            ),
                            Text(
                              'Expenses',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xffECDFCC)),
                            )
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'What you got?',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _valueController,
                      decoration: InputDecoration(
                        labelText: 'How much did you spent/got?',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    TextButton(
                      onPressed: () {
                        if (_selectedType == null &&
                            _valueController.text.isEmpty &&
                            _nameController.text.isEmpty &&
                            int.tryParse(_valueController.text) == null) {
                          _alert(context, "Please fill all the data!");
                        } else if (int.tryParse(_valueController.text) ==
                            null) {
                          _alert(context, "Please input a valid number!");
                        } else {
                          _saveData(context);
                          Navigator.pop(context);
                        }
                      },
                      style: TextButton.styleFrom(
                          backgroundColor: Color(0XFF697565),
                          foregroundColor: Color(0xffECDFCC)),
                      child: Text('Ok'),
                    )
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _alert(BuildContext context, String warning) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(warning),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Omke'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: const Text('Track your spending'), centerTitle: true),
      body: Column(
        children: [
          Container(
              padding: EdgeInsets.only(top: 5, bottom: 5),
              margin: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Color(0XFF697565),
                borderRadius: BorderRadius.circular(10), // Rounded corners
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Expenses',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xffECDFCC)),
                        ),
                        Text(
                          'Rp. $_totalExpenses',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xffECDFCC)),
                        )
                      ]),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Income',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xffECDFCC)),
                        ),
                        Text(
                          'Rp. $_totalIncome',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xffECDFCC)),
                        )
                      ]),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Balance',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xffECDFCC)),
                        ),
                        Text(
                          'Rp. $_totalBalance',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xffECDFCC)),
                        )
                      ]),
                ],
              )),
          const SizedBox(
            height: 20,
          ),
          Expanded(
              child: ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              var transaction = transactions[index];
              int type = transaction.transactionType;
              int value = transaction.value;
              String name = transaction.transactionName;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  border: Border.all(color: Color(0xffECDFCC)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                    title: Text(
                      name,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xffECDFCC)),
                    ),
                    trailing: (type == 1)
                        ? Text(
                            '+ Rp. $value',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xffECDFCC)),
                          )
                        : Text(
                            '- Rp. $value',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xffECDFCC)),
                          )),
              );
            },
          )),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          // ignore: avoid_print
          onPressed: () => _openModal(context),
          backgroundColor: Color(0XFF1E201E),
          foregroundColor: Color(0xffECDFCC),
          child: Icon(Icons.add)),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
