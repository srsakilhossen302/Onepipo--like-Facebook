import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final token = '3736|x1n9AK1qFLihHUn1B64oLIKBl8mfEl9kowvhwT6Tff7744d6';
  
  try {
    // 1. Create a new comment
    print('Creating a new comment...');
    var res = await http.post(
      Uri.parse('https://onepipo.com/api/v1/posts/111/comments'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'content': 'New comment for unlike test.',
      }),
    );
    
    final commentData = jsonDecode(res.body)['data'];
    final id = commentData['id'];
    print('New comment ID: $id. Initial state: is_liked=${commentData['is_liked']}, is_downvoted=${commentData['is_downvoted']}');
    
    final unlikeUrl = Uri.parse('https://onepipo.com/api/v1/comments/$id/unlike');
    final getUrl = Uri.parse('https://onepipo.com/api/v1/posts/111/comments');
    
    // 2. Call /unlike
    print('Calling /unlike...');
    await http.post(unlikeUrl, headers: {'Accept': 'application/json', 'Content-Type': 'application/json', 'Authorization': 'Bearer $token'}, body: jsonEncode({'type': 'comment'}));
    
    // Check state
    res = await http.get(getUrl, headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'});
    var commentsList = jsonDecode(res.body)['data'] as List;
    var comment = commentsList.firstWhere((c) => c['id'] == id);
    print('State after /unlike: is_liked=${comment['is_liked']}, is_downvoted=${comment['is_downvoted']}');
    
  } catch (e) {
    print('Error: $e');
  }
}
