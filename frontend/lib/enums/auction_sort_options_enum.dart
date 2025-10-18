enum AuctionSortOptionsEnum {
  none('N/A'),
  initialPrice('Preço Inicial'),
  currentBid('Lance Atual'),
  endDateAndTime('Data de Término');

  const AuctionSortOptionsEnum(this.displayName);

  final String displayName;

  @override
  String toString() => name;
}
