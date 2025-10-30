import 'package:alert_info/alert_info.dart';
import 'package:flutter/material.dart';
import 'package:lance_certo/models/auction.dart';
import 'package:lance_certo/models/auction_status.dart';
import 'package:lance_certo/models/bid.dart';
import 'package:lance_certo/models/paginated_response.dart';
import 'package:lance_certo/models/user.dart';
import 'package:lance_certo/models/user_role.dart';
import 'package:lance_certo/services/auction_service.dart';
import 'package:lance_certo/services/bid_service.dart';
import 'package:lance_certo/services/web_socket_service.dart';
import 'package:lance_certo/utils/responsive.dart';
import 'package:lance_certo/widgets/dashboard_list_widget.dart';
import 'package:lance_certo/widgets/main_menu_widget.dart';
import 'package:lance_certo/mixins/web_socket_notifier_mixin.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin, WebSocketNotifierMixin<DashboardScreen> {
  late final TabController _tabController;
  late Future<PaginatedResponse<Auction>> _auctionsFuture;
  late Future<PaginatedResponse<Bid>> _bidsFuture;
  int _activeMenu = 0;

  void _fetchMyBidsWithAuctions() async {
    try {
      _bidsFuture = BidService.fetchBidsByBidder();

      if (User.currentUser!.role != UserRole.BUYER) {
        _auctionsFuture = AuctionService.fetchAuctionsBySeller();
      }
    } catch (e) {
      debugPrint('Erro ao buscar lances: $e');
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
    }
  }

  String _getMenuTitle() {
    switch (_activeMenu) {
      case 0:
        return 'Meus Lances Ativos';
      case 1:
        return 'Meus Leilões';
      case 2:
        return 'Leilões Encerrados';
      default:
        return '';
    }
  }

  void _changeMenu(int menu) {
    if (menu == _activeMenu) return;

    if (User.currentUser!.role == UserRole.BUYER && menu == 1) return;

    _fetchMyBidsWithAuctions();

    setState(() {
      _activeMenu = menu;
    });
  }

  Widget _emptyContenMessage(String message) {
    return Center(child: Text('Nenhum $message encontrado.'));
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

    _tabController = TabController(length: 3, vsync: this);
    _fetchMyBidsWithAuctions();
  }

  @override
  void dispose() {
    _tabController.dispose();
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

    final fontSizeTabBar = Responsive.valueForBreakpoints(
      context: context,
      xs: 0.0,
      sm: 16.0,
    );

    final fontSizeSubTitle = Responsive.valueForBreakpoints(
      context: context,
      xs: 16.0,
      sm: 23.0,
    );

    final List<Map<String, dynamic>> menu = [
      {'value': 0, 'label': 'Meus Lances'},
      {'value': 1, 'label': 'Meus Leilões (Vendedor)'},
      {'value': 2, 'label': 'Leilões Encerrados'},
    ];

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
                mainAxisSize: MainAxisSize.min,
                children: [
                  const MainMenuWidget(currentRoute: '/dashboard'),
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 48.0),
                          child: Text(
                            'Minha Área',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: fontSizeTitle,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      if (Responsive.isExtraSmall(context))
                        PopupMenuButton(
                          initialValue: _activeMenu,
                          icon: const Icon(Icons.menu),
                          onSelected: (value) {
                            if (value as int == 1 &&
                                User.currentUser!.role == UserRole.BUYER) {
                              setState(() {
                                _tabController.index = _activeMenu;
                              });
                              AlertInfo.show(
                                context: context,
                                text:
                                    'Somente vendedores podem acessar a aba "Meus Leilões".',
                                typeInfo: TypeInfo.warning,
                              );

                              return;
                            }

                            _changeMenu(value);
                          },
                          itemBuilder: (BuildContext context) {
                            return [
                              PopupMenuItem(
                                value: menu[0]['value'],
                                child: Text(menu[0]['label']),
                              ),
                              PopupMenuItem(
                                value: menu[1]['value'],
                                child: Text(menu[1]['label']),
                              ),
                              PopupMenuItem(
                                value: menu[2]['value'],
                                child: Text(menu[2]['label']),
                              ),
                            ];
                          },
                        ),
                    ],
                  ),
                  if (!Responsive.isExtraSmall(context))
                    TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      tabs: [
                        Text(
                          menu[0]['label'],
                          style: TextStyle(fontSize: fontSizeTabBar),
                        ),
                        Text(
                          menu[1]['label'],
                          style: TextStyle(
                            fontSize: fontSizeTabBar,
                            color: User.currentUser!.role == UserRole.BUYER
                                ? Colors.grey.shade400
                                : null,
                          ),
                        ),
                        Text(
                          menu[2]['label'],
                          style: TextStyle(fontSize: fontSizeTabBar),
                        ),
                      ],
                      onTap: (value) {
                        if (value == 1 &&
                            User.currentUser!.role == UserRole.BUYER) {
                          setState(() {
                            _tabController.index = _activeMenu;
                          });
                          AlertInfo.show(
                            context: context,
                            text:
                                'Somente vendedores podem acessar a aba "Meus Leilões".',
                            typeInfo: TypeInfo.warning,
                          );

                          return;
                        }

                        _changeMenu(value);
                      },
                    ),
                  Expanded(
                    child: Column(
                      spacing: 16.0,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          _getMenuTitle(),
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontSize: fontSizeSubTitle,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Flexible(
                          child: FutureBuilder<dynamic>(
                            future: _activeMenu == 1
                                ? _auctionsFuture
                                : _bidsFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              } else if (snapshot.hasError) {
                                debugPrint('Erro: ${snapshot.error}');
                                return Center(
                                  child: Text('Erro: ${snapshot.error}'),
                                );
                              } else if (!snapshot.hasData ||
                                  snapshot.data!.content.isEmpty) {
                                return _activeMenu == 0
                                    ? _emptyContenMessage('lance')
                                    : _emptyContenMessage('leilão');
                              } else {
                                if (_activeMenu == 0 &&
                                    !snapshot.data!.content
                                        .whereType<Bid>()
                                        .any(
                                          (element) =>
                                              element.auction!.status ==
                                              AuctionStatus.ACTIVE,
                                        )) {
                                  return _emptyContenMessage('lance ativo');
                                }

                                if (_activeMenu == 2 &&
                                    !snapshot.data!.content
                                        .whereType<Bid>()
                                        .any(
                                          (element) =>
                                              element.auction!.status ==
                                              AuctionStatus.CLOSED,
                                        )) {
                                  return _emptyContenMessage(
                                    'leilão encerrado',
                                  );
                                }

                                final paginatedFuture = snapshot.data;
                                late final List<Object> item;

                                if (_activeMenu != 1) {
                                  final List<Bid> allBids = paginatedFuture!
                                      .content
                                      .whereType<Bid>()
                                      .toList();

                                  final Map<int?, Bid> highestBidPerAuction =
                                      {};

                                  for (var bid in allBids) {
                                    final auctionId = bid.auction!.id;

                                    if (!highestBidPerAuction.containsKey(
                                          auctionId,
                                        ) ||
                                        (bid.amount >
                                            highestBidPerAuction[auctionId]!
                                                .amount)) {
                                      highestBidPerAuction[auctionId] = bid;
                                    }
                                  }

                                  item = highestBidPerAuction.values.toList();
                                } else {
                                  item = paginatedFuture!.content
                                      .whereType<Auction>()
                                      .toList();
                                }

                                return ListView.builder(
                                  itemCount: item.length,
                                  itemBuilder: (context, index) =>
                                      DashboardListWidget(
                                        activeMenu: _activeMenu,
                                        item: item[index],
                                        updateList: () async {
                                          WidgetsBinding.instance
                                              .addPostFrameCallback((_) {
                                                setState(() {
                                                  _fetchMyBidsWithAuctions();
                                                });
                                              });
                                        },
                                      ),
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
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
