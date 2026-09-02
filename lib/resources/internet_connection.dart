import 'package:connectivity_plus/connectivity_plus.dart';

class Connection {
  static Future<bool> checkInternet() async {
    final resultados = await Connectivity().checkConnectivity();

    return resultados.any(
      (resultado) =>
          resultado == ConnectivityResult.mobile ||
          resultado == ConnectivityResult.wifi ||
          resultado == ConnectivityResult.ethernet,
    );
  }
}
