import 'package:intl/intl.dart';

final _currencyFormat = NumberFormat.decimalPattern('tr_TR');

String formatCurrency(double? amount) {
  if (amount == null) return '-';
  return '${_currencyFormat.format(amount)} TL';
}
