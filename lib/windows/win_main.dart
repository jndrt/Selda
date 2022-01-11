import 'dart:async';
import 'dart:io';

import 'package:clipboard/clipboard.dart';

import 'package:flutter/material.dart';
import 'package:selda/windows/path_storage.dart';

import 'google_drive_win.dart';


class WinMain extends StatefulWidget {
  WinMain({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _WinMainState createState() => _WinMainState();
}

class _WinMainState extends State<WinMain> {
  String imgPath = '';
  GoogleDrive googleDrive = GoogleDrive();
  bool initStateActive = true;
  final pathStorage = PathStorage();


  @override
  void initState() {
    setImagePath();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(

          title: Text(widget.title),
        ),
        body: initStateActive ?
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RichText(
                text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Press ',
                        style: TextStyle(
                            fontSize: 30,
                            color: Colors.black
                        ),
                      ),
                      WidgetSpan(child: Icon(Icons.image_outlined, size: 30)),
                      TextSpan(
                          text: ' to show the last image you uploaded to Drive',
                          style: TextStyle(
                            fontSize: 30,
                            color: Colors.black,
                          )
                      ),
                      TextSpan(
                        text: '\nTo avoid clutter your image will be deleted from Drive, but will still be available on your mobile phone and PC'
                            '\nYour images will be saved in your Download folder',
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.red
                        )
                      )
                    ]
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        )
        : FutureBuilder(
          future: getImg(),
          builder: (BuildContext context, AsyncSnapshot<String> snap) {
            if (snap.hasData && snap.connectionState == ConnectionState.done && snap.data != 'null') {
              imgPath = snap.data!;
              pathStorage.savePath(imgPath);
              print('${snap.data} loaded');

              return Tooltip(
                message: 'Click here to copy path',
                child: GestureDetector(
                  onTap: _copyToClipboard,
                  child: SizedBox(
                    height: MediaQuery
                        .of(context)
                        .size
                        .height,
                    width: MediaQuery
                        .of(context)
                        .size
                        .width,
                    child: Image.file(File(snap.data!)),
                  ),
                ),
              );
            }
            else if (snap.hasData && snap.connectionState == ConnectionState.done && snap.data == 'null'){
              return Tooltip(
                message: 'Click here to copy path',
                child: GestureDetector(
                  onTap: _copyToClipboard,
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
              );
            }
            else {
              print('No data here');

              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text('Checking for images...',
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
        floatingActionButton: FloatingActionButton(
          onPressed: refresh,
          tooltip: 'Check for images',
          child: const Icon(Icons.image_outlined),
        ),
    );
  }

  Future<void> setImagePath() async {
    await pathStorage.getPath().then((path) {
      imgPath = path!['path'];
    });
  }

  void refresh(){
    setState(() {

      initStateActive = false;

    });
  }

  Future<String> getImg() async {

   return await googleDrive.receive();
  }

  _copyToClipboard() {

    if (!imgPath.isEmpty) {

      FlutterClipboard.copy(imgPath);

    }
  }
}
