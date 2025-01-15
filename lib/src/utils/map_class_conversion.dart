import 'package:spending_note_app/src/models/transaction.dart';

class MapClassConversion {
  List<Transaction> mapToClass(List<Map<String, dynamic>> maps) {
    List<Transaction> transactionsInClass = [];

    for (var map in maps) {
      Transaction transaction =
          Transaction(map['type'], map['value'], map['name'], map['timestamp']);
      transactionsInClass.add(transaction);
    }

    return transactionsInClass;
  }

  List<Map<String, dynamic>> classToMap(List<Transaction> transactions) {
    List<Map<String, dynamic>> transactionsInMap = [];

    for (var transaction in transactions) {
      final data = {
        "type": transaction.transactionType,
        "name": transaction.transactionName,
        "value": transaction.value,
        "timestamp": transaction.timestamp
      };

      transactionsInMap.add(data);
    }

    return transactionsInMap;
  }
}
