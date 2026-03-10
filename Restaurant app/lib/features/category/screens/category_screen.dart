import 'package:mnjood_vendor/common/widgets/custom_app_bar_widget.dart';
import 'package:mnjood_vendor/common/widgets/custom_image_widget.dart';
import 'package:mnjood_vendor/common/widgets/empty_state_widget.dart';
import 'package:mnjood_vendor/features/category/controllers/category_controller.dart';
import 'package:mnjood_vendor/features/category/domain/models/category_model.dart';
import 'package:mnjood_vendor/helper/business_type_helper.dart';
import 'package:mnjood_vendor/util/dimensions.dart';
import 'package:mnjood_vendor/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isGridView = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    Get.find<CategoryController>().getCategoryList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<CategoryModel> _filterCategories(List<CategoryModel> categories) {
    if (_searchQuery.isEmpty) return categories;
    return categories.where((category) {
      final nameMatch = category.name?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false;
      final hasMatchingChild = category.childes?.any(
        (child) => child.name?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false,
      ) ?? false;
      return nameMatch || hasMatchingChild;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final itemLabel = BusinessTypeHelper.getItemsLabel();

    return Scaffold(
      appBar: CustomAppBarWidget(
        title: 'categories'.tr,
        menuWidget: Row(
          children: [
            // Grid/List toggle
            IconButton(
              onPressed: () => setState(() => _isGridView = !_isGridView),
              icon: Icon(
                _isGridView ? HeroiconsOutline.listBullet : HeroiconsOutline.squares2x2,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
              tooltip: _isGridView ? 'list_view'.tr : 'grid_view'.tr,
            ),
          ],
        ),
      ),
      body: GetBuilder<CategoryController>(builder: (categoryController) {
        List<CategoryModel>? categories;

        if (categoryController.categoryList != null) {
          categories = [];
          categories.addAll(categoryController.categoryList!);
        }

        if (categories == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final filteredCategories = _filterCategories(categories);
        final totalItems = categories.fold<int>(0, (sum, cat) => sum + (cat.productsCount ?? 0));
        final totalSubcategories = categories.fold<int>(0, (sum, cat) => sum + (cat.childesCount ?? 0));

        return RefreshIndicator(
          onRefresh: () async {
            await categoryController.getCategoryList();
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Search and Stats Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  child: Column(
                    children: [
                      // Search Bar
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                          border: Border.all(
                            color: Theme.of(context).primaryColor.withOpacity(0.1),
                          ),
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) => setState(() => _searchQuery = value),
                          decoration: InputDecoration(
                            hintText: 'search_categories'.tr,
                            hintStyle: robotoRegular.copyWith(
                              color: Theme.of(context).hintColor,
                            ),
                            prefixIcon: Icon(
                              HeroiconsOutline.magnifyingGlass,
                              color: Theme.of(context).hintColor,
                            ),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() => _searchQuery = '');
                                    },
                                    icon: Icon(
                                      HeroiconsOutline.xMark,
                                      color: Theme.of(context).hintColor,
                                    ),
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: Dimensions.paddingSizeDefault,
                              vertical: Dimensions.paddingSizeSmall,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: Dimensions.paddingSizeDefault),

                      // Stats Row
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              icon: HeroiconsOutline.squares2x2,
                              value: categories.length.toString(),
                              label: 'categories'.tr,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          const SizedBox(width: Dimensions.paddingSizeSmall),
                          Expanded(
                            child: _StatCard(
                              icon: HeroiconsOutline.folder,
                              value: totalSubcategories.toString(),
                              label: 'subcategories'.tr,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(width: Dimensions.paddingSizeSmall),
                          Expanded(
                            child: _StatCard(
                              icon: HeroiconsOutline.shoppingBag,
                              value: totalItems.toString(),
                              label: itemLabel,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Categories
              if (filteredCategories.isEmpty)
                SliverFillRemaining(
                  child: EmptyStateWidget.noCategories(),
                )
              else if (_isGridView)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.85,
                      crossAxisSpacing: Dimensions.paddingSizeSmall,
                      mainAxisSpacing: Dimensions.paddingSizeSmall,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _CategoryGridCard(
                        category: filteredCategories[index],
                        onTap: () => _showCategoryDetails(filteredCategories[index]),
                      ),
                      childCount: filteredCategories.length,
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => Padding(
                        padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                        child: _CategoryListCard(
                          category: filteredCategories[index],
                          categoryController: categoryController,
                          index: index,
                        ),
                      ),
                      childCount: filteredCategories.length,
                    ),
                  ),
                ),

              const SliverToBoxAdapter(
                child: SizedBox(height: Dimensions.paddingSizeDefault),
              ),
            ],
          ),
        );
      }),
    );
  }

  void _showCategoryDetails(CategoryModel category) {
    if (category.childes == null || category.childes!.isEmpty) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CategoryDetailsSheet(category: category),
    );
  }
}

// Stats Card Widget
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
          ),
          Text(
            label,
            style: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeExtraSmall,
              color: Theme.of(context).hintColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// Grid Card Widget
class _CategoryGridCard extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback onTap;

  const _CategoryGridCard({
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasChildren = (category.childesCount ?? 0) > 0;
    final itemLabel = BusinessTypeHelper.getItemsLabel();

    return GestureDetector(
      onTap: hasChildren ? onTap : null,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).primaryColor.withOpacity(0.05),
              spreadRadius: 0,
              blurRadius: 5,
            ),
          ],
          border: Border.all(
            width: 1,
            color: Theme.of(context).primaryColor.withOpacity(0.08),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(Dimensions.radiusDefault),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CustomImageWidget(
                      image: '${category.imageFullUrl}',
                      fit: BoxFit.cover,
                    ),
                    // Subcategory badge
                    if (hasChildren)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                HeroiconsOutline.folder,
                                size: 12,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${category.childesCount}',
                                style: robotoMedium.copyWith(
                                  color: Colors.white,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      category.name ?? '',
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          HeroiconsOutline.shoppingBag,
                          size: 14,
                          color: Theme.of(context).hintColor,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${category.productsCount ?? 0} $itemLabel',
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: Theme.of(context).hintColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// List Card Widget
class _CategoryListCard extends StatelessWidget {
  final CategoryModel category;
  final CategoryController categoryController;
  final int index;

  const _CategoryListCard({
    required this.category,
    required this.categoryController,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final hasChildren = (category.childesCount ?? 0) > 0;
    final itemLabel = BusinessTypeHelper.getItemsLabel();

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 5,
          ),
        ],
        border: Border.all(
          width: 1,
          color: Theme.of(context).primaryColor.withOpacity(0.08),
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.only(
            left: Dimensions.paddingSizeDefault,
            right: Dimensions.paddingSizeDefault,
            top: Dimensions.paddingSizeExtraSmall,
            bottom: Dimensions.paddingSizeExtraSmall,
          ),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
            child: CustomImageWidget(
              image: '${category.imageFullUrl}',
              height: 60,
              width: 65,
              fit: BoxFit.cover,
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  category.name ?? '',
                  style: robotoMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (hasChildren)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  ),
                  child: Text(
                    '${category.childesCount} ${'sub'.tr}',
                    style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeExtraSmall,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                Icon(
                  HeroiconsOutline.shoppingBag,
                  size: 14,
                  color: Theme.of(context).hintColor,
                ),
                const SizedBox(width: 4),
                Text(
                  '${category.productsCount ?? 0} $itemLabel',
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Theme.of(context).hintColor,
                  ),
                ),
              ],
            ),
          ),
          trailing: SizedBox(
            width: 25,
            child: hasChildren
                ? Icon(
                    categoryController.selectedCategoryIndex == index &&
                            categoryController.isExpanded
                        ? HeroiconsOutline.chevronUp
                        : HeroiconsOutline.chevronDown,
                    size: 24,
                    color: Theme.of(context).textTheme.bodyLarge!.color,
                  )
                : const SizedBox(),
          ),
          onExpansionChanged: (value) {
            categoryController.expandedUpdate(value);
            categoryController.setSelectedCategoryIndex(index);
          },
          children: [
            if (category.childes != null && category.childes!.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(
                  left: Dimensions.paddingSizeDefault,
                  right: Dimensions.paddingSizeDefault,
                  bottom: Dimensions.paddingSizeDefault,
                  top: Dimensions.paddingSizeExtraSmall,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  itemCount: category.childes?.length ?? 0,
                  separatorBuilder: (context, index) => Divider(
                    color: Theme.of(context).hintColor.withOpacity(0.3),
                    height: 20,
                  ),
                  itemBuilder: (context, subIndex) {
                    final child = category.childes![subIndex];
                    return Row(
                      children: [
                        // Subcategory image thumbnail
                        if (child.imageFullUrl != null && child.imageFullUrl!.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                            child: CustomImageWidget(
                              image: '${child.imageFullUrl}',
                              height: 40,
                              width: 40,
                              fit: BoxFit.cover,
                            ),
                          )
                        else
                          Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                            ),
                            child: Icon(
                              HeroiconsOutline.folder,
                              size: 20,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        const SizedBox(width: Dimensions.paddingSizeSmall),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                child.name ?? '',
                                style: robotoMedium,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${child.productsCount ?? 0} $itemLabel',
                                style: robotoRegular.copyWith(
                                  fontSize: Dimensions.fontSizeSmall,
                                  color: Theme.of(context).hintColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          HeroiconsOutline.chevronRight,
                          size: 16,
                          color: Theme.of(context).hintColor,
                        ),
                      ],
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Category Details Bottom Sheet
class _CategoryDetailsSheet extends StatelessWidget {
  final CategoryModel category;

  const _CategoryDetailsSheet({required this.category});

  @override
  Widget build(BuildContext context) {
    final itemLabel = BusinessTypeHelper.getItemsLabel();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(Dimensions.radiusLarge),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).hintColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  child: CustomImageWidget(
                    image: '${category.imageFullUrl}',
                    height: 60,
                    width: 60,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeDefault),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.name ?? '',
                        style: robotoBold.copyWith(
                          fontSize: Dimensions.fontSizeLarge,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${category.childesCount} ${'subcategories'.tr} • ${category.productsCount} $itemLabel',
                        style: robotoRegular.copyWith(
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    HeroiconsOutline.xMark,
                    color: Theme.of(context).hintColor,
                  ),
                ),
              ],
            ),
          ),

          Divider(color: Theme.of(context).hintColor.withOpacity(0.2)),

          // Subcategories List
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              itemCount: category.childes?.length ?? 0,
              separatorBuilder: (context, index) => const SizedBox(height: Dimensions.paddingSizeSmall),
              itemBuilder: (context, index) {
                final child = category.childes![index];
                return Container(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  ),
                  child: Row(
                    children: [
                      if (child.imageFullUrl != null && child.imageFullUrl!.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                          child: CustomImageWidget(
                            image: '${child.imageFullUrl}',
                            height: 50,
                            width: 50,
                            fit: BoxFit.cover,
                          ),
                        )
                      else
                        Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                          ),
                          child: Icon(
                            HeroiconsOutline.folder,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      const SizedBox(width: Dimensions.paddingSizeDefault),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              child.name ?? '',
                              style: robotoMedium,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  HeroiconsOutline.shoppingBag,
                                  size: 14,
                                  color: Theme.of(context).hintColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${child.productsCount ?? 0} $itemLabel',
                                  style: robotoRegular.copyWith(
                                    fontSize: Dimensions.fontSizeSmall,
                                    color: Theme.of(context).hintColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        HeroiconsOutline.chevronRight,
                        color: Theme.of(context).hintColor,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
