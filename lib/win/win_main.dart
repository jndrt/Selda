import 'package:bulleted_list/bulleted_list.dart';
import 'package:flutter/material.dart';
import 'package:selda/win/img_screen_win.dart';


class WinMain extends StatefulWidget {
  WinMain({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _WinMainState createState() => _WinMainState();
}

class _WinMainState extends State<WinMain> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(

          title: Text(widget.title),
        ),
        body:

        ///Shows Welcome Page with short tutorial
        Center(
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
              Container(
                alignment: Alignment.center,
                margin: EdgeInsets.only(left: 400),
                child:
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
                              WidgetSpan(child: Icon(Icons.image_outlined, size: 20)),
                              TextSpan(
                                  text: ' um das zuletzt hochgeladene Bild anzuzeigen',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                  )
                              ),
                            ]
                        ),
                      ),
                      Text(
                        'Klicke auf das Bild um es im File Explorer zu öffnen',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.black
                        ),
                      ),
                      Text(
                        'Der Dateiname wird in der Mitte des Bildes angezeigt',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.black
                        ),
                      ),
                      Text(
                        'Ziehe dein Bild vom File Explorer zu Moodle',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.black
                        ),
                      ),
                    ],
                    crossAxisAlignment: CrossAxisAlignment.center,
                  ),
              ),
              RichText(
                text : TextSpan(
                  text: '\nUm Google Drive freizuhalten, wird das Bild nach dem Download gelöscht',
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.red,
                      fontWeight: FontWeight.bold
                  ),
                ),
                textAlign: TextAlign.center,
              )
            ],
          ),
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
   * refreshes page
   * gets called by button
   */
  void refresh(){
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                ImgScreenWin()
        )
    );
  }
}
