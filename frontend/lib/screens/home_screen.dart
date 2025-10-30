import 'package:alert_info/alert_info.dart';
import 'package:flutter/material.dart';
import 'package:lance_certo/enums/auction_filter_params_enum.dart';
import 'package:lance_certo/enums/auction_sort_options_enum.dart';
import 'package:lance_certo/models/auction.dart';
import 'package:lance_certo/models/auction_filter_params.dart';
import 'package:lance_certo/models/auction_status.dart';
import 'package:lance_certo/models/pageable.dart';
import 'package:lance_certo/models/paginated_response.dart';
import 'package:lance_certo/models/user.dart';
import 'package:lance_certo/models/user_role.dart';
import 'package:lance_certo/services/auction_service.dart';
import 'package:lance_certo/services/web_socket_service.dart';
import 'package:lance_certo/utils/responsive.dart';
import 'package:lance_certo/widgets/auction_creation_widget.dart';
import 'package:lance_certo/widgets/auction_list_item_widget.dart';
import 'package:lance_certo/widgets/main_menu_widget.dart';
import 'package:lance_certo/mixins/web_socket_notifier_mixin.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with WebSocketNotifierMixin<HomeScreen> {
  final Map<String, TextEditingController> _filterTextController = {};
  final TextEditingController _selectedFilterMenuController =
      TextEditingController(text: AuctionFilterParamsEnum.all.displayName);
  final TextEditingController _sortMenuControllerSelected =
      TextEditingController(text: AuctionSortOptionsEnum.none.displayName);
  final Pageable _pagination = Pageable(page: 0, size: 6);
  late Future<PaginatedResponse<Auction>> _auctionsFuture;
  bool _isAscendingOrder = true;
  String _oldSortMenuSelected = AuctionSortOptionsEnum.none.displayName;
  int _totalPages = 1;
  String? _keyController;

  void _fetchAuctionsWithPagination() async {
    if (_selectedFilterMenuController.text != 'Tudo' &&
        _filterTextControllerIsEmpty()) {
      return;
    }

    final AuctionFilterParams currentFilters = AuctionFilterParams(
      statuses: [AuctionStatus.ACTIVE],
    );

    switch (_keyController) {
      case 'all':
        break;
      case 'productName':
        currentFilters.productName =
            _filterTextController[_keyController]!.text;
      case 'sellerName':
        currentFilters.sellerName = _filterTextController[_keyController]!.text;
      case 'minCurrentBid':
        currentFilters.minCurrentBid = double.tryParse(
          _filterTextController[_keyController]!.text,
        );
      case 'maxCurrentBid':
        currentFilters.maxCurrentBid = double.tryParse(
          _filterTextController[_keyController]!.text,
        );
      case 'minInitialPrice':
        currentFilters.minInitialPrice = double.tryParse(
          _filterTextController[_keyController]!.text,
        );
      case 'maxInitialPrice':
        currentFilters.maxInitialPrice = double.tryParse(
          _filterTextController[_keyController]!.text,
        );
    }

    _auctionsFuture = AuctionService.fetchAllAuctions(
      _pagination,
      currentFilters,
    );

    _auctionsFuture
        .then((value) {
          setState(() {
            _totalPages = value.totalPages;

            if (_pagination.page + 1 > value.totalPages) {
              _pagination.page = value.totalPages - 1;
            }
          });
        })
        .catchError((e) {
          debugPrint('Erro ao buscar leilões: $e');
          if (mounted) {
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
        });
  }

  Future<void> _handleAuctionCreationPress() async {
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return const AuctionCreationWidget();
      },
    );
  }

  bool _filterTextControllerIsEmpty() {
    return _filterTextController.values.every((controller) {
      return controller.text.trim().isEmpty;
    });
  }

  Future<void> _refreshAuctions() async {
    _pagination.page = 0;

    setState(() {
      _fetchAuctionsWithPagination();
    });
  }

  @override
  void initState() {
    super.initState();

    WebSocketService.registerBidNotifier(onBidUpdate);
    WebSocketService.registerStatusNotifier(onStatusUpdate);

    if (User.currentUser!.role != UserRole.BUYER) {
      WebSocketService.registerBidNotifierForSellers(onSellerBidUpdate);
      WebSocketService.registerStatusNotifierForSellers(onSellerStatusUpdate);
    }

    for (var filter in AuctionFilterParamsEnum.values) {
      _filterTextController[filter.name] = TextEditingController();
    }

    _keyController = AuctionFilterParamsEnum.all.name;

    setState(() {
      _fetchAuctionsWithPagination();
    });
  }

  @override
  void dispose() {
    _selectedFilterMenuController.dispose();
    _filterTextController.forEach((key, value) => value.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final firstContainerPadding = Responsive.valueForBreakpoints(
      context: context,
      xs: 0.0,
      md: 30.0,
    );

    final secondContainerBorderRadius = Responsive.valueForBreakpoints(
      context: context,
      xs: 0.0,
      md: 8.0,
    );

    final fontSizeTitle = Responsive.valueForBreakpoints(
      context: context,
      xs: 20.0,
      sm: 30.0,
      md: 35.0,
    );

    final fontSizeButtom = Responsive.valueForBreakpoints(
      context: context,
      xs: 15.0,
      md: 16.0,
    );

    final widthButtom = Responsive.valueForBreakpoints(
      context: context,
      xs: 100.0,
      sm: 150.0,
    );

    final heightButtom = Responsive.valueForBreakpoints(
      context: context,
      xs: 16.0,
      sm: 50.0,
    );

    final paddingButtom = Responsive.valueForBreakpoints(
      context: context,
      xs: 0.0,
    );

    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(firstContainerPadding),
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 243, 244, 246),
          ),
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(24.0),
              constraints: const BoxConstraints(maxWidth: Responsive.xxl * .9),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(
                  secondContainerBorderRadius,
                ),
              ),
              child: Column(
                spacing: 8.0,
                children: [
                  const MainMenuWidget(currentRoute: '/home'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Flexible(
                        child: Text(
                          'Leilões Ativos',
                          style: TextStyle(
                            fontSize: fontSizeTitle,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Flexible(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          spacing: 16.0,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.all(paddingButtom),
                                backgroundColor: const Color.fromARGB(
                                  255,
                                  22,
                                  163,
                                  74,
                                ),
                                foregroundColor: Colors.white,
                                fixedSize: Size(widthButtom, heightButtom),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                textStyle: TextStyle(
                                  fontSize: fontSizeButtom,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onPressed:
                                  User.currentUser!.role != UserRole.BUYER
                                  ? _handleAuctionCreationPress
                                  : null,
                              child: const Text('+ Novo Leilão'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (!Responsive.isExtraSmall(context) &&
                      !Responsive.isSmall(context))
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            spacing: 16.0,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Filtrar por:'),
                                  DropdownMenu<AuctionFilterParamsEnum>(
                                    controller: _selectedFilterMenuController,
                                    enableSearch: false,
                                    enableFilter: true,
                                    width:
                                        MediaQuery.of(context).size.width *
                                        0.226,
                                    menuHeight:
                                        MediaQuery.of(context).size.height *
                                        0.3,
                                    textStyle: const TextStyle(fontSize: 14.0),
                                    onSelected: (value) {
                                      if (value == null) return;

                                      if (_keyController != value.name) {
                                        _filterTextController[_keyController]
                                            ?.clear();
                                      }

                                      setState(() {
                                        _keyController = value.name;

                                        if (!_filterTextControllerIsEmpty()) {
                                          _pagination.page = 0;
                                          _fetchAuctionsWithPagination();
                                        }
                                      });
                                    },
                                    dropdownMenuEntries: AuctionFilterParamsEnum
                                        .values
                                        .map(
                                          (e) => DropdownMenuEntry(
                                            value: e,
                                            label: e.displayName,
                                          ),
                                        )
                                        .toList(),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Buscar Termo:'),
                                  TextField(
                                    enabled:
                                        _selectedFilterMenuController.text !=
                                            'Tudo'
                                        ? true
                                        : false,
                                    controller:
                                        _filterTextController[_keyController],
                                    onChanged: (value) {
                                      if (_selectedFilterMenuController.text !=
                                          'Tudo') {
                                        setState(() {
                                          _pagination.page = 0;
                                          _fetchAuctionsWithPagination();
                                        });
                                      }
                                    },
                                    decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 10.0, vertical: 16.0
                                      ),
                                      border: const OutlineInputBorder(),
                                      hint: const Text(
                                        'Buscar leilões...',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                      constraints: BoxConstraints(
                                        maxWidth:
                                            MediaQuery.of(context).size.width *
                                            0.196,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Ordernar por:'),
                              DropdownMenu<AuctionSortOptionsEnum>(
                                controller: _sortMenuControllerSelected,
                                textStyle: const TextStyle(fontSize: 14.0),
                                width: MediaQuery.of(context).size.width * 0.25,
                                menuHeight:
                                    MediaQuery.of(context).size.height * 0.3,
                                leadingIcon: Icon(
                                  fill: 0.5,
                                  _sortMenuControllerSelected.text !=
                                          AuctionSortOptionsEnum
                                              .none
                                              .displayName
                                      ? _isAscendingOrder
                                            ? Icons.arrow_upward
                                            : Icons.arrow_downward
                                      : Icons.sort,
                                  color: const Color.fromARGB(
                                    255,
                                    59,
                                    130,
                                    246,
                                  ),
                                ),
                                onSelected: (value) {
                                  if (value == null) return;

                                  setState(() {
                                    _pagination.page = 0;
                                    _pagination.sort = null;

                                    if (value != AuctionSortOptionsEnum.none) {
                                      value.displayName == _oldSortMenuSelected
                                          ? _isAscendingOrder =
                                                !_isAscendingOrder
                                          : _isAscendingOrder = true;

                                      _pagination.sort = [
                                        '${value.name},${_isAscendingOrder ? 'asc' : 'desc'}',
                                      ];
                                    }

                                    _fetchAuctionsWithPagination();

                                    _oldSortMenuSelected = value.displayName;
                                  });
                                },
                                dropdownMenuEntries: AuctionSortOptionsEnum
                                    .values
                                    .map(
                                      (e) => DropdownMenuEntry(
                                        value: e,
                                        label: e.displayName,
                                      ),
                                    )
                                    .toList(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  const Divider(color: Colors.grey),
                  Flexible(
                    child: FutureBuilder<PaginatedResponse<Auction>>(
                      future: _auctionsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (snapshot.hasError) {
                          debugPrint('Erro: ${snapshot.error}');
                          return Center(child: Text('Erro: ${snapshot.error}'));
                        } else if (!snapshot.hasData ||
                            snapshot.data!.content.isEmpty) {
                          return const Center(
                            child: Text('Nenhum leilão ativo encontrado.'),
                          );
                        } else {
                          final paginatedAuctions = snapshot.data!;

                          final List<Auction> auctions = paginatedAuctions
                              .content
                              .where((auctionDynamic) {
                                final Auction auction =
                                    auctionDynamic as Auction;
                                return auction.status == AuctionStatus.ACTIVE &&
                                    (auction.endDateAndTime.isAfter(
                                      DateTime.now(),
                                    ));
                              })
                              .map(
                                (auctionDynamic) => auctionDynamic as Auction,
                              )
                              .toList();

                          return LayoutBuilder(
                            builder: (context, constraints) {
                              final double totalWidth = constraints.maxWidth;

                              final heightLimit =
                                  Responsive.valueForBreakpoints(
                                    context: context,
                                    xs: 375.0,
                                    md: 355.0,
                                  );

                              final double widthLimit =
                                  Responsive.valueForBreakpoints(
                                    context: context,
                                    xs: 320.0,
                                  );

                              const double minSpacing = 6.0;
                              const double maxSpacing = 50.0;

                              final int numberOfCollums =
                                  (totalWidth / widthLimit).floor();

                              double calculatedSpacing =
                                  (totalWidth -
                                      (numberOfCollums * widthLimit)) /
                                  (numberOfCollums - 1);

                              if (calculatedSpacing > maxSpacing) {
                                calculatedSpacing = maxSpacing;
                              }
                              if (calculatedSpacing < minSpacing) {
                                calculatedSpacing = minSpacing;
                              }
                              if (numberOfCollums < 2) calculatedSpacing = 0.0;

                              debugPrint('totalWidth=$totalWidth');
                              debugPrint('numberOfCollums=$numberOfCollums');
                              debugPrint(
                                'calculatedSpacing=$calculatedSpacing',
                              );

                              return RefreshIndicator(
                                onRefresh: _refreshAuctions,
                                child: SingleChildScrollView(
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: Wrap(
                                      spacing: calculatedSpacing,
                                      runSpacing: 10.0,
                                      alignment: WrapAlignment.center,
                                      children: auctions.map((auction) {
                                        return SizedBox(
                                          width: widthLimit,
                                          height: heightLimit,
                                          child: AuctionListItemWidget(
                                            auction: auction,
                                            updateList: () async {
                                              setState(() {
                                                _fetchAuctionsWithPagination();
                                              });
                                            },
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        }
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton.icon(
                        onPressed: _pagination.page > 0
                            ? () {
                                setState(() {
                                  _pagination.page -= 1;
                                  _fetchAuctionsWithPagination();
                                });
                              }
                            : null,
                        label: const Icon(Icons.arrow_left),
                      ),
                      FutureBuilder<PaginatedResponse<Auction>>(
                        future: _auctionsFuture,
                        builder: (context, snapshot) => Text(
                          '${_pagination.page + 1} de ${_totalPages == 0 ? '1' : _totalPages}',
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _totalPages > _pagination.page + 1
                            ? () async {
                                setState(() {
                                  _pagination.page += 1;
                                  _fetchAuctionsWithPagination();
                                });
                              }
                            : null,
                        label: const Icon(Icons.arrow_right),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
