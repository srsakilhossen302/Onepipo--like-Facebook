import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final token = '3736|x1n9AK1qFLihHUn1B64oLIKBl8mfEl9kowvhwT6Tff7744d6';
  final url = Uri.parse('https://onepipo.com/api/v1/comments/143/unlike');
  
  try {
    final response = await http.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'type': 'comment',
      }),
    );
    print('Unlike comment status: ${response.statusCode}, Body: ${response.body}');
  } catch (e) {
    print('Error: $e');
  }
}
