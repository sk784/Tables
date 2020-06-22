import 'dart:io';
import 'package:employeers/data/child.dart';
import 'package:employeers/data/employer.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseProvider {

  DatabaseProvider._();

  static final DatabaseProvider db = DatabaseProvider._();
  Database _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database;
    }

    _database = await initDB();
    return _database;
  }

  initDB() async {
    Directory documentsDir = await getApplicationDocumentsDirectory();
    String path = join(documentsDir.path, 'employers.db');
    return await openDatabase(path, version: 1, onOpen: (db) async {
    }, onCreate: (Database db, int version) async {
      await db.execute(
          'CREATE TABLE employers (id INTEGER PRIMARY KEY, first_name TEXT, last_name TEXT, middle_name TEXT,'
              'position TEXT, children INTEGER, birthday TEXT)'
      );
      await db.execute(
          'CREATE TABLE children (id INTEGER PRIMARY KEY, first_name TEXT, last_name TEXT, middle_name TEXT,'
              'parent_id INTEGER, birthday TEXT)'
      );
    });
  }

  Future addEmployer(Employer employer) async {
    final db = await database;
    var result = await db.insert('employers', employer.toJson(),conflictAlgorithm: ConflictAlgorithm.replace);
    return result;
  }

  Future<List<Employer>> getEmployers() async {
    final db = await database;
    var res = await db.query("employers");
    List<Employer> list =
    res.isNotEmpty ? res.map((c) => Employer.fromJson(c)).toList() : [];
    return list;
  }

  Future addChild(Child child, int id) async {
    final db = await database;
    var result = await db.insert('children', child.toJson(),conflictAlgorithm: ConflictAlgorithm.replace);
    var calculate = await calculateQuantityOfChildren(id);
    var addQuantity = await db.rawUpdate('UPDATE employers SET children = $calculate WHERE id = $id');
    return result;
  }

  Future<List<Child>> getChildren(int id) async {
    final db = await database;
    var res = await db.rawQuery('SELECT * FROM children WHERE parent_id=$id');
    List<Child> list =
    res.isNotEmpty ? res.map((c) => Child.fromJson(c)).toList() : [];
    return list;
  }


  Future<int> calculateQuantityOfChildren(int id) async {
    final db = await database;
    var result = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM children WHERE parent_id=$id'));
    return result;
  }
}

