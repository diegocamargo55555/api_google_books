import 'package:flutter/material.dart';
import 'package:livros_api_google/view/search_page.dart';

void main() {
  runApp(
    MaterialApp(
      home: SearchPage(),
      theme: ThemeData(hintColor: Colors.white),
      debugShowCheckedModeBanner: false,
    ),
  );
}
