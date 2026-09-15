import 'package:dio/dio.dart';

import 'auth_api.dart' show AuthApiException, NetworkException;
import 'http.dart' show newDio;
import 'secure_store.dart';

/// The server's sales endpoints the till calls directly. A sale itself syncs
/// through the outbox; a void is the server's decision about money and stock,
/// so it is asked for online (docs/domain/sales.md).
/// A return the server recorded: a new sale naming the one it takes goods
/// back from. Amounts are positive: what it was worth, and what the shop paid
/// out (the rest came off the customer's account).
final class RefundDone {
  const RefundDone({required this.id, required this.number, required this.totalMinor, required this.moneyBackMinor});
  final String id;
  final String number;
  final int totalMinor;
  final int moneyBackMinor;
}

abstract interface class SalesApi {
  /// Voids a settled sale (sale.void). Its reversal reaches this device with
  /// the next pull.
  Future<void> voidSale(String saleId, {required String reason});

  /// Takes [lines] (quantities by product, in their unit's minor units) back
  /// from a settled sale (sale.void). Money goes back by [method]: 'cash' from
  /// [shiftId]'s drawer, or 'card' or 'transfer'.
  Future<RefundDone> refundSale(
    String saleId, {
    required Map<String, int> lines,
    required String reason,
    required String method,
    String? shiftId,
  });
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
  Future<void> voidSale(String saleId, {required String reason}) =>
      _call(() async => _dio.post('/sales/${Uri.encodeComponent(saleId)}/void', data: {'reason': reason}, options: await _opts()));

  @override
  Future<RefundDone> refundSale(
    String saleId, {
    required Map<String, int> lines,
    required String reason,
    required String method,
    String? shiftId,
  }) async {
    final r = await _call(() async => _dio.post(
          '/sales/${Uri.encodeComponent(saleId)}/refunds',
          data: {
            'lines': [for (final e in lines.entries) {'product_id': e.key, 'qty_minor': e.value}],
            'reason': reason,
            'method': method,
            'shift_id': shiftId,
          },
          options: await _opts(),
        ));
    final j = (r.data as Map).cast<String, dynamic>();
    return RefundDone(
      id: j['id'] as String,
      number: j['number'] as String,
      totalMinor: -((j['total_minor'] as num).toInt()),
      moneyBackMinor: -((j['paid_minor'] as num).toInt()),
    );
  }

  /// A refusal keeps the server's code; anything else is the network.
  Future<Response<dynamic>> _call(Future<Response<dynamic>> Function() request) async {
    try {
      return await request();
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
