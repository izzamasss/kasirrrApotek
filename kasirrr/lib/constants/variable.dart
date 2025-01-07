import 'package:apotek/models/pengguna.dart';
import 'package:intl/intl.dart';

class Variable {
  static const String serverUrl = 'https://4003-120-188-78-221.ngrok-free.app';
  static const String baseUrl = '$serverUrl/api';
  static const headers = {'Content-Type': 'application/json'};

  static final formatRupiah = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static Pengguna? pengguna;
}
