/// FoodItem model to represent food items in the app and database.
class FoodItem {
  final int? id; // Unique identifier for the food item, optional for new items
  final String name; // Name of the food item
  final double cost; // Cost of the food item

  FoodItem({this.id, required this.name, required this.cost});

  /// Convert a FoodItem instance to a map for database storage.
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'name': name,
      'cost': cost,
    };

    // Add ID only if it exists (useful for updates)
    if (id != null) {
      map['id'] = id;
    }

    return map;
  }

  /// Create a FoodItem instance from a map (used for retrieving data from the database).
  factory FoodItem.fromMap(Map<String, dynamic> map) {
    return FoodItem(
      id: map['id'] as int?,
      name: map['name'] as String,
      cost: map['cost'] as double,
    );
  }

  /// Debug-friendly string representation of a FoodItem.
  @override
  String toString() {
    return 'FoodItem(id: $id, name: $name, cost: $cost)';
  }
}
