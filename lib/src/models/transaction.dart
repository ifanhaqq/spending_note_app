class Transaction {
  // 1 for income and 0 for expenses
  int _transactionType;
  String _transactionName;
  int _value;
  String _timestamp;

  Transaction(this._transactionType, this._value, this._transactionName,
      this._timestamp);

  int get transactionType {
    return _transactionType;
  }

  String get transactionName {
    return _transactionName;
  }

  int get value {
    return _value;
  }

  String get timestamp {
    return _timestamp;
  }

  set transactionType(int type) {
    _transactionType = type;
  }

  set value(int value) {
    _value = value;
  }

  set transactionName(String name) {
    _transactionName = name;
  }

  set timestamp(String timestamp) {
    _timestamp = timestamp;
  }
}
