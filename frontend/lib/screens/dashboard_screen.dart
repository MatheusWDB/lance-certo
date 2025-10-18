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
import 'package:lance_certo/widgets/dashboard_list_widget.dart';
import 'package:lance_certo/widgets/main_menu_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  late Future<PaginatedResponse<Bid>> _bidsFuture;
  late Future<PaginatedResponse<Auction>> _auctionsFuture;
  late final TabController _tabController;

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
        return 'Meus Leilões Criados';
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

  Widget _emptyContenMmessage(String message) {
    return Center(child: Text('Nenhum $message encontrado.'));
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchMyBidsWithAuctions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 243, 244, 246),
          ),
          child: Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.87,
              padding: const EdgeInsets.all(32.0),
              margin: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                spacing: 8.0,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const MainMenuWidget(currentRoute: '/dashboard'),
                  const Text(
                    'Minha Área',
                    style: TextStyle(fontSize: 37, fontWeight: FontWeight.bold),
                  ),
                  TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    tabs: [
                      const Text(
                        'Meus Lances',
                        style: TextStyle(fontSize: 16.0),
                      ),
                      Text(
                        'Meus Leilões (Vendedor)',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: User.currentUser!.role == UserRole.BUYER
                              ? Colors.grey.shade400
                              : Colors.black,
                        ),
                      ),
                      const Text(
                        'Leilões Encerrados',
                        style: TextStyle(fontSize: 16.0),
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
                  //const Divider(color: Colors.grey),
                  Expanded(
                    child: Column(
                      spacing: 16.0,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          _getMenuTitle(),
                          textAlign: TextAlign.start,
                          style: const TextStyle(
                            fontSize: 23.0,
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
                                    ? _emptyContenMmessage('lance')
                                    : _emptyContenMmessage('leilão');
                              } else {
                                if (_activeMenu == 0 &&
                                    !snapshot.data!.content
                                        .whereType<Bid>()
                                        .any(
                                          (element) =>
                                              element.auction!.status ==
                                              AuctionStatus.ACTIVE,
                                        )) {
                                  return _emptyContenMmessage('lance ativo');
                                }

                                if (_activeMenu == 2 &&
                                    !snapshot.data!.content
                                        .whereType<Bid>()
                                        .any(
                                          (element) =>
                                              element.auction!.status ==
                                              AuctionStatus.CLOSED,
                                        )) {
                                  return _emptyContenMmessage(
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

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
