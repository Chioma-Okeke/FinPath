import 'package:flutter/material.dart';
import '../models/snapshot.dart';
import '../models/action_item.dart';

class AppState extends ChangeNotifier {
  String _language = 'en';
  Snapshot? _snapshot;
  List<ActionItem> _actions = [];
  bool _onboardingComplete = false;

  String get language => _language;
  Snapshot? get snapshot => _snapshot;
  List<ActionItem> get actions => _actions;
  bool get onboardingComplete => _onboardingComplete;

  void setLanguage(String lang) {
    _language = lang;
    notifyListeners();
  }

  void setSnapshot(Snapshot snapshot) {
    _snapshot = snapshot;
    notifyListeners();
  }

  void setActions(List<ActionItem> actions) {
    _actions = actions;
    notifyListeners();
  }

  void markActionComplete(int actionId) {
    final idx = _actions.indexWhere((a) => a.id == actionId);
    if (idx != -1) {
      _actions[idx].isCompleted = true;
      notifyListeners();
    }
  }

  void setOnboardingComplete(bool value) {
    _onboardingComplete = value;
    notifyListeners();
  }
}
