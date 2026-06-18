import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  test('Test multipart post creation', () async {
    final token = '3929|nKMq2uXUL3KpoqungGLtkQUwbrd6irwjCFFEDOZ1defa11d7';
    final url = Uri.parse('https://onepipo.com/api/v1/posts/create');

    // Create a multipart request
    final request = http.MultipartRequest('POST', url);
    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    // Add fields
    request.fields['description'] = 'test post multipart from dart';
    request.fields['type'] = 'problem';
    request.fields['is_anonymous'] = 'false';
    request.fields['action'] = 'create';

    // Add a dummy JPEG file
    final dummyBytes = List<int>.generate(100, (i) => i);
    final file = http.MultipartFile.fromBytes(
      'image', // Try 'image' key
      dummyBytes,
      filename: 'test.jpg',
    );
    request.files.add(file);

    print('Sending multipart request (file key: "image")...');
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    print('Status: ${response.statusCode}');
    print('Body: ${response.body}');

    // Let's also try with 'photo' key
    final request2 = http.MultipartRequest('POST', url);
    request2.headers.addAll({
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });
    request2.fields['description'] = 'test post multipart photo from dart';
    request2.fields['type'] = 'problem';
    request2.fields['is_anonymous'] = 'false';
    request2.fields['action'] = 'create';

    final file2 = http.MultipartFile.fromBytes(
      'photo', // Try 'photo' key
      dummyBytes,
      filename: 'test.jpg',
    );
    request2.files.add(file2);

    print('\nSending multipart request (file key: "photo")...');
    final streamedResponse2 = await request2.send();
    final response2 = await http.Response.fromStream(streamedResponse2);

    print('Status: ${response2.statusCode}');
    print('Body: ${response2.body}');
  });
}
