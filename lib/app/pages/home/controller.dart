import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_supercluster/flutter_map_supercluster.dart';
import 'package:free_wifi/app/data/controllers/ad.dart';
import 'package:free_wifi/app/data/models/csvFile.dart';
import 'package:free_wifi/secret.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kakaomap_webview/kakaomap_webview.dart';
import 'package:latlong2/latlong.dart' as latLng;

import 'package:get/get.dart';

class HomePageController extends GetxController with StateMixin {
  static HomePageController get to =>
      Get.find<HomePageController>(); // add this line

  final Rx<List<CSVFile>> datas = Rx([]);
  final Rx<double> lat = 0.0.obs;
  final Rx<double> lng = 0.0.obs;
  final MapController mapController = MapController();
  final superclusterController = SuperclusterMutableController();

  final latLng.Distance distance = latLng.Distance();

  @override
  void onInit() async {
    await getPosition();
    await loadAsset();
  }

  Future<Position> getPosition() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    lat.value = position.latitude;
    lng.value = position.longitude;
    return position;
  }

  void moveCurrentPostion() async {
    EasyLoading.show(
      status: 'Loading...',
      maskType: EasyLoadingMaskType.black,
    );
    final position = await getPosition();
    print("moveCurrentPostion");
    mapController.moveAndRotate(
        latLng.LatLng(position.latitude, position.longitude), 20, 0);
    EasyLoading.dismiss();
  }

  Future<void> loadAsset() async {
    final myData = await rootBundle.loadString('csv/test.csv');
    List<List<dynamic>> csvTable = CsvToListConverter().convert(myData);
    List<CSVFile> csvFiles = [];

    for (int i = 0; i < csvTable.length; i++) {
      try {
        csvFiles.add(CSVFile(
            lat: csvTable[i][3],
            lng: csvTable[i][4],
            name: csvTable[i][0],
            address: csvTable[i][1],
            number: csvTable[i][2]));
      } catch (e) {
        //print(csvTable[i]);
      }
    }
    datas.value = csvFiles;

    for (int i = 0; i < datas.value.length; i++) {
      //markers.value.add(makeMarker(datas.value[i]));
      superclusterController.add(makeMarker(datas.value[i]));
    }
  }

  Future<void> _openKakaoMapScreen(double lat, double lng, String name) async {
    AdService.to.showInterstitial();

    Get.to(() => KakaoMapView(
          width: Get.width,
          height: Get.height,
          kakaoMapKey: JAVASCRIPT_KEY,
          lat: lat,
          lng: lng,
        ));
  }

  Marker makeMarker(CSVFile data) {
    return Marker(
        anchorPos: AnchorPos.align(AnchorAlign.center),
        height: 30,
        width: 30,
        point: latLng.LatLng(data.lat, data.lng),
        builder: (ctx) => IconButton(
            icon:
                Icon(Icons.location_on_outlined, size: 50, color: Colors.black),
            onPressed: () => Get.bottomSheet(Container(
                  color: Colors.white,
                  height: 200,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                            child: Center(
                                child: Text(
                              "${data.name}",
                              style: TextStyle(
                                  fontSize: 25, fontWeight: FontWeight.bold),
                            )),
                            height: 50,
                            color: Colors.amber),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.wifi, size: 20, color: Colors.amber),
                            Text("  ${data.address}",
                                style: TextStyle(fontSize: 20)),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.call, size: 20, color: Colors.amber),
                            Text(" ${data.number} (문의)",
                                style: TextStyle(fontSize: 20)),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.social_distance,
                                size: 20, color: Colors.amber),
                            Text(
                                " ${distance.distance(latLng.LatLng(lat.value, lng.value), latLng.LatLng(data.lat, data.lng)) / 1000}Km (직선 기준)",
                                style: TextStyle(fontSize: 20)),
                          ],
                        ),
                        ElevatedButton(
                          child: Text("상세 정보(카카오맵)"),
                          onPressed: () => _openKakaoMapScreen(
                              data.lat, data.lng, data.name),
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.resolveWith(
                                      (states) => Colors.amber)),
                        )
                      ],
                    ),
                  ),
                ))));
  }
}
