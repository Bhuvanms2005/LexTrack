import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class CaseDatabase {

  static Database? _database;

  static Future<Database> getDatabase() async {

    if (_database != null) return _database!;

    String path = join(await getDatabasesPath(), 'cases.db');

    _database = await openDatabase(
  path,
  version: 3,

  onCreate: (db, version) async {

    await db.execute('''
    CREATE TABLE cases(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      caseNumber TEXT,
      year TEXT,
      clientName TEXT,
      opponentName TEXT,
      courtName TEXT,
      caseType TEXT,
      hearingDate TEXT,
      totalFee TEXT,
      notes TEXT
    )
    ''');

    await db.execute('''
    CREATE TABLE hearings(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      caseId INTEGER,
      date TEXT,
      stage TEXT,
      notes TEXT,
      nextHearing TEXT
    )
    ''');

    await db.execute('''
    CREATE TABLE payments(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      caseId INTEGER,
      amount TEXT,
      date TEXT,
      method TEXT,
      notes TEXT
    )
    ''');

    await db.execute('''
    CREATE TABLE case_notes(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      caseId INTEGER,
      note TEXT,
      date TEXT
    )
    ''');

  },

  onUpgrade: (db, oldVersion, newVersion) async {

    if (oldVersion < 2) {
      await db.execute('''
      CREATE TABLE payments(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        caseId INTEGER,
        amount TEXT,
        date TEXT,
        method TEXT,
        notes TEXT
      )
      ''');
    }

    if (oldVersion < 3) {
      await db.execute('''
      CREATE TABLE hearings(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        caseId INTEGER,
        date TEXT,
        stage TEXT,
        notes TEXT,
        nextHearing TEXT
      )
      ''');

      await db.execute('''
      CREATE TABLE case_notes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        caseId INTEGER,
        note TEXT,
        date TEXT
      )
      ''');
    }

  },

);

    return _database!;
  }

  static Future<void> insertCase(Map<String, dynamic> data) async {
    final db = await getDatabase();
    await db.insert('cases', data);
  }

  static Future<List<Map<String,dynamic>>> getCases() async {
    final db = await getDatabase();
    return await db.query('cases', orderBy: 'id DESC');
  }

  static Future<void> insertPayment(Map<String,dynamic> data) async {
    final db = await getDatabase();
    await db.insert('payments', data);
  }

  static Future<void> insertHearing(Map<String,dynamic> data) async {
    final db = await getDatabase();
    await db.insert('hearings', data);
  }

  static Future<void> insertNote(Map<String,dynamic> data) async {
    final db = await getDatabase();
    await db.insert('case_notes', data);
  }
  static Future<void> updateNextHearing(int caseId, String nextDate) async {

  final db = await getDatabase();

  await db.update(
    'cases',
    {"hearingDate": nextDate},
    where: "id = ?",
    whereArgs: [caseId],
  );
}
static Future<List<Map<String,dynamic>>> getHearings(int caseId) async {

  final db = await getDatabase();

  return await db.query(
    'hearings',
    where: "caseId = ?",
    whereArgs: [caseId],
    orderBy: "id DESC",
  );

}
static Future<List<Map<String,dynamic>>> getPayments(int caseId) async {

  final db = await getDatabase();

  return await db.query(
    'payments',
    where: "caseId = ?",
    whereArgs: [caseId],
    orderBy: "id DESC",
  );

}
static Future<int> getTotalPayments(int caseId) async {

  final db = await getDatabase();

  var result = await db.rawQuery(
    "SELECT SUM(amount) as total FROM payments WHERE caseId = ?",
    [caseId]
  );

  if(result.first["total"] == null){
    return 0;
  }

  return int.parse(result.first["total"].toString());
}
static Future<List<Map<String,dynamic>>> getNotes(int caseId) async {

  final db = await getDatabase();

  return await db.query(
    'case_notes',
    where: "caseId = ?",
    whereArgs: [caseId],
    orderBy: "id DESC"
  );

}
static Future<void> updateCase(int id, Map<String,dynamic> data) async {

  final db = await getDatabase();

  await db.update(
    'cases',
    data,
    where: "id = ?",
    whereArgs: [id]
  );

}
static Future<Map<String,dynamic>> getCase(int id) async {

  final db = await getDatabase();

  final result = await db.query(
    'cases',
    where: "id = ?",
    whereArgs: [id]
  );

  return result.first;

}
/*static Future<List<Map<String,dynamic>>> getTodayHearings() async {

  final db = await getDatabase();

  DateTime now = DateTime.now();
  String today = "${now.day}/${now.month}/${now.year}";

  return await db.rawQuery('''
  SELECT cases.caseNumber, cases.year, cases.clientName, cases.courtName,
  hearings.stage, hearings.nextHearing
  FROM hearings
  INNER JOIN cases ON cases.id = hearings.caseId
  WHERE hearings.nextHearing = ?
  ''', [today]);

}*/
static Future<List<Map<String, dynamic>>> getAllHearingsWithCase() async {
  final db = await getDatabase();

  return await db.rawQuery('''
    SELECT hearings.*, cases.caseNumber, cases.year, cases.clientName, cases.courtName
    FROM hearings
    INNER JOIN cases ON hearings.caseId = cases.id
    ORDER BY hearings.date DESC
  ''');
}
static Future<List<Map<String, dynamic>>> getTodayHearingsWithCase() async {
  final db = await getDatabase();

  String today =
      "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}";

  return await db.rawQuery('''
    SELECT hearings.*, cases.caseNumber, cases.clientName
    FROM hearings
    INNER JOIN cases ON hearings.caseId = cases.id
    WHERE hearings.date = ?
  ''', [today]);
}
static Future<int> getTodayHearingsCount() async {
  final db = await getDatabase();

  String today =
      "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}";

  final result = await db.rawQuery(
    "SELECT COUNT(*) as count FROM hearings WHERE date = ?",
    [today],
  );

  return Sqflite.firstIntValue(result) ?? 0;
}

static Future<int> getTotalCasesCount() async {
  final db = await getDatabase();

  final result = await db.rawQuery(
    "SELECT COUNT(*) as count FROM cases",
  );

  return Sqflite.firstIntValue(result) ?? 0;
}

static Future<int> getTotalPendingFees() async {
  final db = await getDatabase();

  final totalFeeResult =
      await db.rawQuery("SELECT SUM(totalFee) as total FROM cases");

  final paidResult =
      await db.rawQuery("SELECT SUM(amount) as total FROM payments");

  int totalFee = (totalFeeResult.first['total'] as int?) ?? 0;
  int paid = (paidResult.first['total'] as int?) ?? 0;

  return totalFee - paid;
}
}