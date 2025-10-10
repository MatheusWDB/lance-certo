import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lance_certo/models/auction.dart';
import 'package:lance_certo/models/product.dart';
import 'package:lance_certo/services/auction_service.dart';
import 'package:lance_certo/services/product_service.dart';
import 'package:lance_certo/widgets/product_creaction_widget.dart';

class AuctionCreationWidget extends StatefulWidget {
  const AuctionCreationWidget({super.key});

  @override
  State<AuctionCreationWidget> createState() => _AuctionCreationWidgetState();
}

class _AuctionCreationWidgetState extends State<AuctionCreationWidget> {
  late Future<List<Product>> _productsFuture;

  final Map<String, dynamic> _auctionController = {
    'product': null,
    'startTime': TextEditingController(),
    'endTime': TextEditingController(),
    'initialPrice': TextEditingController(),
    'minimunBidIncrement': TextEditingController(),
  };

  final Map<String, dynamic> _dateTimeController = {
    'startDate': TextEditingController(),
    'startTime': TextEditingController(),
    'startYear': TextEditingController(),
    'startMonth': TextEditingController(),
    'startDay': TextEditingController(),
    'startHour': TextEditingController(),
    'startMinute': TextEditingController(),
    'endDate': TextEditingController(),
    'endTime': TextEditingController(),
    'endYear': TextEditingController(),
    'endMonth': TextEditingController(),
    'endDay': TextEditingController(),
    'endHour': TextEditingController(),
    'endMinute': TextEditingController(),
  };

  Future<void> _selectDate(BuildContext context, String startOrEnd) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 366)),
    );

    if (picked != null) {
      _dateTimeController['${startOrEnd}Year'].text = picked.year.toString();
      _dateTimeController['${startOrEnd}Month'].text = picked.month.toString();
      _dateTimeController['${startOrEnd}Day'].text = picked.day.toString();

      _dateTimeController['${startOrEnd}Date'].text = DateFormat(
        'dd/MM/yyyy',
      ).format(picked);
    }
  }

  Future<void> _selectTime(String startOrEnd) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: startOrEnd == 'start'
          ? TimeOfDay.now()
          : TimeOfDay.fromDateTime(DateTime.now().add(const Duration(minutes: 1))),
    );

    if (picked != null) {
      if (!mounted) return;

      _dateTimeController['${startOrEnd}Hour'].text = picked.hour.toString();
      _dateTimeController['${startOrEnd}Minute'].text = picked.minute
          .toString();
      _dateTimeController['${startOrEnd}Time'].text = picked.format(context);
    }
  }

  void _fetchAllProducts() {
    _productsFuture = ProductService.fetchAllProducts();
  }

  void _createAuction() async {
    final int startYear = int.parse(_dateTimeController['startYear'].text);
    final int startMonth = int.parse(_dateTimeController['startMonth'].text);
    final int startDay = int.parse(_dateTimeController['startDay'].text);
    final int startHour = int.parse(_dateTimeController['startHour'].text);
    final int startMinute = int.parse(_dateTimeController['startMinute'].text);
    final int endYear = int.parse(_dateTimeController['endYear'].text);
    final int endMonth = int.parse(_dateTimeController['endMonth'].text);
    final int endDay = int.parse(_dateTimeController['endDay'].text);
    final int endHour = int.parse(_dateTimeController['endHour'].text);
    final int endMinute = int.parse(_dateTimeController['endMinute'].text);

    final DateTime startTime = DateTime(
      startYear,
      startMonth,
      startDay,
      startHour,
      startMinute,
    );

    final DateTime endTime = DateTime(
      endYear,
      endMonth,
      endDay,
      endHour,
      endMinute,
    );

    final Auction newAuction = Auction(
      product: _auctionController['product'],
      startTime: startTime,
      endTime: endTime,
      initialPrice: double.parse(_auctionController['initialPrice'].text),
      minimunBidIncrement: double.parse(
        _auctionController['minimunBidIncrement'].text,
      ),
    );
    try {
      await AuctionService.createAuctions(newAuction.toJson());

      if (!mounted) return;

      Navigator.of(context).pop();
    } catch (e) {
      debugPrint('Erro ao criar leilão: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao criar leilão: $e')));
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchAllProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16.0,
        children: [
          const Text(
            'Cadastrar Novo Leilão',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32),
          ),
          FutureBuilder(
            future: _productsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                debugPrint('Erro: ${snapshot.error}');
                return Center(child: Text('Erro: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('Nenhum produto encontrado.'));
              } else {
                final products = snapshot.data!;
                return DropdownMenu<Product>(
                  width: double.infinity,
                  onSelected: (value) {
                    _auctionController['product'] = value;
                  },
                  menuHeight: MediaQuery.of(context).size.height * 0.4,
                  label: const Text('Escolha o Produto:'),
                  dropdownMenuEntries: products
                      .map((e) => DropdownMenuEntry(value: e, label: e.name))
                      .toList(),
                );
              }
            },
          ),
          Column(
            spacing: 6.0,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Preço Inicial (R\$):', textAlign: TextAlign.start),
              TextField(
                controller: _auctionController['initialPrice'],
                decoration: const InputDecoration(
                  label: Text('Ex: 100,00'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(6)),
                  ),
                ),
              ),
            ],
          ),
          Column(
            spacing: 6.0,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('incremento Mínimo (R\$):', textAlign: TextAlign.start),
              TextField(
                controller: _auctionController['minimunBidIncrement'],
                decoration: const InputDecoration(
                  label: Text('Ex: 100,00'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(6)),
                  ),
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
                    const Text('Data de Início:'),
                    TextField(
                      controller: _dateTimeController['startDate'],
                      readOnly: true,
                      onTap: () => _selectDate(context, 'start'),
                      decoration: const InputDecoration(
                        label: Text('dd/mm/aaaa'),
                        suffixIcon: Icon(Icons.calendar_month),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(6)),
                        ),
                      ),
                      keyboardType: TextInputType.datetime,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    const Text('Hora de Início:'),
                    TextField(
                      controller: _dateTimeController['startTime'],
                      readOnly: true,
                      onTap: () => _selectTime('start'),
                      decoration: const InputDecoration(
                        label: Text('--:--'),
                        suffixIcon: Icon(Icons.access_time),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(6)),
                        ),
                      ),
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
                    const Text('Data de Término:'),
                    TextField(
                      controller: _dateTimeController['endDate'],
                      readOnly: true,
                      onTap: () => _selectDate(context, 'end'),
                      decoration: const InputDecoration(
                        label: Text('dd/mm/aaaa'),
                        suffixIcon: Icon(Icons.calendar_month),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(6)),
                        ),
                      ),
                      keyboardType: TextInputType.datetime,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    const Text('Hora de Término:'),
                    TextField(
                      controller: _dateTimeController['endTime'],
                      readOnly: true,
                      onTap: () => _selectTime('end'),
                      decoration: const InputDecoration(
                        label: Text('--:--'),
                        suffixIcon: Icon(Icons.access_time),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(6)),
                        ),
                      ),
                      keyboardType: TextInputType.datetime,
                    ),
                  ],
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 22, 163, 74),
                  foregroundColor: Colors.white,
                  // fixedSize: Size(MediaQuery.of(context).size.width * 0.13, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () => showModalBottomSheet(
                  context: context,
                  builder: (context) => ProductCreationWidget(
                    onProductCreated: () => setState(() {
                      _fetchAllProducts();
                    }),
                  ),
                ),
                child: const Text('Criar Produto'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 37, 99, 235),
                  foregroundColor: Colors.white,
                  // fixedSize: Size(MediaQuery.of(context).size.width * 0.13, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () => _createAuction(),
                child: const Text('Cadastrar Leilão'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
