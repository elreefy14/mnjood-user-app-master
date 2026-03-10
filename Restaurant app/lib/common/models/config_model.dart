class ConfigModel {
  String? businessName;
  String? logoFullUrl;
  String? address;
  String? phone;
  String? email;
  String? currencySymbol;
  bool? cashOnDelivery;
  bool? digitalPayment;
  String? termsAndConditions;
  String? privacyPolicy;
  String? aboutUs;
  String? country;
  DefaultLocation? defaultLocation;
  String? appUrl;
  bool? customerVerification;
  bool? orderDeliveryVerification;
  String? currencySymbolDirection;
  int? appMinimumVersion;
  bool? demo;
  bool? scheduleOrder;
  bool? instantOrder;
  String? orderConfirmationModel;
  bool? showDmEarning;
  bool? canceledByDeliveryman;
  bool? canceledByRestaurant;
  String? timeformat;
  bool? toggleVegNonVeg;
  bool? toggleDmRegistration;
  bool? toggleRestaurantRegistration;
  bool? maintenanceMode;
  String? appUrlAndroidRestaurant;
  String? appUrlIosRestaurant;
  List<Language>? language;
  int? scheduleOrderSlotDuration;
  int? digitAfterDecimalPoint;
  double? adminCommission;
  String? footerText;
  double? appMinimumVersionAndroid;
  double? appMinimumVersionIos;
  bool? takeAway;
  String? additionalChargeName;
  bool? dmPictureUploadStatus;
  List<PaymentBody>? activePaymentMethodList;
  RestaurantAdditionalJoinUsPageData? restaurantAdditionalJoinUsPageData;
  String? disbursementType;
  double? minAmountToPayRestaurant;
  bool? restaurantReviewReply;
  bool? extraPackagingChargeStatus;
  String? favIconFullUrl;
  int? taxIncluded;
  MaintenanceModeData? maintenanceModeData;
  int? subscriptionDeadlineWarningDays;
  String? subscriptionDeadlineWarningMessage;
  int? subscriptionFreeTrialDays;
  bool? subscriptionFreeTrialStatus;
  int? subscriptionBusinessModel;
  int? commissionBusinessModel;
  String? subscriptionFreeTrialType;
  bool? dineInOrderOption;
  String? systemTaxType;
  int? systemTaxIncludeStatus;
  bool? isSmsActive;
  bool? isMailActive;

  ConfigModel({
    this.businessName,
    this.logoFullUrl,
    this.address,
    this.phone,
    this.email,
    this.currencySymbol,
    this.cashOnDelivery,
    this.digitalPayment,
    this.termsAndConditions,
    this.privacyPolicy,
    this.aboutUs,
    this.country,
    this.defaultLocation,
    this.appUrl,
    this.customerVerification,
    this.orderDeliveryVerification,
    this.currencySymbolDirection,
    this.appMinimumVersion,
    this.demo,
    this.scheduleOrder,
    this.instantOrder,
    this.orderConfirmationModel,
    this.showDmEarning,
    this.canceledByDeliveryman,
    this.canceledByRestaurant,
    this.timeformat,
    this.toggleVegNonVeg,
    this.toggleDmRegistration,
    this.toggleRestaurantRegistration,
    this.maintenanceMode,
    this.appUrlAndroidRestaurant,
    this.appUrlIosRestaurant,
    this.language,
    this.scheduleOrderSlotDuration,
    this.digitAfterDecimalPoint,
    this.adminCommission,
    this.footerText,
    this.appMinimumVersionAndroid,
    this.appMinimumVersionIos,
    this.takeAway,
    this.additionalChargeName,
    this.dmPictureUploadStatus,
    this.activePaymentMethodList,
    this.restaurantAdditionalJoinUsPageData,
    this.disbursementType,
    this.minAmountToPayRestaurant,
    this.restaurantReviewReply,
    this.extraPackagingChargeStatus,
    this.favIconFullUrl,
    this.taxIncluded,
    this.maintenanceModeData,
    this.subscriptionDeadlineWarningDays,
    this.subscriptionDeadlineWarningMessage,
    this.subscriptionFreeTrialDays,
    this.subscriptionFreeTrialStatus,
    this.subscriptionBusinessModel,
    this.commissionBusinessModel,
    this.subscriptionFreeTrialType,
    this.dineInOrderOption,
    this.systemTaxType,
    this.systemTaxIncludeStatus,
    this.isSmsActive,
    this.isMailActive,
  });

  ConfigModel.fromJson(Map<String, dynamic> json) {
    businessName = json['business_name']?.toString();
    logoFullUrl = json['logo_full_url']?.toString();
    address = json['address']?.toString();
    phone = json['phone']?.toString();
    email = json['email']?.toString();
    currencySymbol = json['currency_symbol']?.toString();
    cashOnDelivery = json['cash_on_delivery'];
    // Handle both bool and map formats for digital_payment
    if (json['digital_payment'] is bool) {
      digitalPayment = json['digital_payment'];
    } else if (json['digital_payment_info'] is Map) {
      digitalPayment = json['digital_payment_info']['digital_payment'];
    } else {
      digitalPayment = false;
    }
    termsAndConditions = json['terms_and_conditions']?.toString();
    privacyPolicy = json['privacy_policy']?.toString();
    aboutUs = json['about_us']?.toString();
    country = json['country']?.toString();
    defaultLocation = json['default_location'] != null ? DefaultLocation.fromJson(json['default_location']) : null;
    appUrl = json['app_url']?.toString();
    customerVerification = json['customer_verification'];
    orderDeliveryVerification = json['order_delivery_verification'];
    currencySymbolDirection = json['currency_symbol_direction']?.toString();
    appMinimumVersion = json['app_minimum_version'];
    demo = json['demo'];
    scheduleOrder = json['schedule_order'];
    instantOrder = json['instant_order'];
    orderConfirmationModel = json['order_confirmation_model']?.toString();
    showDmEarning = json['show_dm_earning'];
    canceledByDeliveryman = json['canceled_by_deliveryman'];
    canceledByRestaurant = json['canceled_by_restaurant'];
    timeformat = json['timeformat']?.toString();
    toggleVegNonVeg = json['toggle_veg_non_veg'];
    toggleDmRegistration = json['toggle_dm_registration'];
    toggleRestaurantRegistration = json['toggle_restaurant_registration'];
    maintenanceMode = json['maintenance_mode'];
    appUrlAndroidRestaurant = json['app_url_android_restaurant']?.toString();
    appUrlIosRestaurant = json['app_url_ios_restaurant']?.toString();
    if (json['language'] != null) {
      language = [];
      json['language'].forEach((v) {
        language!.add(Language.fromJson(v));
      });
    }
    scheduleOrderSlotDuration = json['schedule_order_slot_duration'];
    digitAfterDecimalPoint = json['digit_after_decimal_point'];
    adminCommission = json['admin_commission']?.toDouble();
    footerText = json['footer_text']?.toString();
    appMinimumVersionAndroid = json['app_minimum_version_android_restaurant'] != null ? json['app_minimum_version_android_restaurant']?.toDouble() : 0.0;
    appMinimumVersionIos = json['app_minimum_version_ios_restaurant'] != null ? json['app_minimum_version_ios_restaurant']?.toDouble() : 0.0;
    takeAway = json['take_away'];
    additionalChargeName = json['additional_charge_name']?.toString();
    dmPictureUploadStatus = json['dm_picture_upload_status'] == 1 ? true : false;
    if (json['active_payment_method_list'] != null) {
      activePaymentMethodList = <PaymentBody>[];
      json['active_payment_method_list'].forEach((v) {
        activePaymentMethodList!.add(PaymentBody.fromJson(v));
      });
    }
    restaurantAdditionalJoinUsPageData = json['restaurant_additional_join_us_page_data'] != null ? RestaurantAdditionalJoinUsPageData.fromJson(json['restaurant_additional_join_us_page_data']) : null;
    disbursementType = json['disbursement_type']?.toString();
    minAmountToPayRestaurant = json['min_amount_to_pay_restaurant']?.toDouble();
    restaurantReviewReply = json['restaurant_review_reply'];
    extraPackagingChargeStatus = json['extra_packaging_charge'];
    favIconFullUrl = json['fav_icon_full_url']?.toString();
    taxIncluded = json['tax_included'];
    maintenanceModeData = json['maintenance_mode_data'] != null ? MaintenanceModeData.fromJson(json['maintenance_mode_data']) : null;
    subscriptionDeadlineWarningDays = json['subscription_deadline_warning_days'];
    subscriptionDeadlineWarningMessage = json['subscription_deadline_warning_message']?.toString();
    subscriptionFreeTrialDays = json['subscription_free_trial_days'];
    subscriptionFreeTrialStatus = json['subscription_free_trial_status'] == 1 ? true : false;
    subscriptionBusinessModel = json['subscription_business_model'];
    commissionBusinessModel = json['commission_business_model'];
    subscriptionFreeTrialType = json['subscription_free_trial_type']?.toString();
    dineInOrderOption = json['dine_in_order_option'] == 1;
    systemTaxType = json['system_tax_type']?.toString();
    systemTaxIncludeStatus = json['system_tax_include_status'];
    isSmsActive = json['is_sms_active'];
    isMailActive = json['is_mail_active'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['business_name'] = businessName;
    data['logo_full_url'] = logoFullUrl;
    data['address'] = address;
    data['phone'] = phone;
    data['email'] = email;
    data['currency_symbol'] = currencySymbol;
    data['cash_on_delivery'] = cashOnDelivery;
    data['digital_payment'] = digitalPayment;
    data['terms_and_conditions'] = termsAndConditions;
    data['privacy_policy'] = privacyPolicy;
    data['about_us'] = aboutUs;
    data['country'] = country;
    if (defaultLocation != null) {
      data['default_location'] = defaultLocation!.toJson();
    }
    data['app_url'] = appUrl;
    data['customer_verification'] = customerVerification;
    data['order_delivery_verification'] = orderDeliveryVerification;
    data['currency_symbol_direction'] = currencySymbolDirection;
    data['app_minimum_version'] = appMinimumVersion;
    data['demo'] = demo;
    data['schedule_order'] = scheduleOrder;
    data['instant_order'] = instantOrder;
    data['order_confirmation_model'] = orderConfirmationModel;
    data['show_dm_earning'] = showDmEarning;
    data['canceled_by_deliveryman'] = canceledByDeliveryman;
    data['canceled_by_restaurant'] = canceledByRestaurant;
    data['timeformat'] = timeformat;
    data['toggle_veg_non_veg'] = toggleVegNonVeg;
    data['toggle_dm_registration'] = toggleDmRegistration;
    data['toggle_restaurant_registration'] = toggleRestaurantRegistration;
    data['maintenance_mode'] = maintenanceMode;
    data['app_url_android_restaurant'] = appUrlAndroidRestaurant;
    data['app_url_ios_restaurant'] = appUrlIosRestaurant;
    if (language != null) {
      data['language'] = language!.map((v) => v.toJson()).toList();
    }
    data['schedule_order_slot_duration'] = scheduleOrderSlotDuration;
    data['digit_after_decimal_point'] = digitAfterDecimalPoint;
    data['footer_text'] = footerText;
    data['app_minimum_version_android'] = appMinimumVersionAndroid;
    data['app_minimum_version_ios'] = appMinimumVersionIos;
    data['take_away'] = takeAway;
    data['additional_charge_name'] = additionalChargeName;
    data['dm_picture_upload_status'] = dmPictureUploadStatus;
    if (activePaymentMethodList != null) {
      data['active_payment_method_list'] = activePaymentMethodList!.map((v) => v.toJson()).toList();
    }
    if (restaurantAdditionalJoinUsPageData != null) {
      data['restaurant_additional_join_us_page_data'] = restaurantAdditionalJoinUsPageData!.toJson();
    }
    data['disbursement_type'] = disbursementType;
    data['min_amount_to_pay_restaurant'] = minAmountToPayRestaurant;
    data['restaurant_review_reply'] = restaurantReviewReply;
    data['extra_packaging_charge'] = extraPackagingChargeStatus;
    data['fav_icon_full_url'] = favIconFullUrl;
    data['tax_included'] = taxIncluded;
    if (maintenanceModeData != null) {
      data['maintenance_mode_data'] = maintenanceModeData!.toJson();
    }
    data['subscription_deadline_warning_days'] = subscriptionDeadlineWarningDays;
    data['subscription_deadline_warning_message'] = subscriptionDeadlineWarningMessage;
    data['subscription_free_trial_days'] = subscriptionFreeTrialDays;
    data['subscription_free_trial_status'] = subscriptionFreeTrialStatus;
    data['subscription_business_model'] = subscriptionBusinessModel;
    data['commission_business_model'] = commissionBusinessModel;
    data['subscription_free_trial_type'] = subscriptionFreeTrialType;
    data['dine_in_order_option'] = dineInOrderOption;
    data['system_tax_type'] = systemTaxType;
    data['system_tax_include_status'] = systemTaxIncludeStatus;
    data['is_sms_active'] = isSmsActive;
    data['is_mail_active'] = isMailActive;
    return data;
  }
}

class DefaultLocation {
  String? lat;
  String? lng;

  DefaultLocation({this.lat, this.lng});

  DefaultLocation.fromJson(Map<String, dynamic> json) {
    lat = json['lat']?.toString();
    lng = json['lng']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['lat'] = lat;
    data['lng'] = lng;
    return data;
  }
}

class Language {
  String? key;
  String? value;

  Language({this.key, this.value});

  Language.fromJson(Map<String, dynamic> json) {
    key = json['key']?.toString();
    value = json['value']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['key'] = key;
    data['value'] = value;
    return data;
  }
}

class PaymentBody {
  String? getWay;
  String? getWayTitle;
  String? getWayImageFullUrl;

  PaymentBody({this.getWay, this.getWayTitle, this.getWayImageFullUrl});

  PaymentBody.fromJson(Map<String, dynamic> json) {
    getWay = json['gateway']?.toString();
    getWayTitle = json['gateway_title']?.toString();
    getWayImageFullUrl = json['gateway_image_full_url']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['gateway'] = getWay;
    data['gateway_title'] = getWayTitle;
    data['gateway_image_full_url'] = getWayImageFullUrl;
    return data;
  }
}

class RestaurantAdditionalJoinUsPageData {
  List<Data>? data;

  RestaurantAdditionalJoinUsPageData({this.data});

  RestaurantAdditionalJoinUsPageData.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  String? fieldType;
  String? inputData;
  List<String>? checkData;
  MediaData? mediaData;
  String? placeholderData;
  int? isRequired;

  Data({
    this.fieldType,
    this.inputData,
    this.checkData,
    this.mediaData,
    this.placeholderData,
    this.isRequired,
  });

  Data.fromJson(Map<String, dynamic> json) {
    fieldType = json['field_type']?.toString();
    inputData = json['input_data']?.toString();
    // checkData = json['check_data'].cast<String>();

    if (json['check_data'] != null) {
      checkData = [];
      json['check_data'].forEach((e) => checkData!.add(e.toString()));
    }
    mediaData = json['media_data'] != null ? MediaData.fromJson(json['media_data']) : null;
    placeholderData = json['placeholder_data']?.toString();
    isRequired = json['is_required'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['field_type'] = fieldType;
    data['input_data'] = inputData;
    data['check_data'] = checkData;
    if (mediaData != null) {
      data['media_data'] = mediaData!.toJson();
    }
    data['placeholder_data'] = placeholderData;
    data['is_required'] = isRequired;
    return data;
  }
}

class MediaData {
  int? uploadMultipleFiles;
  int? image;
  int? pdf;
  int? docs;

  MediaData({this.uploadMultipleFiles, this.image, this.pdf, this.docs});

  MediaData.fromJson(Map<String, dynamic> json) {
    uploadMultipleFiles = json['upload_multiple_files'];
    image = json['image'];
    pdf = json['pdf'];
    docs = json['docs'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['upload_multiple_files'] = uploadMultipleFiles;
    data['image'] = image;
    data['pdf'] = pdf;
    data['docs'] = docs;
    return data;
  }
}

class MaintenanceModeData {
  List<String>? maintenanceSystemSetup;
  MaintenanceDurationSetup? maintenanceDurationSetup;
  MaintenanceMessageSetup? maintenanceMessageSetup;

  MaintenanceModeData({
    this.maintenanceSystemSetup,
    this.maintenanceDurationSetup,
    this.maintenanceMessageSetup,
  });

  MaintenanceModeData.fromJson(Map<String, dynamic> json) {
    if (json['maintenance_system_setup'] != null) {
      try {
        maintenanceSystemSetup = (json['maintenance_system_setup'] as List).map((e) => e.toString()).toList();
      } catch (e) {
        maintenanceSystemSetup = [];
      }
    }
    maintenanceDurationSetup = json['maintenance_duration_setup'] != null ? MaintenanceDurationSetup.fromJson(json['maintenance_duration_setup']) : null;
    maintenanceMessageSetup = json['maintenance_message_setup'] != null ? MaintenanceMessageSetup.fromJson(json['maintenance_message_setup']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['maintenance_system_setup'] = maintenanceSystemSetup;
    if (maintenanceDurationSetup != null) {
      data['maintenance_duration_setup'] = maintenanceDurationSetup!.toJson();
    }
    if (maintenanceMessageSetup != null) {
      data['maintenance_message_setup'] = maintenanceMessageSetup!.toJson();
    }
    return data;
  }
}

class MaintenanceDurationSetup {
  String? maintenanceDuration;
  String? startDate;
  String? endDate;

  MaintenanceDurationSetup({
    this.maintenanceDuration,
    this.startDate,
    this.endDate,
  });

  MaintenanceDurationSetup.fromJson(Map<String, dynamic> json) {
    maintenanceDuration = json['maintenance_duration']?.toString();
    startDate = json['start_date']?.toString();
    endDate = json['end_date']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['maintenance_duration'] = maintenanceDuration;
    data['start_date'] = startDate;
    data['end_date'] = endDate;
    return data;
  }
}

class MaintenanceMessageSetup {
  int? businessNumber;
  int? businessEmail;
  String? maintenanceMessage;
  String? messageBody;

  MaintenanceMessageSetup({this.businessNumber, this.businessEmail, this.maintenanceMessage, this.messageBody});

  MaintenanceMessageSetup.fromJson(Map<String, dynamic> json) {
    businessNumber = json['business_number'];
    businessEmail = json['business_email'];
    maintenanceMessage = json['maintenance_message']?.toString();
    messageBody = json['message_body']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['business_number'] = businessNumber;
    data['business_email'] = businessEmail;
    data['maintenance_message'] = maintenanceMessage;
    data['message_body'] = messageBody;
    return data;
  }
}
