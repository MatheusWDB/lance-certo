// ignore_for_file: constant_identifier_names

enum AuctionStatus {
  PENDING('Pendente', 0),
  ACTIVE('Ativo', 1),
  CLOSED('Fechado', 2),
  CANCELLED('Cancelado', 3);

  final String displayName;
  final int code;

  const AuctionStatus(this.displayName, this.code);

  static AuctionStatus fromCode(int code) {
    return AuctionStatus.values.firstWhere(
      (e) => e.code == code,
      orElse: () => throw ArgumentError('Código inválido: $code'),
    );
  }

  static AuctionStatus fromString(String name) {
    return AuctionStatus.values.firstWhere(
      (e) => e.name == name.toUpperCase(),
      orElse: () => throw ArgumentError('Tipo inválido: $name'),
    );
  }

  @override
  String toString() => name;
}
