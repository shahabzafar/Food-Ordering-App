import 'package:flutter/material.dart';
import '../helpers/database_helper.dart';
import '../models/food_item.dart';

/// Screen to display order details for a specific date.
class OrderDetailsScreen extends StatefulWidget {
  final String selectedDate;

  OrderDetailsScreen({required this.selectedDate});

  @override
  _OrderDetailsScreenState createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  double? _targetCost;
  List<FoodItem> _orderItems = [];

  @override
  void initState() {
    super.initState();
    _fetchOrderDetails();
  }

  /// Fetch order details for the selected date.
  Future<void> _fetchOrderDetails() async {
    final plan = await _dbHelper.fetchOrderPlanForDate(widget.selectedDate);

    if (plan != null) {
      setState(() {
        _targetCost = plan['targetCost'];
        _orderItems = List<FoodItem>.from(plan['items']);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Details (${widget.selectedDate})'),
      ),
      body: _orderItems.isEmpty
          ? Center(child: Text('No order found for this date.'))
          : Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Target Cost: \$${_targetCost?.toStringAsFixed(2) ?? 'N/A'}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: _orderItems.length,
                itemBuilder: (context, index) {
                  final item = _orderItems[index];
                  return ListTile(
                    title: Text(item.name),
                    subtitle: Text('Cost: \$${item.cost.toStringAsFixed(2)}'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
