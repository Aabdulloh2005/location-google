import 'package:flutter/material.dart';
import 'package:lesson72/views/screens/google_map_screen.dart';

void main(List<String> args) async {
  runApp(const MainRunner());
}

class MainRunner extends StatelessWidget {
  const MainRunner({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: GoogleMapScreen(),
    );
  }
}
