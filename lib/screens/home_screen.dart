import 'package:flutter/material.dart';
import '../helpers/database_helper.dart';
import '../models/food_item.dart';
import 'order_details_screen.dart';

/// Main screen for creating new food orders
/// Allows users to select date, target cost, and food items
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Controllers for input fields
  late TextEditingController _targetCostController;
  late TextEditingController _dateController;

  // State variables to track order details
  double _targetCost = 0.0;
  String _selectedDate = '';
  List<FoodItem> _foodItems = [];         // All available food items
  List<FoodItem> _selectedFoodItems = []; // Items selected for current order

  /// Initialize controllers and load food items from database
  @override
  void initState() {
    super.initState();
    _targetCostController = TextEditingController();
    _dateController = TextEditingController();
    _loadFoodItems();
  }

  /// Loads all available food items from database
  Future<void> _loadFoodItems() async {
    final foodItems = await DatabaseHelper.instance.fetchAllFoodItems();
    setState(() {
      _foodItems = foodItems;
    });
  }

  /// Saves the order plan to database after validation
  /// Creates entries in both order_plans and order_details tables
  Future<void> _saveOrderPlan() async {
    if (_selectedDate.isEmpty || _selectedFoodItems.isEmpty || _targetCost <= 0) {
      _showErrorMessage('Please fill in all fields and select food items.');
      return;
    }

    final orderPlanId = await DatabaseHelper.instance.insertOrderPlan(
      _selectedDate,
      _targetCost,
    );

    await DatabaseHelper.instance.insertOrderDetails(orderPlanId, _selectedFoodItems);

    _showSuccessMessage('Order plan saved successfully!');
    _resetSelections();
  }

  /// Resets all form fields and selections after successful order
  void _resetSelections() {
    setState(() {
      _targetCost = 0.0;
      _selectedDate = '';
      _selectedFoodItems.clear();
      _targetCostController.clear();
      _dateController.clear();
    });
  }

  /// Shows error message in red snackbar
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  /// Shows success message in green snackbar
  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  /// Opens date picker and formats selected date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2025),
    );
    
    if (picked != null) {
      setState(() {
        _selectedDate = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
        _dateController.text = _selectedDate;
      });
    }
  }

  /// Calculates total cost of currently selected items
  double _calculateTotalCost() {
    return _selectedFoodItems.fold(0, (sum, item) => sum + item.cost);
  }

  /// Checks if adding an item would exceed the target cost
  bool _wouldExceedTarget(FoodItem item) {
    return (_calculateTotalCost() + item.cost) > _targetCost;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Food Ordering App')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _dateController,
                  decoration: const InputDecoration(
                    labelText: 'Enter Order Date (YYYY-MM-DD)',
                  ),
                  onChanged: (text) {
                    setState(() {
                      _selectedDate = text;
                    });
                  },
                ),
                SizedBox(height: 8),
                TextField(
                  controller: _targetCostController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Enter Target Cost',
                  ),
                  onChanged: (text) {
                    setState(() {
                      _targetCost = double.tryParse(text) ?? 0.0;
                    });
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'Select Food Items',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Total Selected: \$${_calculateTotalCost().toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              physics: ScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.5,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _foodItems.length,
              itemBuilder: (context, index) {
                final item = _foodItems[index];
                return Card(
                  child: InkWell(
                    onTap: () {
                      if (!_selectedFoodItems.contains(item)) {
                        if (_targetCost <= 0) {
                          _showErrorMessage('Please set a target cost first');
                          return;
                        }
                        if (_wouldExceedTarget(item)) {
                          _showErrorMessage('Adding this item would exceed your target cost');
                          return;
                        }
                        setState(() {
                          _selectedFoodItems.add(item);
                        });
                      } else {
                        setState(() {
                          _selectedFoodItems.remove(item);
                        });
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _selectedFoodItems.contains(item)
                              ? [Colors.purple.shade50, Colors.purple.shade100]
                              : [Colors.white, Colors.white],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            item.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple.shade700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 8),
                          Text(
                            '\$${item.cost.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Icon(
                            _selectedFoodItems.contains(item)
                                ? Icons.check_circle
                                : Icons.add_circle_outline,
                            color: _selectedFoodItems.contains(item)
                                ? Colors.purple
                                : Colors.grey,
                            size: 28,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _saveOrderPlan,
              child: const Text('Save Order Plan'),
            ),
          ),
        ],
      ),
    );
  }
}
