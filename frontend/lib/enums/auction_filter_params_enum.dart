enum AuctionFilterParamsEnum {
  all('Tudo'),
  productName('Nome do Produto'),
  sellerName('Nome do Vendedor'),
  minCurrentBid('Menor Lance Mínimo Atual'),
  maxCurrentBid('Maior Lance Mínimo Atual'),
  minInitialPrice('Menor Preço Inicial'),
  maxInitialPrice('Maior Preço Inicial');

  const AuctionFilterParamsEnum(this.displayName);

  final String displayName;
}
