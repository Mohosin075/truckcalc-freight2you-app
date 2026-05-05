import 'package:flutter/cupertino.dart';

class InterestScreenController extends ChangeNotifier {
  Set<int> selectedItems = {};

  void toggleSelection(int index) {
    if (selectedItems.contains(index)) {
      selectedItems.remove(index);
    } else {
      selectedItems.add(index);
    }
    notifyListeners();
  }

  bool isSelected(int index) {
    return selectedItems.contains(index);
  }

  int get selectedItemCount => selectedItems.length;
}
