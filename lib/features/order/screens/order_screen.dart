import 'package:mnjood/features/order/controllers/order_controller.dart';
import 'package:mnjood/features/order/widgets/order_view_widget.dart';
import 'package:mnjood/helper/auth_helper.dart';
import 'package:mnjood/helper/route_helper.dart';
import 'package:mnjood/helper/responsive_helper.dart';
import 'package:mnjood/util/dimensions.dart';
import 'package:mnjood/common/widgets/custom_app_bar_widget.dart';
import 'package:mnjood/common/widgets/menu_drawer_widget.dart';
import 'package:mnjood/common/widgets/not_logged_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  OrderScreenState createState() => OrderScreenState();
}

class OrderScreenState extends State<OrderScreen> {

  @override
  void initState() {
    super.initState();
    initCall();
  }

  void initCall(){
    if(AuthHelper.isLoggedIn()) {
      Get.find<OrderController>().getRunningOrders(1, limit: 10, notify: false);
      Get.find<OrderController>().getHistoryOrders(1, notify: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = AuthHelper.isLoggedIn();
    return PopScope(
      canPop: Navigator.canPop(context),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Get.offAllNamed(RouteHelper.getInitialRoute());
        }
      },
      child: Scaffold(
        appBar: CustomAppBarWidget(title: 'orders'.tr, isBackButtonExist: ResponsiveHelper.isDesktop(context)),
        endDrawer: const MenuDrawerWidget(), endDrawerEnableOpenDragGesture: false,
        body: isLoggedIn ? const OrderViewWidget(isRunning: true, isCombined: true) : NotLoggedInScreen(callBack: (bool value) {
          initCall();
          setState(() {});
        }),
      ),
    );
  }
}
