// ignore_for_file: await_only_futures

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:online_food_delivery/views/product_Screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.yellow,
      ),
      home: const ProductScreen(),
    );
  }
}
