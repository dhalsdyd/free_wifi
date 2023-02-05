import 'package:free_wifi/app/data/controllers/ad.dart';
import 'package:free_wifi/app/data/controllers/lifecycle.dart';
import 'package:get/get.dart';

class AppInitalizer {
  Future<void> init() async {
    await Get.putAsync<AdService>(() => AdService().init());
    Get.put<LifeCycleController>(LifeCycleController());
    // await Get.putAsync<DatabaseController>(() => DatabaseController().init());
    // await Get.putAsync<AuthController>(() => AuthController().init());
  }
}
