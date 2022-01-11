import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

import 'package:googleapis/drive/v3.dart' as drive;
import 'package:selda/and/and_main.dart';

import 'GoogleAuthClient.dart';


class ImgScreen extends StatefulWidget {
  final List args;

  ImgScreen({required this.args});

  @override
  State<StatefulWidget> createState() => _ImgScreenState();
}

class _ImgScreenState extends State<ImgScreen> {
  late File _image;
  late GoogleSignInAccount _account;

  late bool _loading;
  
  @override
  void initState(){
    super.initState();
    _loading = true;
    _loadImage();

    _account = widget.args[1];
  }
  
  Future<void> _loadImage() async {
    _image = widget.args[0];

    final lastIndex = _image.path.lastIndexOf(new RegExp(r'.jp'));
    final splitted = _image.path.substring(0, lastIndex);
    final outPath = "${splitted}_out${_image.path.substring(lastIndex)}";

    _image = (await FlutterImageCompress.compressAndGetFile(_image.path.toString(), outPath, quality: 50))!;

    Future.delayed(Duration(seconds: 0)).whenComplete(() => setState(() {
      _loading = false;
    }));
  }

  _save() async {
    Uint8List bytes = _image.readAsBytesSync();

    await ImageGallerySaver.saveImage(bytes);
  }

  Future<void> _upload() async {
    final authHeaders = await _account.authHeaders;
    final authenticateClient = GoogleAuthClient(authHeaders);
    final driveApi = drive.DriveApi(authenticateClient);
    late String folderId;


    try {
      await driveApi.files.list(q: "name = 'SeldaUploads'").then((folder) {

        folderId = folder.files!.first.id!;

      });
    } catch (e) {

      await driveApi.files.create(
          drive.File(
              name: 'SeldaUploads',
              mimeType: 'application/vnd.google-apps.folder'
          )
      ).then((folder) => folderId = folder.id!);

    }


    var media = new drive.Media(_image.openRead(), _image.lengthSync());
    var driveFile = new drive.File();

    driveFile.name = DateTime.now().toString();
    driveFile.parents = [folderId ];

    final result = await driveApi.files.create(driveFile, uploadMedia: media);
    print("Upload result: $result");

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                AndMain(title: 'Selda',)
        )
    );

    showMessage("Success", "Image has been saved and uploaded to Goolge Drive");
  }

  showMessage(String title, String message){

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          message,
          style: TextStyle(fontSize: 20),
        )));

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Work'),
      ),
      body: _loading
        ? _loadingScreen(context)
        : SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Image.file(_image),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Upload to Drive',
        onPressed: () async {
          await _save();
          await _upload();
        },
        child: Icon(Icons.upload),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget _loadingScreen(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      color: Colors.white,
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 6,
          backgroundColor: Colors.blue[300],
          valueColor:
          new AlwaysStoppedAnimation<Color>(Colors.blue[900]!),
        ),
      ),
    );
  }
}