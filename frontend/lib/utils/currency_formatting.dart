import 'package:intl/intl.dart';

class CurrencyFormatting {
  static String currencyFormat(double? number) {
    final value = number ?? 0.0;
    return NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(value);
  }
}
