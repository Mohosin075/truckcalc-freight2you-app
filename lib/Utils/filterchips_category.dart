import 'package:flutter/material.dart';

class FilterchipsCategory{
  final String name ;
  final IconData icon;
  final int id;
  FilterchipsCategory({
    required this.name,
    required this.icon,
    required this.id,
});
  List<FilterchipsCategory> categories = [
    FilterchipsCategory(name: "All", icon: Icons.auto_awesome, id: 0),
    FilterchipsCategory(name: "Nightlife", icon: Icons.nights_stay_outlined, id: 1),
    // ... API থেকে আসবে
  ];

  int selectedCategoryId = 0;
}