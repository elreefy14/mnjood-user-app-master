import 'package:mnjood_vendor/util/dimensions.dart';
import 'package:mnjood_vendor/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';

class RatingBarWidget extends StatelessWidget {
  final double? rating;
  final double size;
  final int? ratingCount;
  const RatingBarWidget({super.key, required this.rating, required this.ratingCount, this.size = 18});

  @override
  Widget build(BuildContext context) {

    List<Widget> starList = [];

    int realNumber = rating!.floor();
    int partNumber = ((rating! - realNumber) * 10).ceil();

    for (int i = 0; i < 5; i++) {
      if (i < realNumber) {
        starList.add(Icon(HeroiconsSolid.star, color: Theme.of(context).primaryColor, size: size));
      } else if (i == realNumber) {
        starList.add(SizedBox(
          height: size,
          width: size,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Icon(HeroiconsSolid.star, color: Theme.of(context).primaryColor, size: size),
              ClipRect(
                clipper: _Clipper(part: partNumber),
                child: Icon(HeroiconsSolid.star, color: Colors.grey, size: size),
              )
            ],
          ),
        ));
      } else {
        starList.add(Icon(HeroiconsSolid.star, color: Colors.grey, size: size));
      }
    }
    ratingCount != null ? starList.add(Padding(
      padding: const EdgeInsets.only(left: Dimensions.paddingSizeExtraSmall),
      child: Text('($ratingCount)', style: robotoRegular.copyWith(fontSize: size*0.8, color: Theme.of(context).hintColor)),
    )) : const SizedBox();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: starList,
    );
  }
}

class _Clipper extends CustomClipper<Rect> {
  final int part;

  _Clipper({required this.part});

  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(
      (size.width / 10) * part,
      0.0,
      size.width,
      size.height,
    );
  }

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) => true;
}