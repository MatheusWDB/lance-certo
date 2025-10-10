import 'package:flutter/material.dart';
//import 'package:lance_certo/enums/auction_filter_options.dart';
import 'package:lance_certo/models/auction.dart';
import 'package:lance_certo/models/auction_filter_params.dart';
import 'package:lance_certo/models/auction_status.dart';
import 'package:lance_certo/models/pageable.dart';
import 'package:lance_certo/models/paginated_response.dart';
import 'package:lance_certo/models/product.dart';
import 'package:lance_certo/models/user.dart';
import 'package:lance_certo/models/user_role.dart';
import 'package:lance_certo/services/auction_service.dart';
import 'package:lance_certo/services/product_service.dart';
import 'package:lance_certo/widgets/auction_list_widget.dart';
import 'package:lance_certo/widgets/main_menu_widget.dart';
import 'package:lance_certo/widgets/auction_creation_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<PaginatedResponse<Auction>> _auctionsFuture;

  final TextEditingController _researchController = TextEditingController();

  AuctionFilterParams currentFilters = AuctionFilterParams(
    statuses: [AuctionStatus.ACTIVE],
  );
  final Pageable _pagination = Pageable(page: 0, size: 6, sort: []);
  int _totalPages = 1;
  final AuctionStatus _filterByStatus = AuctionStatus.ACTIVE;

  void _fetchAuctionsWithPagination() async {
    _auctionsFuture = AuctionService.fetchAllAuctions(
      _pagination,
      currentFilters,
    );

    _auctionsFuture.then((value) {
      setState(() {
        _totalPages = value.totalPages;
      });
    });
  }

  Future<void> _handleAuctionCreationPress() async {
    // 1. Verificação de permissão

    // 2. Chamada Assíncrona
    final List<Product> myProducts = await ProductService.fetchAllProducts();

    // 3. Verificação CRÍTICA do mounted após o await
    if (!mounted) return;

    // 4. Uso seguro do context (showModalBottomSheet)
    if (myProducts.isNotEmpty) {
      showModalBottomSheet(
        context: context, // O linter agora entende que este 'context'
        // pertence ao State que tem o 'mounted'
        isScrollControlled: true,
        builder: (BuildContext context) {
          return const AuctionCreationWidget();
        },
      );
    }
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
    setState(() {
      _fetchAuctionsWithPagination();
    });
  }

  @override
  void dispose() {
    _researchController.dispose();
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
                children: [
                  /** 
                  ElevatedButton.icon(
                    onPressed: () => _fetchAuctionsWithPagination(),
                    label: Icon(Icons.refresh),
                    icon: Text('Atualizar'),
                  ),
                  */
                  const MainMenuWidget(currentRoute: '/home'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          'Leilões ${_filterByStatus.displayName}s',
                          style: const TextStyle(
                            fontSize: 37,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Flexible(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          spacing: 16.0,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              width: MediaQuery.of(context).size.width * 0.22,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8.0),
                                border: Border.all(color: Colors.grey),
                              ),
                              child: TextField(
                                controller: _researchController,
                                onChanged: (value) {
                                  currentFilters.productName =
                                      _researchController.text;
                                  _pagination.page = 0;
                                  setState(() {
                                    _fetchAuctionsWithPagination();
                                  });
                                },
                                decoration: const InputDecoration(
                                  label: Text(
                                    'Buscar leilões...',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(
                                  255,
                                  22,
                                  163,
                                  74,
                                ),
                                foregroundColor: Colors.white,
                                fixedSize: Size(
                                  MediaQuery.of(context).size.width * 0.13,
                                  50,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 16,
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
                  const Divider(color: Colors.grey),
                  /** 
                  Row(
                    children: [
                      DropdownMenu<dynamic>(
                        enableSearch: false,
                        width: MediaQuery.of(context).size.width * 0.2,
                        enableFilter: true,
                        onSelected: (value) {},
                        menuHeight: MediaQuery.of(context).size.height * 0.3,
                        label: Text('Filtro por Preço/Lance'),
                        dropdownMenuEntries: AuctionFilterOptions.values
                            .where(
                              (element) =>
                                  element.name.contains('Price') ||
                                  element.name.contains('Bid'),
                            )
                            .map(
                              (e) => DropdownMenuEntry(
                                value: e,
                                label: e.displayName,
                              ),
                            )
                            .toList(),
                      ),
                      DropdownMenu<dynamic>(
                        enableSearch: false,
                        width: MediaQuery.of(context).size.width * 0.2,
                        enableFilter: true,
                        onSelected: (value) {},
                        menuHeight: MediaQuery.of(context).size.height * 0.3,
                        label: Text('Filtro por Tempo'),
                        dropdownMenuEntries: AuctionFilterOptions.values
                            .where((element) => element.name.contains('Time'))
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
                 */
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
                                    (auction.endTime.isAfter(DateTime.now()));
                              })
                              .map(
                                (auctionDynamic) => auctionDynamic as Auction,
                              )
                              .toList();

                          return RefreshIndicator(
                            onRefresh: _refreshAuctions,
                            child: GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    mainAxisExtent: 365,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 10,
                                  ),
                              itemCount: auctions.length,
                              itemBuilder: (context, index) {
                                final auction = auctions[index];

                                return AuctionListWidget(
                                  auction: auction,
                                  updateList: () async {
                                    setState(() {
                                      _fetchAuctionsWithPagination();
                                    });
                                  },
                                );
                              },
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          if (_pagination.page != 0) {
                            setState(() {
                              _pagination.page -= 1;
                              _fetchAuctionsWithPagination();
                            });
                          }
                        },
                        label: const Icon(Icons.arrow_left),
                      ),
                      FutureBuilder<PaginatedResponse<Auction>>(
                        future: _auctionsFuture,
                        builder: (context, snapshot) => Text(
                          '${_pagination.page + 1} de ${_totalPages == 0 ? '1' : _totalPages}',
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () async {
                          if (_totalPages > _pagination.page + 1) {
                            setState(() {
                              _pagination.page += 1;
                              _fetchAuctionsWithPagination();
                            });
                          }
                        },
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
