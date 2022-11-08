import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:unsplash_flutter/views/pictures_page.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: PicturesPage(),
        ),
      ),
    );
  }
}