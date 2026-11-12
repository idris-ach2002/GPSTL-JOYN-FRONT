import 'dart:convert';

import '../../../core/network/api_client.dart';
import '../../recruiter_workspace/data/recruiter_workspace_repository.dart';
import 'studio_store.dart';

abstract interface class StudioRepository {
  Future<Map<String, dynamic>> load(String userId);
  Future<Map<String, dynamic>> patch(
    String userId,
    Map<String, dynamic> changes,
  );
}

class LocalStudioRepository implements StudioRepository {
  LocalStudioRepository(this.store);
  final StudioStore store;
  @override
  Future<Map<String, dynamic>> load(String userId) async {
    final value = await store.read('joyn.studio.v2.$userId');
    return value == null
        ? {}
        : Map<String, dynamic>.from(jsonDecode(value) as Map);
  }

  @override
  Future<Map<String, dynamic>> patch(
    String userId,
    Map<String, dynamic> changes,
  ) async {
    final value = {...await load(userId), ...changes};
    await store.write('joyn.studio.v2.$userId', jsonEncode(value));
    return value;
  }
}

class ApiStudioRepository implements StudioRepository {
  ApiStudioRepository(this.api);
  final ApiClient api;
  static const path = '/api/v1/recruiters/workspace';
  @override
  Future<Map<String, dynamic>> load(String userId) async =>
      apiObject(await api.getJson(path));
  @override
  Future<Map<String, dynamic>> patch(
    String userId,
    Map<String, dynamic> changes,
  ) async {
    final response = await api.patchJson(path, body: changes);
    return response == null ? load(userId) : apiObject(response);
  }
}
