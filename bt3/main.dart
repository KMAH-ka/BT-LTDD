import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'provider/sanpham_provider.dart';
import 'view/v_sanpham.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => SanPhamProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quản lý Sản Phẩm',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const SanPhamListScreen(),
    );
  }
}