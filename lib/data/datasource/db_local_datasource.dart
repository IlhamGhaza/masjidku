import 'package:shared_preferences/shared_preferences.dart';

import '../model/bookmark_model.dart';
import 'db_helper.dart';

class DbLocalDatasource {
  
  Future<void> saveBookmark(BookmarkModel model) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('surat', model.suratName);
    await prefs.setInt('suratNumber', model.suratNumber);
    await prefs.setInt('ayatNumber', model.ayatNumber);
  }

  Future<BookmarkModel?> getBookmark() async {
    final prefs = await SharedPreferences.getInstance();
    final surat = prefs.getString('surat');
    final suratNumber = prefs.getInt('suratNumber');
    final ayatNumber = prefs.getInt('ayatNumber');
    if (surat != null && suratNumber != null && ayatNumber != null) {
      return BookmarkModel(surat, suratNumber, ayatNumber);
    }
    return null;
  }

  Future<void> saveLatLng(double lat, double lng) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('lat', lat);
    await prefs.setDouble('lng', lng);
  }

  Future<List<double>> getLatLng() async {
    final prefs = await SharedPreferences.getInstance();
    final lat = prefs.getDouble('lat');
    final lng = prefs.getDouble('lng');
    if (lat != null && lng != null) {
      return [lat, lng];
    }
    return [];
  }

  //bookmark with sqflite
   Future<int> saveBookmarkWithSqlite(BookmarkModel model) async {
    final db = await DbHelper.instance.database;
    return await db.insert('bookmark', {
      'surat': model.suratName,
      'suratNumber': model.suratNumber,
      'ayatNumber': model.ayatNumber,
    });
  }
  
  Future<List<BookmarkModel>> getAllBookmarks() async {
    final db = await DbHelper.instance.database;
    final result = await db.query('bookmark', orderBy: 'createdAt DESC');
    
    return result.map((json) => BookmarkModel(
      json['surat'] as String,
      json['suratNumber'] as int,
      json['ayatNumber'] as int,
    )).toList();
  }
  
  Future<BookmarkModel?> getBookmarkBySurat(int suratNumber) async {
    final db = await DbHelper.instance.database;
    final maps = await db.query(
      'bookmark',
      where: 'suratNumber = ?',
      whereArgs: [suratNumber],
    );
    
    if (maps.isNotEmpty) {
      return BookmarkModel(
        maps.first['surat'] as String,
        maps.first['suratNumber'] as int,
        maps.first['ayatNumber'] as int,
      );
    }
    return null;
  }
  
  Future<int> deleteBookmark(int suratNumber) async {
    final db = await DbHelper.instance.database;
    return await db.delete(
      'bookmark',
      where: 'suratNumber = ?',
      whereArgs: [suratNumber],
    );
  }
  
  Future<int> updateBookmark(BookmarkModel model) async {
    final db = await DbHelper.instance.database;
    return await db.update(
      'bookmark',
      {
        'surat': model.suratName,
        'ayatNumber': model.ayatNumber,
      },
      where: 'suratNumber = ?',
      whereArgs: [model.suratNumber],
    );
  }

}
