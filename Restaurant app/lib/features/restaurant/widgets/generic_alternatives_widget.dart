import 'package:flutter/material.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:get/get.dart';
import 'package:mnjood_vendor/features/restaurant/domain/models/product_model.dart';
import 'package:mnjood_vendor/helper/price_converter_helper.dart';
import 'package:mnjood_vendor/util/dimensions.dart';
import 'package:mnjood_vendor/util/styles.dart';

/// Widget for managing generic alternatives for pharmacy products
class GenericAlternativesWidget extends StatefulWidget {
  final List<GenericAlternative>? initialAlternatives;
  final Function(List<GenericAlternative>) onChanged;
  final bool isEnabled;

  const GenericAlternativesWidget({
    super.key,
    this.initialAlternatives,
    required this.onChanged,
    this.isEnabled = true,
  });

  @override
  State<GenericAlternativesWidget> createState() => _GenericAlternativesWidgetState();
}

class _GenericAlternativesWidgetState extends State<GenericAlternativesWidget> {
  late List<GenericAlternative> _alternatives;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  List<GenericAlternative> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _alternatives = widget.initialAlternatives ?? [];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _searchProducts(String query) {
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
      });
      return;
    }

    setState(() => _isSearching = true);

    // TODO: Replace with actual API call
    // Get.find<ProductController>().searchProducts(query).then((results) {
    //   setState(() {
    //     _isSearching = false;
    //     _searchResults = results.map((p) => GenericAlternative(
    //       productId: p.id,
    //       name: p.name,
    //       price: p.price,
    //       imageUrl: p.imageFullUrl,
    //     )).toList();
    //   });
    // });

    // Placeholder search results
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isSearching = false;
          _searchResults = [
            GenericAlternative(
              productId: 1,
              name: 'Generic Medicine A',
              price: 15.0,
            ),
            GenericAlternative(
              productId: 2,
              name: 'Generic Medicine B',
              price: 12.5,
            ),
          ];
        });
      }
    });
  }

  void _addAlternative(GenericAlternative alternative) {
    if (!_alternatives.any((a) => a.productId == alternative.productId)) {
      setState(() {
        _alternatives.add(alternative);
        _searchController.clear();
        _searchResults = [];
      });
      widget.onChanged(_alternatives);
    }
  }

  void _removeAlternative(int productId) {
    setState(() {
      _alternatives.removeWhere((a) => a.productId == productId);
    });
    widget.onChanged(_alternatives);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              Icon(
                HeroiconsOutline.arrowsRightLeft,
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'generic_alternatives'.tr,
                      style: robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeLarge,
                      ),
                    ),
                    Text(
                      'link_similar_medicines'.tr,
                      style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Theme.of(context).disabledColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: Dimensions.paddingSizeDefault),

          // Search field
          if (widget.isEnabled)
            TextField(
              controller: _searchController,
              onChanged: _searchProducts,
              decoration: InputDecoration(
                hintText: 'search_products'.tr,
                prefixIcon: const Icon(HeroiconsOutline.magnifyingGlass),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(HeroiconsOutline.xMark),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchResults = [];
                          });
                        },
                      )
                    : null,
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeDefault,
                  vertical: Dimensions.paddingSizeSmall,
                ),
              ),
            ),

          // Search results
          if (_isSearching)
            const Padding(
              padding: EdgeInsets.all(Dimensions.paddingSizeDefault),
              child: Center(child: CircularProgressIndicator()),
            ),

          if (_searchResults.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).disabledColor.withOpacity(0.3),
                ),
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _searchResults.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final result = _searchResults[index];
                  final isAdded = _alternatives.any(
                    (a) => a.productId == result.productId,
                  );

                  return ListTile(
                    dense: true,
                    title: Text(
                      result.name ?? '',
                      style: robotoMedium,
                    ),
                    subtitle: PriceConverter.convertPriceWithSvg(result.price ?? 0, textStyle: robotoRegular.copyWith(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    trailing: isAdded
                        ? const Icon(HeroiconsOutline.check, color: Colors.green)
                        : IconButton(
                            icon: const Icon(HeroiconsOutline.plusCircle),
                            color: Theme.of(context).primaryColor,
                            onPressed: () => _addAlternative(result),
                          ),
                  );
                },
              ),
            ),

          const SizedBox(height: Dimensions.paddingSizeDefault),

          // Added alternatives
          if (_alternatives.isEmpty)
            Container(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    HeroiconsOutline.informationCircle,
                    color: Theme.of(context).disabledColor,
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Text(
                    'no_alternatives_added'.tr,
                    style: robotoRegular.copyWith(
                      color: Theme.of(context).disabledColor,
                    ),
                  ),
                ],
              ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'linked_alternatives'.tr + ' (${_alternatives.length})',
                  style: robotoMedium.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),
                ..._alternatives.map((alternative) {
                  return _buildAlternativeCard(context, alternative);
                }),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildAlternativeCard(BuildContext context, GenericAlternative alternative) {
    return Container(
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.05),
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        border: Border.all(color: Colors.green.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          // Product image placeholder
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            ),
            child: alternative.imageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    child: Image.network(
                      alternative.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        HeroiconsOutline.beaker,
                        color: Colors.grey[400],
                      ),
                    ),
                  )
                : Icon(
                    HeroiconsOutline.beaker,
                    color: Colors.grey[400],
                  ),
          ),

          const SizedBox(width: Dimensions.paddingSizeSmall),

          // Product info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alternative.name ?? '',
                  style: robotoMedium.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  PriceConverter.convertPrice(alternative.price ?? 0),
                  style: robotoMedium.copyWith(
                    color: Colors.green,
                    fontSize: Dimensions.fontSizeSmall,
                  ),
                ),
              ],
            ),
          ),

          // Remove button
          if (widget.isEnabled)
            IconButton(
              icon: const Icon(HeroiconsOutline.minusCircle, color: Colors.red),
              onPressed: () => _removeAlternative(alternative.productId ?? 0),
            ),
        ],
      ),
    );
  }
}

/// Compact display widget for showing generic alternatives in product details
class GenericAlternativesDisplayWidget extends StatelessWidget {
  final List<GenericAlternative> alternatives;
  final Function(int)? onAlternativeTap;

  const GenericAlternativesDisplayWidget({
    super.key,
    required this.alternatives,
    this.onAlternativeTap,
  });

  @override
  Widget build(BuildContext context) {
    if (alternatives.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.05),
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(color: Colors.green.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(HeroiconsOutline.arrowsRightLeft, color: Colors.green, size: 20),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Text(
                'generic_alternatives'.tr,
                style: robotoBold.copyWith(
                  color: Colors.green,
                  fontSize: Dimensions.fontSizeDefault,
                ),
              ),
            ],
          ),

          const SizedBox(height: Dimensions.paddingSizeDefault),

          ...alternatives.map((alt) {
            return InkWell(
              onTap: onAlternativeTap != null
                  ? () => onAlternativeTap!(alt.productId ?? 0)
                  : null,
              child: Container(
                margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        alt.name ?? '',
                        style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                        ),
                      ),
                    ),
                    Text(
                      PriceConverter.convertPrice(alt.price ?? 0),
                      style: robotoMedium.copyWith(
                        color: Colors.green,
                        fontSize: Dimensions.fontSizeSmall,
                      ),
                    ),
                    if (onAlternativeTap != null)
                      const Icon(
                        HeroiconsOutline.chevronRight,
                        color: Colors.grey,
                        size: 20,
                      ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
