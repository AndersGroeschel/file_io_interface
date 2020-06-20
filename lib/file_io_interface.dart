import 'dart:io';
import 'dart:typed_data';
import 'package:abstract_io/abstract_io.dart';
import 'package:path_provider/path_provider.dart';

/// the base interface for using files for saving with local files
abstract class _BaseFileInterface<T> extends IOInterface<T> {
  /// the file path of the file there is no need to get the local app directory
  /// that is done automatically
  final String filePath;

  _BaseFileInterface(this.filePath);

  /// returns the file associated with the [filePath]
  Future<File> get _file async {
    return File('${(await getApplicationDocumentsDirectory()).path}/$filePath');
  }

  @override
  Future<bool> deleteData() async {
    try {
      (await _file).delete();
      return true;
    } catch (e) {
      print("delete error for $filePath: \n$e");
      return false;
    }
  }
}

/// an [IOInterface] for saving a value to a file as a string
class StringFileInterface extends _BaseFileInterface<String> {
  StringFileInterface(String filePath) : super(filePath);

  @override
  Future<void> requestData() async {
    File file = await _file;
    String data = await file.readAsString();
    onDataRecieved(data);
  }

  @override
  Future<bool> sendData(String data) async {
    File file = await _file;
    try {
      await file.writeAsString(data);
      return true;
    } catch (e) {
      print("error saving to file $filePath\n$e");
    }
    return false;
  }
}

/// an [IOInterface] for saving a value to a file as a list of bytes
class ByteFileInterface extends _BaseFileInterface<Uint8List> {
  ByteFileInterface(String filePath) : super(filePath);

  @override
  Future<void> requestData() async {
    File file = await _file;
    Uint8List data = await file.readAsBytes();
    onDataRecieved(data);
  }

  @override
  Future<bool> sendData(Uint8List data) async {
    File file = await _file;
    try {
      file.writeAsBytes(data);
      return true;
    } catch (e) {
      print("error saving to file $filePath\n$e");
    }
    return false;
  }
}
