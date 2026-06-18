import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  test('Test multipart post creation with boolean 0', () async {
    final token = '3929|nKMq2uXUL3KpoqungGLtkQUwbrd6irwjCFFEDOZ1defa11d7';
    final url = Uri.parse('https://onepipo.com/api/v1/posts/create');

    // Read real image file
    final imagePath = r'C:\Users\sakil\.gemini\antigravity-ide\brain\4b3a2f95-1919-4344-87d0-8af40142601e\media__1781808237079.png';
    final fileBytes = await File(imagePath).readAsBytes();

    final request = http.MultipartRequest('POST', url);
    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    request.fields['description'] = 'test multipart with is_anonymous=0 and image file';
    request.fields['type'] = 'problem';
    request.fields['is_anonymous'] = '0'; // Send '0' which is parsed as boolean false
    request.fields['action'] = 'create';

    final multipartFile = http.MultipartFile.fromBytes(
      'image',
      fileBytes,
      filename: 'media__1781808237079.png',
    );
    request.files.add(multipartFile);

    print('Sending multipart request with is_anonymous="0"...');
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    print('Status: ${response.statusCode}');
    print('Body: ${response.body}');
  });
}
