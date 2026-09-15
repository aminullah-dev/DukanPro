import 'package:dio/dio.dart';

import 'auth_api.dart' show AuthApiException, NetworkException;
import 'http.dart' show newDio;
import 'secure_store.dart';

/// The server's sales endpoints the till calls directly. A sale itself syncs
/// through the outbox; a void is the server's decision about money and stock,
/// so it is asked for online (docs/domain/sales.md).
abstract interface class SalesApi {
  /// Voids a settled sale (sale.void). Its reversal reaches this device with
  /// the next pull.
  Future<void> voidSale(String saleId, {required String reason});
}

/// Dio-backed [SalesApi]. Bearer from secure storage.
class DioSalesApi implements SalesApi {
  DioSalesApi({required String baseUrl, required this.store, Dio? dio}) : _dio = dio ?? newDio(baseUrl);
  final Dio _dio;
  final SecureStore store;

  Future<Options> _opts() async {
    final token = await store.read(SecureKeys.accessToken);
    return Options(headers: {if (token != null) 'authorization': 'Bearer $token'});
  }

  @override
  Future<void> voidSale(String saleId, {required String reason}) async {
    try {
      await _dio.post('/sales/${Uri.encodeComponent(saleId)}/void', data: {'reason': reason}, options: await _opts());
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map && data['error'] is Map) {
        final err = (data['error'] as Map).cast<String, dynamic>();
        throw AuthApiException((err['code'] as String?) ?? 'UNKNOWN', statusCode: e.response?.statusCode);
      }
      throw const NetworkException();
    }
  }
}
