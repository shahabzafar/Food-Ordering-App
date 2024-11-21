// food_management.dart
import 'package:flutter/material.dart';
import 'helpers/database_helper.dart';
import 'models/food_item.dart';

/// FoodManagement screen to handle food item additions, updates, and deletions.
class FoodManagementScreen extends StatefulWidget {
  const FoodManagementScreen({Key? key}) : super(key: key);

  @override
  _FoodManagementScreenState createState() => _FoodManagementScreenState();
}

class _FoodManagementScreenState extends State<FoodManagementScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _costController = TextEditingController();

  List<FoodItem> _foodItems = [];
  int? _selectedFoodItemId;

  @override
  void initState() {
    super.initState();
    _fetchFoodItems();
  }

  /// Fetch all food items from the database.
  Future<void> _fetchFoodItems() async {
    final items = await _dbHelper.fetchAllFoodItems();
    setState(() {
      _foodItems = items;
    });
  }

  /// Add or update a food item.
  Future<void> _saveFoodItem() async {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text;
      final cost = double.tryParse(_costController.text) ?? 0.0;

      if (_selectedFoodItemId == null) {
        // Add a new food item
        await _dbHelper.insertFoodItem(FoodItem(name: name, cost: cost));
      } else {
        // Update an existing food item
        final updatedFoodItem = FoodItem(
          id: _selectedFoodItemId,
          name: name,
          cost: cost,
        );
        await _dbHelper.updateFoodItem(updatedFoodItem);
      }

      _nameController.clear();
      _costController.clear();
      _selectedFoodItemId = null;

      _fetchFoodItems();
    }
  }

  /// Delete a food item.
  Future<void> _deleteFoodItem(int id) async {
    await _dbHelper.deleteFoodItem(id);
    _fetchFoodItems();
  }

  /// Populate fields for updating an item.
  void _editFoodItem(FoodItem item) {
    _nameController.text = item.name;
    _costController.text = item.cost.toString();
    setState(() {
      _selectedFoodItemId = item.id;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Food Management'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(labelText: 'Food Name'),
                      validator: (value) =>
                          value!.isEmpty ? 'Name cannot be empty' : null,
                    ),
                    TextFormField(
                      controller: _costController,
                      decoration: InputDecoration(labelText: 'Cost'),
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          double.tryParse(value!) == null ? 'Invalid cost' : null,
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _saveFoodItem,
                      child: Text(
                        _selectedFoodItemId == null ? 'Add Food Item' : 'Update',
                      ),
                    ),
                  ],
                ),
              ),
              Divider(),
              Container(
                height: 500, // Fixed height for the list
                child: ListView.builder(
                  itemCount: _foodItems.length,
                  itemBuilder: (context, index) {
                    final item = _foodItems[index];
                    return ListTile(
                      title: Text('${item.name} (\$${item.cost.toStringAsFixed(2)})'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () => _editFoodItem(item),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => _deleteFoodItem(item.id!),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
