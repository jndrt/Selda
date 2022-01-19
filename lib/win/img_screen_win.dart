import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:selda/win/path_storage.dart';
import 'package:url_launcher/url_launcher.dart';

import 'google_drive_win.dart';


class ImgScreenWin extends StatefulWidget {
  @override
  _ImgScreenWinState createState() => _ImgScreenWinState();
}

class _ImgScreenWinState extends State<ImgScreenWin> {
  final pathStorage = PathStorage();

  String imgPath = '';
  GoogleDrive googleDrive = GoogleDrive();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        title: Text('Dein Bild'),
      ),
      body: FutureBuilder(
          future: getImg(),
          builder: (BuildContext context, AsyncSnapshot<String> snap) {
            print(snap.data);

            ///Image is fetched from Goolge Drive
            if (snap.hasData &&
                (snap.data != 'noFolder' &&
                snap.data != 'noImage' &&
                snap.connectionState == ConnectionState.done ||
                snap.data == 'noFolder' &&
                imgPath != '')) {

              if (snap.data != 'noFolder') {
                imgPath = snap.data!;
                pathStorage.savePath(imgPath);
              }

              final name = imgPath.substring(imgPath.length - 23, imgPath.length - 4);
              print('${snap.data} loaded');

              return Stack(
                  children : [
                    ///image
                    Tooltip(
                      message: 'Öffne im File Explorer',
                      child: GestureDetector(
                        onTap: _openInFileExplorer,
                        child: SizedBox(
                          height: MediaQuery
                              .of(context)
                              .size
                              .height,
                          width: MediaQuery
                              .of(context)
                              .size
                              .width,
                          child: Image.file(File(imgPath)),
                        ),
                      ),
                    ),

                    ///image name
                    Center(
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(width: 2, color: Colors.transparent),
                              borderRadius: BorderRadius.all(Radius.elliptical(100, 50)),
                              color: Colors.black.withOpacity(0.7)
                          ),
                          child: Text(name,
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.white
                            ),
                          ),
                        )
                    )
                  ]
              );
            }

            /**
             * no new upload on Goolge Drive
             * image is fetched from Downloads folder
             */
            else if (snap.hasData &&
                snap.connectionState == ConnectionState.done &&
                snap.data == 'noImage'){

              print(snap.data);

              final name = imgPath.substring(imgPath.length - 23, imgPath.length - 4);

              return Stack(
                  children : [

                    ///image
                    Tooltip(
                      message: 'Öffne im File Explorer',
                      child: GestureDetector(
                        onTap: _openInFileExplorer,
                        child: SizedBox(
                          height: MediaQuery
                              .of(context)
                              .size
                              .height,
                          width: MediaQuery
                              .of(context)
                              .size
                              .width,
                          child: Image.file(File(imgPath)),
                        ),
                      ),
                    ),

                    ///image name
                    Center(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(width: 2, color: Colors.transparent),
                            borderRadius: BorderRadius.all(Radius.elliptical(100, 50)),
                            color: Colors.black.withOpacity(0.7),
                          ),
                          child: Text(name,
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.white
                            ),
                          ),
                        )
                    )
                  ]
              );
            }

            ///user hasn't uploaded anything yet
            else if (snap.hasData &&
                snap.connectionState == ConnectionState.done &&
                snap.data == 'noFolder' &&
                imgPath == ''){
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text('Kein Bild gefunden',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.black,
                      ),
                    ),

                  ],
                ),
              );
            }

            ///loading screen
            else {

              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text('Suche nach Bildern...',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.black,
                      ),
                    ),

                  ],
                ),
              );
            }
          }
      ),

      ///button to check Google Drive
      floatingActionButton: FloatingActionButton(
        onPressed: refresh,
        tooltip: 'Letztes Bild anzeigen',
        child: const Icon(Icons.image_outlined),
      ),
    );
  }

  /**
   * if no new image is available on Google Drive
   * this loads path to last downloaded image
   */
  Future<void> setImagePath() async {
    await pathStorage.getPath().then((path) {
      imgPath = path!['path'];
    });
  }

  /**
   * refreshes page
   * gets called by button
   */
  void refresh(){
    setState(() {
      

    });
  }

  /**
   * provides local path to image
   * gets called by FutureBuilder
   */
  Future<String> getImg() async {
    await setImagePath();

    print(imgPath);

    return await googleDrive.receive();
  }

  _openInFileExplorer() async {
    final dir = await getDownloadsDirectory();

    launch(dir!.path);
  }
}
