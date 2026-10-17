import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  // =========================
  // LẤY DATABASE
  // =========================
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDB('expense_manager.db');

    return _database!;
  }

  // =========================
  // KHỞI TẠO DATABASE
  // =========================
  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();

    final path = join(
      dbPath,
      fileName,
    );

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  // =========================
  // TẠO BẢNG
  // =========================
  Future<void> _createDB(
      Database db,
      int version,
      ) async {
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        category TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        note TEXT
      )
    ''');
  }

  // =========================
  // THÊM GIAO DỊCH
  // =========================
  Future<int> insertTransaction(
      Map<String, dynamic> transaction,
      ) async {
    final db = await database;

    return await db.insert(
      'transactions',
      transaction,
    );
  }

  // =========================
  // LẤY TẤT CẢ GIAO DỊCH
  // =========================
  Future<List<Map<String, dynamic>>> getTransactions() async {
    final db = await database;

    return await db.query(
      'transactions',
      orderBy: 'id DESC',
    );
  }

  // =========================
  // LẤY 1 GIAO DỊCH
  // =========================
  Future<Map<String, dynamic>?> getTransaction(
      int id,
      ) async {
    final db = await database;

    final result = await db.query(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return result.first;
    }

    return null;
  }

  // =========================
  // SỬA GIAO DỊCH
  // =========================
  Future<int> updateTransaction(
      int id,
      Map<String, dynamic> transaction,
      ) async {
    final db = await database;

    return await db.update(
      'transactions',
      transaction,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // =========================
  // XÓA GIAO DỊCH
  // =========================
  Future<int> deleteTransaction(
      int id,
      ) async {
    final db = await database;

    return await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // =========================
  // TỔNG THU NHẬP
  // =========================
  Future<double> getTotalIncome() async {
    final db = await database;

    final result = await db.rawQuery('''
      SELECT SUM(amount) AS total
      FROM transactions
      WHERE type = 'income'
    ''');

    return (result.first['total'] as num?)?.toDouble() ?? 0;
  }

  // =========================
  // TỔNG CHI TIÊU
  // =========================
  Future<double> getTotalExpense() async {
    final db = await database;

    final result = await db.rawQuery('''
      SELECT SUM(amount) AS total
      FROM transactions
      WHERE type = 'expense'
    ''');

    return (result.first['total'] as num?)?.toDouble() ?? 0;
  }

  // =========================
  // SỐ DƯ
  // =========================
  Future<double> getBalance() async {
    final income = await getTotalIncome();
    final expense = await getTotalExpense();

    return income - expense;
  }

  // =========================
  // ĐÓNG DATABASE
  // =========================
  Future<void> close() async {
    final db = await database;

    await db.close();

    _database = null;
  }
}