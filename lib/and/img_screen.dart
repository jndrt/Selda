import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

import 'package:googleapis/drive/v3.dart' as drive;

import 'google_auth_client.dart';


class ImgScreen extends StatefulWidget {
  final List args;
  final bool instantSend;

  ImgScreen({required this.args, required this.instantSend});

  @override
  State<StatefulWidget> createState() => _ImgScreenState();
}

class _ImgScreenState extends State<ImgScreen> {
  late File _image;
  late GoogleSignInAccount _account;


  @override
  void initState(){
    super.initState();

    _image = widget.args[0];
    _account = widget.args[1];

    if (widget.instantSend) {
      _upload();
    }
  }
  
  Future<void> _compress() async {
    ///builds output path for image compressor
    final lastIndex = _image.path.lastIndexOf(new RegExp(r'.jp'));
    final splitted = _image.path.substring(0, lastIndex);
    final outPath = "${splitted}_out${_image.path.substring(lastIndex)}";

    ///image compress
    _image = (await FlutterImageCompress.compressAndGetFile(_image.path.toString(), outPath, quality: 100))!;

  }

  _save() async {
    Uint8List bytes = _image.readAsBytesSync();

    await ImageGallerySaver.saveImage(bytes);
  }

  Future<void> _upload() async {
    await _compress();
    await _save();

    final authHeaders = await _account.authHeaders;
    final authenticateClient = GoogleAuthClient(authHeaders);
    final driveApi = drive.DriveApi(authenticateClient);
    late String folderId;


    ///tries to find App folder in Google Drive
    try {
      await driveApi.files.list(q: "name = 'SeldaUploads'").then((folder) async {

        folderId = folder.files!.first.id!;

        ///deletes previously sent images
        await driveApi.files.list(q: "'$folderId' in parents").then((files) async {

          if (files.files!.isNotEmpty){

            files.files!.forEach((element) async {

              await driveApi.files.delete(element.id!);

            });
          }
        });
      });
    }
    ///creates App folder
    catch (e) {

      await driveApi.files.create(
          drive.File(
              name: 'SeldaUploads',
              mimeType: 'application/vnd.google-apps.folder'
          )
      ).then((folder) => folderId = folder.id!);

    }


    ///creates new upload file + content
    var media = new drive.Media(_image.openRead(), _image.lengthSync());
    var driveFile = new drive.File();

    ///names upload file and specifies parent folder

    final dateTime = DateTime.now().toString();

    ///formats dateTime to make it suitable for saving
    final lastIndex = dateTime.indexOf('.');
    final essentials = dateTime.substring(0, lastIndex).replaceAll(':', '-');

    driveFile.name = essentials;
    driveFile.parents = [folderId ];

    ///uploads file
    final result = await driveApi.files.create(driveFile, uploadMedia: media);
    print("Upload result: $result");

    ///returns to welcome screen
    Navigator.popUntil(context, (Route<dynamic> predicate) => predicate.isFirst);

    showMessage("200", "Bild wurde erfolgreich gespeichert und hochgeladen");
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
        title: Text('Dein Bild'),
      ),
      body: widget.instantSend ?
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Dein Bild wird hochgeladen...',
           style: TextStyle(
             fontSize: 24,
              color: Colors.black,
            ),
          ),
        ])
      )
      : SizedBox(
        height: MediaQuery
            .of(context)
            .size
            .height,
        width: MediaQuery
            .of(context)
            .size
            .width,
        child: Image.file(File(_image.path)),
      ),

      floatingActionButton: getActionButton(),
    );
  }

  Widget getActionButton() {
    if (widget.instantSend){
      return Container();
    } else {
      return FloatingActionButton(
        onPressed: _upload,
        tooltip: 'Letztes Bild anzeigen',
        child: const Icon(Icons.upload),
      );
    }
  }
}