import 'dart:io';

import 'package:bulleted_list/bulleted_list.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'img_screen.dart';
import 'package:edge_detection/edge_detection.dart';

import 'package:googleapis/drive/v3.dart' as drive;
import 'package:google_sign_in/google_sign_in.dart' as signInService;


class AndMain extends StatefulWidget {
  AndMain({Key? key, required this.title, required this.init}) : super(key: key);

  final bool init;
  final String title;

  @override
  _AndMainState createState() => _AndMainState();
}

class _AndMainState extends State<AndMain> {
  late String? _imgPath;
  late signInService.GoogleSignInAccount _account;



  @override
  void initState() {

    if(widget.init) signIn();

    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [openGallery()],

          title: Text(widget.title),
        ),

        ///Welcome screen with tutorial
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Wie es funktioniert:',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.black
                ),
              ),
              BulletedList(
                listItems: [
                  RichText(
                    text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Drücke ',
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.black
                            ),
                          ),
                          WidgetSpan(child: Icon(Icons.camera, size: 20)),
                          TextSpan(
                              text: ' um ein Bild von deiner Arbeit zu machen',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              )
                          ),
                        ]
                    ),
                  ),
                  Text(
                    'Richte die Kamera so aus, dass die Kanten des Blattes erkannt werden',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    'Passe die Kanten an',
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.black
                    ),
                  ),
                  RichText(

                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Drücke ',
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.black
                            ),
                          ),
                          WidgetSpan(child: Icon(Icons.crop)),
                          TextSpan(
                            text: ' oben ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black
                            )
                          ),
                          TextSpan(
                              text: ' rechts um dein Bild zuzuschneiden',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              )
                          ),
                        ]

                      )
                  ),
                  Text(
                    'Lade dein Bild zu Google Drive hoch',
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.black
                    ),
                  ),
                ],
              ),
              RichText(
                text : TextSpan(
                  children: [
                    TextSpan(
                      text: '\nDamit die Kantenerkennung möglichst gut funktioniert, wird empfohlen, einen möglichst dunklen Hintergrund zu benutzen.'
                          '\n'
                          '\nEs wird jeweils nur ein Bild auf Google Drive gespeichert, um ein Bild erneut zu senden drücke ',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    WidgetSpan(child: Icon(Icons.photo)),
                  ]
                ),
                textAlign: TextAlign.center,
              )
            ],
          ),
        ),

        ///button to take picture
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
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
          ]
    );

    _account = (await googleSignIn.signIn())!;
  }


  Future<void> _openCamera() async {

    ///opens camera with edgeDetection plugin
    String? edgeImg = await EdgeDetection.detectEdge;

    ///refreshes page with path to image
    setState(() {
      _imgPath = edgeImg;
    });

    ///forwards user to image screen
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

  Widget openGallery() {
    return IconButton(
        onPressed: () async {
          var file = await ImagePicker().pickImage(source: ImageSource.gallery);

          _imgPath = file!.path;

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
        },
        icon: Icon(Icons.photo));
  }
}
