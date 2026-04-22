import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/diary_entry.dart';

class DiaryRepository {
  DiaryRepository(this._firestore);

  final FirebaseFirestore _firestore;
  Database? _database;

  Future<Database> get _db async {
    final database = _database;
    if (database != null) return database;

    final documents = await getApplicationDocumentsDirectory();
    final databasePath = p.join(documents.path, 'dailylingo.db');
    final opened = await openDatabase(
      databasePath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE diary_logs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id TEXT NOT NULL,
            date INTEGER NOT NULL,
            title TEXT NOT NULL,
            content TEXT NOT NULL,
            local_audio_path TEXT,
            wpm INTEGER NOT NULL
          )
        ''');
      },
    );
    _database = opened;
    return opened;
  }

  Future<List<DiaryEntry>> getEntries(String userId) async {
    final database = await _db;
    final rows = await database.query(
      'diary_logs',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );
    return rows.map(DiaryEntry.fromMap).toList();
  }

  Future<DiaryEntry?> getEntryById(int id) async {
    final database = await _db;
    final rows = await database.query(
      'diary_logs',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return DiaryEntry.fromMap(rows.first);
  }

  Future<int> saveEntry(DiaryEntry entry) async {
    final database = await _db;
    final values = entry.toMap()..remove('id');

    final id = entry.id == null
        ? await database.insert(
            'diary_logs',
            values,
            conflictAlgorithm: ConflictAlgorithm.replace,
          )
        : await database
              .update(
                'diary_logs',
                values,
                where: 'id = ?',
                whereArgs: [entry.id],
                conflictAlgorithm: ConflictAlgorithm.replace,
              )
              .then((_) => entry.id!);

    await _firestore
        .collection('users')
        .doc(entry.userId)
        .collection('diary_logs')
        .doc(id.toString())
        .set({
          'title': entry.title,
          'content': entry.content,
          'date': Timestamp.fromDate(entry.date),
          'wpm': entry.wpm,
          'localAudioPath': entry.localAudioPath,
        });

    return id;
  }

  Future<void> deleteEntry(DiaryEntry entry) async {
    final database = await _db;
    if (entry.id != null) {
      await database.delete(
        'diary_logs',
        where: 'id = ?',
        whereArgs: [entry.id],
      );
      await _firestore
          .collection('users')
          .doc(entry.userId)
          .collection('diary_logs')
          .doc(entry.id.toString())
          .delete();
    }

    final audioPath = entry.localAudioPath;
    if (audioPath != null && audioPath.isNotEmpty) {
      final file = File(audioPath);
      if (await file.exists()) {
        await file.delete();
      }
    }
  }

  Future<String> createRecordingPath(String userId) async {
    final directory = await getApplicationDocumentsDirectory();
    final recordings = Directory(p.join(directory.path, 'recordings', userId));
    if (!await recordings.exists()) {
      await recordings.create(recursive: true);
    }
    final name = 'dailylingo_${DateTime.now().millisecondsSinceEpoch}.m4a';
    return p.join(recordings.path, name);
  }
}
