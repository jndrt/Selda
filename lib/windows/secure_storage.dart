import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:googleapis_auth/auth_io.dart';

class SecureStorage {
  final storage = FlutterSecureStorage();
  
  Future saveCredentials(AccessToken token, String? refreshtoken) async {
    await storage.write(key: 'type', value: token.type);
    await storage.write(key: 'data', value: token.data);
    await storage.write(key: 'expiry', value: token.expiry.toIso8601String());
    await storage.write(key: 'refreshToken', value: refreshtoken);

  }

  Future<Map<String, dynamic>?> getCredentials () async {
    var res = await storage.readAll();

    if (res.isEmpty) return null;
    return res;
  }

  Future clear() {
    return storage.deleteAll();
  }
}