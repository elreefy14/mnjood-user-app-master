import 'package:mnjood_vendor/common/widgets/custom_card.dart';
import 'package:mnjood_vendor/util/dimensions.dart';
import 'package:mnjood_vendor/util/styles.dart';
import 'package:flutter/material.dart';

class ProfileCardWidget extends StatelessWidget {
  final String title;
  final String data;
  const ProfileCardWidget({super.key, required this.data, required this.title});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: CustomCard(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              data,
              style: robotoBold.copyWith(
                fontSize: Dimensions.fontSizeOverLarge,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: Theme.of(context).hintColor,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}