import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:selda/windows/win_main.dart';

import 'and/and_main.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Selda',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        textTheme: GoogleFonts.fahkwangTextTheme(),
      ),
      home: Platform.isWindows ? WinMain(title: 'Selda')
          : AndMain(title: 'Selda')
    );
  }
}
