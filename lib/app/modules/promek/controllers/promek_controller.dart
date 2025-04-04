import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:launch_review/launch_review.dart';
import 'package:package_info/package_info.dart';

import '../../../componen/color.dart';

class PromekController extends GetxController {
  final TextEditingController odometer = TextEditingController();
  final TextEditingController catatan = TextEditingController();
  final TextEditingController mekanik = TextEditingController();
  final TextEditingController jam = TextEditingController();
  final TextEditingController tanggal = TextEditingController();
  final TextEditingController keluhan = TextEditingController();
  final TextEditingController perintah = TextEditingController();
  final TextEditingController rangka = TextEditingController();
  final TextEditingController mesin = TextEditingController();
  final TextEditingController pic = TextEditingController();
  final TextEditingController hppic = TextEditingController();
  final TextEditingController nomberlambung = TextEditingController();
  final TextEditingController nomesin = TextEditingController();

  void setInitialValues(Map args) {
    tanggal.text = args['tgl_booking'] ?? '';
    jam.text = args['jam_booking'] ?? '';
    rangka.text = args['no_rangka'] ?? '';
    mesin.text = args['no_mesin'] ?? '';
    odometer.text = args['odometer'] ?? '';
    pic.text = args['pic'] ?? '';
    hppic.text = args['hp_pic'] ?? '';
    keluhan.text = args['keluhan'] ?? '';
    perintah.text = args['perintah_kerja'] ?? '';
    nomberlambung.text = args['vin_number'] ?? '';
  }

  void printAllData() {
    print('Keluhan: ${keluhan.text}');
    print('Odometer: ${odometer.text}');
    print('PIC: ${pic.text}');
    print('HP PIC: ${hppic.text}');
    print('Tanggal: ${tanggal.text}');
    print('Jam: ${jam.text}');
    print('Perintah Kerja: ${perintah.text}');
  }

  var keluhanText = ''.obs;

  var selectedDate = DateTime.now().obs;
  Rx<TimeOfDay> selectedTime = TimeOfDay.now().obs;

  void updateDate(DateTime newDate) {
    selectedDate.value = newDate;
  }

  void updateTime(TimeOfDay newTime) {
    selectedTime.value = newTime;
  }

  final count = 0.obs;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    catatan.dispose();
    keluhan.dispose();
    mekanik.dispose();
    jam.dispose();
    tanggal.dispose();
    rangka.dispose();
    mesin.dispose();
    pic.dispose();
    hppic.dispose();
    nomesin.dispose();
    super.onClose();
  }

  final InAppUpdate inAppUpdate = InAppUpdate();

  get updateAvailable => null;

  Future<void> checkForUpdate() async {
    final packageInfo = (GetPlatform.isAndroid)
        ? await PackageInfo.fromPlatform()
        : PackageInfo(
            appName: '',
            packageName: '',
            version: '',
            buildNumber: '',
          );
    final currentVersion = packageInfo.version;

    try {
      final updateInfo = await InAppUpdate.checkForUpdate();
      if (updateInfo.flexibleUpdateAllowed) {
        final latestVersion = updateInfo.availableVersionCode.toString();
        if (currentVersion != latestVersion) {
          showUpdateDialog();
        }
      }
    } catch (e) {
      print('Error checking for updates: $e');
    }
  }

  void showUpdateDialog() {
    Get.defaultDialog(
      title: 'Pembaruan Tersedia',
      content: Column(
        children: [
          Image.asset(
            "assets/logo_update.png",
            gaplessPlayback: true,
            fit: BoxFit.fitHeight,
            height: 200,
          ),
          const Text(
              'Versi baru aplikasi tersedia. Apakah Anda ingin mengunduh pembaruan sekarang?',
              textAlign: TextAlign.center),
        ],
      ),
      confirm: InkWell(
        onTap: () async {
          LaunchReview.launch(
            androidAppId: "com.tech.mekanik.demo",
            // iOSAppId: "585027354",
          );
          // await InAppUpdate.performImmediateUpdate();
          Get.back();
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: MyColors.appPrimaryColor,
          ),
          child: const Center(
            child: Text(
              'Unduh Sekarang',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void increment() => count.value++;
}
