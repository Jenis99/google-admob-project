import 'dart:io';
import 'package:google_admob_project/screen/viewproduct.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class homescreen extends StatefulWidget {
  const homescreen({super.key});

  @override
  State<homescreen> createState() => _homescreenState();
}
//ca-app-pub-8653866596960071~5507123682

//ca-app-pub-8653866596960071/3749805995 - home top
//ca-app-pub-8653866596960071/2436724324 - home bottom



// ca-app-pub-8653866596960071/8228107052 - interstitialAd full page

class _homescreenState extends State<homescreen> {
  var count;

   InterstitialAd? _interstitialAd;
    RewardedAd? _rewardedAd;
  BannerAd? _topBannerAd;
  bool _istop=false;

  final adUnitId = Platform.isAndroid
    ? 'ca-app-pub-3940256099942544/1033173712'
    : 'ca-app-pub-3940256099942544/4411468910';
  loadtopbanner()
  {
    _topBannerAd = BannerAd(
      adUnitId: "ca-app-pub-3940256099942544/6300978111",
      size: AdSize.largeBanner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _istop = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    );
    _topBannerAd!.load();
  }

   loadinterstitialAd() {
     InterstitialAd.load(
        adUnitId: 'ca-app-pub-3940256099942544/1033173712',
        request: AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            print('$ad loaded');
            _interstitialAd = ad;
            _interstitialAd?.setImmersiveMode(true);
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('InterstitialAd failed to load: $error.');
            _interstitialAd = null;
          },
        ));
        }
  showInterstitialAd() {
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
        loadinterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        loadinterstitialAd();
      },
    );
    _interstitialAd!.show();
    _interstitialAd = null;
  }

  createRewardedAd() async{
    RewardedAd.load(
        adUnitId:"ca-app-pub-3940256099942544/5224354917",
        request: AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (RewardedAd ad) {
            print('$ad loaded.');
            _rewardedAd = ad;

          },
          onAdFailedToLoad: (LoadAdError error) {
            print('RewardedAd failed to load: $error');
            _rewardedAd = null;
            createRewardedAd();
          }),);
  }

  showRewardedAd()async {
    if (_rewardedAd == null) {
      print('Warning: attempt to show rewarded before loaded.');
      return;
    }
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedAd ad) =>
          print('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        createRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        createRewardedAd();
      },
    );

    _rewardedAd!.setImmersiveMode(true);
    _rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
          print('$ad with reward $RewardItem(${reward.amount}, ${reward.type})');
        });
    // _rewardedAd!.show(onUserEarnedReward: );
    _rewardedAd = null;
  }


  checkcount()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(prefs.containsKey("count")){
      setState(() {
        count = prefs.getInt("count");
        count++;
        prefs.setInt("count", count);
        print("count : "+count.toString());
      });
    }
    else{
      setState(() {
        prefs.setInt("count", 1);
         print("count : "+count.toString());
      });
    }
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkcount();
    loadtopbanner();
    loadinterstitialAd();
    createRewardedAd();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: ()async {
           SharedPreferences prefs = await SharedPreferences.getInstance();
            if(prefs.getInt("count")==3){
               final showad = await showInterstitialAd()<bool>(
                  context: context,
                  builder: (context)async {
                      showInterstitialAd();
                  },
                );
                return showad!;
            }
            else{
              return true;
            }
        },

      child: Scaffold(
        appBar: AppBar(
          title: Text("Google admob"),
        ),
        body:
         Column(
          children: [
             (_istop)?
              Container(
                height: _topBannerAd!.size.height.toDouble(),
                width: _topBannerAd!.size.width.toDouble(),
                child: AdWidget(ad: _topBannerAd!),
              ):SizedBox(height: 0,),
              SizedBox(height: 20.0,),
              ElevatedButton(onPressed: (){
                showInterstitialAd();
              }, child: Text("Load Add")),
            SizedBox(height: 20.0,),
              ElevatedButton(onPressed: (){
                showRewardedAd();
              }, child: Text("Load Rewarded Add")),
              ElevatedButton(onPressed: (){
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context)=>viewproduct())
                );
              }, child: Text("View"))
          ],
        ),
      ),
    );
  }
}