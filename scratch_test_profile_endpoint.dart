import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final token = '3736|x1n9AK1qFLihHUn1B64oLIKBl8mfEl9kowvhwT6Tff7744d6';
  final endpoints = [
    '/user',
    '/me',
    '/users/me',
    '/auth/me',
    '/auth/user',
    '/profile',
    '/user/profile',
    '/users/profile',
  ];
  
  for (var endpoint in endpoints) {
    final url = Uri.parse('https://onepipo.com/api/v1$endpoint');
    try {
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      print('Endpoint $endpoint -> status: ${response.statusCode}, body length: ${response.body.length}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('SUCCESS for $endpoint: ${response.body}');
      }
    } catch (e) {
      print('Error for $endpoint: $e');
    }
  }
}
