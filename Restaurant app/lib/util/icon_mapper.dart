import 'package:flutter/material.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';
import 'package:mnjood_vendor/helper/business_type_helper.dart';
import 'package:mnjood_vendor/util/app_colors.dart';

/// Icon mapping utility for consistent icon usage across the app
class IconMapper {
  IconMapper._();

  // ========== ORDER STATUS ICONS ==========

  static IconData getOrderStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return HeroiconsOutline.clock;
      case 'confirmed':
        return HeroiconsOutline.checkCircle;
      case 'cooking':
      case 'processing':
      case 'preparing':
      case 'brewing':
        return _getProcessingIcon();
      case 'ready':
      case 'handover':
        return HeroiconsOutline.shoppingBag;
      case 'picked_up':
      case 'on_the_way':
        return HeroiconsOutline.truck;
      case 'delivered':
        return HeroiconsOutline.checkBadge;
      case 'cancelled':
      case 'canceled':
      case 'failed':
        return HeroiconsOutline.xCircle;
      case 'refunded':
        return HeroiconsOutline.receiptRefund;
      default:
        return HeroiconsOutline.ellipsisHorizontalCircle;
    }
  }

  static IconData _getProcessingIcon() {
    final type = BusinessTypeHelper.getCurrentBusinessType();
    switch (type) {
      case BusinessType.restaurant:
        return HeroiconsOutline.fire;
      case BusinessType.supermarket:
        return HeroiconsOutline.cube;
      case BusinessType.pharmacy:
        return HeroiconsOutline.beaker;
      case BusinessType.coffeeShop:
        return HeroiconsSolid.fire;
    }
  }

  // ========== FEATURE ICONS ==========

  /// Dashboard
  static const IconData dashboard = HeroiconsOutline.squares2x2;
  static const IconData dashboardSolid = HeroiconsSolid.squares2x2;

  /// Orders
  static const IconData orders = HeroiconsOutline.clipboardDocumentList;
  static const IconData ordersSolid = HeroiconsSolid.clipboardDocumentList;
  static const IconData newOrder = HeroiconsOutline.documentPlus;

  /// Products/Items
  static const IconData products = HeroiconsOutline.shoppingBag;
  static const IconData productsSolid = HeroiconsSolid.shoppingBag;
  static const IconData addProduct = HeroiconsOutline.plusCircle;

  /// Categories
  static const IconData categories = HeroiconsOutline.squares2x2;
  static const IconData categoriesSolid = HeroiconsSolid.squares2x2;

  /// Addons
  static const IconData addons = HeroiconsOutline.puzzlePiece;
  static const IconData addonsSolid = HeroiconsSolid.puzzlePiece;

  /// Coupons
  static const IconData coupons = HeroiconsOutline.ticket;
  static const IconData couponsSolid = HeroiconsSolid.ticket;

  /// Reviews
  static const IconData reviews = HeroiconsOutline.star;
  static const IconData reviewsSolid = HeroiconsSolid.star;

  /// Chat/Messages
  static const IconData chat = HeroiconsOutline.chatBubbleLeftRight;
  static const IconData chatSolid = HeroiconsSolid.chatBubbleLeftRight;

  /// Notifications
  static const IconData notifications = HeroiconsOutline.bell;
  static const IconData notificationsSolid = HeroiconsSolid.bell;
  static const IconData notificationOff = HeroiconsOutline.bellSlash;

  /// Wallet/Finance
  static const IconData wallet = HeroiconsOutline.wallet;
  static const IconData walletSolid = HeroiconsSolid.wallet;
  static const IconData banknotes = HeroiconsOutline.banknotes;
  static const IconData creditCard = HeroiconsOutline.creditCard;

  /// Profile/Settings
  static const IconData profile = HeroiconsOutline.userCircle;
  static const IconData profileSolid = HeroiconsSolid.userCircle;
  static const IconData settings = HeroiconsOutline.cog6Tooth;
  static const IconData settingsSolid = HeroiconsSolid.cog6Tooth;

  /// Reports/Analytics
  static const IconData analytics = HeroiconsOutline.chartBar;
  static const IconData analyticsSolid = HeroiconsSolid.chartBar;
  static const IconData pieChart = HeroiconsOutline.chartPie;
  static const IconData trendUp = HeroiconsOutline.arrowTrendingUp;
  static const IconData trendDown = HeroiconsOutline.arrowTrendingDown;

  /// Inventory
  static const IconData inventory = HeroiconsOutline.cube;
  static const IconData inventorySolid = HeroiconsSolid.cube;
  static const IconData stock = HeroiconsOutline.archiveBox;
  static const IconData barcode = HeroiconsOutline.qrCode;

  /// Store/Restaurant
  static const IconData store = HeroiconsOutline.buildingStorefront;
  static const IconData storeSolid = HeroiconsSolid.buildingStorefront;

  /// Location/Delivery
  static const IconData location = HeroiconsOutline.mapPin;
  static const IconData locationSolid = HeroiconsSolid.mapPin;
  static const IconData delivery = HeroiconsOutline.truck;
  static const IconData deliverySolid = HeroiconsSolid.truck;

  /// Time/Schedule
  static const IconData clock = HeroiconsOutline.clock;
  static const IconData clockSolid = HeroiconsSolid.clock;
  static const IconData calendar = HeroiconsOutline.calendarDays;
  static const IconData calendarSolid = HeroiconsSolid.calendarDays;

  /// Actions
  static const IconData add = HeroiconsOutline.plus;
  static const IconData addCircle = HeroiconsOutline.plusCircle;
  static const IconData edit = HeroiconsOutline.pencil;
  static const IconData editSquare = HeroiconsOutline.pencilSquare;
  static const IconData delete = HeroiconsOutline.trash;
  static const IconData deleteSolid = HeroiconsSolid.trash;
  static const IconData search = HeroiconsOutline.magnifyingGlass;
  static const IconData filter = HeroiconsOutline.funnel;
  static const IconData sort = HeroiconsOutline.bars3BottomLeft;
  static const IconData refresh = HeroiconsOutline.arrowPath;
  static const IconData copy = HeroiconsOutline.clipboard;
  static const IconData share = HeroiconsOutline.share;
  static const IconData download = HeroiconsOutline.arrowDownTray;
  static const IconData upload = HeroiconsOutline.arrowUpTray;
  static const IconData print = HeroiconsOutline.printer;

  /// Navigation
  static const IconData chevronRight = HeroiconsOutline.chevronRight;
  static const IconData chevronLeft = HeroiconsOutline.chevronLeft;
  static const IconData chevronDown = HeroiconsOutline.chevronDown;
  static const IconData chevronUp = HeroiconsOutline.chevronUp;
  static const IconData arrowRight = HeroiconsOutline.arrowRight;
  static const IconData arrowLeft = HeroiconsOutline.arrowLeft;
  static const IconData back = HeroiconsOutline.arrowLeft;
  static const IconData close = HeroiconsOutline.xMark;
  static const IconData menu = HeroiconsOutline.bars3;

  /// Status
  static const IconData check = HeroiconsOutline.check;
  static const IconData checkCircle = HeroiconsOutline.checkCircle;
  static const IconData checkBadge = HeroiconsOutline.checkBadge;
  static const IconData xMark = HeroiconsOutline.xMark;
  static const IconData xCircle = HeroiconsOutline.xCircle;
  static const IconData warning = HeroiconsOutline.exclamationTriangle;
  static const IconData info = HeroiconsOutline.informationCircle;
  static const IconData error = HeroiconsOutline.exclamationCircle;
  static const IconData question = HeroiconsOutline.questionMarkCircle;

  /// Communication
  static const IconData phone = HeroiconsOutline.phone;
  static const IconData phoneSolid = HeroiconsSolid.phone;
  static const IconData email = HeroiconsOutline.envelope;
  static const IconData emailSolid = HeroiconsSolid.envelope;

  /// Other
  static const IconData camera = HeroiconsOutline.camera;
  static const IconData photo = HeroiconsOutline.photo;
  static const IconData document = HeroiconsOutline.document;
  static const IconData documentText = HeroiconsOutline.documentText;
  static const IconData eye = HeroiconsOutline.eye;
  static const IconData eyeOff = HeroiconsOutline.eyeSlash;
  static const IconData lock = HeroiconsOutline.lockClosed;
  static const IconData unlock = HeroiconsOutline.lockOpen;
  static const IconData link = HeroiconsOutline.link;
  static const IconData globe = HeroiconsOutline.globeAlt;
  static const IconData language = HeroiconsOutline.language;
  static const IconData support = HeroiconsOutline.lifebuoy;
  static const IconData help = HeroiconsOutline.questionMarkCircle;
  static const IconData logout = HeroiconsOutline.arrowRightOnRectangle;

  // ========== PHARMACY-SPECIFIC ICONS ==========

  static const IconData prescription = HeroiconsOutline.clipboardDocumentList;
  static const IconData medicine = HeroiconsOutline.beaker;
  static const IconData pill = HeroiconsOutline.cube;
  static const IconData dosage = HeroiconsOutline.scale;

  // ========== COFFEE SHOP-SPECIFIC ICONS ==========

  static const IconData coffee = HeroiconsSolid.fire;
  static const IconData queue = HeroiconsOutline.queueList;
  static const IconData stamp = HeroiconsOutline.star;
  static const IconData loyalty = HeroiconsOutline.gift;
  static const IconData barista = HeroiconsOutline.userCircle;

  // ========== NOTIFICATION TYPE ICONS ==========

  static IconData getNotificationIcon(String type) {
    switch (type.toLowerCase()) {
      case 'order':
        return orders;
      case 'system':
        return settings;
      case 'promotion':
        return HeroiconsOutline.megaphone;
      case 'alert':
        return warning;
      case 'chat':
      case 'message':
        return chat;
      case 'payment':
        return wallet;
      default:
        return notifications;
    }
  }

  // ========== MENU ICONS ==========

  static IconData getMenuIcon(String menuKey) {
    switch (menuKey) {
      case 'dashboard':
        return dashboard;
      case 'orders':
        return orders;
      case 'products':
      case 'food':
      case 'items':
        return products;
      case 'categories':
        return categories;
      case 'addons':
        return addons;
      case 'coupons':
        return coupons;
      case 'reviews':
        return reviews;
      case 'chat':
        return chat;
      case 'wallet':
        return wallet;
      case 'profile':
        return profile;
      case 'settings':
        return settings;
      case 'analytics':
      case 'reports':
        return analytics;
      case 'inventory':
        return inventory;
      case 'notifications':
        return notifications;
      case 'support':
        return support;
      case 'prescription':
        return prescription;
      case 'queue':
        return queue;
      default:
        return HeroiconsOutline.ellipsisHorizontalCircle;
    }
  }
}

/// Icon with color based on status
class StatusIcon extends StatelessWidget {
  final String status;
  final double size;
  final Color? colorOverride;

  const StatusIcon({
    super.key,
    required this.status,
    this.size = 24,
    this.colorOverride,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      IconMapper.getOrderStatusIcon(status),
      size: size,
      color: colorOverride ?? AppColors.getOrderStatusColor(status),
    );
  }
}
