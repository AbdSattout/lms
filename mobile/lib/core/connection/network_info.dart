import 'package:data_connection_checker_tv/data_connection_checker.dart';

import '../databases/api/end_points.dart';

abstract class NetworkInfo {
  Future<bool>? get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  final DataConnectionChecker connectionChecker;

  NetworkInfoImpl(this.connectionChecker);

  @override
  Future<bool>? get isConnected async {
    if (_usesLocalApiBaseUrl()) return true;

    return connectionChecker.hasConnection;
  }

  bool _usesLocalApiBaseUrl() {
    final uri = Uri.tryParse(EndPoints.baseUrl);
    if (uri == null || uri.scheme != 'http') return false;

    final host = uri.host.toLowerCase();
    if (host == 'localhost' || host == '127.0.0.1' || host == '10.0.2.2') {
      return true;
    }

    final octets = host.split('.').map(int.tryParse).toList();
    if (octets.length != 4 || octets.any((octet) => octet == null)) {
      return false;
    }

    final first = octets[0]!;
    final second = octets[1]!;
    return first == 10 ||
        (first == 172 && second >= 16 && second <= 31) ||
        (first == 192 && second == 168);
  }
}
