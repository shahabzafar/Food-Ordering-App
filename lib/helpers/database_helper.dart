import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/food_item.dart';

/// DatabaseHelper handles all interactions with the SQLite database.
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  DatabaseHelper._privateConstructor();

  /// Getter for the database instance.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize the database.
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'food_ordering.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onUpgrade: _onUpgradeDB,  // Handle upgrades to the database schema
    );
  }

  /// Create the database and tables.
  Future<void> _createDB(Database db, int version) async {
    await db.execute(''' 
      CREATE TABLE food_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        cost REAL NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE order_plans (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        target_cost REAL NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE order_details (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_plan_id INTEGER NOT NULL,
        food_item_id INTEGER NOT NULL,
        FOREIGN KEY (order_plan_id) REFERENCES order_plans (id),
        FOREIGN KEY (food_item_id) REFERENCES food_items (id)
      )
    ''');

    // Insert default food items into the database
    await _insertDefaultFoodItems(db);
  }

  /// Upgrade database if schema version changes (handle future migrations)
  Future<void> _onUpgradeDB(Database db, int oldVersion, int newVersion) async {
    // Clear the existing food items and reinsert the defaults on upgrade
    await db.delete('food_items');  // Clear existing food items
    await _insertDefaultFoodItems(db);  // Reinsert default items
  }

  /// Insert default food items into the database
  Future<void> _insertDefaultFoodItems(Database db) async {
    const defaultItems = [
      {'name': 'Pizza Margherita', 'cost': 12.99},
      {'name': 'Chicken Burger', 'cost': 8.99},
      {'name': 'Caesar Salad', 'cost': 7.50},
      {'name': 'Spaghetti Carbonara', 'cost': 11.99},
      {'name': 'Fish and Chips', 'cost': 13.50},
      {'name': 'Vegetable Stir Fry', 'cost': 9.99},
      {'name': 'Grilled Chicken', 'cost': 12.50},
      {'name': 'Beef Burrito', 'cost': 10.99},
      {'name': 'Mushroom Risotto', 'cost': 11.50},
      {'name': 'Greek Salad', 'cost': 8.50},
      {'name': 'Chicken Wings', 'cost': 9.99},
      {'name': 'Veggie Sandwich', 'cost': 6.99},
      {'name': 'Shrimp Pasta', 'cost': 14.99},
      {'name': 'BBQ Ribs', 'cost': 16.99},
      {'name': 'Tofu Curry', 'cost': 10.50},
      {'name': 'Salmon Fillet', 'cost': 15.99},
      {'name': 'Chicken Wrap', 'cost': 7.99},
      {'name': 'Beef Lasagna', 'cost': 13.99},
      {'name': 'Vegetable Soup', 'cost': 5.99},
      {'name': 'Tuna Sandwich', 'cost': 6.99},
    ];

    for (var item in defaultItems) {
      await db.insert('food_items', item);
    }
  }

  /// Fetch all food items from the database.
  Future<List<FoodItem>> fetchAllFoodItems() async {
    final db = await database;
    final maps = await db.query('food_items');
    return maps.map((map) => FoodItem.fromMap(map)).toList();
  }

  /// Insert a new food item into the database.
  Future<int> insertFoodItem(FoodItem foodItem) async {
    final db = await database;
    return await db.insert('food_items', foodItem.toMap());
  }

  /// Update an existing food item in the database.
  Future<int> updateFoodItem(FoodItem foodItem) async {
    final db = await database;
    return await db.update(
      'food_items',
      foodItem.toMap(),
      where: 'id = ?',
      whereArgs: [foodItem.id],
    );
  }

  /// Delete a food item from the database.
  Future<int> deleteFoodItem(int id) async {
    final db = await database;
    return await db.delete(
      'food_items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Insert a new order plan.
  Future<int> insertOrderPlan(String date, double targetCost) async {
    final db = await database;
    return await db.insert('order_plans', {
      'date': date,
      'target_cost': targetCost,
    });
  }

  /// Fetch order details for a given date.
  Future<Map<String, dynamic>?> fetchOrderPlanForDate(String date) async {
    final db = await database;
    final plan = await db.query(
      'order_plans',
      where: 'date = ?',
      whereArgs: [date],
      limit: 1,
    );

    if (plan.isEmpty) return null;

    final orderPlanId = plan.first['id'];
    final targetCost = plan.first['target_cost'];

    final details = await db.query(
      'order_details',
      where: 'order_plan_id = ?',
      whereArgs: [orderPlanId],
    );

    final items = <FoodItem>[];
    for (var detail in details) {
      final itemId = detail['food_item_id'];
      final foodItemMap = await db.query(
        'food_items',
        where: 'id = ?',
        whereArgs: [itemId],
      );

      if (foodItemMap.isNotEmpty) {
        items.add(FoodItem.fromMap(foodItemMap.first));
      }
    }

    return {
      'targetCost': targetCost,
      'items': items,
    };
  }

  /// Insert order details for a given order plan.
  Future<void> insertOrderDetails(int orderPlanId, List<FoodItem> items) async {
    final db = await database;

    for (var item in items) {
      await db.insert('order_details', {
        'order_plan_id': orderPlanId,
        'food_item_id': item.id,
      });
    }
  }

  Future<List<Map<String, dynamic>>> fetchAllOrderPlans() async {
    final db = await database;
    return await db.query('order_plans', orderBy: 'date DESC');
  }

  Future<List<Map<String, dynamic>>> fetchAllOrderPlansWithDetails() async {
    final db = await database;
    final List<Map<String, dynamic>> plans = await db.query(
      'order_plans',
      orderBy: 'date DESC',
    );

    List<Map<String, dynamic>> result = [];
    for (var plan in plans) {
      final orderPlanId = plan['id'];
      final details = await fetchOrderPlanForDate(plan['date'] as String);
      
      result.add({
        ...plan,
        'items': details?['items'] ?? [],
        'total_items': (details?['items'] as List?)?.length ?? 0,
      });
    }
    
    return result;
  }

  Future<void> deleteOrderPlan(String date) async {
    final db = await database;
    await db.delete(
      'order_plans',
      where: 'date = ?',
      whereArgs: [date],
    );
    await db.delete(
      'order_details',
      where: 'order_plan_id IN (SELECT id FROM order_plans WHERE date = ?)',
      whereArgs: [date],
    );
  }
}
