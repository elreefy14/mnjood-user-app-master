import 'package:mnjood/features/language/domain/models/language_model.dart';
import 'package:mnjood/util/images.dart';
import 'package:get/get.dart';

class AppConstants {
  static const String appName = 'Mnjood';
  static const double appVersion = 8.5; /// StackFood API version (sent in headers, do not change without backend update)

  static const String fontFamily = 'GraphikArabic';
  static const String headingFontFamily = 'GraphikArabic';
  static const bool payInWevView = false;
  static const String webHostedUrl = 'https://mnjood.sa';
  static const bool useReactWebsite = false;
  static const String googleServerClientId = '491987943015-agln6biv84krpnngdphj87jkko7r9lb8.apps.googleusercontent.com';

  static const String baseUrl = 'https://mnjood.sa';
  static const String bannerUri = '/api/v3/banners';
  static const String slidersUri = '/api/v1/mobile-app-sliders';
  static const String mainCategoriesUri = '/api/v3/main-categories';
  static const String restaurantCategoriesUri = '/api/v1/restaurant-categories';
  static const String supermarketCategoriesUri = '/api/v1/supermarket-categories';
  static const String pharmacyCategoriesUri = '/api/v1/pharmacy-categories';
  static const String coffeeShopCategoriesUri = '/api/v1/coffee-shop-categories';
  // Coffee Shop API endpoints (Base: /api/v1/coffee)
  static const String coffeeShopListUri = '/api/v1/coffee/list';
  static const String coffeeShopProductsUri = '/api/v1/coffee/products';
  static const String coffeeShopTopRatedProductsUri = '/api/v1/coffee/products/top-rated';
  static const String coffeeShopRecommendedProductsUri = '/api/v1/coffee/products/recommended';
  static const String coffeeShopPopularProductsUri = '/api/v1/coffee/products/popular';
  static const String coffeeShopDetailsUri = '/api/v1/coffee/';  // Append {shop_id}/info
  static const String coffeeShopCategoryProductsUri = '/api/v1/coffee/';  // Append {shop_id}/categories
  static const String coffeeShopFiltersUri = '/api/v1/coffee/';  // Append {shop_id}/filters
  static const String coffeeShopItemsUri = '/api/v1/coffee/';  // Append {shop_id}/products
  static const String coffeeShopProductDetailsUri = '/api/v1/coffee/';  // Append {shop_id}/products/{product_id}
  static const String restaurantProductUri = '/api/v3/products?sort_by=latest';
  static const String popularProductUri = '/api/v3/products?sort_by=popular';
  static const String reviewedProductUri = '/api/v3/products?sort_by=most_reviewed';
  static const String subCategoryUri = '/api/v3/categories/';  // Append {id}/children
  static const String categoryProductUri = '/api/v3/categories/';  // Append {id}/products
  static const String categoryRestaurantUri = '/api/v3/categories/';  // Append {id}/vendors
  static const String configUri = '/api/v3/config/app';
  static const String trackUri = '/api/v3/orders/';  // Append {id}/track
  static const String messageUri = '/api/v3/customers/me/messages';
  static const String forgetPasswordUri = '/api/v3/auth/customers/password/forgot';
  static const String verifyTokenUri = '/api/v3/auth/customers/verify-token';
  static const String resetPasswordUri = '/api/v3/auth/customers/password/reset';
  static const String verifyPhoneUri = '/api/v3/auth/customers/verify-phone';
  static const String checkEmailUri = '/api/v3/auth/customers/check-email';
  static const String verifyEmailUri = '/api/v3/auth/customers/verify-email';
  static const String registerUri = '/api/v3/auth/customers/register';
  static const String loginUri = '/api/v3/auth/customers/login';
  static const String tokenUri = '/api/v3/customers/me/fcm-token';
  static const String placeOrderUri = '/api/v3/orders';
  static const String addressListUri = '/api/v3/customers/me/addresses';
  static const String zoneUri = '/api/v3/config/zones';
  static const String checkZoneUri = '/api/v3/zones/check';
  static const String removeAddressUri = '/api/v3/customers/me/addresses/';  // Append {id} for DELETE
  static const String addAddressUri = '/api/v3/customers/me/addresses';
  static const String updateAddressUri = '/api/v3/customers/me/addresses/';  // Append {id} for PATCH
  static const String setMenuUri = '/api/v3/products/set-menu';
  static const String customerInfoUri = '/api/v3/customers/me';
  static const String couponUri = '/api/v3/customers/me/coupons';
  static const String restaurantWiseCouponUri = '/api/v3/coupons/vendor-wise';
  static const String couponApplyUri = '/api/v3/coupons/apply?code=';
  // Running orders: all orders except delivered, completed, cancelled
  static const String runningOrderListUri = '/api/v3/customers/me/orders/running';
  static const String runningSubscriptionOrderListUri = '/api/v3/customers/me/orders/subscriptions';
  static const String historyOrderListUri = '/api/v3/customers/me/orders';
  static const String orderCancelUri = '/api/v3/orders/';  // Append {id}/cancel for PATCH
  static const String codSwitchUri = '/api/v3/orders/';  // Append {id}/payment-method
  static const String orderDetailsUri = '/api/v3/orders/';
  static const String wishListGetUri = '/api/v3/customers/me/wishlist';
  static const String addWishListUri = '/api/v3/customers/me/wishlist';  // POST with body {restaurant_id: x} or {food_id: x}
  static const String removeWishListUri = '/api/v3/customers/me/wishlist/';  // DELETE: Append {type}/{id}
  static const String notificationUri = '/api/v3/customers/me/notifications';
  static const String updateProfileUri = '/api/v3/customers/me';  // Use PATCH method
  static const String searchUri = '/api/v3/';
  static const String productSearchUri = '/api/v3/search/search';
  static const String reviewUri = '/api/v3/reviews';  // POST to submit review
  static const String productDetailsUri = '/api/v3/products/';
  static const String lastLocationUri = '/api/v3/delivery-men/';  // Append {id}/location?order_id=
  static const String deliveryManReviewUri = '/api/v3/delivery-men/reviews';
  // V3 Vendor endpoints - supports restaurants, supermarkets, and pharmacies
  static const String restaurantUri = '/api/v3/vendors/restaurants';
  static const String popularRestaurantUri = '/api/v3/vendors/restaurants?sort_by=popular';
  static const String latestRestaurantUri = '/api/v3/vendors/restaurants?sort_by=latest';
  static const String restaurantDetailsUri = '/api/v3/vendors/restaurants/';
  static const String supermarketDetailsUri = '/api/v3/vendors/supermarkets/';
  static const String pharmacyDetailsUri = '/api/v3/vendors/pharmacies/';
  static const String supermarketsUri = '/api/v3/vendors/supermarkets';
  static const String pharmaciesUri = '/api/v3/vendors/pharmacies';
  // Discount endpoints for each business type
  static const String restaurantDiscountsUri = '/api/v3/vendors/restaurants/discounts';
  static const String supermarketDiscountsUri = '/api/v3/vendors/supermarkets/discounts';
  static const String pharmacyDiscountsUri = '/api/v3/vendors/pharmacies/discounts';
  // Filter endpoints for each business type (V1 API)
  static const String restaurantFiltersUri = '/api/v1/restaurant-food/';  // Append {id}/filters
  static const String supermarketFiltersUri = '/api/v1/mnjood-mart/filters';  // No ID needed
  static const String pharmacyFiltersUri = '/api/v1/pharmacy/';  // Append {id}/filters
  static const String basicCampaignUri = '/api/v3/campaigns/basic';
  static const String itemCampaignUri = '/api/v3/campaigns/items';
  static const String basicCampaignDetailsUri = '/api/v3/campaigns/basic/';  // Append {id}
  static const String interestUri = '/api/v3/customers/me/interests';
  static const String suggestedFoodUri = '/api/v3/customers/me/suggested-products';
  static const String restaurantReviewUri = '/api/v3/vendors/restaurants/';  // Append {id}/reviews
  static const String distanceMatrixUri = '/api/v3/config/distance';
  static const String searchLocationUri = '/api/v3/config/places/autocomplete';
  static const String placeDetailsUri = '/api/v3/config/places/details';
  static const String geocodeUri = '/api/v3/config/geocode';
  static const String updateZoneUri = '/api/v3/customers/me/zone';
  static const String walletTransactionUri = '/api/v3/customers/me/wallet/transactions';
  static const String loyaltyTransactionUri = '/api/v3/customers/me/loyalty-points/transactions';
  static const String loyaltyPointTransferUri = '/api/v3/customers/me/loyalty-points/transfer';
  static const String customerRemoveUri = '/api/v3/customers/me';  // Use DELETE method
  static const String conversationListUri = '/api/v1/customer/message/list';
  static const String searchConversationListUri = '/api/v1/customer/message/search-list';
  static const String messageListUri = '/api/v1/customer/message/details';
  static const String sendMessageUri = '/api/v1/customer/message/send';
  static const String zoneListUri = '/api/v3/config/zones';
  static const String restaurantRegisterUri = '/api/v3/auth/vendors/register';
  static const String dmRegisterUri = '/api/v3/auth/delivery-men/register';
  static const String refundReasonsUri = '/api/v3/orders/refund-reasons';
  static const String refundRequestUri = '/api/v3/orders/';  // Append {id}/refund (POST)
  static const String orderCancellationUri = '/api/v3/orders/cancellation-reasons';
  static const String cuisineUri = '/api/v3/cuisines';
  static const String cuisineRestaurantUri = '/api/v3/cuisines/';  // Append {id}/vendors
  static const String restaurantRecommendedItemUri = '/api/v3/products/recommended';
  static const String vehicleChargeUri = '/api/v3/config/vehicles/extra-charge';
  static const String vehiclesUri = '/api/v3/vehicles';
  static const String productListWithIdsUri = '/api/v3/products/by-ids';
  static const String recentlyViewedRestaurantUri = '/api/v3/vendors/restaurants/recently-viewed';
  static const String subscriptionListUri = '/api/v3/customers/me/subscriptions';
  static const String sendCheckoutNotificationUri = '/api/v3/orders/send-notification';
  static const String cartRestaurantSuggestedItemsUri = '/api/v3/products/recommended/most-reviewed';
  static const String aboutUsUri = '/about-us';
  static const String privacyPolicyUri = '/privacy-policy';
  static const String termsAndConditionUri = '/terms-and-conditions';
  static const String cancellationUri = '/cancellation-policy';
  static const String refundUri = '/refund-policy';
  static const String shippingPolicyUri = '/shipping-policy';
  static const String subscriptionUri = '/api/v3/newsletter/subscribe';
  static const String addFundUri = '/api/v3/customers/me/wallet/add-funds';
  static const String walletBonusUri = '/api/v3/customers/me/wallet/bonuses';
  static const String mostTipsUri = '/api/v3/tips/popular';
  static const String orderAgainUri = '/api/v3/customers/me/orders/order-again';
  static const String guestLoginUri = '/api/v3/auth/guests/request';
  static const String offlineMethodListUri = '/api/v3/config/payment-methods/offline';
  static const String offlinePaymentSaveInfoUri = '/api/v3/orders/';  // Append {id}/offline-payment (POST)
  static const String offlinePaymentUpdateInfoUri = '/api/v3/orders/';  // Append {id}/offline-payment (PATCH)
  static const String searchSuggestionsUri = '/api/v3/search/suggestions';
  static const String cashBackOfferListUri = '/api/v3/cashback/offers';
  static const String getCashBackAmountUri = '/api/v3/cashback/calculate';
  static const String advertisementListUri = '/api/v3/advertisements';
  static const String personalInformationUri = '/api/v3/auth/customers/update-info';
  static const String firebaseAuthVerify = '/api/v3/auth/customers/firebase-verify';
  static const String firebaseResetPassword = '/api/v3/auth/customers/firebase-reset-password';
  static const String dineInRestaurantListUri = '/api/v3/vendors/restaurants/dine-in';
  static const String checkRestaurantValidation = '/api/v3/orders/validate-vendor';
  static const String vendorBannersUri = '/api/v3/vendors/';  // Append {id}/banners
  // Business-type specific product endpoints
  static const String supermarketProductsUri = '/api/v3/vendors/supermarkets/';  // Append {id}/products
  static const String mnjoodMartProductsUri = '/api/v1/mnjood-mart/products';  // Mnjood Mart dedicated endpoint
  static const String pharmacyProductsUri = '/api/v3/vendors/pharmacies/';  // Append {id}/products
  static const String getOrderTaxUri = '/api/v3/orders/calculate-tax';
  // Homepage sections - Top Pharmacies and Supermarket Categories
  static const String popularPharmaciesUri = '/api/v3/pharmacies/popular';
  static const String popularSupermarketCategoriesUri = '/api/v3/supermarkets/categories/popular';
  static const String homeSectionsUri = '/api/v1/home/sections';
  static const String otpSendUri = '/api/v3/auth/customers/otp/send';
  static const String otpVerifyUri = '/api/v3/auth/customers/otp/verify';
  static const String moyasarVerifyUri = '/api/v3/payment/moyasar/verify';
  static const String initializePaymentUri = '/api/v3/payment/initialize';

  /// Substitution
  static const String substitutionProposalsUri = '/api/v1/customer/order/substitution-proposals';
  static const String substitutionRespondUri = '/api/v1/customer/order/substitution-respond';

  /// Order Chat
  static const String orderChatListUri = '/api/v1/customer/order-chat/list';
  static const String orderChatSendUri = '/api/v1/customer/order-chat/send';
  static const String orderChatMarkReadUri = '/api/v1/customer/order-chat/mark-read';

  /// POS (Point of Sale) Endpoints
  static const String posPlaceOrderUri = '/api/v1/vendor/pos/place-order';
  static const String posOrdersUri = '/api/v1/vendor/pos/orders';
  static const String posCustomersUri = '/api/v1/vendor/pos/customers';
  static const String posOrderStatusUri = '/api/v1/vendor/pos/orders/';  // Append {id}/status (PATCH)

  ///Subscription (Vendor-related, may not be used in customer app)
  static const String businessPlanUri = '/api/v3/vendors/business-plans';
  static const String businessPlanPaymentUri = '/api/v3/vendors/subscriptions/payment';
  static const String restaurantPackagesUri = '/api/v3/vendors/packages';

  /// Cart
  static const String getCartListUri = '/api/v3/carts';  // Append {cartId} to get specific cart
  static const String addCartUri = '/api/v3/carts';  // POST to create cart
  static const String updateCartUri = '/api/v3/carts/';  // Append {cartId}/items/{itemId} (PATCH)
  static const String removeAllCartUri = '/api/v3/carts/';  // Append {cartId} (DELETE)
  static const String removeItemCartUri = '/api/v3/carts/';  // Append {cartId}/items/{itemId} (DELETE)
  static const String addMultipleItemCartUri = '/api/v3/carts/';  // Append {cartId}/items/bulk (POST)

  /// Shared Key
  static const String theme = 'theme';
  static const String token = 'multivendor_token';
  static const String countryCode = 'country_code';
  static const String languageCode = 'language_code';
  static const String cacheCountryCode = 'cache_country_code';
  static const String cacheLanguageCode = 'cache_language_code';
  static const String cartList = 'cart_list';
  static const String userPassword = 'user_password';
  static const String userAddress = 'user_address';
  static const String userNumber = 'user_number';
  static const String userCountryCode = 'user_country_code';
  static const String userOtpPhoneNumber = 'user_otp_phone_number';
  static const String notification = 'notification';
  static const String searchHistory = 'search_history';
  static const String intro = 'intro';
  static const String notificationCount = 'notification_count';
  static const String notificationIdList = 'notification_id_list';
  static const String topic = 'all_zone_customer';
  static const String zoneId = 'zoneId';
  static const String localizationKey = 'X-localization';
  static const String latitude = 'latitude';
  static const String longitude = 'longitude';
  static const String earnPoint = 'mnjood_earn_point';
  static const String acceptCookies = 'mnjood_accept_cookies';
  static const String cookiesManagement = 'cookies_management';
  static const String dmTipIndex = 'mnjood_dm_tip_index';
  static const String walletAccessToken = 'mnjood_wallet_access_token';
  static const String guestId = 'mnjood_guest_id';
  static const String guestNumber = 'mnjood_guest_number';
  static const String dmRegisterSuccess = 'mnjood_dm_registration_success';
  static const String isRestaurantRegister = 'mnjood_restaurant_registration';
  static const String referBottomSheet = 'mnjood_reffer_bottomsheet_show';
  static const String maintenanceModeTopic = 'maintenance_mode_user_app';
  static const String demoResetTopic = 'mnjood_demo_reset';
  static const String configCacheKey = 'mnjood_config_cache';


  ///Refer & Earn work flow list..
  static final dataList = [
    'invite_your_friends_and_business'.tr,
    '${'they_register'.tr} ${AppConstants.appName} ${'with_special_offer'.tr}',
    'you_made_your_earning'.tr,
  ];

  /// Delivery Tips
  static List<String> tips = ['0' ,'15', '10', '20', '40', 'custom'];

  static List<String> deliveryInstructionList = [
    'Deliver to front door',
    'Deliver to the reception desk',
    'Avoid calling me',
  ];

  /// Deep Links
  static const String yourScheme = 'Mnjood';
  static const String yourHost = 'mnjood.sa';

  /// Languages
  static List<LanguageModel> languages = [
    LanguageModel(imageUrl: Images.english, languageName: 'English', countryCode: 'US', languageCode: 'en'),
    LanguageModel(imageUrl: Images.saudiArabia, languageName: 'العربية', countryCode: 'SA', languageCode: 'ar'),
  ];

  static List<String> joinDropdown = [
    'join_us',
    'become_a_vendor',
    'become_a_delivery_man'
  ];

  ///Wallet
  static final List<Map<String, String>> walletTransactionSortingList = [
    {
      'title' : 'all_transactions',
      'value' : 'all'
    },
    {
      'title' : 'order_transactions',
      'value' : 'order'
    },
    {
      'title' : 'converted_from_loyalty_point',
      'value' : 'loyalty_point'
    },
    {
      'title' : 'added_via_payment_method',
      'value' : 'add_fund'
    },
    {
      'title' : 'earned_by_referral',
      'value' : 'referrer'
    },
    {
      'title' : 'cash_back_transactions',
      'value' : 'CashBack'
    },
  ];
}
