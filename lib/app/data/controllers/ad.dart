import 'package:flutter/foundation.dart';
import 'package:free_wifi/secret.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService extends GetxService {
  static AdService get to => Get.find<AdService>(); // add this line

  final stopAd = false;

  final Map<String, String> UNIT_ID = kReleaseMode
      ? AD_KEY
      : {
          'banner': 'ca-app-pub-3940256099942544/6300978111',
          'interstitial': 'ca-app-pub-3940256099942544/1033173712',
          'reward': 'ca-app-pub-3940256099942544/5224354917',
          "open": "ca-app-pub-3940256099942544/3419835294",
        };

  late BannerAd bannerAd;
  RxBool isBannerReady = false.obs;

  late InterstitialAd interstitialAd;
  int showCount = 0;
  RxBool isInterstitialReady = false.obs;

  late RewardedAd rewardAd;
  RxBool isRewardReady = false.obs;

  Future<AdService> init() async {
    if (!kReleaseMode) testSetting();

    if (!stopAd) {
      initBannerAd();
      initInterstitialAd();
      //initRewardedAd();
    }

    return this;
  }

  void testSetting() {
    print("TEST SETTING");
    MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(
        tagForChildDirectedTreatment: TagForChildDirectedTreatment.unspecified,
        testDeviceIds: <String>["A419F86372F5C84C70CCD802C69C7371"],
      ),
    );
  }

  void initBannerAd() {
    BannerAd _bannerAd = BannerAd(
      adUnitId: UNIT_ID['banner']!,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          isBannerReady.value = true;
          print('Banner Ad loaded.');
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          isBannerReady.value = false;
          ad.dispose();
          print('Ad failed to load: $error');
        },
        onAdOpened: (Ad ad) => print('Ad opened.'),
        onAdClosed: (Ad ad) => print('Ad closed.'),
      ),
    )..load();
    bannerAd = _bannerAd;
  }

  void initInterstitialAd() {
    InterstitialAd.load(
      adUnitId: UNIT_ID['interstitial']!,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) => print('Ad showed fullscreen.'),
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              isInterstitialReady.value = false;
              initInterstitialAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              isInterstitialReady.value = false;
              initInterstitialAd();
            },
          );
          isInterstitialReady.value = true;
          interstitialAd = ad;
          print('Interstial Ad loaded.');
        },
        onAdFailedToLoad: (err) {
          isInterstitialReady.value = false;
          print('Ad failed to load: $err');
        },
      ),
    );
  }

  void showInterstitial() {
    if (showCount % 2 != 0) {
      showCount++;
      return;
    }

    if (isInterstitialReady.value) {
      interstitialAd.show();
      showCount++;
    } else {
      print('Interstitial ad is not ready yet.');
    }
  }

  void initRewardedAd() {
    RewardedAd.load(
      adUnitId: UNIT_ID['reward']!,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) => print('Ad showed fullscreen.'),
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              isRewardReady.value = false;
              initRewardedAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              isRewardReady.value = false;
              initRewardedAd();
            },
          );

          isRewardReady.value = true;
          rewardAd = ad;
          print('Reward Ad loaded.');
        },
        onAdFailedToLoad: (err) {
          isRewardReady.value = false;
          print('Ad failed to load: $err');
        },
      ),
    );
  }

  void showRewarded({Function(num, String)? onUserEarnedReward}) {
    if (isRewardReady.value) {
      rewardAd.show(
        onUserEarnedReward: (ad, reward) {
          print('Reward earned: ${reward.amount}, ${reward.type}');
          onUserEarnedReward?.call(reward.amount, reward.type);
        },
      );
    }
  }
}
