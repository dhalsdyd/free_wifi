import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:csv/csv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latLng;
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'dart:async';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:kakaomap_webview/kakaomap_webview.dart';
import "package:google_mobile_ads/google_mobile_ads.dart";

bool a = false;
List<List<dynamic>> data = [];
List<Marker> markers = [];
double lat = 0;
double lng = 0;
MapController _mapController = MapController();
final latLng.Distance distance = latLng.Distance();

Future<Position> getPosition() async {
  Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best);
  return position;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();
  runApp(MyApp());
  configLoading();
}

void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.dark
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..progressColor = Colors.yellow
    ..backgroundColor = Colors.green
    ..indicatorColor = Colors.yellow
    ..textColor = Colors.yellow
    ..maskColor = Colors.blue.withOpacity(0.5)
    ..userInteractions = true
    ..dismissOnTap = false;
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter EasyLoading',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
      builder: EasyLoading.init(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Timer? _timer;

  InterstitialAd? _interstitialAd;
  int _numInterstitialLoadAttempts = 0;

  void _createInter() {
    InterstitialAd.load(
        adUnitId: InterstitialAd.testAdUnitId,
        request: AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(onAdLoaded: (ad) {
          _interstitialAd = ad;
          _numInterstitialLoadAttempts = 0;
        }, onAdFailedToLoad: (error) {
          _numInterstitialLoadAttempts += 1;
          _interstitialAd = null;
          if (_numInterstitialLoadAttempts <= 3) _createInter();
        }));
  }

  void _showInterstitialAd() {
    if (_interstitialAd == null) {
      print('Warning: attempt to show interstitial before loaded.');
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) =>
          print('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _createInter();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _createInter();
      },
    );
    _interstitialAd!.show();
    _interstitialAd = null;
  }

  Future<void> loadAsset() async {
    final myData = await rootBundle.loadString('csv/test.csv');
    List<List<dynamic>> csvTable = CsvToListConverter().convert(myData);
    data = csvTable;
  }

  Future<void> _openKakaoMapScreen(
      BuildContext context, double lat, double lng, String name) async {
    KakaoMapUtil util = KakaoMapUtil();

    // String url = await util.getResolvedLink(
    //     util.getKakaoMapURL(37.402056, 127.108212, name: 'Kakao ??????'));

    /// This is short form of the above comment
    String url = await util.getMapScreenURL(lat, lng, name: name);

    Navigator.push(
        context, MaterialPageRoute(builder: (_) => KakaoMapScreen(url: url)));
  }

  @override
  void initState() {
    _createInter();
    super.initState();
    EasyLoading.addStatusCallback((status) {
      if (status == EasyLoadingStatus.dismiss) {
        _timer?.cancel();
      }
    });
    EasyLoading.showSuccess('Use in initState');
    EasyLoading.show(
      status: '????????? ??????????????????...\n(????????? ??????????????? ?????????.)',
      maskType: EasyLoadingMaskType.black,
    );
    // EasyLoading.removeCallbacks();
    loadAsset()
        .then((_) => {
              for (int i = 0; i < data.length; i++)
                {
                  if (data[i][3] != '' &&
                      data[i][3] is double &&
                      data[i][4] is double)
                    markers.add(
                      Marker(
                          anchorPos: AnchorPos.align(AnchorAlign.center),
                          height: 30,
                          width: 30,
                          point: latLng.LatLng(data[i][3], data[i][4]),
                          builder: (ctx) => IconButton(
                                icon: Icon(Icons.location_on_outlined,
                                    size: 40, color: Colors.black),
                                onPressed: () {
                                  showModalBottomSheet(
                                      context: context,
                                      builder: (builder) {
                                        return Container(
                                          color: Colors.white,
                                          height: 200,
                                          child: Center(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    child: Center(
                                                        child: Text(
                                                      "${data[i][0]}",
                                                      style: TextStyle(
                                                          fontSize: 25,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    )),
                                                    height: 50,
                                                    color: Colors.amber),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(Icons.wifi,
                                                        size: 20,
                                                        color: Colors.amber),
                                                    Text("  ${data[i][1]}",
                                                        style: TextStyle(
                                                            fontSize: 20)),
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(Icons.call,
                                                        size: 20,
                                                        color: Colors.amber),
                                                    Text(" ${data[i][2]} (??????)",
                                                        style: TextStyle(
                                                            fontSize: 20)),
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(Icons.social_distance,
                                                        size: 20,
                                                        color: Colors.amber),
                                                    Text(
                                                        " ${distance.distance(latLng.LatLng(lat, lng), latLng.LatLng(data[i][3], data[i][4])) / 1000}Km (?????? ??????)",
                                                        style: TextStyle(
                                                            fontSize: 20)),
                                                  ],
                                                ),
                                                ElevatedButton(
                                                  child: Text("?????? ??????(????????????)"),
                                                  onPressed: () => {
                                                    _openKakaoMapScreen(
                                                        context,
                                                        data[i][3],
                                                        data[i][4],
                                                        data[i][0]),
                                                    _interstitialAd?.show() ??
                                                        null,
                                                  },
                                                  style: ButtonStyle(
                                                      backgroundColor:
                                                          MaterialStateProperty
                                                              .resolveWith(
                                                                  (states) =>
                                                                      Colors
                                                                          .amber)),
                                                )
                                              ],
                                            ),
                                          ),
                                        );
                                      });
                                },
                              )),
                    ),
                },
            })
        .then((_) => getPosition()
            .then((pos) => {
                  lat = pos.latitude,
                  lng = pos.longitude,
                  markers.add(Marker(
                      anchorPos: AnchorPos.align(AnchorAlign.center),
                      height: 30,
                      width: 30,
                      point: latLng.LatLng(lat, lng),
                      builder: (ctx) => IconButton(
                            icon: Icon(Icons.my_location_rounded,
                                size: 40, color: Colors.orange),
                            onPressed: () {
                              showModalBottomSheet(
                                  context: context,
                                  builder: (builder) {
                                    return Container(
                                        height: 200,
                                        color: Colors.white,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                child: Center(
                                                    child: Text(
                                                  "????????????",
                                                  style: TextStyle(
                                                      fontSize: 25,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                )),
                                                height: 50,
                                                color: Colors.amber),
                                            ElevatedButton(
                                              child: Text("?????? ??????"),
                                              onPressed: () => {
                                                _openKakaoMapScreen(
                                                    context, lat, lng, "?????? ??????"),
                                                _showInterstitialAd()
                                              },
                                              style: ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStateProperty
                                                          .resolveWith(
                                                              (states) => Colors
                                                                  .amber)),
                                            )
                                          ],
                                        ));
                                  });
                            },
                          ))),
                })
            .then((_) => {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => MapTest(lat, lng))),
                  EasyLoading.dismiss(),
                }));
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class MapTest extends StatefulWidget {
  MapTest(double lat, double lng) {
    this.centerLat = lat;
    this.centerLng = lng;
  }

  double centerLng = 0;
  double centerLat = 0;

  @override
  _MapTestState createState() => _MapTestState();

  static _MapTestState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MapTestState>();
}

class _MapTestState extends State<MapTest> {
  BannerAd? _ad;

  @override
  void initState() {
    _ad = BannerAd(
        size: AdSize.banner,
        adUnitId: BannerAd.testAdUnitId,
        listener: BannerAdListener(
          // Called when an ad is successfully received.
          onAdLoaded: (Ad ad) {},
          // Called when an ad request failed.
          onAdFailedToLoad: (Ad ad, LoadAdError error) {
            // Dispose the ad here to free resources.
            ad.dispose();
          },
          // Called when an ad opens an overlay that covers the screen.
          onAdOpened: (Ad ad) {},
          // Called when an ad removes an overlay that covers the screen.
          onAdClosed: (Ad ad) {},
          // Called when an impression occurs on the ad.
          onAdImpression: (Ad ad) {},
        ),
        request: AdRequest());
    _ad!.load();
    super.initState();
    //while(true) print("$centerLat,$centerLng");
  }

  @override
  void dispose() {
    super.dispose();
  }

  _showErrorAlert(String title, String message) {
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
              title: new Text(title),
              content: new Text(message),
              actions: <Widget>[
                FlatButton(
                  child: Center(child: Text('??????')),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        floatingActionButton: Column(
          children: [
            FloatingActionButton(
              onPressed: () => {
                _showErrorAlert(
                    "?????? ???????????? ?????? ????????? ????????? :)\n\nsmiledevelop626@gmail.com",
                    "==============\n?????? ????????? ?????? ??????????????? ??? ????????? ????????? ????\n?????? ????????? ?????? ????????? ?????? ????????? ??? ?????? ???????????????!\n==============\n")
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.alternate_email),
                  Text("????????????", style: TextStyle(fontSize: 7)),
                ],
              ),
              backgroundColor: Colors.amber,
            ),
            SizedBox(height: 5),
            FloatingActionButton(
              onPressed: () => {
                _showErrorAlert("???",
                    "??? ?????? ???\n==============\n1. ???????????? ?????? ????????? ???????????????\n2.??????????????? ?????? ?????? ????????? ????????? ?????? ????????????.\n\n?????? ?????? ???\n==============\n1. Public WiFi Secure??? ???????????????\n2. '?????? ??????' ??????+ ???????????? ????????? ??????\n3. ???????????? ?????? ?????? ????????? ????????????")
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lightbulb),
                  Text("???", style: TextStyle(fontSize: 7)),
                ],
              ),
              backgroundColor: Colors.amber,
            ),
            SizedBox(height: 5),
            FloatingActionButton(
              onPressed: () => {
                EasyLoading.show(
                  status: 'Loading...',
                  maskType: EasyLoadingMaskType.black,
                ),
                getPosition()
                    .then((pos) => {lat = pos.latitude, lng = pos.longitude})
                    .then((_) {
                  _mapController.moveAndRotate(latLng.LatLng(lat, lng), 18, 0,
                      id: "?????? ??????");
                  EasyLoading.dismiss();
                })
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.my_location),
                  Center(
                      child: Center(
                          child: Text("????????? ???????????? ????????????",
                              style: TextStyle(fontSize: 7)))),
                ],
              ),
              backgroundColor: Colors.amber,
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.miniEndTop,
        body: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height - _ad!.size.height,
              width: MediaQuery.of(context).size.width,
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  center: latLng.LatLng(widget.centerLat, widget.centerLng),
                  minZoom: 10,
                  maxZoom: 18,
                  zoom: 15,
                  plugins: [
                    MarkerClusterPlugin(),
                  ],
                  //onPositionChanged:
                ),
                layers: [
                  new TileLayerOptions(
                    urlTemplate:
                        "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    subdomains: ['a', 'b', 'c'],
                  ),
                  MarkerClusterLayerOptions(
                    maxClusterRadius: 140,
                    size: Size(40, 40),
                    anchor: AnchorPos.align((AnchorAlign.center)),
                    fitBoundsOptions:
                        FitBoundsOptions(padding: EdgeInsets.all(5)),
                    markers: markers,
                    builder: (BuildContext context, List<Marker> markers) {
                      return FloatingActionButton(
                        onPressed: null,
                        child: Text(markers.length.toString()),
                        backgroundColor: Colors.amber,
                      );
                    },
                  )
                ],
              ),
            ),
            SizedBox(
                height: _ad!.size.height.toDouble(), child: AdWidget(ad: _ad!))
          ],
        ),
      ),
      onWillPop: () async => false,
    );
  }
}

/*// @dart=2.9
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PopupController _popupController = PopupController();

  List<Marker> markers;
  int pointIndex;
  List points = [
    LatLng(51.5, -0.09),
    LatLng(49.8566, 3.3522),
  ];

  @override
  void initState() {
    pointIndex = 0;
    markers = [
      Marker(
        anchorPos: AnchorPos.align(AnchorAlign.center),
        height: 30,
        width: 30,
        point: points[pointIndex],
        builder: (ctx) => Icon(Icons.pin_drop),
      ),
      Marker(
        anchorPos: AnchorPos.align(AnchorAlign.center),
        height: 30,
        width: 30,
        point: LatLng(53.3498, -6.2603),
        builder: (ctx) => Icon(Icons.pin_drop),
      ),
      Marker(
        anchorPos: AnchorPos.align(AnchorAlign.center),
        height: 30,
        width: 30,
        point: LatLng(53.3488, -6.2613),
        builder: (ctx) => Icon(Icons.pin_drop),
      ),
      Marker(
        anchorPos: AnchorPos.align(AnchorAlign.center),
        height: 30,
        width: 30,
        point: LatLng(53.3488, -6.2613),
        builder: (ctx) => Icon(Icons.pin_drop),
      ),
      Marker(
        anchorPos: AnchorPos.align(AnchorAlign.center),
        height: 30,
        width: 30,
        point: LatLng(48.8566, 2.3522),
        builder: (ctx) => Icon(Icons.pin_drop),
      ),
      Marker(
        anchorPos: AnchorPos.align(AnchorAlign.center),
        height: 30,
        width: 30,
        point: LatLng(49.8566, 3.3522),
        builder: (ctx) => Icon(Icons.pin_drop),
      ),
    ];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          pointIndex++;
          if (pointIndex >= points.length) {
            pointIndex = 0;
          }
          setState(() {
            markers[0] = Marker(
              point: points[pointIndex],
              anchorPos: AnchorPos.align(AnchorAlign.center),
              height: 30,
              width: 30,
              builder: (ctx) => Icon(Icons.pin_drop),
            );
            markers = List.from(markers);
          });
        },
        child: Icon(Icons.refresh),
      ),
      body: FlutterMap(
        options: MapOptions(
          center: points[0],
          zoom: 5,
          maxZoom: 15,
          plugins: [
            MarkerClusterPlugin(),
          ],
          onTap: (_) => _popupController
              .hidePopup(), // Hide popup when the map is tapped.
        ),
        layers: [
          TileLayerOptions(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
          ),
          MarkerClusterLayerOptions(
            maxClusterRadius: 120,
            size: Size(40, 40),
            anchor: AnchorPos.align(AnchorAlign.center),
            fitBoundsOptions: FitBoundsOptions(
              padding: EdgeInsets.all(50),
            ),
            markers: markers,
            polygonOptions: PolygonOptions(
                borderColor: Colors.blueAccent,
                color: Colors.black12,
                borderStrokeWidth: 3),
            popupOptions: PopupOptions(
                popupSnap: PopupSnap.markerTop,
                popupController: _popupController,
                popupBuilder: (_, marker) => Container(
                      width: 200,
                      height: 100,
                      color: Colors.white,
                      child: GestureDetector(
                        onTap: () => debugPrint('Popup tap!'),
                        child: Text(
                          'Container popup for marker at ${marker.point}',
                        ),
                      ),
                    )),
            builder: (context, markers) {
              return FloatingActionButton(
                onPressed: null,
                child: Text(markers.length.toString()),
              );
            },
          ),
        ],
      ),
    );
  }
}*/
