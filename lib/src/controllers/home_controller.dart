import 'package:flutter/cupertino.dart';
import 'package:location/location.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../helpers/helper.dart';
import '../models/category.dart';
import '../models/market.dart';
import '../models/product.dart';
import '../models/review.dart';
import '../models/slide.dart';
import '../repository/category_repository.dart';
import '../repository/market_repository.dart';
import '../repository/product_repository.dart';
import '../repository/settings_repository.dart';
import '../repository/slider_repository.dart';

class HomeController extends ControllerMVC {
  List<Category> categories = <Category>[];
  List<Slide> slides = <Slide>[];
  List<Market> topMarkets = <Market>[];
  List<Market> allMarkets = <Market>[];
  List<Market> popularMarkets = <Market>[];
  List<Review> recentReviews = <Review>[];
  List<Product> trendingProducts = <Product>[];

  HomeController() {
    print("beforeloc");
    requestLoc();
  }

  Future<void> listenForSlides() async {
    final Stream<Slide> stream = await getSlides();
    stream.listen((Slide _slide) {
      setState(() => slides.add(_slide));
    }, onError: (a) {
      print(a);
    }, onDone: () {});
  }

  Future<void> listenForCategories() async {
    final Stream<Category> stream = await getCategories();
    stream.listen((Category _category) {
      setState(() => categories.add(_category));
    }, onError: (a) {
      print(a);
    }, onDone: () {});
  }

  Future<void> listenForTopMarkets() async {
    final Stream<Market> stream =
        await getNearMarkets(deliveryAddress.value, deliveryAddress.value);
    stream.listen((Market _market) {
      setState(() => topMarkets.add(_market));
    }, onError: (a) {}, onDone: () {});
  }

  Future<void> listenForAllMarkets() async {
    final Stream<Market> stream =
        await getAllMarkets(deliveryAddress.value, deliveryAddress.value);
    stream.listen((Market _market) {
      setState(() => allMarkets.add(_market));
    }, onError: (a) {}, onDone: () {});
  }

  Future<void> listenForPopularMarkets() async {
    final Stream<Market> stream =
        await getPopularMarkets(deliveryAddress.value);
    stream.listen((Market _market) {
      setState(() => popularMarkets.add(_market));
    }, onError: (a) {}, onDone: () {});
  }

  Future<void> listenForRecentReviews() async {
    final Stream<Review> stream = await getRecentReviews();
    stream.listen((Review _review) {
      setState(() => recentReviews.add(_review));
    }, onError: (a) {}, onDone: () {});
  }

  Future<void> listenForTrendingProducts() async {
    final Stream<Product> stream =
        await getTrendingProducts(deliveryAddress.value);
    stream.listen((Product _product) {
      setState(() => trendingProducts.add(_product));
    }, onError: (a) {
      print(a);
    }, onDone: () {});
  }

  void requestForCurrentLocation(BuildContext context) {
    OverlayEntry loader = Helper.overlayLoader(context);
    Overlay.of(context).insert(loader);
    setCurrentLocation().then((_address) async {
      deliveryAddress.notifyListeners();
      await refreshHome();
      loader.remove();
    }).catchError((e) {
      loader.remove();
    });
  }

  Future<void> requestLoc() async {
    print("requestloc");
    var location = Location();
    await location.requestPermission();
    setState(() {});
    print(deliveryAddress.value.toMap());
    if (!deliveryAddress.value.isUnknown()) {
      print("deliveryAddress.value.toMap()");
      // changeCurrentLocation(deliveryAddress.value);
      listenForTopMarkets();
      listenForSlides();
      listenForTrendingProducts();
      listenForCategories();
      listenForPopularMarkets();
      listenForRecentReviews();
      listenForAllMarkets();
    } else {
      print("else");
      setCurrentLocation().then((_address) async {
        print("setcurrentlocation");
        setState(() {});

        // setState(() {});
        print(deliveryAddress.value);
        print(deliveryAddress.value.toMap());
        listenForTopMarkets();
        listenForSlides();
        listenForTrendingProducts();
        listenForCategories();
        listenForPopularMarkets();
        listenForRecentReviews();
        listenForAllMarkets();
        // refreshHome();
      }).catchError((e) {});
    }
  }

  Future<void> refreshHome() async {
    print("refresh");
    setState(() {
      slides = <Slide>[];
      categories = <Category>[];
      topMarkets = <Market>[];
      popularMarkets = <Market>[];
      recentReviews = <Review>[];
      trendingProducts = <Product>[];
      allMarkets = <Market>[];
    });
    await listenForSlides();
    await listenForTopMarkets();
    await listenForTrendingProducts();
    await listenForCategories();
    await listenForPopularMarkets();
    await listenForRecentReviews();
    await listenForAllMarkets();
  }
}
