import 'dart:async';
import 'dart:io';

import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/auth_io.dart';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:selda/windows/secure_storage.dart';
import 'package:url_launcher/url_launcher.dart';


const clientId = '624219046831-jrlnjmihibnqko4gj3ddbd1mvg8lmgft.apps.googleusercontent.com';
const clientSecret = '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';
const scopes = [drive.DriveApi.driveReadonlyScope, drive.DriveApi.driveScope];

class GoogleDrive {
  final _storage = SecureStorage();
  String _imgPath = '';
  String driveImgId = "";

  Future<http.Client> getHttpClient() async {
    var credentials = await _storage.getCredentials();

    if (credentials == null) {
      var authClient = await clientViaUserConsent(
          ClientId(clientId, clientSecret), scopes, (url) {
        launch(url);
      });

      await _storage.saveCredentials(authClient.credentials.accessToken, authClient.credentials.refreshToken);

      return authClient;
    }

    return authenticatedClient(http.Client(), AccessCredentials(
        AccessToken(credentials['type'], credentials['data'], DateTime.parse(credentials['expiry'])),
        credentials['refreshToken'],
        scopes));
  }

  Future<http.Client> getNewCredentials() async {
    var credentials = await _storage.getCredentials();

    var newCredentials = await refreshCredentials(
      ClientId(clientId, clientSecret),
      AccessCredentials(
        AccessToken(
            credentials!['type'],
            credentials['data'],
            DateTime.parse(credentials['expiry'])
        ),
        credentials['refreshToken'],
        scopes
      ),
      http.Client()
    );

    _storage.saveCredentials(newCredentials.accessToken, newCredentials.refreshToken);

    return authenticatedClient(http.Client(), newCredentials);
  }

  Future<String> receive() async {
    var client = await getHttpClient();
    var driveApi = drive.DriveApi(client);

    late String lastEntryDriveId;

    try {
      await driveApi.files.list(q: "name = 'SeldaUploads'").then((folder) async {

        await driveApi.files.list(q: "'${folder.files!.first.id}' in parents")

            .then((file) {
              print(file.files!.isEmpty);

              if (file.files!.isEmpty) {
                _imgPath = 'null';

                print(_imgPath);
              }

              else {
                print(file.files!.first.id);

                lastEntryDriveId = file.files!.first.id!;
              }
        });

      });
    } catch (e){

      getNewCredentials();

    }


    if (_imgPath == ''){

      driveImgId = lastEntryDriveId;

      final dir = await getDownloadsDirectory();
      _imgPath = dir!.path + "\\$lastEntryDriveId";

      drive.Media img = (await driveApi.files.get(lastEntryDriveId, downloadOptions: drive.DownloadOptions.fullMedia)) as drive.Media;

      final saveFile = File('$_imgPath');
      List<int> dataStore = [];

      await img.stream.listen((data) {

        dataStore.insertAll(dataStore.length, data);

      }, onDone: await () async {

        print('Task done!');
        await saveFile.writeAsBytes(dataStore);
        print('Saved at $_imgPath');

      });

      await driveApi.files.delete(driveImgId);
    }

    await Future.delayed(Duration(seconds: 3));

    return _imgPath;
  }
}