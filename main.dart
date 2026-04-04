import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'provider/sinhvien_provider.dart';
import 'view/v_sinhvien.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => SinhVienProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quản lý Sinh Viên',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const SinhVienListScreen(),
    );
  }
}