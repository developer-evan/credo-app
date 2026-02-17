import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = 'https://dummyjson.com';

  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      print('=== API REQUEST ===');
      print('URL: $baseUrl/auth/login');
      print('Username: $username');
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
          'expiresInMins': 30,
        }),
      );

      print('=== API RESPONSE ===');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        print('=== DECODED DATA ===');
        print('Data: $data');

        // Check if accessToken exists (DummyJSON uses accessToken instead of token)
        if (data.containsKey('accessToken') && data['accessToken'] != null) {
          await _saveToken(data['accessToken'].toString());

          // Also save refresh token if available
          if (data.containsKey('refreshToken') &&
              data['refreshToken'] != null) {
            await _saveRefreshToken(data['refreshToken'].toString());
          }

          await _saveUserData(data);

          print('=== LOGIN SUCCESS ===');
          print('Access Token saved successfully');

          return {'success': true, 'data': data, 'message': 'Login successful'};
        } else {
          print('=== ERROR: Access token not found in response ===');
          return {'success': false, 'message': 'Invalid response from server'};
        }
      } else {
        print('=== API ERROR ===');
        print('Status: ${response.statusCode}');

        try {
          final error = jsonDecode(response.body) as Map<String, dynamic>;
          print('Error Response: $error');
          return {
            'success': false,
            'message': error['message']?.toString() ?? 'Login failed',
          };
        } catch (e) {
          return {
            'success': false,
            'message': 'Login failed with status ${response.statusCode}',
          };
        }
      }
    } catch (e, stackTrace) {
      print('=== EXCEPTION ===');
      print('Error: $e');
      print('StackTrace: $stackTrace');

      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  Future<void> _saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      print('Access token saved successfully');
    } catch (e) {
      print('Error saving token: $e');
    }
  }

  Future<void> _saveRefreshToken(String refreshToken) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('refresh_token', refreshToken);
      print('Refresh token saved successfully');
    } catch (e) {
      print('Error saving refresh token: $e');
    }
  }

  Future<void> _saveUserData(Map<String, dynamic> userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', jsonEncode(userData));
      print('User data saved successfully');
    } catch (e) {
      print('Error saving user data: $e');
    }
  }

  Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('auth_token');
    } catch (e) {
      print('Error getting token: $e');
      return null;
    }
  }

  Future<String?> getRefreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('refresh_token');
    } catch (e) {
      print('Error getting refresh token: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString('user_data');
      if (userData != null) {
        return jsonDecode(userData) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('refresh_token');
      await prefs.remove('user_data');
      print('Logged out successfully');
    } catch (e) {
      print('Error logging out: $e');
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // get request
  Future<dynamic> getData(String endpoint) async {
    final url = Uri.parse('$baseUrl/auth/me');
    final token = await getToken();
    final response = await http.get(
      url,
      headers: {
        // 'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  }
}