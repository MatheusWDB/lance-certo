// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:lance_certo/widgets/dashboard_list.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  String activeMenu = 'myBids';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
