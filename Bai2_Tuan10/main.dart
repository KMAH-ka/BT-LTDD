import 'package:flutter/material.dart';
import 'router_finder_screen.dart';

void main() {
  runApp(RouteFinderApp());
}

class RouteFinderApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Route Finder', home: RouteFinderScreen());
  }
}