import 'package:flutter/material.dart';
import 'package:lance_certo/screens/dashboard_screen.dart';
import 'package:lance_certo/screens/home_screen.dart';

class MainMenuWidget extends StatelessWidget {
  const MainMenuWidget({required this.currentRoute, super.key});

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
              child: Text('Início', style: _style('/home')),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const DashboardScreen()),
                );
              },
              child: Text('Minha Área', style: _style('/dashboard')),
            ),
          ],
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  TextStyle _style(String route) {
    return TextStyle(
      color: currentRoute == route
          ? const Color(0xFF2563EB)
          : const Color(0xFF4B5563),
      fontWeight: currentRoute == route ? FontWeight.bold : FontWeight.normal,
      fontSize: 16.0,
    );
  }
}
