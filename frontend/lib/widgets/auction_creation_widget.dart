import 'package:alert_info/alert_info.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lance_certo/models/auction.dart';
import 'package:lance_certo/models/product.dart';
import 'package:lance_certo/models/user.dart';
import 'package:lance_certo/services/auction_service.dart';
import 'package:lance_certo/services/product_service.dart';
import 'package:lance_certo/services/web_socket_service.dart';
import 'package:lance_certo/widgets/product_creaction_widget.dart';

class AuctionCreationWidget extends StatefulWidget {
  const AuctionCreationWidget({super.key});

  @override
  State<AuctionCreationWidget> createState() => _AuctionCreationWidgetState();
}

class _AuctionCreationWidgetState extends State<AuctionCreationWidget> {
  late Future<List<Product>> _productsFuture;

  bool _isLoading = false;
  bool _hasProducts = true;
  bool _productSelected = false;

  final Map<String, dynamic> _auctionController = {
    'product': null,
    'startTime': TextEditingController(),
    'endTime': TextEditingController(),
    'startDate': TextEditingController(),
    'endDate': TextEditingController(),
    'initialPrice': TextEditingController(),
    'minimunBidIncrement': TextEditingController(),
  };

  final Map<String, String?> _auctionError = {
    'product': null,
    'startDate': null,
    'startTime': null,
    'endDate': null,
    'endTime': null,
    'initialPrice': null,
    'minimunBidIncrement': null,
  };

  Future<void> _selectDate(BuildContext context, String startOrEnd) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 366)),
    );

    if (picked != null) {
      _auctionController['${startOrEnd}Date'].text = DateFormat(
        'dd/MM/yyyy',
      ).format(picked);
    }
  }

  Future<void> _selectTime(String startOrEnd) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: startOrEnd == 'start'
          ? TimeOfDay.now()
          : TimeOfDay.fromDateTime(
              DateTime.now().add(const Duration(minutes: 1)),
            ),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (picked != null) {
      if (!mounted) return;

      //final bool is24hFormat = MediaQuery.of(context).alwaysUse24HourFormat;

      final String formattedHour = picked.hour.toString().padLeft(2, '0');
      final String formattedMinute = picked.minute.toString().padLeft(2, '0');

      _auctionController['${startOrEnd}Time'].text =
          '$formattedHour:$formattedMinute';
    }
  }

  void _fetchAllProducts() {
    try {
      _productsFuture = ProductService.fetchProductsBySeller();
    } catch (e) {
      debugPrint('Erro ao buscar produtos: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        final String errorMessage = e.toString();
        final String cleanMessage = errorMessage.replaceFirst(
          'Exception: ',
          '',
        );

        AlertInfo.show(
          context: context,
          text: cleanMessage,
          typeInfo: TypeInfo.error,
        );
      }
    }
  }

  void _createAuction() async {
    setState(() {
      _auctionError.clear();
      _isLoading = true;
    });

    bool hasErrors = false;

    if (_auctionController['product'] == null) {
      _auctionError['product'] = 'Selecione um produto.';
      hasErrors = true;
    }

    for (var entry in _auctionController.entries) {
      final key = entry.key;
      final value = entry.value;

      // Ignora 'product' (já checado) e garante que é um TextEditingController
      if (key != 'product' && value is TextEditingController) {
        if (value.text.isEmpty) {
          _auctionError[key] = 'Campo obrigatório.';
          hasErrors = true;
        }
      }
    }

    if (hasErrors) {
      setState(() {
        _isLoading = false;
      });

      return;
    }

    final String startDate = _auctionController['startDate'].text;
    final String endDate = _auctionController['endDate'].text;
    final String startTime = _auctionController['startTime'].text;
    final String endTime = _auctionController['endTime'].text;

    final List<String> separateStartDate = startDate.split('/');
    final List<String> separateStartTime = startTime
        .replaceAll('AM', '')
        .replaceAll('PM', '')
        .split(':');
    final List<String> separateEndDate = endDate.split('/');
    final List<String> separateEndTime = endTime
        .replaceAll('AM', '')
        .replaceAll('PM', '')
        .split(':');

    final int startYear = int.parse(separateStartDate[2]);
    final int startMonth = int.parse(separateStartDate[1]);
    final int startDay = int.parse(separateStartDate[0]);
    final int startHour = int.parse(separateStartTime[0]);
    final int startMinute = int.parse(separateStartTime[1]);
    final int endYear = int.parse(separateEndDate[2]);
    final int endMonth = int.parse(separateEndDate[1]);
    final int endDay = int.parse(separateEndDate[0]);
    final int endHour = int.parse(separateEndTime[0]);
    final int endMinute = int.parse(separateEndTime[1]);

    final DateTime startDateAndTime = DateTime(
      startYear,
      startMonth,
      startDay,
      startHour,
      startMinute,
      15,
    );

    final DateTime endDateAndTime = DateTime(
      endYear,
      endMonth,
      endDay,
      endHour,
      endMinute,
      15,
    );

    final DateTime now = DateTime.now();

    //final DateTime today = DateTime(now.year, now.month, now.day);

    final DateTime startDateOnly = DateTime(startYear, startMonth, startDay);
    final DateTime endDateOnly = DateTime(endYear, endMonth, endDay);

    if (startDateAndTime.isBefore(now)) {
      setState(() {
        _isLoading = false;

        _auctionError['startTime'] = 'Hora de início tem quer ser no futuro.';
      });

      return;
    }

    if (endDateAndTime.isBefore(now)) {
      setState(() {
        _isLoading = false;

        _auctionError['endTime'] = 'Hora do fim tem quer ser no futuro.';
      });

      return;
    }

    if (!endDateAndTime.isAfter(startDateAndTime)) {
      setState(() {
        _isLoading = false;

        if (startDateOnly.isAfter(endDateOnly)) {
          _auctionError['startDate'] =
              'A data do fim tem quer ser igual ou depois da data de início.';
          _auctionError['endDate'] =
              'A data do fim tem quer ser igual ou depois da data de início.';

          return;
        }

        _auctionError['startTime'] =
            'A hora do fim tem quer ser depois da hora de início.';
        _auctionError['endTime'] =
            'A hora do fim tem quer ser depois da hora de início.';
      });

      return;
    }

    final Auction newAuction = Auction(
      product: _auctionController['product'],
      startDateAndTime: startDateAndTime,
      endDateAndTime: endDateAndTime,
      initialPrice: double.parse(_auctionController['initialPrice'].text),
      minimunBidIncrement: double.parse(
        _auctionController['minimunBidIncrement'].text,
      ),
    );

    try {
      await AuctionService.createAuctions(newAuction.toJson());

      final String sellerStatusTopic = WebSocketService.getSellerStatusTopic(
        User.currentUser!.id!,
      );
      final String sellerBidTopic = WebSocketService.getSellerBidTopic(
        User.currentUser!.id!,
      );

      WebSocketService.subscribe(sellerStatusTopic);
      WebSocketService.subscribe(sellerBidTopic);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      Navigator.of(context).pop();
    } catch (e) {
      debugPrint('Erro ao criar leilão: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        final String errorMessage = e.toString();
        final String cleanMessage = errorMessage.replaceFirst(
          'Exception: ',
          '',
        );

        setState(() {
          _auctionError['product'] = cleanMessage;
        });

        AlertInfo.show(
          context: context,
          text: cleanMessage,
          typeInfo: TypeInfo.error,
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchAllProducts();
  }

  @override
  void dispose() {
    _auctionController.forEach((key, value) {
      if (key != 'product') value.dispose();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
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
              const Text('Selecione o Produto:', textAlign: TextAlign.start),
              FutureBuilder(
                future: _productsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    debugPrint('Erro: ${snapshot.error}');
                    return Center(child: Text('Erro: ${snapshot.error}'));
                  } else {
                    final products = snapshot.data!;

                    return DropdownMenu<Product>(
                      enabled: snapshot.hasData && snapshot.data!.isNotEmpty
                          ? true
                          : false,
                      width: double.infinity,
                      menuHeight: MediaQuery.of(context).size.height * 0.4,
                      label: Text(
                        !snapshot.hasData || snapshot.data!.isEmpty
                            ? 'Nenhum produto encontrado.'
                            : _productSelected
                            ? ''
                            : 'Nenhum produto selecionado.',
                      ),
                      errorText: _auctionError['product'],
                      dropdownMenuEntries: products
                          .map(
                            (e) => DropdownMenuEntry(value: e, label: e.name),
                          )
                          .toList(),
                      onSelected: (value) {
                        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                          setState(() {
                            _auctionError['product'] = null;
                            _auctionController['product'] = value;
                            _productSelected = true;
                          });
                        }
                      },
                    );
                  }
                },
              ),
              Column(
                spacing: 6.0,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Preço Inicial (R\$):',
                    textAlign: TextAlign.start,
                  ),
                  TextField(
                    controller: _auctionController['initialPrice'],
                    decoration: InputDecoration(
                      label: const Text('Ex: 100,00'),
                      errorText: _auctionError['initialPrice'],
                      errorMaxLines: 2,
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(6)),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _auctionError['initialPrice'] = null;
                      });
                    },
                  ),
                ],
              ),
              Column(
                spacing: 6.0,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Incremento Mínimo (R\$):'),
                  TextField(
                    controller: _auctionController['minimunBidIncrement'],
                    decoration: InputDecoration(
                      label: const Text('Ex: 100,00'),
                      errorText: _auctionError['minimunBidIncrement'],
                      errorMaxLines: 2,
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(6)),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _auctionError['minimunBidIncrement'] = null;
                      });
                    },
                  ),
                ],
              ),

              Row(
                spacing: 16,
                children: [
                  Expanded(
                    child: Column(
                      spacing: 6.0,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Data de Início:'),
                        TextField(
                          controller: _auctionController['startDate'],
                          readOnly: true,
                          onTap: () => _selectDate(context, 'start'),
                          decoration: InputDecoration(
                            label: const Text('dd/mm/aaaa'),
                            suffixIcon: const Icon(Icons.calendar_month),
                            errorText: _auctionError['startDate'],
                            errorMaxLines: 2,
                            border: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(6),
                              ),
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _auctionError['startDate'] = null;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      spacing: 6.0,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Hora de Início:'),
                        TextField(
                          controller: _auctionController['startTime'],
                          readOnly: true,
                          onTap: () => _selectTime('start'),
                          decoration: InputDecoration(
                            label: const Text('--:--'),
                            suffixIcon: const Icon(Icons.access_time),
                            errorText: _auctionError['startTime'],
                            errorMaxLines: 2,
                            border: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(6),
                              ),
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _auctionError['startTime'] = null;
                            });
                          },
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
                      spacing: 6.0,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Data de Término:'),
                        TextField(
                          controller: _auctionController['endDate'],
                          readOnly: true,
                          onTap: () => _selectDate(context, 'end'),
                          decoration: InputDecoration(
                            label: const Text('dd/mm/aaaa'),
                            suffixIcon: const Icon(Icons.calendar_month),
                            errorText: _auctionError['endDate'],
                            errorMaxLines: 2,
                            border: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(6),
                              ),
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _auctionError['endDate'] = null;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      spacing: 6.0,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Hora de Término:'),
                        TextField(
                          controller: _auctionController['endTime'],
                          readOnly: true,
                          onTap: () => _selectTime('end'),
                          decoration: InputDecoration(
                            label: const Text('--:--'),
                            suffixIcon: const Icon(Icons.access_time),
                            errorText: _auctionError['endTime'],
                            errorMaxLines: 2,
                            border: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(6),
                              ),
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _auctionError['endTime'] = null;
                            });
                          },
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
                  FutureBuilder(
                    future: _productsFuture,
                    builder: (context, snapshot) {
                      _hasProducts = true;
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        _hasProducts = false;
                      }

                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            37,
                            99,
                            235,
                          ),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: _hasProducts ? _createAuction : null,
                        child: const Text('Cadastrar Leilão'),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        if (_isLoading) ...[
          ModalBarrier(
            dismissible: false,
            color: Colors.black.withValues(alpha: 0.4),
          ),
          const Center(child: CircularProgressIndicator()),
        ],
      ],
    );
  }
}
