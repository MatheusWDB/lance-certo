import 'package:flutter/material.dart';

class NewAuctionDialog extends StatefulWidget {
  const NewAuctionDialog({super.key});

  @override
  State<NewAuctionDialog> createState() => _NewAuctionDialogState();
}

class _NewAuctionDialogState extends State<NewAuctionDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Cadastrar Novo Leilão'),
      scrollable: true,
      actions: [
        TextButton(onPressed: () {}, child: Text('Cancelar')),
        TextButton(onPressed: () {}, child: Text('Criar')),
      ],
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Título do Produto:'),
          TextField(
            decoration: InputDecoration(
              label: Text('Ex: Câmera Fotográfica Vintage'),
            ),
          ),
          Text('Descrição:'),
          TextField(
            decoration: InputDecoration(
              label: Text(
                'Descreva o item, incluindo detalhes, condição, etc.',
              ),
            ),
          ),
          Text('Preço Inicial (R\$):'),
          TextField(decoration: InputDecoration(label: Text('Ex: 100,00'))),
          Text('incremento Mínimo (R\$):'),
          TextField(decoration: InputDecoration(label: Text('Ex: 100,00'))),
          Row(
            spacing: 16,
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text('Data de Início:'),
                    TextField(
                      decoration: InputDecoration(label: Text('dd/mm/aaaa')),
                      keyboardType: TextInputType.datetime,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text('Hora de Início:'),
                    TextField(
                      decoration: InputDecoration(label: Text('dd/mm/aaaa')),
                      keyboardType: TextInputType.datetime,
                    ),
                  ],
                ),
              ),
            ],
          ),
          Row(
            spacing: 16,
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text('Data de Término:'),
                    TextField(
                      decoration: InputDecoration(label: Text('dd/mm/aaaa')),
                      keyboardType: TextInputType.datetime,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text('Hora de Término:'),
                    TextField(
                      decoration: InputDecoration(label: Text('dd/mm/aaaa')),
                      keyboardType: TextInputType.datetime,
                    ),
                  ],
                ),
              ),
            ],
          ),
          Text('Imagem do Produto:'),
          TextField(),
          TextButton(onPressed: () {}, child: Text('Cadastrar Leilão')),
        ],
      ),
    );
  }
}
