import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryPreferences {
  static SharedPreferences? _preferences;

  static const _keyHistory = "calcHistory";

  static Future init() async =>
      _preferences = await SharedPreferences.getInstance();

  static Future setHistory(List<String> history) async =>
      await _preferences?.setStringList(_keyHistory, history);

  static List<String>? getHistory() => _preferences?.getStringList(_keyHistory);
}
