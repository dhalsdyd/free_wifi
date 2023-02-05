import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:free_wifi/app/data/controllers/ad.dart';
import 'package:free_wifi/app/pages/home/controller.dart';
import 'package:free_wifi/app/widgets/modal.dart';
import 'package:get/get.dart';
import 'package:flutter_map_supercluster/flutter_map_supercluster.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class HomePage extends GetView<HomePageController> {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        floatingActionButton: Column(
          children: [
            _optionButton("문의", "smiledevelop999@gmail.com 이 메일로 문의를 주세요"),
            SizedBox(height: 5),
            _optionButton("팁",
                "앱 관련 팁\n==============\n1. 아이콘의 왼쪽 상단을 눌러주세요\n2.와이파이가 없을 경우 지도는 업로드 되지 않습니다.\n\n보안 관련 팁\n==============\n1. Public WiFi Secure를 이용하세요\n2. '자동 접속' 해지+ 와이파이 리스트 삭제\n3. 와이파이 보안 등급 조회를 해보세요"),
            SizedBox(height: 5),
            FloatingActionButton(
              onPressed: () {
                controller.moveCurrentPostion();
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.my_location),
                  Center(
                      child: Center(
                          child: Text("현재 위치", style: TextStyle(fontSize: 7)))),
                ],
              ),
              backgroundColor: Colors.amber,
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.miniEndTop,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: FlutterMap(
                  mapController: controller.mapController,
                  options: MapOptions(
                      minZoom: 1,
                      maxZoom: 18,
                      zoom: 15,
                      onMapReady: controller.moveCurrentPostion
                      //onPositionChanged:
                      ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                      subdomains: ['a', 'b', 'c'],
                    ),
                    SuperclusterLayer.mutable(
                      maxClusterRadius: 500,
                      calculateAggregatedClusterData: false,
                      clusterWidgetSize: const Size(40, 40),
                      anchor: AnchorPos.align(AnchorAlign.center),
                      popupOptions: PopupOptions(
                        selectedMarkerBuilder: (context, marker) => const Icon(
                          Icons.pin_drop,
                          color: Colors.red,
                        ),
                        popupBuilder: (BuildContext context, Marker marker) =>
                            Container(
                          color: Colors.white,
                          child: Text(marker.point.toString()),
                        ),
                      ),
                      initialMarkers: [],
                      controller: controller.superclusterController,
                      builder:
                          (context, position, markerCount, extraClusterData) {
                        return Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20.0),
                              color: const Color(0xff383838)),
                          child: Center(
                            child: Text(
                              markerCount.toString(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              _banner(),
            ],
          ),
        ),
      ),
      onWillPop: () async => false,
    );
  }

  Widget _banner() {
    return Obx(
      () => AdService.to.isBannerReady.value
          ? SizedBox(
              height: AdService.to.bannerAd.size.height.toDouble(),
              width: AdService.to.bannerAd.size.width.toDouble(),
              child: AdWidget(ad: AdService.to.bannerAd),
            )
          : Container(),
    );
  }

  FloatingActionButton _optionButton(String title, String content) {
    return FloatingActionButton(
      onPressed: () =>
          Get.dialog(FGBPSimpleDialog(title: title, content: content)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.alternate_email),
          Text("문의하기", style: TextStyle(fontSize: 7)),
        ],
      ),
      backgroundColor: Colors.amber,
    );
  }
}
