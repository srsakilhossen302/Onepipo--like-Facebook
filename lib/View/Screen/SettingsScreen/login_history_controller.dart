import 'dart:convert';
import 'package:get/get.dart';
import '../../../service/api_client.dart';

class LoginHistoryItem {
  final String id;
  final String message;
  final String time;

  LoginHistoryItem({
    required this.id,
    required this.message,
    required this.time,
  });

  factory LoginHistoryItem.fromJson(Map<String, dynamic> json) {
    String? message = json['message'] ?? json['body'] ?? json['description'] ?? json['text'];
    
    // Extract metadata from 'data' field (which can be a map or a JSON string)
    Map<String, dynamic>? meta;
    if (json['data'] is Map) {
      meta = json['data'] as Map<String, dynamic>;
    } else if (json['data'] is String) {
      try {
        final decoded = jsonDecode(json['data']);
        if (decoded is Map) {
          meta = decoded as Map<String, dynamic>;
        }
      } catch (_) {}
    }
    
    String? device = json['device'] ?? json['device_name'] ?? meta?['device'] ?? meta?['device_name'] ?? meta?['device_token'];
    String? browser = json['browser'] ?? meta?['browser'];
    String? os = json['os'] ?? meta?['os'];
    String? ip = json['ip'] ?? json['ip_address'] ?? meta?['ip'] ?? meta?['ip_address'];
    String? location = json['location'] ?? meta?['location'];

    // Construct descriptive message from metadata if message is null or default description
    if (message == null || message.isEmpty || message.toLowerCase() == 'login activity recorded') {
      List<String> parts = [];
      if (device != null && device.isNotEmpty) {
        parts.add(device);
      } else {
        if (browser != null && browser.isNotEmpty) parts.add(browser);
        if (os != null && os.isNotEmpty) parts.add(os);
      }
      if (ip != null && ip.isNotEmpty) {
        parts.add('IP: $ip');
      }
      if (location != null && location.isNotEmpty) {
        parts.add('Location: $location');
      }
      
      if (parts.isNotEmpty) {
        message = parts.join(' | ');
      }
    }
    
    message ??= 'Login activity recorded';

    return LoginHistoryItem(
      id: json['id']?.toString() ?? '',
      message: message,
      time: json['time'] ?? json['time_ago'] ?? json['created_at'] ?? 'Just now',
    );
  }
}

class LoginHistoryController extends GetxController {
  var loginHistories = <LoginHistoryItem>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchLoginHistory();
  }

  Future<void> fetchLoginHistory() async {
    isLoading.value = true;
    try {
      final response = await Get.find<ApiClient>().get('/notifications?filter=login');
      print('Login History API Response status: ${response.statusCode}');
      print('Login History API Response body: ${response.body}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        List<dynamic> dataList = [];
        if (decoded is List) {
          dataList = decoded;
        } else if (decoded is Map && decoded.containsKey('data')) {
          if (decoded['data'] is List) {
            dataList = decoded['data'];
          }
        }
        loginHistories.value = dataList
            .map((json) => LoginHistoryItem.fromJson(json))
            .toList();
      }
    } catch (e) {
      print('Error fetching login history: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
