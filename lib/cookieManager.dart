import 'package:shared_preferences/shared_preferences.dart';

class CookieManager {
  // Save a cookie
  Future<void> setCookie(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  // Retrieve a cookie
  Future<String?> getCookie(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  // Delete a cookie
  Future<void> deleteCookie(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  // Clear all cookies
  Future<void> clearCookies() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
