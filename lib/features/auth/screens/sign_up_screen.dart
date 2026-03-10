import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mnjood/helper/route_helper.dart';

/// Sign-up screen now redirects to sign-in (OTP login handles registration).
class SignUpScreen extends StatefulWidget {
  final bool exitFromApp;
  const SignUpScreen({super.key, this.exitFromApp = false});

  @override
  SignUpScreenState createState() => SignUpScreenState();
}

class SignUpScreenState extends State<SignUpScreen> {
  @override
  void initState() {
    super.initState();
    // Redirect to sign-in screen — OTP login auto-registers new users.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.offNamed(RouteHelper.getSignInRoute(RouteHelper.signUp));
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
