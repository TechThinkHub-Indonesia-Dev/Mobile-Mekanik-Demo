import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mekanik/app/modules/home/componen/stats_grid.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../componen/color.dart';
import '../../../componen/loading_shammer_booking.dart';
import '../../../data/data_endpoint/absenhistory.dart';
import '../../../data/data_endpoint/boking.dart';
import '../../../data/data_endpoint/kategory.dart';
import '../../../data/data_endpoint/pkb.dart';
import '../../../data/endpoint.dart';
import '../../../routes/app_pages.dart';
import '../../boking/componen/card_booking_home.dart';
import '../../promek/componen/card_pkb_home.dart';
import '../controllers/home_controller.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  _StatsScreenState createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final controller = Get.put(HomeController());
  late RefreshController _refreshController;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String idkaryawan = '';
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _fetchidkaryawan();
    _refreshController = RefreshController();
    _initializeNotifications();
    _scheduleDailyNotifications();
  }

  void _initializeNotifications() {
    const initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void _scheduleDailyNotifications() {
    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'daily_channel_id',
      'Daily Notifications',
      channelDescription: 'Waktunya untuk mengikatkan absen pada jam 15 : 30!',
      importance: Importance.max,
      priority: Priority.max,
      ticker: 'ticker',
      sound: RawResourceAndroidNotificationSound('sounds'),
    );
    final platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    const startTime = 15;
    const endTime = 16;
    Timer.periodic(const Duration(minutes: 10), (timer) {
      final now = DateTime.now();
      final currentHour = now.hour;
      if (currentHour >= startTime && currentHour < endTime) {
        flutterLocalNotificationsPlugin.show(
          0,
          'Reminder',
          'Waktunya untuk mengikatkan absen pada jam 15 : 30!',
          platformChannelSpecifics,
          payload: 'item x',
        );
      } else if (currentHour >= endTime) {
        timer.cancel();
      }
    });
  }

  void _fetchidkaryawan() async {
    try {
      final idkaryawan2 = await API.profileiD();
      setState(() {
        idkaryawan = idkaryawan2?.data?.id.toString() ?? '';
        print('$idkaryawan');
      });
    } catch (e) {
      print('Error fetching absen info: $e');
    }
  }

  /// Fungsi helper untuk mendapatkan 5 hari kerja terakhir (Senin–Jumat) sebelum hari ini.
  List<DateTime> _getLastFiveWorkingDays(DateTime current) {
    // Mulai dari hari sebelumnya
    DateTime temp = current.subtract(const Duration(days: 1));
    final List<DateTime> days = [];
    while (days.length < 5) {
      if (temp.weekday >= DateTime.monday && temp.weekday <= DateTime.friday) {
        days.add(temp);
      }
      temp = temp.subtract(const Duration(days: 1));
    }
    return days;
  }

  /// Fungsi helper untuk menampilkan dialog peringatan.
  void _showWarningDialog(String message) {
    Get.defaultDialog(
      title: 'Perhatian!',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.warning,
            color: Colors.red,
            size: 60,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
      confirm: TextButton(
        onPressed: () {
          Get.back();
        },
        child: const Text('Tutup'),
      ),
      barrierDismissible: false,
      titlePadding: const EdgeInsets.all(16),
      contentPadding: const EdgeInsets.all(16),
      radius: 10,
    );
  }

  Future<void> handleBookingTapPKB(DataPKB e) async {
    if (e.status?.toLowerCase() == 'pkb') {
      Get.toNamed(
        Routes.DETAILPKB,
        arguments: {
          'id': e.id ?? '',
          'kode_booking': e.kodeBooking ?? '',
          'cabang_id': e.cabangId ?? '',
          'kode_svc': e.kodeSvc ?? '',
          'kode_estimasi': e.kodeEstimasi ?? '',
          'kode_pkb': e.kodePkb ?? '',
          'kode_pelanggan': e.kodePelanggan ?? '',
          'kode_kendaraan': e.kodeKendaraan ?? '',
          'odometer': e.odometer ?? '',
          'pic': e.pic ?? '',
          'hp_pic': e.hpPic ?? '',
          'kode_membership': e.kodeMembership ?? '',
          'kode_paketmember': e.kodePaketmember ?? '',
          'tipe_svc': e.tipeSvc ?? '',
          'tipe_pelanggan': e.tipePelanggan ?? '',
          'referensi': e.referensi ?? '',
          'referensi_teman': e.referensiTeman ?? '',
          'po_number': e.poNumber ?? '',
          'paket_svc': e.paketSvc ?? '',
          'tgl_keluar': e.tglKeluar ?? '',
          'tgl_kembali': e.tglKembali ?? '',
          'km_keluar': e.kmKeluar ?? '',
          'km_kembali': e.kmKembali ?? '',
          'keluhan': e.keluhan ?? '',
          'perintah_kerja': e.perintahKerja ?? '',
          'pergantian_part': e.pergantianPart ?? '',
          'saran': e.saran ?? '',
          'ppn': e.ppn ?? '',
          'penanggung_jawab': e.penanggungJawab ?? '',
          'tgl_estimasi': e.tglEstimasi ?? '',
          'tgl_pkb': e.tglPkb ?? '',
          'tgl_tutup': e.tglTutup ?? '',
          'jam_estimasi_selesai': e.jamEstimasiSelesai ?? '',
          'jam_selesai': e.jamSelesai ?? '',
          'pkb': e.pkb ?? '',
          'tutup': e.tutup ?? '',
          'faktur': e.faktur ?? '',
          'deleted': e.deleted ?? '',
          'notab': e.notab ?? '',
          'status_approval': e.statusApproval ?? '',
          'created_by': e.createdBy ?? '',
          'created_by_pkb': e.createdByPkb ?? '',
          'created_at': e.createdAt ?? '',
          'updated_by': e.updatedBy ?? '',
          'updated_at': e.updatedAt ?? '',
          'kode': e.kode ?? '',
          'no_polisi': e.noPolisi ?? '',
          'id_merk': e.idMerk ?? '',
          'id_tipe': e.idTipe ?? '',
          'tahun': e.tahun ?? '',
          'warna': e.warna ?? '',
          'transmisi': e.transmisi ?? '',
          'no_rangka': e.noRangka ?? '',
          'no_mesin': e.noMesin ?? '',
          'model_karoseri': e.modelKaroseri ?? '',
          'driving_mode': e.drivingMode ?? '',
          'power': e.power ?? '',
          'kategori_kendaraan': e.kategoriKendaraan ?? '',
          'jenis_kontrak': e.jenisKontrak ?? '',
          'jenis_unit': e.jenisUnit ?? '',
          'id_pic_perusahaan': e.idPicPerusahaan ?? '',
          'pic_id_pelanggan': e.picIdPelanggan ?? '',
          'id_customer': e.idCustomer ?? '',
          'nama': e.nama ?? '',
          'alamat': e.alamat ?? '',
          'telp': e.telp ?? '',
          'hp': e.hp ?? '',
          'email': e.email ?? '',
          'kontak': e.kontak ?? '',
          'due': e.due ?? '',
          'jenis_kontrak_x': e.jenisKontrakX ?? '',
          'nama_tagihan': e.namaTagihan ?? '',
          'alamat_tagihan': e.alamatTagihan ?? '',
          'telp_tagihan': e.telpTagihan ?? '',
          'npwp_tagihan': e.npwpTagihan ?? '',
          'pic_tagihan': e.picTagihan ?? '',
          'password': e.password ?? '',
          'remember_token': e.rememberToken ?? '',
          'email_verified_at': e.emailVerifiedAt ?? '',
          'otp': e.otp ?? '',
          'otp_expiry': e.otpExpiry ?? '',
          'gambar': e.gambar ?? '',
          'nama_cabang': e.namaCabang ?? '',
          'nama_merk': e.namaMerk ?? '',
          'vin_number': e.vinNumber ?? '',
          'nama_tipe': e.namaTipe ?? '',
          'status': e.status ?? '',
          'parts': e.parts ?? [],
        },
      );
    } else {
      Get.toNamed(
        Routes.DetailPKBView,
        arguments: {
          'id': e.id ?? '',
          'kode_booking': e.kodeBooking ?? '',
          'cabang_id': e.cabangId ?? '',
          'kode_svc': e.kodeSvc ?? '',
          'kode_estimasi': e.kodeEstimasi ?? '',
          'kode_pkb': e.kodePkb ?? '',
          'kode_pelanggan': e.kodePelanggan ?? '',
          'kode_kendaraan': e.kodeKendaraan ?? '',
          'odometer': e.odometer ?? '',
          'pic': e.pic ?? '',
          'hp_pic': e.hpPic ?? '',
          'kode_membership': e.kodeMembership ?? '',
          'kode_paketmember': e.kodePaketmember ?? '',
          'tipe_svc': e.tipeSvc ?? '',
          'tipe_pelanggan': e.tipePelanggan ?? '',
          'referensi': e.referensi ?? '',
          'referensi_teman': e.referensiTeman ?? '',
          'po_number': e.poNumber ?? '',
          'paket_svc': e.paketSvc ?? '',
          'tgl_keluar': e.tglKeluar ?? '',
          'tgl_kembali': e.tglKembali ?? '',
          'km_keluar': e.kmKeluar ?? '',
          'km_kembali': e.kmKembali ?? '',
          'keluhan': e.keluhan ?? '',
          'perintah_kerja': e.perintahKerja ?? '',
          'pergantian_part': e.pergantianPart ?? '',
          'saran': e.saran ?? '',
          'ppn': e.ppn ?? '',
          'penanggung_jawab': e.penanggungJawab ?? '',
          'tgl_estimasi': e.tglEstimasi ?? '',
          'tgl_pkb': e.tglPkb ?? '',
          'tgl_tutup': e.tglTutup ?? '',
          'jam_estimasi_selesai': e.jamEstimasiSelesai ?? '',
          'jam_selesai': e.jamSelesai ?? '',
          'pkb': e.pkb ?? '',
          'tutup': e.tutup ?? '',
          'faktur': e.faktur ?? '',
          'deleted': e.deleted ?? '',
          'notab': e.notab ?? '',
          'status_approval': e.statusApproval ?? '',
          'created_by': e.createdBy ?? '',
          'created_by_pkb': e.createdByPkb ?? '',
          'created_at': e.createdAt ?? '',
          'updated_by': e.updatedBy ?? '',
          'updated_at': e.updatedAt ?? '',
          'kode': e.kode ?? '',
          'no_polisi': e.noPolisi ?? '',
          'id_merk': e.idMerk ?? '',
          'id_tipe': e.idTipe ?? '',
          'tahun': e.tahun ?? '',
          'warna': e.warna ?? '',
          'transmisi': e.transmisi ?? '',
          'no_rangka': e.noRangka ?? '',
          'no_mesin': e.noMesin ?? '',
          'model_karoseri': e.modelKaroseri ?? '',
          'driving_mode': e.drivingMode ?? '',
          'power': e.power ?? '',
          'kategori_kendaraan': e.kategoriKendaraan ?? '',
          'jenis_kontrak': e.jenisKontrak ?? '',
          'jenis_unit': e.jenisUnit ?? '',
          'id_pic_perusahaan': e.idPicPerusahaan ?? '',
          'pic_id_pelanggan': e.picIdPelanggan ?? '',
          'id_customer': e.idCustomer ?? '',
          'nama': e.nama ?? '',
          'alamat': e.alamat ?? '',
          'telp': e.telp ?? '',
          'hp': e.hp ?? '',
          'email': e.email ?? '',
          'kontak': e.kontak ?? '',
          'due': e.due ?? '',
          'jenis_kontrak_x': e.jenisKontrakX ?? '',
          'nama_tagihan': e.namaTagihan ?? '',
          'alamat_tagihan': e.alamatTagihan ?? '',
          'telp_tagihan': e.telpTagihan ?? '',
          'npwp_tagihan': e.npwpTagihan ?? '',
          'pic_tagihan': e.picTagihan ?? '',
          'password': e.password ?? '',
          'remember_token': e.rememberToken ?? '',
          'email_verified_at': e.emailVerifiedAt ?? '',
          'otp': e.otp ?? '',
          'otp_expiry': e.otpExpiry ?? '',
          'gambar': e.gambar ?? '',
          'nama_cabang': e.namaCabang ?? '',
          'nama_merk': e.namaMerk ?? '',
          'vin_number': e.vinNumber ?? '',
          'nama_tipe': e.namaTipe ?? '',
          'status': e.status ?? '',
          'parts': e.parts ?? [],
        },
      );
    }
  }

  /// Fungsi untuk mengecek absen dalam 5 hari kerja terakhir (Senin–Jumat)
  /// Jika ada hari yang tidak memiliki record absen atau belum lengkap (misal belum absen pulang),
  /// maka akan muncul dialog peringatan. Jika tidak, akan diarahkan ke halaman AbsenView.
  void _checkAbsenAndNavigate() async {
    try {
      final getDataAcc = await API.AbsenHistoryID(idkaryawan: idkaryawan);
      final currentTime = DateTime.now();
      final dateFormat = DateFormat('yyyy-MM-dd');

      if (getDataAcc != null &&
          getDataAcc.historyAbsen != null &&
          getDataAcc.historyAbsen!.isNotEmpty) {
        // Dapatkan 5 hari kerja terakhir (Senin–Jumat) sebelum hari ini
        final List<DateTime> lastFiveWorkingDays =
            _getLastFiveWorkingDays(currentTime);

        bool hasMissingAbsen = false;
        for (DateTime day in lastFiveWorkingDays) {
          final dayStr = dateFormat.format(day);
          // Cek apakah terdapat record absen untuk tanggal tersebut
          final records = getDataAcc.historyAbsen!
              .where((e) => e.tglAbsen == dayStr)
              .toList();

          if (records.isEmpty) {
            // Tidak ada record absen pada hari tersebut
            hasMissingAbsen = true;
            break;
          } else {
            // Jika ada record, periksa apakah terdapat record yang belum absen pulang (jamKeluar == null)
            if (records.any((record) => record.jamKeluar == null)) {
              hasMissingAbsen = true;
              break;
            }
          }
        }

        if (hasMissingAbsen) {
          print(
              'Ditemukan absen yang belum lengkap dalam 5 hari kerja terakhir.');
          _showWarningDialog(
              'Sepertinya terdapat absen yang belum lengkap (tidak absen sama sekali atau belum absen pulang) dalam 5 hari kerja terakhir. Mohon segera hubungi admin untuk menyelesaikan masalah ini.');
        } else {
          // Jika semua data absen lengkap, navigasi ke halaman AbsenView
          Get.toNamed(Routes.AbsenView);
        }
      } else {
        print('Tidak ada data history absen.');
        _showWarningDialog(
            'Riwayat absen tidak ditemukan. Silakan hubungi admin.');
      }
    } catch (e) {
      print('Error checking absen history: $e');
      _showWarningDialog('Terjadi kesalahan saat memeriksa data absen.');
    }
  }

  @override
  Widget build(BuildContext context) {
    controller.checkForUpdate();
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        forceMaterialTransparency: false,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: MyColors.appPrimaryDarkmod,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
          systemNavigationBarColor: MyColors.appPrimaryDarkmod,
        ),
        centerTitle: false,
        title: Row(
          children: [
            // Logo
            Image.asset(
              'assets/logo_dejavu.png',
              height: 35,
            ),
          ],
        ),
        actions: [
          // Indikator Absen / Belum Absen
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: InkWell(
              onTap: _checkAbsenAndNavigate,
              child: FutureBuilder(
                future: API.AbsenHistoryID(idkaryawan: idkaryawan),
                builder: (context, snapshot) {
                  if (snapshot.hasData &&
                      snapshot.connectionState != ConnectionState.waiting &&
                      snapshot.data != null) {
                    AbsenHistory getDataAcc = snapshot.data!;
                    final currentTime = DateTime.now();
                    HistoryAbsen? matchingAbsen;

                    if (getDataAcc.historyAbsen != null &&
                        getDataAcc.historyAbsen!.isNotEmpty) {
                      for (var e in getDataAcc.historyAbsen!) {
                        if (e.jamMasuk != null && e.tglAbsen != null) {
                          final dateStr = e.tglAbsen!;
                          final timeStr = e.jamMasuk!;
                          final dateTimeStr = '$dateStr $timeStr';
                          try {
                            final jamMasuk = DateFormat('yyyy-MM-dd HH:mm')
                                .parse(dateTimeStr);

                            // Bandingkan tanggal dan jam
                            final isSameDay =
                                jamMasuk.year == currentTime.year &&
                                    jamMasuk.month == currentTime.month &&
                                    jamMasuk.day == currentTime.day;

                            if (isSameDay &&
                                (jamMasuk.hour == currentTime.hour ||
                                    jamMasuk.isBefore(currentTime))) {
                              matchingAbsen = e;
                              break;
                            }
                          } catch (e) {
                            // Tangani error parsing jika diperlukan
                          }
                        }
                      }
                    }

                    if (matchingAbsen != null) {
                      final timeStr = matchingAbsen.jamMasuk!;
                      final jamMasuk =
                          DateFormat('HH:mm').parse(timeStr); // Parse jam saja

                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green[600],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: AnimationConfiguration.staggeredList(
                          position: 1,
                          duration: const Duration(milliseconds: 475),
                          child: SlideAnimation(
                            child: FadeInAnimation(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.check_circle,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    "Absen: ${DateFormat('HH:mm').format(jamMasuk)}",
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    } else {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: const [
                            Icon(
                              Icons.warning,
                              color: Colors.white,
                              size: 18,
                            ),
                            SizedBox(width: 5),
                            Text(
                              'Belum Absen',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      );
                    }
                  } else {
                    // Loading State
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 5),
                          Text(
                            'Loading...',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
      body: SmartRefresher(
        controller: _refreshController,
        enablePullDown: true,
        header: const WaterDropHeader(
          waterDropColor: Colors.blue,
          complete: Icon(Icons.check, color: Colors.blue),
        ),
        onLoading: _onLoading,
        onRefresh: _onRefresh,
        child: CustomScrollView(
          physics: const ClampingScrollPhysics(),
          slivers: <Widget>[
            // Bagian StatsGrid
            SliverPadding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
              sliver: SliverToBoxAdapter(
                child: StatsGrid(),
              ),
            ),
            // Bagian Booking Masuk
            SliverPadding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
              sliver: SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Booking Masuk',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.blueGrey[800],
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Get.toNamed(Routes.BOKING);
                            },
                            child: Text(
                              'Lihat Semua',
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 15,
                                color: Colors.blueAccent,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      FutureBuilder<Boking>(
                        future: API.bokingid(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const SingleChildScrollView(
                              child: Loadingshammer(),
                            );
                          } else if (snapshot.hasError) {
                            return Container(
                              height: 100,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/no_signal.png',
                                    width: 100.0,
                                    height: 100.0,
                                    fit: BoxFit.cover,
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    'Jaringan bermasalah / tidak ada jaringan\nTarik kebawah untuk Refresh halaman',
                                    style: TextStyle(
                                        color: MyColors.appPrimaryColor,
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              ),
                            );
                          } else if (snapshot.hasData) {
                            Boking getDataAcc = snapshot.data!;
                            if (getDataAcc.status == false) {
                              return SizedBox(
                                height: 120,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'assets/icons/booking.png',
                                        width: 50.0,
                                        height: 50.0,
                                        fit: BoxFit.cover,
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        'Belum ada data Booking',
                                        style: TextStyle(
                                          color: MyColors.appPrimaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            } else if (getDataAcc.message ==
                                'Invalid token: Expired') {
                              Get.offAllNamed(Routes.SIGNIN);
                              return const SizedBox.shrink();
                            }
                            // Filter data booking dengan status 'booking'
                            List<DataBooking> filteredList = getDataAcc
                                .dataBooking!
                                .where((item) =>
                                    item.bookingStatus != null &&
                                    item.bookingStatus!.toLowerCase() ==
                                        'booking')
                                .toList();

                            // Urutkan data berdasarkan tgl_booking dan jam_booking (terbaru ke terlama)
                            filteredList.sort((a, b) {
                              DateTime? aDateTime;
                              DateTime? bDateTime;
                              try {
                                aDateTime = DateTime.parse(
                                    '${a.tglBooking} ${a.jamBooking}');
                              } catch (e) {
                                aDateTime = null;
                              }
                              try {
                                bDateTime = DateTime.parse(
                                    '${b.tglBooking} ${b.jamBooking}');
                              } catch (e) {
                                bDateTime = null;
                              }
                              if (aDateTime == null && bDateTime == null) {
                                return 0;
                              } else if (aDateTime == null) {
                                return 1;
                              } else if (bDateTime == null) {
                                return -1;
                              } else {
                                return bDateTime.compareTo(aDateTime);
                              }
                            });

                            if (filteredList.isEmpty) {
                              return SizedBox(
                                height: 120,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'assets/icons/booking.png',
                                        width: 50.0,
                                        height: 50.0,
                                        fit: BoxFit.cover,
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        'Belum ada data Booking',
                                        style: TextStyle(
                                          color: MyColors.appPrimaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                            // Tampilkan daftar booking secara horizontal dengan batasan ukuran untuk setiap item
                            return SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children:
                                    AnimationConfiguration.toStaggeredList(
                                  duration: const Duration(milliseconds: 475),
                                  childAnimationBuilder: (widget) =>
                                      SlideAnimation(
                                    child: FadeInAnimation(
                                      child: widget,
                                    ),
                                  ),
                                  children: filteredList.map((e) {
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: SizedBox(
                                        width:
                                            250, // Atur lebar sesuai kebutuhan
                                        child: BokingListHome(
                                          items: e,
                                          onTap: () async {
                                            HapticFeedback.lightImpact();
                                            if (kDebugMode) {
                                              print(
                                                  'Nilai e.namaService: ${e.namaService ?? ''}');
                                            }
                                            if (e.bookingStatus != null &&
                                                e.namaService != null) {
                                              String kategoriKendaraanId = '';
                                              final generalData =
                                                  await API.kategoriID();
                                              if (generalData != null) {
                                                final matchingKategori =
                                                    generalData
                                                        .dataKategoriKendaraan
                                                        ?.firstWhere(
                                                  (kategori) =>
                                                      kategori
                                                          .kategoriKendaraan ==
                                                      e.kategoriKendaraan,
                                                  orElse: () =>
                                                      DataKategoriKendaraan(
                                                    kategoriKendaraanId: '',
                                                    kategoriKendaraan: '',
                                                  ),
                                                );
                                                if (matchingKategori != null &&
                                                    matchingKategori
                                                        is DataKategoriKendaraan) {
                                                  kategoriKendaraanId =
                                                      matchingKategori
                                                              .kategoriKendaraanId ??
                                                          '';
                                                }
                                              }
                                              final arguments = {
                                                'tgl_booking':
                                                    e.tglBooking ?? '',
                                                'jam_booking':
                                                    e.jamBooking ?? '',
                                                'nama': e.nama ?? '',
                                                'kode_kendaraan':
                                                    e.kodeKendaraan ?? '',
                                                'kode_pelanggan':
                                                    e.kodePelanggan ?? '',
                                                'kode_booking':
                                                    e.kodeBooking ?? '',
                                                'nama_jenissvc':
                                                    e.namaService ?? '',
                                                'no_polisi': e.noPolisi ?? '',
                                                'tahun': e.tahun ?? '',
                                                'keluhan': e.keluhan ?? '',
                                                'pm_opt': e.pmopt ?? '',
                                                'type_order': e.typeOrder ?? '',
                                                'kategori_kendaraan':
                                                    e.kategoriKendaraan ?? '',
                                                'kategori_kendaraan_id':
                                                    kategoriKendaraanId,
                                                'warna': e.warna ?? '',
                                                'hp': e.hp ?? '',
                                                'vin_number': e.vinNumber ?? '',
                                                'nama_merk': e.namaMerk ?? '',
                                                'transmisi': e.transmisi ?? '',
                                                'nama_tipe': e.namaTipe ?? '',
                                                'alamat': e.alamat ?? '',
                                                'booking_id': e.bookingId ?? '',
                                                'status': e.bookingStatus ?? '',
                                              };
                                              if (e.bookingStatus!
                                                      .toLowerCase() ==
                                                  'booking') {
                                                Get.toNamed(Routes.APPROVE,
                                                    arguments: arguments);
                                              } else if (e.bookingStatus!
                                                      .toLowerCase() ==
                                                  'approve') {
                                                // Penanganan lainnya
                                              } else {
                                                Get.toNamed(
                                                    Routes.DetailBooking,
                                                    arguments: arguments);
                                              }
                                            } else {
                                              print(
                                                  'Booking status atau namaService bernilai null');
                                            }
                                          },
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            );
                          } else {
                            return const Center(
                              child: Text('No data'),
                            );
                          }
                        },
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'PKB Service',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.blueGrey[800],
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Get.toNamed(Routes.PROMEX);
                            },
                            child: Text(
                              'Lihat Semua',
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 15,
                                color: Colors.blueAccent,
                              ),
                            ),
                          ),
                        ],
                      ),
                      FutureBuilder<PKB>(
                        future: API.PKBID(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: Loadingshammer());
                          } else if (snapshot.hasError) {
                            return Center(child: Text('Terjadi kesalahan'));
                          } else if (!snapshot.hasData ||
                              snapshot.data!.dataPKB == null ||
                              snapshot.data!.dataPKB!.isEmpty) {
                            return Container(
                              height: 120,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Jika memiliki asset image, ganti widget Icon di bawah ini dengan Image.asset()
                                  Icon(Icons.book,
                                      size: 50,
                                      color: MyColors.appPrimaryColor),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Belum ada data PKB',
                                    style: TextStyle(
                                      color: MyColors.appPrimaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                ],
                              ),
                            );
                          } else {
                            PKB getDataAcc = snapshot.data!;

                            // Filter data dengan status "PKB"
                            List<DataPKB> filteredDataPKB = getDataAcc.dataPKB!
                                .where((data) => data.status == 'PKB')
                                .toList();

                            // Sorting descending berdasarkan nomor yang diambil dari akhir kode PKB
                            filteredDataPKB.sort((a, b) {
                              int extractNumber(String kodePkb) {
                                RegExp regex = RegExp(r'(\d+)$');
                                Match? match = regex.firstMatch(kodePkb);
                                return match != null
                                    ? int.parse(match.group(0)!)
                                    : 0;
                              }

                              int aNumber = extractNumber(a.kodePkb ?? '');
                              int bNumber = extractNumber(b.kodePkb ?? '');
                              return bNumber.compareTo(aNumber);
                            });

                            return SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children:
                                    AnimationConfiguration.toStaggeredList(
                                  duration: const Duration(milliseconds: 475),
                                  childAnimationBuilder: (widget) =>
                                      SlideAnimation(
                                    child: FadeInAnimation(
                                      child: widget,
                                    ),
                                  ),
                                  children: filteredDataPKB.map((e) {
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: SizedBox(
                                        width:
                                            250, // Atur lebar sesuai kebutuhan desain
                                        child: PkbListHome(
                                          items: e,
                                          onTap: () {
                                            handleBookingTapPKB(e);
                                          },
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _onLoading() {
    _refreshController.loadComplete();
  }

  _onRefresh() {
    HapticFeedback.lightImpact();
    setState(() {
      const StatsScreen();
      _refreshController.refreshCompleted();
    });
  }
}
