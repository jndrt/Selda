import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:googleapis_auth/auth_io.dart';

class PathStorage {
  final storage = FlutterSecureStorage();

  Future savePath(String path) async {
    await storage.write(key: 'path', value: path);
  }

  Future<Map<String, dynamic>?> getPath () async {
    var res = await storage.readAll();

    if (res.isEmpty) return null;
    return res;
  }

  Future clear() {
    return storage.deleteAll();
  }
}