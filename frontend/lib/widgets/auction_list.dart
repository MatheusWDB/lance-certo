import 'package:flutter/material.dart';

class AuctionList extends StatefulWidget {
  const AuctionList({super.key});

  @override
  State<AuctionList> createState() => _AuctionListState();
}

class _AuctionListState extends State<AuctionList> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('IMAGEM'),
            Text('NOME'),
            Text('DESCRIÇÃO'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(children: [Text('Lance Atual:'), Text('PREÇO')]),
                Column(children: [Text('Tempo Restante:'), Text('TEMPO')]),
              ],
            ),
            TextButton(onPressed: () {}, child: Text('Ver Detalhes')),
          ],
        ),
      ),
    );
  }
}
