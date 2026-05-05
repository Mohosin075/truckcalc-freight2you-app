
import 'package:flutter/material.dart';

class BottomNavController extends ChangeNotifier {
  int _selectedIndex = 0;

  int get selectedIndex => _selectedIndex;

  void onItemTapped(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  void reset() {
    _selectedIndex = 0;
    notifyListeners();
  }
}
