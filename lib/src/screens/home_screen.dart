// import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:spending_note_app/src/utils/map_class_conversion.dart';
import '../services/file_storage.dart';
import '../models/transaction.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FileStorage _fileStorage = FileStorage();
  List<Transaction> transactions = [];
  int _totalExpenses = 0;
  int _totalIncome = 0;
  int get _totalBalance => _totalIncome - _totalExpenses;

  final TextEditingController _valueController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  String? _selectedType;
  String? _transactionId;

  @override
  void initState() {
    super.initState();

    _loadData();
  }

  Future<void> _loadData() async {
    final data = await _fileStorage.readData();
    print(data);
    List<Transaction> transactionsFromJson =
        MapClassConversion().mapToClass(data);

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

  void _editData(BuildContext context) {
    Transaction transaction = transactions
        .firstWhere((transaction) => transaction.timestamp == _transactionId);

    setState(() {
      _valueController.text = transaction.value.toString();
      _nameController.text = transaction.transactionName;
      _selectedType = transaction.transactionType.toString();
    });

    _openModal(context, 0);
  }

  Future<void> _updateData(BuildContext context) async {
    setState(() {
      for (var transaction in transactions) {
        if (transaction.timestamp == _transactionId) {
          transaction.transactionName = _nameController.text;
          transaction.transactionType = int.parse(_selectedType!);
          transaction.value = int.parse(_valueController.text);
        }
      }
    });

    List<Map<String, dynamic>> newData =
        MapClassConversion().classToMap(transactions);

    await _fileStorage.rewriteData(newData);
    _loadData();
    _valueController.clear();
    _nameController.clear();
    _selectedType = null;
  }

  Future<void> _deleteData(BuildContext context) async {
    setState(() {
      transactions.removeWhere(
          (transaction) => transaction.timestamp == _transactionId);
    });

    List<Map<String, dynamic>> newData =
        MapClassConversion().classToMap(transactions);

    await _fileStorage.rewriteData(newData);
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

  void _openModal(BuildContext context, int type) {
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
                return Container(
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom),
                    child: Column(
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
                                      selectedType =
                                          value; // Update local state
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
                                      selectedType =
                                          value; // Update local state
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
                          style: TextStyle(color: Color(0xffECDFCC)),
                        ),
                        SizedBox(height: 20),
                        TextField(
                            controller: _valueController,
                            decoration: InputDecoration(
                              labelText: 'How much did you spent/got?',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            style: TextStyle(color: Color(0xffECDFCC))),
                        SizedBox(
                          height: 20,
                        ),
                        TextButton(
                          onPressed: () {
                            if (_selectedType == null ||
                                _valueController.text.isEmpty ||
                                _nameController.text.isEmpty ||
                                int.tryParse(_valueController.text) == null) {
                              _alert(context, "Please fill all the data!");
                            } else if (int.tryParse(_valueController.text) ==
                                null) {
                              _alert(context, "Please input a valid number!");
                            } else {
                              if (type == 1) {
                                _saveData(context);
                              } else if (type == 0) {
                                _updateData(context);
                                Navigator.pop(context);
                              }
                              Navigator.pop(context);
                            }
                          },
                          style: TextButton.styleFrom(
                              backgroundColor: Color(0XFF697565),
                              foregroundColor: Color(0xffECDFCC)),
                          child: Text('Ok'),
                        )
                      ],
                    ));
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _optionsAlert(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0XFF3C3D37),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton.icon(
                  onPressed: () => _editData(context),
                  label: Icon(
                    Icons.edit,
                    size: 50,
                    color: Color(0XFFECDFCC),
                  )),
              TextButton.icon(
                  onPressed: () {
                    showDialog<void>(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Are you sure?',
                              style: TextStyle(color: Color(0XFFECDFCC))),
                          backgroundColor: Color(0XFF3C3D37),
                          actions: <Widget>[
                            TextButton(
                              style: TextButton.styleFrom(
                                textStyle:
                                    Theme.of(context).textTheme.labelLarge,
                              ),
                              child: const Text(
                                'Omke',
                                style: TextStyle(color: Color(0XFFECDFCC)),
                              ),
                              onPressed: () {
                                _deleteData(context);
                                Navigator.of(context).pop();
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              style: TextButton.styleFrom(
                                textStyle:
                                    Theme.of(context).textTheme.labelLarge,
                              ),
                              child: const Text('No',
                                  style: TextStyle(color: Color(0XFFECDFCC))),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  label: Icon(
                    Icons.delete,
                    size: 50,
                    color: Color(0XFFECDFCC),
                  ))
            ],
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0XFFECDFCC)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _alert(BuildContext context, String warning) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            warning,
            style: TextStyle(color: Color(0XFFECDFCC)),
          ),
          backgroundColor: Color(0XFF3C3D37),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Omke',
                  style: TextStyle(color: Color(0XFFECDFCC))),
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
                borderRadius: BorderRadius.circular(5), // Rounded corners
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
                              color: Color(0xffECDFCC),
                              fontSize: 12),
                        )
                      ]),
                  Container(
                      decoration: BoxDecoration(
                          border: Border(
                              right: BorderSide(color: Color(0xffECDFCC)),
                              left: BorderSide(color: Color(0xffECDFCC)))),
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
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
                                  color: Color(0xffECDFCC),
                                  fontSize: 12),
                            )
                          ])),
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
                              color: Color(0xffECDFCC),
                              fontSize: 12),
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
              return InkWell(
                onLongPress: () {
                  setState(() {
                    _transactionId = transaction.timestamp;
                  });

                  _optionsAlert(context);
                },
                splashColor: const Color.fromARGB(29, 158, 158, 158),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    border:
                        Border(bottom: BorderSide(color: Color(0xffECDFCC))),
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
                ),
              );
            },
          )),
        ],
      ),
      floatingActionButton: Stack(
        children: [
          Positioned(
              bottom: 0,
              right: 5,
              child: FloatingActionButton(
                  // ignore: avoid_print
                  onPressed: () => _openModal(context, 1),
                  backgroundColor: Color(0XFF1E201E),
                  foregroundColor: Color(0xffECDFCC),
                  child: Icon(Icons.add))),
          Positioned(
              bottom: 0,
              left: 40,
              child: FloatingActionButton(
                  // ignore: avoid_print
                  onPressed: () {
                    showDialog<void>(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text(
                              textAlign: TextAlign.center,
                              'Are you sure? If you do so, all tracked spending you have will be deleted forever!',
                              style: TextStyle(color: Color(0XFFECDFCC))),
                          backgroundColor: Color(0XFF3C3D37),
                          actions: <Widget>[
                            TextButton(
                              style: TextButton.styleFrom(
                                textStyle:
                                    Theme.of(context).textTheme.labelLarge,
                              ),
                              child: const Text(
                                'Omke',
                                style: TextStyle(color: Color(0XFFECDFCC)),
                              ),
                              onPressed: () async {
                                await _fileStorage.reset();
                                _loadData();
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              style: TextButton.styleFrom(
                                textStyle:
                                    Theme.of(context).textTheme.labelLarge,
                              ),
                              child: const Text('No',
                                  style: TextStyle(color: Color(0XFFECDFCC))),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  backgroundColor: Colors.red,
                  foregroundColor: Color(0xffECDFCC),
                  child: Icon(Icons.delete_forever)))
        ],
      ),
    );
  }
}
