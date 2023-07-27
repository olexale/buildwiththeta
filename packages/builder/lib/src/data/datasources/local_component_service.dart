import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:theta/src/core/constants.dart';
import 'package:theta/src/data/models/get_page_response.dart';
import 'package:theta/src/data/models/preload_file.dart';
import 'package:theta/src/data/models/token.dart';

class LocalComponentService {
  const LocalComponentService(
    this._clientToken,
    this._preloadFile,
    this.cacheExtentionInSeconds,
    this.isCacheEnabled,
  );

  final ClientToken _clientToken;
  final PreloadFile _preloadFile;
  final int cacheExtentionInSeconds;
  final bool isCacheEnabled;

  Future<Box> getBox() async => await Hive.openBox('component_cache');

  Future<GetPageResponseEntity?> getLocalComponent(String componentName) async {
    if (!isCacheEnabled) {
      return null;
    }

    final box = await getBox();

    if (box.get(componentName) == null) {
      return null;
    }

    final cachedJson = json.decode(box.get(componentName));

    if (cachedJson == null) {
      return null;
    }

    // if the cached component is older than [cacheExtentionInSeconds] in seconds, return null
    final createdAt = cachedJson['created_at'];
    final now = DateTime.now().millisecondsSinceEpoch;
    final diff = now - createdAt;
    if (diff > 1000 * cacheExtentionInSeconds) {
      return null;
    }

    // if the cache is not expired, return it
    if (cachedJson != null) {
      return GetPageResponseEntity.fromJson(cachedJson);
    }
    return null;
  }

  void saveResponse(
      String componentName, GetPageResponseEntity pageResponseEntity) async {
    final box = await getBox();
    box.put(
        componentName,
        json.encode({
          ...pageResponseEntity.toJson(),
          'created_at': DateTime.now().millisecondsSinceEpoch,
        }));
  }

  void clearCache() async {
    final box = await getBox();
    box.clear();
  }

  Future<GetPageResponseEntity> getPreloadedComponent(
      String componentName) async {
    final res = _preloadFile.customJson ??
        jsonDecode(await rootBundle.loadString('assets/theta_preload.json'));
    return GetPageResponseEntity.fromJson(
        jsonDecode(decompressAndDecrypt(_clientToken.key, res[componentName])));
  }
}
