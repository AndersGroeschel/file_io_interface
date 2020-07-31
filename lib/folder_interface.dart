import 'dart:io';
import 'dart:typed_data';

import 'package:abstract_io/abstract_io.dart';
import 'package:path_provider/path_provider.dart';

abstract class _BaseFolderInterface<T> extends MapIOInterface<String, T>{

  final String folderPath;

  _BaseFolderInterface(this.folderPath);

  /// returns the file associated with the [filePath]
  Future<File> _file(String fileName) async {
    return File('${await _folderPath}/$fileName');
  }

  Future<Directory> get _directory async{
    return (Directory(await _folderPath));
  }

  Future<String> get _folderPath async => "${(await getApplicationDocumentsDirectory()).path}/$folderPath";

  @override
  Future<bool> deleteData({bool recursive = true}) async {
    try {
      await (await _directory).delete(recursive: recursive);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> deleteEntry(String key) async {
    try {
      await (await _file(key)).delete();
      return true;
    } catch (e) {
      return false;
    }
  }
}

class StringFolderInterface extends _BaseFolderInterface<String>{


  StringFolderInterface(String folderPath) : super(folderPath);


  @override
  Future<String> addEntry(String value) async {
    final String name = DateTime.now().toIso8601String();
    await (await _file(name)).writeAsString(value);
    return name;
  }

  @override
  Future<String> getEntry(String key) async {
    return (await _file(key)).readAsString();
  }
  
  @override
  Future<void> requestData({bool recursive = false, bool followLinks = false}) async {
    Directory dir = await _directory;
    await for(FileSystemEntity file in dir.list(recursive: recursive,followLinks: followLinks)){
      if(file is File){
        try {
          final String val = await file.readAsString();
          final String fileName = file.path.split("/").last;
          onEntryRecieved(fileName, val);
        } catch (e) {
        }
      }
    }
  }

  @override
  Future<bool> sendData(Map<String, String> data) async {
    try {
      await Future.wait([
        for(MapEntry<String, String> entry in data.entries)
          (await _file(entry.key)).writeAsString(entry.value),
      ]);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> setEntry(String key, String value) async {
    try {
      (await _file(key)).writeAsString(value);
      return true;
    } catch (e) {
      return false;
    }
  }
}

class ByteFolderInterface extends _BaseFolderInterface<Uint8List>{


  ByteFolderInterface(String folderPath) : super(folderPath);


  @override
  Future<String> addEntry(Uint8List value) async {
    final String name = DateTime.now().toIso8601String();
    await (await _file(name)).writeAsBytes(value);
    return name;
  }

  @override
  Future<Uint8List> getEntry(String key) async {
    return (await _file(key)).readAsBytes();
  }
  
  @override
  Future<void> requestData({bool recursive = false, bool followLinks = false}) async {
    Directory dir = await _directory;
    await for(FileSystemEntity file in dir.list(recursive: recursive,followLinks: followLinks)){
      if(file is File){
        try {
          final Uint8List val = await file.readAsBytes();
          final String fileName = file.path.split("/").last;
          onEntryRecieved(fileName, val);
        } catch (e) {
        }
      }
    }
  }

  @override
  Future<bool> sendData(Map<String, Uint8List> data) async {
    try {
      await Future.wait([
        for(MapEntry<String, Uint8List> entry in data.entries)
          (await _file(entry.key)).writeAsBytes(entry.value),
      ]);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> setEntry(String key, Uint8List value) async {
    try {
      (await _file(key)).writeAsBytes(value);
      return true;
    } catch (e) {
      return false;
    }
  }
}


