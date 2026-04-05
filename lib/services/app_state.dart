import 'package:flutter/material.dart';
import '../models/snapshot.dart';
import '../models/action_item.dart';

class AppState extends ChangeNotifier {
  String _language = 'en';
  Snapshot? _snapshot;
  List<ActionItem> _actions = [];
  bool _onboardingComplete = false;
  String _userName = '';
  String _employmentType = '';

  String get language => _language;
  Snapshot? get snapshot => _snapshot;
  List<ActionItem> get actions => _actions;
  bool get onboardingComplete => _onboardingComplete;
  String get userName => _userName;
  String get employmentType => _employmentType;

  void setLanguage(String lang) {
    _language = lang;
    notifyListeners();
  }

  void setUserName(String name) {
    _userName = name;
    notifyListeners();
  }

  void setEmploymentType(String type) {
    _employmentType = type;
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

  void markActionComplete(String key) {
    for (var action in actions) {
      if (action.key == key) {
        action.isCompleted = true;
        break;
      }
    }
    notifyListeners();
  }

  void setOnboardingComplete(bool value) {
    _onboardingComplete = value;
    notifyListeners();
  }
}
