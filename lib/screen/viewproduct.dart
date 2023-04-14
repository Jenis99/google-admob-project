import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart' as http;

class viewproduct extends StatefulWidget {
  const viewproduct({super.key});

  @override
  State<viewproduct> createState() => _viewproductState();
}

// ca-app-pub-8653866596960071/3546448407 ---middle of list
class _viewproductState extends State<viewproduct> {
  Future<List>? allproducts;

  BannerAd? _middlebannerad;
  bool _istop = false;

  Future<List>? getproduct_data() async {
    Uri url = Uri.parse("http://picsyapps.com/studentapi/getProducts.php");
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var body = response.body.toString();
      var json = jsonDecode(body);
      return json["data"];
    } else {
      return [];
    }
  }

  loadmiddlebanner() {
    _middlebannerad = BannerAd(
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
    _middlebannerad!.load();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadmiddlebanner();
    setState(() {
      allproducts = getproduct_data();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("This is View Product Screen"),
      ),
      body: FutureBuilder(
          future: allproducts,
          builder: (context, snapshot) {
            {
              if (snapshot.hasData) {
                if (snapshot.data!.length < 0) {
                  return Center(
                    child: Text("Their is no user"),
                  );
                } else {
                  return ListView.separated(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        var count;
                        return ListTile(
                          title: Text("Product Name : " +
                              snapshot.data![index]["pname"].toString()),
                          subtitle: Text("Price : " +
                              snapshot.data![index]["price"].toString()),
                          trailing:
                              Text(snapshot.data![index]["qty"].toString()),
                        );
                      },
                      separatorBuilder: (context, index) {
                        if (index == 3) {
                          return Container(
                              height: _middlebannerad!.size.height.toDouble(),
                              width: _middlebannerad!.size.width.toDouble(),
                              // color: Colors.yellow,
                              child: AdWidget(
                                ad: _middlebannerad!,
                              ));
                        } else {
                          return Container();
                        }
                      });
                    }
                    } else {
                       return Center(
                  child: CircularProgressIndicator(),
                );
              }
            }
          }),
    );
  }
}
