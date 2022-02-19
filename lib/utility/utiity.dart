import 'dart:convert';
import 'dart:math';

import 'package:audio_manager/audio_manager.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

class Utility {
  static showToast(String msg) {
    Fluttertoast.showToast(msg: msg);
  }

  static Widget progress(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      color: Colors.white,
      child: Container(
        width: MediaQuery.of(context).size.width / 4,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            backgroundColor: Colors.black.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
          ),
        ),
      ),
    );
  }

  static Widget emptyView(String text) {
    return Center(
      child: Text(
        text,
        textAlign: TextAlign.center,
      ),
    );
  }

  static Image imageLoaderImage(String url, String placeholder) {
    return url == null || url == ""
        ? Image.asset(placeholder)
        : Image.network(
            url,
            // (url.startsWith("http")) ? url : AppStrings.IMAGEBASE_URL + url,
            fit: BoxFit.contain,
          );
  }

  // static launchURL(String url) async {
  //   if (await canLaunch(url)) {
  //     await launch(url);
  //   } else {
  //     showToast("Invalid");
  //   }
  // }

  // static LinearGradient buttonGradient() {
  //   return LinearGradient(
  //     begin: Alignment.topCenter,
  //     end: Alignment.bottomCenter,
  //     stops: [0.1, 0.7, 1],
  //     colors: [
  //       AppColors.appColor,
  //       AppColors.appColor1,
  //       AppColors.appColor2,
  //     ],
  //   );
  // }

  static bool isValidEmail(String email) {
    return RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
  }

  static String calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    double distance = 12742 * asin(sqrt(a));
    String strDistance = distance.toStringAsFixed(2);
    return strDistance + " km";
  }

  static String getHMS(int seconds) {
    if (seconds == null) return "";
    final int minutes = (seconds / 60).truncate();
    // final int hours = (minutes / 60).truncate();
    String secondsStr = (seconds % 60).toString().padLeft(2, '0');
    String minutesStr = (minutes % 60).toString().padLeft(2, '0');
    // String hoursStr = (hours % 60).toString().padLeft(2, '0');
    // return "$hoursStr.$minutesStr.$secondsStr";
    return "$minutesStr:$secondsStr";
  }

  static String formatDate(String date) {
    return DateFormat('MMM dd, yyy').format(DateTime.tryParse(date));
  }

  static String formatTime(String date) {
    return DateFormat('hh:mm a').format(DateFormat("HH:mm").parse(date));
  }

  static String formatTimeApi(String date) {
    return DateFormat('HH:mm').format(DateFormat("hh:mm a").parse(date));
  }

  static String formatDuration(Duration d) {
    if (d == null) return "--:--";
    int minute = d.inMinutes;
    int second = (d.inSeconds > 60) ? (d.inSeconds % 60) : d.inSeconds;
    String format = ((minute < 10) ? "0$minute" : "$minute") +
        ":" +
        ((second < 10) ? "0$second" : "$second");
    return format;
  }
}
