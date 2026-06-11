import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../helper/shared_prefe/shared_prefe.dart';
import '../../helper/network_info/network_info.dart';
import '../../service/api_client.dart';
import '../../service/socket_service.dart';

class DependencyInjection extends Bindings {
  @override
  void dependencies() {
    // Inject core services with fenix: true to keep them alive
    Get.lazyPut(() => NetworkInfo(), fenix: true);
    Get.lazyPut(() => ApiClient(), fenix: true);
    Get.lazyPut(() => SocketService(), fenix: true);
  }

  // Pre-initialize SharedPreferences synchronously before calling runApp()
  static Future<void> init() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    Get.put<SharedPreferences>(sharedPreferences, permanent: true);
    Get.put<SharedPreferenceHelper>(SharedPreferenceHelper(sharedPreferences: Get.find()), permanent: true);
  }
}
