import 'package:flutter/material.dart';

class DashboardList extends StatefulWidget {
  final String activeMenu;
  const DashboardList({required this.activeMenu, super.key});

  @override
  State<DashboardList> createState() => _DashboardListState();
}

class _DashboardListState extends State<DashboardList> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _rowContent(),
          ),
        ),
      ),
    );
  }

  List<Widget> _rowContent() {
    String text1 = '';
    String text2 = '';
    String text3 = '';
    String text4 = '';
    String text5 = '';

    switch (widget.activeMenu) {
      case 'myBids':
        text1 = 'Seu lance: ';
        text2 = 'R\$ 160,00';
        text3 = 'Tempo Restante: ';
        text4 = '00h 00m 00s';
        text5 = 'Ver Leilão';
        break;
      case 'myAuctions':
        text1 = 'Lance Atual: ';
        text2 = 'R\$ 160,00';
        text3 = 'Status: ';
        text4 = 'Ativo';
        text5 = 'Gerenciar';
        break;
      case 'closedAuctions':
        text1 = 'Seu lance final: ';
        text2 = 'R\$ 160,00';
        text3 = 'Status: ';
        text4 = 'Você Venceu!';
        text5 = 'Detalhes do Leilão';
        break;
      default:
        text1 = '';
        text2 = '';
        text3 = '';
        text4 = '';
        text5 = '';
        break;
    }

    return [
      Column(
        children: [
          Text('NOME'),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(text: text1),
                TextSpan(text: text2),
              ],
            ),
          ),
        ],
      ),
      RichText(
        text: TextSpan(
          children: [
            TextSpan(text: text3),
            TextSpan(text: text4),
          ],
        ),
      ),
      ElevatedButton(onPressed: () {}, child: Text(text5)),
    ];
  }
}
