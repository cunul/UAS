import 'package:project_app/database/database_queries/address_query.dart';
import 'package:project_app/database/database_queries/cart_query.dart';
import 'package:project_app/database/database_queries/order_products_query.dart';
import 'package:project_app/database/database_queries/order_query.dart';
import 'package:project_app/models/order.dart';
import 'package:sqflite/sqflite.dart' as sqlite;
import 'package:sqflite/sqlite_api.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as path;

class DbHelper {
  //membuat method singleton
  static final DbHelper _dbHelper = DbHelper._singleton();

  factory DbHelper() {
    return _dbHelper;
  }

  DbHelper._singleton();

  //baris terakhir singleton

  final tables = [
    CartQuery.CREATE_TABLE,
    AddressQuery.CREATE_TABLE,
    OrderQuery.CREATE_TABLE,
    OrderProductsQuery.CREATE_TABLE
  ]; // membuat daftar table yang akan dibuat

  Future<Database> openDB() async {
    final dbPath = await sqlite.getDatabasesPath();
    return sqlite.openDatabase(path.join(dbPath, 'project_app.db'),
        onCreate: (db, version) async {
      for (var table in tables) {
        await db.execute(table).then((value) {
          print("success");
        }).catchError((err) {
          print("error: ${err.toString()}");
        });
      }
      print('Table Created');
    }, version: 1);
  }

  insert(String table, Map<String, dynamic> data) {
    openDB().then((db) {
      db.insert(table, data, conflictAlgorithm: ConflictAlgorithm.replace);
    }).catchError((err) {
      print("error $err");
    });
  }

  delete(String table, int id) {
    openDB().then((db) {
      db.delete(table, where: 'id = ?', whereArgs: [id]);
    }).catchError((err) {
      print("error $err");
    });
  }

  update(String table, Map<String, dynamic> data) {
    openDB().then((db) {
      db.update(table, data, where: 'id = ?', whereArgs: [data['id']]);
    }).catchError((err) {
      print("error $err");
    });
  }

  Future<List> getDataByUserId(String tableName, int idUser) async {
    final db = await openDB();
    var result =
        await db.query(tableName, where: 'userId=?', whereArgs: [idUser]);
    return result.toList();
  }

  Future<List> getAllData(String tableName) async {
    final db = await openDB();
    var result = await db.query(tableName);
    return result.toList();
  }

  Future<Order> getOrder(String orderNumber) async {
    final db = await openDB();
    var result = await db.query(OrderQuery.TABLE_NAME,
        where: 'orderNumber=?', whereArgs: [orderNumber]);
    return Order.fromJson(result.first);
  }

  Future<List> getOrderProducts(String orderNumber) async {
    final db = await openDB();
    var result = await db.query(OrderProductsQuery.TABLE_NAME,
        where: 'orderNumber=?', whereArgs: [orderNumber]);
    return result.toList();
  }
}
