import 'package:flutter/material.dart';
import '../helpers/database_helper.dart';
import 'order_details_screen.dart';

/// Screen that displays a list of all saved order plans
/// Allows viewing details and deletion of orders
class OrderPlansScreen extends StatefulWidget {
  @override
  _OrderPlansScreenState createState() => _OrderPlansScreenState();
}

class _OrderPlansScreenState extends State<OrderPlansScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<Map<String, dynamic>> _orderPlans = [];
  List<Map<String, dynamic>> _filteredPlans = []; // For search results
  final TextEditingController _searchController = TextEditingController();

  /// Loads order plans when screen is first opened
  @override
  void initState() {
    super.initState();
    _loadOrderPlans();
  }

  /// Fetches all order plans with their associated items from database
  Future<void> _loadOrderPlans() async {
    final plans = await _dbHelper.fetchAllOrderPlansWithDetails();
    setState(() {
      _orderPlans = plans;
      _filteredPlans = plans; // Initially show all plans
    });
  }

  /// Deletes an order plan and refreshes the list
  Future<void> _deleteOrderPlan(String date) async {
    await _dbHelper.deleteOrderPlan(date);
    _loadOrderPlans();
  }

  // Search function to filter orders by date
  void _searchOrders(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredPlans = _orderPlans;
      } else {
        _filteredPlans = _orderPlans
            .where((plan) => plan['date'].toString().contains(query))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Plans'),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search by date',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _searchOrders,
            ),
          ),
          // Results list
          Expanded(
            child: _filteredPlans.isEmpty
                ? Center(child: Text('No matching orders found'))
                : ListView.builder(
                    itemCount: _filteredPlans.length,
                    itemBuilder: (context, index) {
                      final plan = _filteredPlans[index];
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text('${plan['total_items']}'),
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        title: Text('Date: ${plan['date']}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Target Cost: \$${plan['target_cost'].toStringAsFixed(2)}'),
                            Text('Items: ${plan['total_items']}'),
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteOrderPlan(plan['date'] as String),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OrderDetailsScreen(
                                selectedDate: plan['date'] as String,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
} 