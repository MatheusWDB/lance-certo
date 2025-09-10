// ignore_for_file: constant_identifier_names

enum UserRole {
  BUYER('Comprador', 0),
  SELLER('Vendedor', 1),
  ADMIN('Administrador', 2);

  final String displayName;
  final int code;

  const UserRole(this.displayName, this.code);

  static UserRole fromCode(int code) {
    return UserRole.values.firstWhere(
      (e) => e.code == code,
      orElse: () => throw ArgumentError('Código inválido: $code'),
    );
  }

  static UserRole fromString(String name) {
    return UserRole.values.firstWhere(
      (e) => e.name == name.toUpperCase(),
      orElse: () => throw ArgumentError('Tipo inválido: $name'),
    );
  }

  @override
  String toString() => name;
}
