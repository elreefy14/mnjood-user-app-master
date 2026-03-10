import 'package:image_picker/image_picker.dart';
import 'package:mnjood/common/models/restaurant_model.dart';
import 'package:mnjood/features/checkout/domain/models/offline_method_model.dart';
import 'package:mnjood/features/checkout/domain/models/place_order_body_model.dart';
import 'package:mnjood/features/checkout/domain/models/timeslote_model.dart';
import 'package:mnjood/features/checkout/domain/repositories/checkout_repository_interface.dart';
import 'package:mnjood/features/checkout/domain/services/checkout_service_interface.dart';
import 'package:mnjood/helper/date_converter.dart';
import 'package:mnjood/util/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/response/response.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CheckoutService implements CheckoutServiceInterface {
  final CheckoutRepositoryInterface checkoutRepositoryInterface;
  CheckoutService({required this.checkoutRepositoryInterface});

  @override
  Future<int?> getDmTipMostTapped() async {
    return await checkoutRepositoryInterface.getDmTipMostTapped();
  }

  @override
  Future<List<OfflineMethodModel>> getOfflineMethodList() async {
    return await checkoutRepositoryInterface.getOfflineMethodList();
  }

  @override
  Future<double> getExtraCharge(double? distance) async {
    return await checkoutRepositoryInterface.getExtraCharge(distance);
  }

  @override
  List<TextEditingController> generateTextControllerList(List<MethodInformations>? methodInformation) {
    List<TextEditingController> informationControllerList = [];

    for(int index=0; index<methodInformation!.length; index++) {
      informationControllerList.add(TextEditingController());
    }
    return informationControllerList;
  }

  @override
  List<FocusNode> generateFocusList(List<MethodInformations>? methodInformation) {
    List<FocusNode> informationFocusList = [];

    for(int index=0; index<methodInformation!.length; index++) {
      informationFocusList.add(FocusNode());
    }
    return informationFocusList;
  }

  @override
  Future<List<TimeSlotModel>?> initializeTimeSlot(Restaurant restaurant, int? scheduleOrderSlotDuration) async {
    List<TimeSlotModel>? timeSlots = [];

    if(restaurant.schedules == null || restaurant.schedules!.isEmpty) {
      if(restaurant.open == 1) {
        DateTime now = DateTime.now();
        for(int day = 0; day < 7; day++) {
          timeSlots.add(TimeSlotModel(
            day: day,
            startTime: DateTime(now.year, now.month, now.day, 0, 0),
            endTime: DateTime(now.year, now.month, now.day, 23, 59),
          ));
        }
      }
      return timeSlots;
    }

    int minutes = 0;
    DateTime now = DateTime.now();
    int slotDuration = scheduleOrderSlotDuration ?? 30; // Default to 30 minutes if null
    for(int index=0; index<restaurant.schedules!.length; index++) {
      // Skip schedules with null opening/closing times
      String? openingTime = restaurant.schedules![index].openingTime;
      String? closingTime = restaurant.schedules![index].closingTime;
      if (openingTime == null || closingTime == null) {
        continue;
      }

      DateTime openTime = DateTime(
        now.year, now.month, now.day, DateConverter.convertStringTimeToDate(openingTime).hour,
        DateConverter.convertStringTimeToDate(openingTime).minute,
      );
      DateTime closeTime = DateTime(
        now.year, now.month, now.day, DateConverter.convertStringTimeToDate(closingTime).hour,
        DateConverter.convertStringTimeToDate(closingTime).minute,
      );
      if(closeTime.difference(openTime).isNegative) {
        minutes = openTime.difference(closeTime).inMinutes;
      }else {
        minutes = closeTime.difference(openTime).inMinutes;
      }
      if(minutes > slotDuration) {
        DateTime time = openTime;
        for(;;) {
          if(time.isBefore(closeTime)) {
            DateTime start = time;
            DateTime end = start.add(Duration(minutes: slotDuration));
            if(end.isAfter(closeTime)) {
              end = closeTime;
            }
            timeSlots.add(TimeSlotModel(day: restaurant.schedules![index].day, startTime: start, endTime: end));
            time = time.add(Duration(minutes: slotDuration));
          }else {
            break;
          }
        }
      }else {
        timeSlots.add(TimeSlotModel(day: restaurant.schedules![index].day, startTime: openTime, endTime: closeTime));
      }
    }

    return timeSlots;
  }

  @override
  List<TimeSlotModel>? validateTimeSlot(List<TimeSlotModel> slots, DateTime date) {
    List<TimeSlotModel>? timeSlots = [];
    int day = 0;
    bool isToday = DateTime(date.year, date.month, date.day).isAtSameMomentAs(
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
    );
    day = date.weekday;

    if(day == 7) {
      day = 0;
    }
    for(int index=0; index<slots.length; index++) {
      if (day == slots[index].day && (isToday ? slots[index].endTime!.isAfter(DateTime.now()) : true)) {
        slots[index] = TimeSlotModel(
          day: slots[index].day,
          startTime: DateTime(date.year, date.month, date.day, slots[index].startTime!.hour, slots[index].startTime!.minute, slots[index].startTime!.second),
          endTime: DateTime(date.year, date.month, date.day, slots[index].endTime!.hour, slots[index].endTime!.minute, slots[index].endTime!.second),
        );
        timeSlots.add(slots[index]);
      }
    }
    return timeSlots;
  }

  @override
  List<int>? validateSlotIndexes(List<TimeSlotModel> slots, DateTime date) {
    List<int>? slotIndexList = [];
    int day = 0;
    bool isToday = DateTime(date.year, date.month, date.day).isAtSameMomentAs(
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
    );
    day = date.weekday;

    if(day == 7) {
      day = 0;
    }

    int index0 = 0;
    for(int index=0; index<slots.length; index++) {
      if (day == slots[index].day && (isToday ? slots[index].endTime!.isAfter(DateTime.now()) : true)) {
        slotIndexList.add(index0);
        index0 ++;
      }
    }
    return slotIndexList;
  }

  @override
  Future<bool> saveOfflineInfo(String data, String? guestId) async {
    return await checkoutRepositoryInterface.saveOfflineInfo(data, guestId);
  }

  @override
  int selectInstruction(int index, int selected){
    int selectedInstruction = selected;
    if(selectedInstruction == index){
      selectedInstruction = -1;
    }else {
      selectedInstruction = index;
    }
    return selectedInstruction;
  }

  @override
  Future<Response> placeOrder(PlaceOrderBodyModel orderBody, {XFile? prescriptionImage}) async {
    return await checkoutRepositoryInterface.placeOrder(orderBody, prescriptionImage: prescriptionImage);
  }

  @override
  Future<Response> sendNotificationRequest(String orderId, String? guestId) async {
    return await checkoutRepositoryInterface.sendNotificationRequest(orderId, guestId);
  }

  @override
  String setPreferenceTimeForView(String time, bool instanceOrder){
    String preferableTime = '';
    if(instanceOrder) {
      preferableTime = time;
    }else {
      preferableTime = '';
    }
    return preferableTime;
  }

  @override
  int selectTimeSlot(bool instanceOrder) {
    int selectedTimeSlot = 0;
    if(instanceOrder) {
      selectedTimeSlot = 0;
    } else {
      selectedTimeSlot = 1;
    }
    return selectedTimeSlot;
  }

  @override
  double updateTips(int index, int selectedTips) {
    double tips = 0;
    if(selectedTips == 0 || selectedTips == AppConstants.tips.length -1) {
      tips = 0;
    }else{
      tips = double.parse(AppConstants.tips[index]);
    }
    return tips;
  }

  @override
  Future<double?> getDistanceInKM(LatLng originLatLng, LatLng destinationLatLng, {bool isDuration = false}) async {
    double distance = -1;
    Response response = await checkoutRepositoryInterface.getDistanceInMeter(originLatLng, destinationLatLng);
    try {
      if (response.statusCode == 200) {
        if(isDuration){
          final String duration = response.body['duration'] as String;
          double parsedDuration = parseDuration(duration);
          distance = parsedDuration / 3600;
        }else{
          // Try multiple possible field names from V3 API response
          final data = response.body['data'];
          double? distanceMeter = response.body['distanceMeters']?.toDouble()
              ?? response.body['distance_meters']?.toDouble()
              ?? response.body['distance']?.toDouble();

          // Handle Google Maps Distance Matrix API format (V3 API)
          // Structure: data.rows[0].elements[0].distance.value
          if (distanceMeter == null && data is Map) {
            try {
              final rows = data['rows'];
              if (rows != null && rows is List && rows.isNotEmpty) {
                final elements = rows[0]['elements'];
                if (elements != null && elements is List && elements.isNotEmpty) {
                  final distanceObj = elements[0]['distance'];
                  if (distanceObj != null && distanceObj is Map) {
                    var rawValue = distanceObj['value'];
                    if (rawValue is num) {
                      distanceMeter = rawValue.toDouble();
                    } else if (rawValue is String) {
                      distanceMeter = double.tryParse(rawValue.replaceAll(',', ''));
                    }
                  }
                }
              }
            } catch (_) {
              // Ignore parsing errors
            }
          }

          // Fallback: Try simple nested structure {distance: {text: "...", value: 123}}
          if (distanceMeter == null && data is Map) {
            final distanceData = data['distance'];
            if (distanceData is Map && distanceData['value'] != null) {
              var rawValue = distanceData['value'];
              if (rawValue is num) {
                distanceMeter = rawValue.toDouble();
              } else if (rawValue is String) {
                distanceMeter = double.tryParse(rawValue.replaceAll(',', ''));
              }
            } else if (distanceData is num) {
              distanceMeter = distanceData.toDouble();
            } else if (distanceData is String) {
              distanceMeter = double.tryParse(distanceData.replaceAll(',', ''));
            }
          }

          if (distanceMeter != null) {
            distance = distanceMeter / 1000;
          } else {
            // Fall back to Geolocator calculation
            distance = Geolocator.distanceBetween(originLatLng.latitude, originLatLng.longitude, destinationLatLng.latitude, destinationLatLng.longitude) / 1000;
          }
        }
      } else {
        // API returned non-200 status - use Geolocator fallback
        if(!isDuration) {
          distance = Geolocator.distanceBetween(originLatLng.latitude, originLatLng.longitude, destinationLatLng.latitude, destinationLatLng.longitude) / 1000;
        }
      }
    } catch (_) {
      // Use Geolocator fallback on exception
      if(!isDuration) {
        distance = Geolocator.distanceBetween(originLatLng.latitude, originLatLng.longitude, destinationLatLng.latitude, destinationLatLng.longitude) / 1000;
      }
    }

    return distance;
  }

  double parseDuration(String duration) {
    return double.tryParse(duration.replaceAll('s', '')) ?? 0.0;
  }

  @override
  Future<bool> updateOfflineInfo(String data, String? guestId) async {
    return await checkoutRepositoryInterface.updateOfflineInfo(data, guestId);
  }

  @override
  Future<bool> checkRestaurantValidation({required Map<String, dynamic> data, String? guestId}) async {
    return await checkoutRepositoryInterface.checkRestaurantValidation(data: data, guestId: guestId);
  }

  @override
  Future<Response> getOrderTax(PlaceOrderBodyModel placeOrderBody) async {
    return await checkoutRepositoryInterface.getOrderTax(placeOrderBody);
  }

  @override
  void saveDmTipIndex(String i) {
    checkoutRepositoryInterface.saveDmTipIndex(i);
  }

  @override
  String getDmTipIndex() {
    return checkoutRepositoryInterface.getDmTipIndex();
  }

  @override
  Future<Response> verifyMoyasarPayment(String orderId, String paymentId) async {
    return await checkoutRepositoryInterface.verifyMoyasarPayment(orderId, paymentId);
  }

  @override
  Future<Response> initializePaymentSession(Map<String, dynamic> data) async {
    return await checkoutRepositoryInterface.initializePaymentSession(data);
  }
}