import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_client.dart';
import '../models/room_model.dart';

class RoomRemoteDataSource {
  final ApiClient _apiClient;

  RoomRemoteDataSource(this._apiClient);

  Future<List<RoomModel>> getRooms({String? property, String? status}) async {
    try {
      final params = <String, dynamic>{
        'order': 'room_number.asc',
      };
      if (property != null) params['property'] = 'eq.$property';
      if (status != null) params['status'] = 'eq.$status';

      final response = await _apiClient.get('/rooms', queryParameters: params);
      final list = response.data as List<dynamic>;
      return list
          .map((e) => RoomModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw AppException('Gagal memuat data kamar: $e');
    }
  }

  Future<RoomModel> getRoomById(String id) async {
    try {
      final response = await _apiClient.get(
        '/rooms',
        queryParameters: {'id': 'eq.$id', 'limit': '1'},
      );
      final list = response.data as List<dynamic>;
      if (list.isEmpty) throw const NotFoundException('Kamar tidak ditemukan');
      return RoomModel.fromJson(list.first as Map<String, dynamic>);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('Gagal memuat kamar: $e');
    }
  }

  Future<void> updateRoomStatus(String id, String status) async {
    try {
      await _apiClient.patch(
        '/rooms',
        data: {'status': status},
      );
    } catch (e) {
      throw AppException('Gagal update status kamar: $e');
    }
  }
}
