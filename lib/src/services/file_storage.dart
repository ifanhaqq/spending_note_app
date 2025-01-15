import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class FileStorage {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/data.json');
  }

  Future<List<Map<String, dynamic>>> readData() async {
    try {
      final file = await _localFile;

      if (await file.exists()) {
        final contents = await file.readAsString();
        return List<Map<String, dynamic>>.from(jsonDecode(contents));
      } else {
        return [];
      }
    } catch (e) {
      return [
        {"error": e}
      ];
    }
  }

  Future<File> addData(Map<String, dynamic> newData) async {
    final file = await _localFile;
    final currentData = await readData();
    currentData.add(newData);
    return file.writeAsString(jsonEncode(currentData));
  }

  // Used in edit & delete function
  Future<File> rewriteData(List<Map<String, dynamic>> newData) async {
    final file = await _localFile;
    return file.writeAsString(jsonEncode(newData));
  }

  Future<void> reset() async {
    try {
      final file = await _localFile;

      if (await file.exists()) {
        await file.delete();
        print('Sucessfully resetted!');
      } else {
        print('The data is not even there yet!');
      }
    } catch (e) {
      print('Error: $e');
    }
  }
}
