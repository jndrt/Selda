import 'dart:io';

import 'package:flutter/material.dart';

import 'ImgScreen.dart';
import 'package:edge_detection/edge_detection.dart';

import 'package:googleapis/drive/v3.dart' as drive;
import 'package:google_sign_in/google_sign_in.dart' as signInService;


class AndMain extends StatefulWidget {
  AndMain({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _AndMainState createState() => _AndMainState();
}

class _AndMainState extends State<AndMain> {
  late String? _imgPath;
  late signInService.GoogleSignInAccount _account;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(

          title: Text(widget.title),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RichText(
                text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Press ',
                        style: TextStyle(
                            fontSize: 24,
                            color: Colors.black
                        ),
                      ),
                      WidgetSpan(child: Icon(Icons.camera, size: 24)),
                      TextSpan(
                          text: ' to take a picture of your work',
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.black,
                          )
                      ),
                      TextSpan(
                        text: '\nFor the Edge Detection to work best, use a dark background',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.red,
                          fontWeight: FontWeight.bold
                        )
                      )
                    ]
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await signIn();
            await _openCamera();
          },
          tooltip: 'Take Picture',
          child: Icon(Icons.camera),
        )
    );
  }

  Future<void> signIn() async {
    final googleSignIn = signInService.GoogleSignIn.standard(
        scopes: [
          drive.DriveApi.driveScope,
          drive.DriveApi.driveReadonlyScope]
    );
    _account = (await googleSignIn.signIn())!;

    print(_account);
  }

  Future<void> _openCamera() async {

    String? edgeImg = await EdgeDetection.detectEdge;

    setState(() {
      _imgPath = edgeImg;
    });

    if (_imgPath != null) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                 ImgScreen(
                    args: [
                      File(_imgPath!),
                      _account
                    ],
                  )
          )
      );
    }
  }
}
