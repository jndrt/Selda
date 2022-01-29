import 'dart:async';
import 'dart:io';

import 'package:faker/faker.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/auth_io.dart';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:selda/win/secure_storage.dart';
import 'package:url_launcher/url_launcher.dart';


const clientId = '624219046831-jrlnjmihibnqko4gj3ddbd1mvg8lmgft.apps.googleusercontent.com';
const clientSecret = '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';
const scopes = [drive.DriveApi.driveReadonlyScope, drive.DriveApi.driveScope];

class GoogleDrive {
  final _storage = SecureStorage();

  String _imgPath = '';

  ///provides Credentials for Goolge login
  Future<http.Client> getHttpClient() async {
    var credentials = await _storage.getCredentials();

    ///login to Google
    if (credentials == null) {
      var authClient = await clientViaUserConsent(
          ClientId(clientId, clientSecret), scopes, (url) {
        launch(url);
      });

      await _storage.saveCredentials(authClient.credentials.accessToken, authClient.credentials.refreshToken);

      return authClient;
    }

    ///fetches credentials from storage
    return authenticatedClient(http.Client(), AccessCredentials(
        AccessToken(credentials['type'], credentials['data'], DateTime.parse(credentials['expiry'])),
        credentials['refreshToken'],
        scopes));
  }

  ///refresh if AccessToken has expired
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

  ///returns path to local image
  Future<String> receive() async {
    var client = await getHttpClient();
    var driveApi = drive.DriveApi(client);

    String lastEntryDriveId = '';

    ///tries to log into Google
    try {
      ///fetches App folder on Goolge Drive
      await driveApi.files.list(q: "name = 'SeldaUploads'").then((folder) async {

        ///user hasn't uploaded anything yet
        if (folder.files!.isEmpty) {
          _imgPath = 'noFolder';
        }

        else {

          ///fetches image inside folder
          await driveApi.files.list(q: "'${folder.files!.first.id}' in parents").then((file) {

            ///no new image found
            if (file.files!.isEmpty) {

              _imgPath = 'noImage';

            }

            ///fetches image id
            else {

              lastEntryDriveId = file.files!.first.id!;

            }
          });
        }
      });
    }
    ///AccessToken expired -> refresh
    catch (e){

      getNewCredentials();
      receive();

    }

    ///download and save image from Google Drive
    if (lastEntryDriveId != ''){

      final dir = await getDownloadsDirectory();

      //final dateTime = DateTime.now().toString();

      ///formats dateTime to make it suitable for saving
      //final lastIndex = dateTime.indexOf('.');
      //final essentials = dateTime.substring(0, lastIndex).replaceAll(':', '-');

      var faker = Faker();

      final essentials = faker.person;

      ///sets saving path
      _imgPath = dir!.path + "\\${essentials.firstName()} ${essentials.lastName()}.jpg";

      ///downloads image
      drive.Media img = (await driveApi.files.get(lastEntryDriveId, downloadOptions: drive.DownloadOptions.fullMedia)) as drive.Media;

      ///sets empty file and dataStore for download
      final saveFile = File('$_imgPath');
      List<int> dataStore = [];

      await img.stream.listen((data) {

        ///writes data fetched from download in dataStore
        dataStore.insertAll(dataStore.length, data);

      }, onDone: await () async {

        ///writes data to file
        print('Task done!');
        await saveFile.writeAsBytes(dataStore);
        print('Saved at $_imgPath');

      });

      ///deletes image on Google Drive to avoid clutter
      await driveApi.files.delete(lastEntryDriveId);
    }

    await Future.delayed(Duration(milliseconds: 1000));

    return _imgPath;
  }
}