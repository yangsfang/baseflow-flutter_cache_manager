import 'dart:io';

import 'package:flutter_cache_manager/src/storage/cache_info_repositories/helper_methods.dart';
import 'package:hive/hive.dart';
import '../cache_object.dart';
import 'cache_info_repository.dart';

class HiveCacheObjectProvider extends CacheInfoRepository with CacheInfoRepositoryHelperMethods {
  Box<Map<String, dynamic>>? db;
  final String? _path;
  String databaseName;

  /// Initializes the Hive instance to store data.
  ///
  /// [path] is the path to the directory to the Hive file. Defaults to Application Directory
  /// [databaseName] is the HiveBox name
  HiveCacheObjectProvider({
    String? path,
    this.databaseName = 'flutter_cache_manager',
  }) : _path = path;

  @override
  Future<bool> open() async {
    if (!shouldOpenOnNewConnection()) {
      return openCompleter!.future;
    }
    var path = await _getPath();
    db = await Hive.openBox<Map<String, dynamic>>(databaseName, path: path);
    return opened();
  }

  @override
  Future<dynamic> updateOrInsert(CacheObject cacheObject) {
    if (cacheObject.id == null) {
      return insert(cacheObject);
    } else {
      return update(cacheObject);
    }
  }

  @override
  Future<CacheObject> insert(CacheObject cacheObject, {bool setTouchedToNow = true}) async {
    cacheObject = cacheObject.copyWith(id: cacheObject.key.hashCode);
    await db!.put(
      cacheObject.id!,
      cacheObject.toMap(setTouchedToNow: setTouchedToNow),
    );
    return cacheObject;
  }

  @override
  Future<CacheObject?> get(String key) async {
    final id = key.hashCode;
    Map<String, dynamic>? map = db!.get(id);
    if (map != null) {
      return CacheObject.fromMap(map);
    }
    return null;
  }

  @override
  Future<int> delete(int id) async {
    await db!.delete(id);
    return 1;
  }

  @override
  Future<int> deleteAll(Iterable<int> ids) async {
    await db!.deleteAll(ids);
    return ids.length;
  }

  @override
  Future<int> update(CacheObject cacheObject, {bool setTouchedToNow = true}) async {
    if (cacheObject.key.hashCode != cacheObject.id) {
      cacheObject = cacheObject.copyWith(id: cacheObject.key.hashCode);
    }
    await db!.put(
      cacheObject.id!,
      cacheObject.toMap(setTouchedToNow: setTouchedToNow),
    );
    return 1;
  }

  @override
  Future<List<CacheObject>> getAllObjects() async {
    return CacheObject.fromMapList(
      db!.values.toList(),
    );
  }

  @override
  Future<List<CacheObject>> getObjectsOverCapacity(int capacity) async {
    final list = db!.values.toList()
      ..sort((a, b) =>
          b[CacheObject.columnTouched] - a[CacheObject.columnTouched]); // from large to small
    final oldest100 = list.skip(capacity).toList().reversed.take(100).toList();
    return CacheObject.fromMapList(oldest100);
  }

  @override
  Future<List<CacheObject>> getOldObjects(Duration maxAge) async {
    var list = db!.values
        .where((item) =>
            item[CacheObject.columnTouched] <
            DateTime.now().subtract(maxAge).millisecondsSinceEpoch)
        .take(100)
        .toList();
    return CacheObject.fromMapList(list);
  }

  @override
  Future<bool> close() async {
    if (!shouldClose()) return false;
    await db!.close();
    return true;
  }

  @override
  Future<void> deleteDataFile() async {
    final path = await _getPath();
    await Hive.deleteBoxFromDisk(databaseName, path: path);
  }

  @override
  Future<bool> exists() async {
    final path = await _getPath();
    return Hive.boxExists(databaseName, path: path);
  }

  Future<String?> _getPath() async {
    Directory directory;
    if (_path != null) {
      directory = Directory(_path!);
      await directory.create(recursive: true);
      return directory.path;
    } else {
      return null;
    }
  }
}
