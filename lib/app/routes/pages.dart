import 'package:free_wifi/app/pages/home/binding.dart';
import 'package:free_wifi/app/pages/home/page.dart';
import 'package:free_wifi/app/routes/route.dart';
import 'package:get/get.dart';

class AppPages {
  static final pages = [
    GetPage(
        name: Routes.home,
        page: () => const HomePage(),
        binding: HomePageBinding()),
  ];
}
