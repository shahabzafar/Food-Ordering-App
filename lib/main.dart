import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'food_management.dart';
import 'screens/order_plans_screen.dart';

/// Entry point of the Food Ordering application
/// Sets up the main app structure and navigation
void main() {
  runApp(const FoodOrderingApp());
}

/// Root widget of the application
/// Manages navigation state between different screens
class FoodOrderingApp extends StatefulWidget {
  const FoodOrderingApp({Key? key}) : super(key: key);

  @override
  _FoodOrderingAppState createState() => _FoodOrderingAppState();
}

class _FoodOrderingAppState extends State<FoodOrderingApp> {
  // Tracks currently selected navigation tab
  int _selectedIndex = 0;
  
  // List of main screens in the app
  // - Home: Create new orders
  // - Food Management: Add/edit food items
  // - Order Plans: View saved orders
  final List<Widget> _screens = [
    const HomeScreen(),
    const FoodManagementScreen(),
    OrderPlansScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Ordering App',
      // Global theme configuration
      theme: ThemeData(
        // Purple color scheme
        primarySwatch: Colors.purple,
        scaffoldBackgroundColor: Colors.grey[50],
        
        // Elevated card style with rounded corners
        cardTheme: CardTheme(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        
        // Custom button styling
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        
        // Global input field styling
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.purple, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
      
      // Main app structure with bottom navigation
      home: Scaffold(
        body: _screens[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.restaurant_menu),
              label: 'Manage Food',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list),
              label: 'Order Plans',
            ),
          ],
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
