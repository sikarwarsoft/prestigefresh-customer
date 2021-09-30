import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../generated/l10n.dart';
import '../helpers/helper.dart';
import '../models/market.dart';
import '../models/route_argument.dart';
import '../repository/settings_repository.dart';

// ignore: must_be_immutable
class CardWidget2 extends StatelessWidget {
  Market market;
  String heroTag;

  CardWidget2({Key key, this.market, this.heroTag}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 292,
      margin: EdgeInsets.only(left: 20, right: 20, top: 7, bottom: 7),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.all(Radius.circular(10)),
        boxShadow: [
          BoxShadow(
              color: Theme.of(context).focusColor.withOpacity(0.1),
              blurRadius: 15,
              offset: Offset(0, 5)),
        ],
      ),
      child: Row(
        children: <Widget>[
          Container(
              width: 110,
              height: 110,
              child: Stack(
                children: <Widget>[
                  Hero(
                    tag: this.heroTag + market.id,
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10)),
                      child: CachedNetworkImage(
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        imageUrl: market.image.url,
                        placeholder: (context, url) => Image.asset(
                          'assets/img/loading.gif',
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 150,
                        ),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      ),
                    ),
                  ),
                ],
              )),
          new Expanded(
            child: new Container(
              padding: new EdgeInsets.only(left: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          market.name,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                        Text(
                          Helper.skipHtml(market.description),
                          overflow: TextOverflow.fade,
                          softWrap: false,
                          style: Theme.of(context).textTheme.caption,
                        ),
                        SizedBox(height: 5),
                        Row(
                          children:
                              Helper.getStarsList(double.parse(market.rate)),
                        ),
                        Row(
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 3),
                              decoration: BoxDecoration(
                                  color: market.closed
                                      ? Colors.grey
                                      : Colors.green,
                                  borderRadius: BorderRadius.circular(24)),
                              child: market.closed
                                  ? Text(
                                      S.of(context).closed,
                                      style: Theme.of(context)
                                          .textTheme
                                          .caption
                                          .merge(TextStyle(
                                              color: Theme.of(context)
                                                  .primaryColor)),
                                    )
                                  : Text(
                                      S.of(context).open,
                                      style: Theme.of(context)
                                          .textTheme
                                          .caption
                                          .merge(TextStyle(
                                              color: Theme.of(context)
                                                  .primaryColor)),
                                    ),
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 8),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 3),
                              decoration: BoxDecoration(
                                  color: Helper.canDelivery(market)
                                      ? Colors.green
                                      : Colors.orange,
                                  borderRadius: BorderRadius.circular(24)),
                              child: Helper.canDelivery(market)
                                  ? Text(
                                      S.of(context).delivery,
                                      style: Theme.of(context)
                                          .textTheme
                                          .caption
                                          .merge(TextStyle(
                                              color: Theme.of(context)
                                                  .primaryColor)),
                                    )
                                  : Text(
                                      S.of(context).pickup,
                                      style: Theme.of(context)
                                          .textTheme
                                          .caption
                                          .merge(TextStyle(
                                              color: Theme.of(context)
                                                  .primaryColor)),
                                    ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 15),
                ],
              ),
            ),
          ),
          Container(
              width: 50,
              padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
              child: Container(
                child: Column(
                  children: <Widget>[
                    FlatButton(
                      padding: EdgeInsets.all(0),
                      onPressed: () {
                        Navigator.of(context).pushNamed('/Pages',
                            arguments:
                                new RouteArgument(id: '1', param: market));
                      },
                      child: Icon(Icons.directions,
                          color: Theme.of(context).primaryColor),
                      color: Theme.of(context).accentColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                    ),
                    market.distance > 0
                        ? Text(
                            Helper.getDistance(
                                market.distance,
                                Helper.of(context)
                                    .trans(setting.value.distanceUnit,"")),
                            overflow: TextOverflow.fade,
                            maxLines: 1,
                            style: new TextStyle(
                              fontSize: 10.0,
                            ),
                            softWrap: false,
                          )
                        : SizedBox(height: 0)
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
