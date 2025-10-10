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

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<PaginatedResponse<Bid>> _bidsFuture;
  late Future<PaginatedResponse<Auction>> _auctionsFuture;

  String _activeMenu = 'myBids';

  void _fetchMyBidsWithAuctions() async {
    _bidsFuture = BidService.fetchBidsByBidder();

    if (User.currentUser!.role != UserRole.BUYER) {
      _auctionsFuture = AuctionService.fetchAuctionsBySeller();
    }
  }

  String _getMenuTitle() {
    switch (_activeMenu) {
      case 'myBids':
        return 'Meus Lances Ativos';
      case 'myAuctions':
        return 'Meus Leilões Criados';
      case 'closedAuctions':
        return 'Leilões Encerrados';
      default:
        return '';
    }
  }

  void _changeMenu(String menu) {
    if (menu == _activeMenu) return;

    if (User.currentUser!.role == UserRole.BUYER && menu == 'myAuctions') {
      return;
    }

    _fetchMyBidsWithAuctions();

    setState(() {
      _activeMenu = menu;
    });
  }

  Color _menuColor(String menu) {
    return _activeMenu == menu ? const Color(0xFF2563EB) : const Color(0xFF4B5563);
  }

  Widget _emptyContenMmessage(String message) {
    return Center(child: Text('Nenhum $message encontrado.'));
  }

  @override
  void initState() {
    super.initState();
    _fetchMyBidsWithAuctions();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(color: Color.fromARGB(255, 243, 244, 246)),
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
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => _changeMenu('myBids'),
                        style: ButtonStyle(
                          foregroundColor: WidgetStateProperty.all(
                            _menuColor('myBids'),
                          ),
                        ),
                        child: const Text('Meus Lances', style: TextStyle(fontSize: 16.0),),
                      ),
                      TextButton(
                        onPressed: () => _changeMenu('myAuctions'),
                        style: ButtonStyle(
                          foregroundColor: WidgetStateProperty.all(
                            User.currentUser!.role == UserRole.BUYER
                                ? Colors.grey
                                : _menuColor('myAuctions'),
                          ),
                        ),
                        child: const Text('Meus Leilões (Vendedor)', style: TextStyle(fontSize: 16.0),),
                      ),
                      TextButton(
                        onPressed: () => _changeMenu('closedAuctions'),
                        style: ButtonStyle(
                          foregroundColor: WidgetStateProperty.all(
                            _menuColor('closedAuctions'),
                          ),
                        ),
                        child: const Text('Leilões Encerrados', style: TextStyle(fontSize: 16.0),),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.grey),
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
                            future: _activeMenu == 'myAuctions'
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
                                return _activeMenu == 'myBids'
                                    ? _emptyContenMmessage('lance')
                                    : _emptyContenMmessage('leilão');
                              } else {
                                if (_activeMenu == 'myBids' &&
                                    !snapshot.data!.content
                                        .whereType<Bid>()
                                        .any(
                                          (element) =>
                                              element.auction!.status ==
                                              AuctionStatus.ACTIVE,
                                        )) {
                                  return _emptyContenMmessage('lance ativo');
                                }

                                if (_activeMenu == 'closedAuctions' &&
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

                                if (_activeMenu != 'myAuctions') {
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
