import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  test('Test real image multipart post creation', () async {
    final token = '3929|nKMq2uXUL3KpoqungGLtkQUwbrd6irwjCFFEDOZ1defa11d7';
    final url = Uri.parse('https://onepipo.com/api/v1/posts/create');

    // Read real image file
    final imagePath = r'C:\Users\sakil\.gemini\antigravity-ide\brain\4b3a2f95-1919-4344-87d0-8af40142601e\media__1781808237079.png';
    final fileBytes = await File(imagePath).readAsBytes();

    // 1. Try with file key 'image'
    final request = http.MultipartRequest('POST', url);
    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    request.fields['description'] = 'test post multipart real image';
    request.fields['type'] = 'problem';
    request.fields['is_anonymous'] = 'false';
    request.fields['action'] = 'create';

    final multipartFile = http.MultipartFile.fromBytes(
      'image',
      fileBytes,
      filename: 'media__1781808237079.png',
    );
    request.files.add(multipartFile);

    print('Sending multipart request with real image under "image"...');
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    print('Status: ${response.statusCode}');
    print('Body: ${response.body}');

    // 2. Try with file key 'photo'
    final request2 = http.MultipartRequest('POST', url);
    request2.headers.addAll({
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    request2.fields['description'] = 'test post multipart real photo';
    request2.fields['type'] = 'problem';
    request2.fields['is_anonymous'] = 'false';
    request2.fields['action'] = 'create';

    final multipartFile2 = http.MultipartFile.fromBytes(
      'photo',
      fileBytes,
      filename: 'media__1781808237079.png',
    );
    request2.files.add(multipartFile2);

    print('\nSending multipart request with real image under "photo"...');
    final streamedResponse2 = await request2.send();
    final response2 = await http.Response.fromStream(streamedResponse2);

    print('Status: ${response2.statusCode}');
    print('Body: ${response2.body}');
  });
}
