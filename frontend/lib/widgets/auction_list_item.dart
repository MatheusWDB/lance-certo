import 'package:flutter/material.dart';

class AuctionListItem extends StatefulWidget {
  const AuctionListItem({super.key});

  @override
  State<AuctionListItem> createState() => _AuctionListItemState();
}

class _AuctionListItemState extends State<AuctionListItem> {
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
