// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:lance_certo/widgets/dashboard_list.dart';
import 'package:lance_certo/widgets/main_menu.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String activeMenu = 'myBids';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MainMenu(currentRoute: '/dashboard'),
            Text('Meu Dashboard'),
            Row(
              children: [
                TextButton(
                  onPressed: () => setState(() {
                    activeMenu = 'myBids';
                  }),
                  child: Text('Meus Lances'),
                ),
                TextButton(
                  onPressed: () => setState(() {
                    activeMenu = 'myAuctions';
                  }),
                  child: Text('Meus Leilões (Vendedor)'),
                ),
                TextButton(
                  onPressed: () => setState(() {
                    activeMenu = 'closedAuctions';
                  }),
                  child: Text('Leilões Encerrados'),
                ),
              ],
            ),
            Expanded(
              child: Column(
                children: [
                  Text(_getMenuTitle()),
                  Expanded(
                    child: ListView.builder(
                      itemCount: 2,
                      itemBuilder: (context, index) =>
                          DashboardList(activeMenu: activeMenu),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getMenuTitle() {
    switch (activeMenu) {
      case 'myBids':
        return 'Meus Lances Ativos';
      case 'myAuctions':
        return 'Meus Leilões Criados';
      case 'closedAuctions':
        return 'Leilões Encerrados';
      default:
        return '';
    }
  }
}
