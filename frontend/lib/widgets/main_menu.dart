import 'package:flutter/material.dart';
import 'package:lance_certo/screens/dashboard_screen.dart';
import 'package:lance_certo/screens/home_screen.dart';

class MainMenu extends StatelessWidget {
  const MainMenu({required this.currentRoute, super.key});

  final String currentRoute;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                );
              },
              child: Text('Início', style: style('/home')),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => DashboardScreen()),
                );
              },
              child: Text('Produtos', style: style('/dashboard')),
            ),
          ],
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  TextStyle style(String route) {
    return TextStyle(
      color: currentRoute == route
          ? const Color(0xFF551A8B)
          : const Color(0xFF0000EE),
      fontWeight: currentRoute == route ? FontWeight.bold : FontWeight.normal,
    );
  }
}
