import 'package:flutter/material.dart';
import 'package:lance_certo/widgets/auction_list_item.dart';

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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Text('Leilões Ativos'),
                TextField(
                  decoration: InputDecoration(label: Text('Buscar leilões...')),
                ),
                TextButton(onPressed: () {}, child: Text('+ Novo Leilão')),
              ],
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(64.0),
                child: Column(
                  children: [
                    ListView.builder(
                      itemCount: 1,
                      itemBuilder: (context, index) => AuctionListItem(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
