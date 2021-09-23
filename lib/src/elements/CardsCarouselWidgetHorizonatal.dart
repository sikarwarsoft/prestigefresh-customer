import 'package:flutter/material.dart';
import 'package:markets/src/elements/CardWidget2.dart';

import '../elements/CardsCarouselLoaderWidget.dart';
import '../models/market.dart';
import '../models/route_argument.dart';

// ignore: must_be_immutable
class CardsCarouselWidgetHorizonatal extends StatefulWidget {
  List<Market> marketsList;
  String heroTag;
  int page = 0;

  CardsCarouselWidgetHorizonatal({Key key, this.marketsList, this.heroTag})
      : super(key: key);

  @override
  _CardsCarouselWidgetState createState() => _CardsCarouselWidgetState();
}

class _CardsCarouselWidgetState extends State<CardsCarouselWidgetHorizonatal> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.marketsList.isEmpty
        ? CardsCarouselLoaderWidget()
        : Container(
            child: ListView.builder(
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              scrollDirection: Axis.vertical,
              itemCount: widget.marketsList.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushNamed('/Details',
                        arguments: RouteArgument(
                          id: widget.marketsList.elementAt(index).id,
                          heroTag: widget.heroTag,
                        ));
                  },
                  child: CardWidget2(
                      market: widget.marketsList.elementAt(index),
                      heroTag: widget.heroTag),
                );
              },
            ),
          );
  }
}
