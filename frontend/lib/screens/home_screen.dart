import 'package:flutter/material.dart';
import 'package:lance_certo/widgets/auction_list.dart';
import 'package:lance_certo/widgets/main_menu.dart';
import 'package:lance_certo/widgets/new_auction_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            MainMenu(currentRoute: '/home'),
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Row(
                spacing: 64,
                children: [
                  Text('Leilões Ativos'),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        label: Text('Buscar leilões...'),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (context) => NewAuctionDialog(),
                    ),
                    child: Text('+ Novo Leilão'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: 5,
                itemBuilder: (context, index) => AuctionList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
