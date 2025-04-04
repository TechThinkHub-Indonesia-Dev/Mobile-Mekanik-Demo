import 'dart:io'; // cek SocketException

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:search_page/search_page.dart';

// Import file terkait warna, model, endpoint, dan komponen Anda
import '../../../componen/color.dart';
import '../../../componen/loading_shammer_booking.dart';
import '../../../data/data_endpoint/boking.dart';
import '../../../data/data_endpoint/kategory.dart';
import '../../../data/data_endpoint/listplanning.dart';
import '../../../data/data_endpoint/pkb.dart';
import '../../../data/data_endpoint/profile.dart';
import '../../../data/data_endpoint/uploadperpart.dart';
import '../../../data/endpoint.dart';
import '../../../data/localstorage.dart';
import '../../../routes/app_pages.dart';
import '../../boking/componen/card_booking.dart';
import '../componen/card_pkb.dart';
import '../componen/card_planning_service.dart';
import '../componen/card_uploadperpart.dart';
import '../controllers/promek_controller.dart';

/// Satu halaman utama yang memuat PKB (dengan 2 sub-tab) & PKB TUTUP
class PKBlist extends StatefulWidget {
  const PKBlist({Key? key}) : super(key: key);

  @override
  State<PKBlist> createState() => _PKBlistState();
}

class _PKBlistState extends State<PKBlist>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  // ------------------ Variabel Tanggal & Mode Filter ------------------
  DateTime selectedDate = DateTime.now();
  DateTimeRange? selectedDateRange;
  bool isFilterSingleDate = false;
  bool isFilterRangeDate = false;

  // Role user
  String userRole = '';

  // ------------------ FILTER BOOKING ------------------
  // Daftar pilihan status booking
  final List<String> statusOptions = [
    'Semua',
    'Booking',
    'Approve',
    'Diproses',
    'Ditolak By Sistem',
    'Cancel Booking',
    'Ditolak',
  ];

  // Variable penampung status terpilih
  String selectedStatus = 'Semua';

  // Daftar pilihan nama service
  final List<String> serviceOptions = [
    'Semua',
    'Repair & Maintenance',
    'Periodical Maintenance',
    'Tire/ Ban',
    'General Check Up/P2H',
    'Emergency Service',
  ];

  // Variable penampung service terpilih
  String selectedService = 'Semua';

  // ------------------ TAB CONTROLLERS ------------------
  late TabController _mainTabController;
  late TabController _pkbSubTabController;
  late TabController _bookingSubTabController;

  // ------------------ REFRESH CONTROLLERS ------------------
  late RefreshController _refreshControllerListPKB;
  late RefreshController _refreshControllerListBooking;
  late RefreshController _refreshControllerUpload;
  late RefreshController _refreshControllerPKBTutup;

  final controller = Get.put(PromekController());

  @override
  void initState() {
    super.initState();
    // Inisialisasi TabController
    _mainTabController = TabController(length: 4, vsync: this);
    _pkbSubTabController = TabController(length: 2, vsync: this);
    _bookingSubTabController = TabController(length: 11, vsync: this);

    // Inisialisasi RefreshController terpisah untuk masing-masing Tab
    _refreshControllerListPKB = RefreshController();
    _refreshControllerListBooking = RefreshController();
    _refreshControllerUpload = RefreshController();
    _refreshControllerPKBTutup = RefreshController();
  }

  // Supaya state tetap terjaga di masing-masing tab
  @override
  bool get wantKeepAlive => true;

  // ------------------ FUNGSI PEMILIHAN TANGGAL & RENTANG ------------------
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'Pilih Tanggal PKB',
    );
    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
        isFilterSingleDate = true;
        isFilterRangeDate = false;
      });
    }
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? pickedRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'Pilih Rentang Tanggal PKB',
      initialDateRange: selectedDateRange ??
          DateTimeRange(
            start: DateTime.now(),
            end: DateTime.now().add(const Duration(days: 1)),
          ),
    );

    if (pickedRange != null) {
      setState(() {
        selectedDateRange = pickedRange;
        isFilterRangeDate = true;
        isFilterSingleDate = false;
      });
    }
  }

  void _resetDateFilter() {
    setState(() {
      isFilterSingleDate = false;
      isFilterRangeDate = false;
      selectedDate = DateTime.now();
      selectedDateRange = null;
    });
  }

  DateTime? parseTglPkb(String? tglPkb) {
    if (tglPkb == null) return null;
    try {
      return DateTime.parse(tglPkb);
    } catch (_) {
      return null;
    }
  }

  // ------------------ FUNGSI NAVIGASI TAP ITEM ------------------
  Future<void> handleBookingTapPKB(DataPKB e) async {
    var posisi = LocalStorages.getPosisi;
    if (posisi != null && posisi.toString() == "4") {
      // Mekanik
      Get.toNamed(Routes.DETAILPKBMEKANIK, arguments: _buildArguments(e));
    } else {
      // Selain Mekanik
      if ((e.status ?? '').toLowerCase() == 'pkb') {
        Get.toNamed(Routes.DETAILPKB, arguments: _buildArguments(e));
      } else {
        Get.toNamed(Routes.DetailPKBView, arguments: _buildArguments(e));
      }
    }
  }

  Future<void> handleBookingTap(DataBooking e) async {
    HapticFeedback.lightImpact();

    if (kDebugMode) {
      print('Nilai e.namaService: ${e.namaService ?? ''}');
    }

    if (e.bookingStatus != null && e.namaService != null) {
      String kategoriKendaraanId = '';
      final generalData = await API.kategoriID();
      if (generalData != null) {
        final matchingKategori = generalData.dataKategoriKendaraan?.firstWhere(
          (kategori) => kategori.kategoriKendaraan == e.kategoriKendaraan,
          orElse: () => DataKategoriKendaraan(
              kategoriKendaraanId: '', kategoriKendaraan: ''),
        );

        if (matchingKategori != null &&
            matchingKategori is DataKategoriKendaraan) {
          kategoriKendaraanId = matchingKategori.kategoriKendaraanId ?? '';
        }
      }

      final arguments = {
        'tgl_booking': e.tglBooking ?? '',
        'jam_booking': e.jamBooking ?? '',
        'nama': e.nama ?? '',
        'kode_kendaraan': e.kodeKendaraan ?? '',
        'kode_pelanggan': e.kodePelanggan ?? '',
        'kode_booking': e.kodeBooking ?? '',
        'nama_jenissvc': e.namaService ?? '',
        'no_polisi': e.noPolisi ?? '',
        'tahun': e.tahun ?? '',
        'keluhan': e.keluhan ?? '',
        'pm_opt': e.pmopt ?? '',
        'type_order': e.typeOrder ?? '',
        'kategori_kendaraan': e.kategoriKendaraan ?? '',
        'kategori_kendaraan_id': kategoriKendaraanId,
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

      // Logika buka halaman berdasarkan status & namaService
      if (e.bookingStatus!.toLowerCase() == 'booking') {
        Get.toNamed(Routes.APPROVE, arguments: arguments);
      } else if (e.bookingStatus!.toLowerCase() == 'approve') {
        if (e.typeOrder != null &&
            e.typeOrder!.toLowerCase() == 'emergency service') {
          arguments['location'] = e.location ?? '';
          arguments['location_name'] = e.locationname ?? '';
          Get.toNamed(Routes.EmergencyView, arguments: arguments);
        } else {
          if (e.namaService!.toLowerCase() == 'repair & maintenance') {
            Get.toNamed(Routes.REPAIR_MAINTENEN, arguments: arguments);
          } else if (e.namaService!.toLowerCase() == 'periodical maintenance') {
            Get.toNamed(Routes.StarStopProdical, arguments: arguments);
          } else if (e.namaService!.toLowerCase() == 'tire/ ban') {
            Get.toNamed(Routes.REPAIR_MAINTENEN, arguments: arguments);
          } else if (e.namaService!.toLowerCase() == 'general check up/p2h') {
            Get.toNamed(Routes.GENERAL_CHECKUP, arguments: arguments);
          }
        }
      } else if (e.bookingStatus!.toLowerCase() == 'diproses') {
        if (e.namaService!.toLowerCase() == 'general check up/p2h') {
          Get.toNamed(Routes.GENERAL_CHECKUP, arguments: arguments);
        } else if (e.namaService!.toLowerCase() == 'periodical maintenance') {
          Get.toNamed(
            Routes.StarStopProdical,
            arguments: {
              'tgl_booking': e.tglBooking ?? '',
              'booking_id': e.bookingId.toString(),
              'jam_booking': e.jamBooking ?? '',
              'nama': e.nama ?? '',
              'kode_booking': e.kodeBooking ?? '',
              'kode_kendaraan': e.kodeKendaraan ?? '',
              'kode_pelanggan': e.kodePelanggan ?? '',
              'nama_jenissvc': e.namaService ?? '',
              'no_polisi': e.noPolisi ?? '',
              'tahun': e.tahun ?? '',
              'keluhan': e.keluhan ?? '',
              'kategori_kendaraan': e.kategoriKendaraan ?? '',
              'kategori_kendaraan_id': kategoriKendaraanId,
              'warna': e.warna ?? '',
              'ho': e.hp ?? '',
              'pm_opt': e.pmopt ?? '',
              'vin_number': e.vinNumber ?? '',
              'nama_merk': e.namaMerk ?? '',
              'transmisi': e.transmisi ?? '',
              'nama_tipe': e.namaTipe ?? '',
              'alamat': e.alamat ?? '',
              'status': e.bookingStatus ?? '',
            },
          );
        } else {
          // handle other namaService jika dibutuhkan
        }
      } else {
        Get.toNamed(
          Routes.DetailBooking,
          arguments: arguments,
        );
      }
    } else {
      print('Booking status atau namaService bernilai null');
    }
  }

  Map<String, dynamic> _buildArguments(DataPKB e) {
    return {
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
    };
  }

  Future<void> handleBookingTapSparepart(DataPhotosparepart e) async {
    Get.toNamed(
      Routes.CardDetailPKBSperepart,
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
      },
    );
  }

  // ------------------ REFRESHING METHODS ------------------
  void _onRefreshListPKB() {
    HapticFeedback.lightImpact();
    setState(() {});
    _refreshControllerListPKB.refreshCompleted();
  }

  void _onRefreshListBooking() {
    HapticFeedback.lightImpact();
    setState(() {});
    _refreshControllerListBooking.refreshCompleted();
  }

  void _onLoadingListPKB() {
    _refreshControllerListPKB.loadComplete();
  }

  void _onLoadingListBooking() {
    _refreshControllerListBooking.loadComplete();
  }

  void _onRefreshUpload() {
    HapticFeedback.lightImpact();
    setState(() {});
    _refreshControllerUpload.refreshCompleted();
  }

  void _onLoadingUpload() {
    _refreshControllerUpload.loadComplete();
  }

  void _onRefreshPKBTutup() {
    HapticFeedback.lightImpact();
    setState(() {});
    _refreshControllerPKBTutup.refreshCompleted();
  }

  void _onLoadingPKBTutup() {
    _refreshControllerPKBTutup.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    bool isTablet = MediaQuery.of(context).size.width > 600;
    double fontSize = isTablet ? 16.0 : 12.0;
    double iconSize = isTablet ? 28.0 : 24.0;

    controller.checkForUpdate();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 80,
        title: Text(
          'Home',
          style: GoogleFonts.nunito(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        actions: [
          Row(
            children: [
              IconButton(
                tooltip: 'Filter Single Date',
                onPressed: () => _selectDate(context),
                icon: Icon(Icons.date_range_outlined, size: iconSize),
              ),
              IconButton(
                tooltip: 'Filter Rentang Tanggal',
                onPressed: () => _selectDateRange(context),
                icon: Icon(Icons.date_range, size: iconSize),
              ),
              IconButton(
                tooltip: 'Tampilkan Semua (Reset Filter)',
                onPressed: _resetDateFilter,
                icon: Icon(Icons.clear, size: iconSize),
              ),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48.0),
          child: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade200,
            ),
            child: TabBar(
              controller: _mainTabController,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: MyColors.appPrimaryColor,
              ),
              labelColor: Colors.white,
              dividerColor: Colors.transparent,
              unselectedLabelColor: MyColors.appPrimaryColor,
              tabs: const [
                Padding(
                  padding: EdgeInsets.only(right: 10, left: 10),
                  child: Tab(text: 'Booking'),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 10, left: 10),
                  child: Tab(text: 'PKB'),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 10, left: 10),
                  child: Tab(text: 'PKB TUTUP'),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 10, left: 10),
                  child: Tab(text: 'Planning'),
                ),
              ],
            ),
          ),
        ),
      ),
      body: FutureBuilder<Profile>(
        future: API.profileiD(),
        builder: (context, snapshotProfile) {
          if (snapshotProfile.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshotProfile.hasError) {
            if (snapshotProfile.error is SocketException) {
              return const Center(
                child: Text(
                  'Tidak ada koneksi internet.\n'
                  'Pastikan Anda terhubung ke internet dan coba lagi.',
                  textAlign: TextAlign.center,
                ),
              );
            } else {
              return const Center(
                child: Text(
                  'Terjadi kesalahan saat memuat data.\n'
                  'Silakan coba lagi nanti.',
                  textAlign: TextAlign.center,
                ),
              );
            }
          } else {
            userRole = snapshotProfile.data?.data?.role?.trim() ?? '';
            return TabBarView(
              controller: _mainTabController,
              children: [
                // TAB 1: Booking
                _buildTabContent(),

                // TAB 2: PKB
                _buildTabPKBContent(),

                // TAB 3: PKB TUTUP
                _buildTabPkbTutup(),

                // TAB 4: Planning
                _buildListPlanningTab(),
              ],
            );
          }
        },
      ),
    );
  }

  // ------------------ TAB BOOKING ------------------
  Widget _buildTabContent() {
    return FutureBuilder<Boking>(
      future: API.bokingid(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SingleChildScrollView(child: Loadingshammer());
        } else if (snapshot.hasError) {
          if (snapshot.error is SocketException) {
            return const Center(
              child: Text(
                'Tidak ada koneksi internet.\n'
                'Data Booking gagal dimuat. Periksa koneksi Anda.',
                textAlign: TextAlign.center,
              ),
            );
          } else {
            return const Center(
              child: Text(
                'Terjadi kesalahan. Data Booking gagal dimuat.\n'
                'Silakan coba beberapa saat lagi.',
                textAlign: TextAlign.center,
              ),
            );
          }
        } else {
          if (!snapshot.hasData ||
              snapshot.data?.dataBooking == null ||
              snapshot.data!.dataBooking!.isEmpty) {
            // Jika tidak ada data sama sekali
            return Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Semua: 0',
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: MyColors.appPrimaryColor,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.filter_list,
                            color: MyColors.appPrimaryColor),
                        onPressed: () {
                          // setelah bottom sheet ditutup, kita panggil setState agar data refresh
                          showModalBottomSheet(
                            context: context,
                            builder: (BuildContext context) {
                              return _buildBookingFilterSheet();
                            },
                          ).then((_) {
                            // Panggil setState untuk me-refresh tampilan
                            setState(() {});
                          });
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        'Tidak ada data Booking.\n',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: MyColors.appPrimaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else {
            // Ada data booking
            final allBooking = snapshot.data!.dataBooking!;

            // Urutkan data booking desc by tglBooking
            allBooking.sort((a, b) {
              DateTime aDate =
                  DateTime.tryParse(a.tglBooking ?? '') ?? DateTime(0);
              DateTime bDate =
                  DateTime.tryParse(b.tglBooking ?? '') ?? DateTime(0);
              return bDate.compareTo(aDate);
            });

            // Filter tanggal
            List<DataBooking> filteredByDate;
            if (!isFilterSingleDate && !isFilterRangeDate) {
              filteredByDate = allBooking;
            } else if (isFilterSingleDate) {
              filteredByDate = allBooking.where((booking) {
                final dt = DateTime.tryParse(booking.tglBooking ?? '');
                if (dt == null) return false;
                return dt.year == selectedDate.year &&
                    dt.month == selectedDate.month &&
                    dt.day == selectedDate.day;
              }).toList();
            } else {
              final start = selectedDateRange!.start;
              final end = selectedDateRange!.end;
              filteredByDate = allBooking.where((booking) {
                final dt = DateTime.tryParse(booking.tglBooking ?? '');
                if (dt == null) return false;
                return dt.isAtSameMomentAs(start) ||
                    dt.isAtSameMomentAs(end) ||
                    (dt.isAfter(start) && dt.isBefore(end));
              }).toList();
            }

            // Filter status
            List<DataBooking> filteredByStatus = selectedStatus == 'Semua'
                ? filteredByDate
                : filteredByDate.where((booking) {
                    final status = booking.bookingStatus ?? '';
                    return status.toLowerCase() == selectedStatus.toLowerCase();
                  }).toList();

            // Filter namaService
            final filteredData = selectedService == 'Semua'
                ? filteredByStatus
                : filteredByStatus.where((booking) {
                    final svc = booking.namaService ?? '';
                    return svc.toLowerCase() == selectedService.toLowerCase();
                  }).toList();

            return SmartRefresher(
              controller: _refreshControllerListBooking,
              enablePullDown: true,
              header: const WaterDropHeader(),
              onRefresh: _onRefreshListBooking,
              onLoading: _onLoadingListBooking,
              child: Column(
                children: [
                  // Search Box
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 10),
                    child: InkWell(
                      onTap: () => showSearch(
                        context: context,
                        delegate: SearchPage<DataBooking>(
                          items: filteredData,
                          searchLabel: 'Cari Booking',
                          searchStyle: GoogleFonts.nunito(color: Colors.black),
                          showItemsOnEmpty: true,
                          failure: Center(
                            child: Text(
                              'Booking tidak ditemukan :(',
                              style: GoogleFonts.nunito(),
                            ),
                          ),
                          filter: (booking) => [
                            booking.nama,
                            booking.noPolisi,
                            booking.bookingStatus,
                            booking.kodeBooking,
                            booking.vinNumber,
                            booking.kodePelanggan,
                          ],
                          builder: (item) => BokingList(
                            items: item,
                            onTap: () => handleBookingTap(item),
                          ),
                        ),
                      ),
                      child: _buildSearchBox('Pencarian Booking'),
                    ),
                  ),

                  // Info total
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total ${selectedStatus == 'Semua' ? 'Semua' : selectedStatus}: ${filteredData.length}',
                          style: GoogleFonts.nunito(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: MyColors.appPrimaryColor,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.filter_list,
                            color: MyColors.appPrimaryColor,
                          ),
                          onPressed: () {
                            // setelah bottom sheet ditutup, kita panggil setState agar data refresh
                            showModalBottomSheet(
                              showDragHandle: true,
                              enableDrag: true,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(20)),
                              ),
                              context: context,
                              builder: (BuildContext context) {
                                return _buildBookingFilterSheet();
                              },
                            ).then((_) {
                              // Panggil setState untuk me-refresh tampilan
                              setState(() {});
                            });
                          },
                        ),
                      ],
                    ),
                  ),

                  // Tampilkan chip filter yang terpilih (jika bukan 'Semua')
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          // Jika status != 'Semua', tampilkan chip
                          if (selectedStatus != 'Semua')
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Chip(
                                label: Text(
                                  'Status: $selectedStatus',
                                  style: GoogleFonts.nunito(fontSize: 14),
                                ),
                                deleteIcon: const Icon(Icons.close, size: 15),
                                labelPadding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                onDeleted: () {
                                  setState(() {
                                    selectedStatus = 'Semua';
                                  });
                                },
                              ),
                            ),

                          // Jika service != 'Semua', tampilkan chip
                          if (selectedService != 'Semua')
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Chip(
                                label: Text(
                                  'Service: $selectedService',
                                  style: GoogleFonts.nunito(fontSize: 14),
                                ),
                                deleteIcon: const Icon(Icons.close, size: 15),
                                labelPadding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                onDeleted: () {
                                  setState(() {
                                    selectedService = 'Semua';
                                  });
                                },
                              ),
                            ),

                          // Jika keduanya "Semua", tampilkan teks 'Tidak ada filter khusus'
                          if (selectedStatus == 'Semua' &&
                              selectedService == 'Semua')
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Text(
                                'Tidak ada filter khusus',
                                style: GoogleFonts.nunito(fontSize: 14),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  // Tampilkan data
                  filteredData.isEmpty
                      ? Expanded(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Text(
                                'Tidak ada data Booking sesuai filter Anda.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: MyColors.appPrimaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        )
                      : Expanded(
                          child: AnimationLimiter(
                            child: ListView.builder(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              itemCount: filteredData.length,
                              itemBuilder: (context, index) {
                                final e = filteredData[index];
                                return AnimationConfiguration.staggeredList(
                                  position: index,
                                  duration: const Duration(milliseconds: 475),
                                  child: SlideAnimation(
                                    verticalOffset: 50.0,
                                    child: FadeInAnimation(
                                      child: BokingList(
                                        items: e,
                                        onTap: () => handleBookingTap(e),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                ],
              ),
            );
          }
        }
      },
    );
  }

  // ------------------ TAB PKB ------------------
  Widget _buildTabPKBContent() {
    return Column(
      children: [
        TabBar(
          controller: _pkbSubTabController,
          labelColor: MyColors.appPrimaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: MyColors.appPrimaryColor,
          tabs: const [
            Tab(text: 'List PKB'),
            Tab(text: 'Upload Sparepart'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _pkbSubTabController,
            children: [
              _buildListPKBTab(),
              _buildUploadSparepartTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildListPKBTab() {
    return FutureBuilder<PKB>(
      future: API.PKBID(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SingleChildScrollView(child: Loadingshammer());
        } else if (snapshot.hasError) {
          if (snapshot.error is SocketException) {
            return const Center(
              child: Text(
                'Tidak ada koneksi internet.\n'
                'Data PKB gagal dimuat. Periksa koneksi Anda.',
                textAlign: TextAlign.center,
              ),
            );
          } else {
            return const Center(
              child: Text(
                'Terjadi kesalahan. Data PKB gagal dimuat.\n'
                'Silakan coba beberapa saat lagi.',
                textAlign: TextAlign.center,
              ),
            );
          }
        } else {
          if (!snapshot.hasData ||
              snapshot.data?.dataPKB == null ||
              snapshot.data!.dataPKB!.isEmpty) {
            return _buildEmptyPKB();
          } else {
            final allPkb = snapshot.data!.dataPKB!;
            final onlyPKB = allPkb
                .where((item) => item.status?.toLowerCase() == 'pkb')
                .toList();

            if (onlyPKB.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    'Tidak ada data dengan status PKB.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: MyColors.appPrimaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }

            // Urutkan descending
            onlyPKB.sort((a, b) {
              int extractNumber(String kodePkb) {
                RegExp regex = RegExp(r'(\d+)$');
                Match? match = regex.firstMatch(kodePkb);
                return match != null ? int.parse(match.group(0)!) : 0;
              }

              int aNumber = extractNumber(a.kodePkb ?? '');
              int bNumber = extractNumber(b.kodePkb ?? '');
              return bNumber.compareTo(aNumber);
            });

            List<DataPKB> filteredData;
            if (!isFilterSingleDate && !isFilterRangeDate) {
              filteredData = onlyPKB;
            } else if (isFilterSingleDate) {
              filteredData = onlyPKB.where((pkb) {
                final dt = parseTglPkb(pkb.tglPkb);
                if (dt == null) return false;
                return dt.year == selectedDate.year &&
                    dt.month == selectedDate.month &&
                    dt.day == selectedDate.day;
              }).toList();
            } else {
              final start = selectedDateRange!.start;
              final end = selectedDateRange!.end;
              filteredData = onlyPKB.where((pkb) {
                final dt = parseTglPkb(pkb.tglPkb);
                if (dt == null) return false;
                return dt.isAtSameMomentAs(start) ||
                    dt.isAtSameMomentAs(end) ||
                    (dt.isAfter(start) && dt.isBefore(end));
              }).toList();
            }

            if (filteredData.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    'Tidak ada data PKB sesuai filter Anda.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: MyColors.appPrimaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }

            final searchBox = InkWell(
              onTap: () => showSearch(
                context: context,
                delegate: SearchPage<DataPKB>(
                  items: filteredData,
                  searchLabel: 'Cari PKB Service',
                  searchStyle: GoogleFonts.nunito(color: Colors.black),
                  showItemsOnEmpty: true,
                  failure: Center(
                    child: Text(
                      'PKB Service tidak ditemukan :(',
                      style: GoogleFonts.nunito(),
                    ),
                  ),
                  filter: (pkb) => [
                    pkb.nama,
                    pkb.noPolisi,
                    pkb.status,
                    pkb.createdByPkb,
                    pkb.createdBy,
                    pkb.tglEstimasi,
                    pkb.tipeSvc,
                    pkb.kodePkb,
                    pkb.vinNumber,
                    pkb.kodePelanggan,
                  ],
                  builder: (item) => PkbList(
                    items: item,
                    onTap: () => handleBookingTapPKB(item),
                  ),
                ),
              ),
              child: _buildSearchBox('Pencarian PKB Service'),
            );

            return SmartRefresher(
              controller: _refreshControllerListPKB,
              enablePullDown: true,
              header: const WaterDropHeader(),
              onRefresh: _onRefreshListPKB,
              onLoading: _onLoadingListPKB,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 10),
                    child: searchBox,
                  ),
                  Text(
                    'Total PKB: ${filteredData.length}',
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: MyColors.appPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: AnimationLimiter(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        itemCount: filteredData.length,
                        itemBuilder: (context, index) {
                          final e = filteredData[index];
                          return AnimationConfiguration.staggeredList(
                            position: index,
                            duration: const Duration(milliseconds: 475),
                            child: SlideAnimation(
                              verticalOffset: 50.0,
                              child: FadeInAnimation(
                                child: PkbList(
                                  items: e,
                                  onTap: () => handleBookingTapPKB(e),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        }
      },
    );
  }

  Widget _buildUploadSparepartTab() {
    return FutureBuilder<UploadSpertpart>(
      future: API.ListSperpartID(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SingleChildScrollView(child: Loadingshammer());
        } else if (snapshot.hasError) {
          if (snapshot.error is SocketException) {
            return const Center(
              child: Text(
                'Tidak ada koneksi internet.\n'
                'Data Sparepart gagal dimuat. Periksa koneksi Anda.',
                textAlign: TextAlign.center,
              ),
            );
          } else {
            return const Center(
              child: Text(
                'Terjadi kesalahan. Data Sparepart gagal dimuat.\n'
                'Silakan coba beberapa saat lagi.',
                textAlign: TextAlign.center,
              ),
            );
          }
        } else {
          if (!snapshot.hasData ||
              snapshot.data!.dataPhotosparepart == null ||
              snapshot.data!.dataPhotosparepart!.isEmpty) {
            return Center(
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/icons/booking.png',
                      width: 120.0,
                      height: 120.0,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Belum ada data Foto Sparepart',
                      style: TextStyle(
                        color: MyColors.appPrimaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            final allSparepart = snapshot.data!.dataPhotosparepart!;
            allSparepart.sort((a, b) {
              int extractNumber(String kodePkb) {
                RegExp regex = RegExp(r'(\d+)$');
                Match? match = regex.firstMatch(kodePkb);
                return match != null ? int.parse(match.group(0)!) : 0;
              }

              int aNumber = extractNumber(a.kodePkb ?? '');
              int bNumber = extractNumber(b.kodePkb ?? '');
              return bNumber.compareTo(aNumber);
            });

            List<DataPhotosparepart> filteredSparepart;
            if (!isFilterSingleDate && !isFilterRangeDate) {
              filteredSparepart = allSparepart;
            } else if (isFilterSingleDate) {
              filteredSparepart = allSparepart.where((item) {
                final dt = parseTglPkb(item.tglPkb);
                if (dt == null) return false;
                return dt.year == selectedDate.year &&
                    dt.month == selectedDate.month &&
                    dt.day == selectedDate.day;
              }).toList();
            } else {
              final start = selectedDateRange!.start;
              final end = selectedDateRange!.end;
              filteredSparepart = allSparepart.where((item) {
                final dt = parseTglPkb(item.tglPkb);
                if (dt == null) return false;
                return dt.isAtSameMomentAs(start) ||
                    dt.isAtSameMomentAs(end) ||
                    (dt.isAfter(start) && dt.isBefore(end));
              }).toList();
            }

            if (filteredSparepart.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    'Tidak ada data Sparepart sesuai filter Anda.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: MyColors.appPrimaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }

            final searchBox = InkWell(
              onTap: () => showSearch(
                context: context,
                delegate: SearchPage<DataPhotosparepart>(
                  items: filteredSparepart,
                  searchLabel: 'Cari Sparepart',
                  searchStyle: GoogleFonts.nunito(color: Colors.black),
                  showItemsOnEmpty: true,
                  failure: Center(
                    child: Text(
                      'Data Sparepart tidak ditemukan :(',
                      style: GoogleFonts.nunito(),
                    ),
                  ),
                  filter: (data) => [
                    data.nama,
                    data.noPolisi,
                    data.createdBy,
                    data.createdByPkb,
                    data.kodePkb,
                    data.kodePelanggan,
                  ],
                  builder: (item) => PkbListSperpart(
                    items: item,
                    onTap: () => handleBookingTapSparepart(item),
                  ),
                ),
              ),
              child: _buildSearchBox('Pencarian Sparepart'),
            );

            return SmartRefresher(
              controller: _refreshControllerUpload,
              enablePullDown: true,
              header: const WaterDropHeader(),
              onRefresh: _onRefreshUpload,
              onLoading: _onLoadingUpload,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 10),
                    child: searchBox,
                  ),
                  Text(
                    'Total Sparepart: ${filteredSparepart.length}',
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: MyColors.appPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: AnimationLimiter(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        itemCount: filteredSparepart.length,
                        itemBuilder: (context, index) {
                          final e = filteredSparepart[index];
                          return AnimationConfiguration.staggeredList(
                            position: index,
                            duration: const Duration(milliseconds: 475),
                            child: SlideAnimation(
                              verticalOffset: 50.0,
                              child: FadeInAnimation(
                                child: PkbListSperpart(
                                  items: e,
                                  onTap: () => handleBookingTapSparepart(e),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        }
      },
    );
  }

  // ------------------ TAB PKB TUTUP ------------------
  Widget _buildTabPkbTutup() {
    return FutureBuilder<PKB>(
      future: API.PKBID(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SingleChildScrollView(child: Loadingshammer());
        } else if (snapshot.hasError) {
          if (snapshot.error is SocketException) {
            return const Center(
              child: Text(
                'Tidak ada koneksi internet.\n'
                'Data PKB gagal dimuat. Periksa koneksi Anda.',
                textAlign: TextAlign.center,
              ),
            );
          } else {
            return const Center(
              child: Text(
                'Terjadi kesalahan. Data PKB gagal dimuat.\n'
                'Silakan coba beberapa saat lagi.',
                textAlign: TextAlign.center,
              ),
            );
          }
        } else {
          if (!snapshot.hasData ||
              snapshot.data?.dataPKB == null ||
              snapshot.data!.dataPKB!.isEmpty) {
            return _buildEmptyPKB();
          } else {
            final allPkb = snapshot.data!.dataPKB!;
            allPkb.sort((a, b) {
              int extractNumber(String kodePkb) {
                RegExp regex = RegExp(r'(\d+)$');
                Match? match = regex.firstMatch(kodePkb);
                return match != null ? int.parse(match.group(0)!) : 0;
              }

              int aNumber = extractNumber(a.kodePkb ?? '');
              int bNumber = extractNumber(b.kodePkb ?? '');
              return bNumber.compareTo(aNumber);
            });

            // Hanya yang status == PKB TUTUP
            List<DataPKB> pkbTutupData = allPkb
                .where(
                    (pkb) => (pkb.status?.toUpperCase() ?? '') == 'PKB TUTUP')
                .toList();

            List<DataPKB> filteredData;
            if (!isFilterSingleDate && !isFilterRangeDate) {
              filteredData = pkbTutupData;
            } else if (isFilterSingleDate) {
              filteredData = pkbTutupData.where((pkb) {
                final dt = parseTglPkb(pkb.tglPkb);
                if (dt == null) return false;
                return dt.year == selectedDate.year &&
                    dt.month == selectedDate.month &&
                    dt.day == selectedDate.day;
              }).toList();
            } else {
              final start = selectedDateRange!.start;
              final end = selectedDateRange!.end;
              filteredData = pkbTutupData.where((pkb) {
                final dt = parseTglPkb(pkb.tglPkb);
                if (dt == null) return false;
                return dt.isAtSameMomentAs(start) ||
                    dt.isAtSameMomentAs(end) ||
                    (dt.isAfter(start) && dt.isBefore(end));
              }).toList();
            }

            if (filteredData.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    'Tidak ada data PKB TUTUP sesuai filter Anda.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: MyColors.appPrimaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }

            final searchBox = InkWell(
              onTap: () => showSearch(
                context: context,
                delegate: SearchPage<DataPKB>(
                  items: filteredData,
                  searchLabel: 'Cari PKB TUTUP',
                  searchStyle: GoogleFonts.nunito(color: Colors.black),
                  showItemsOnEmpty: true,
                  failure: Center(
                    child: Text(
                      'PKB TUTUP tidak ditemukan :(',
                      style: GoogleFonts.nunito(),
                    ),
                  ),
                  filter: (pkb) => [
                    pkb.nama,
                    pkb.noPolisi,
                    pkb.status,
                    pkb.createdByPkb,
                    pkb.createdBy,
                    pkb.tglEstimasi,
                    pkb.tipeSvc,
                    pkb.kodePkb,
                    pkb.vinNumber,
                    pkb.kodePelanggan,
                  ],
                  builder: (item) => PkbList(
                    items: item,
                    onTap: () => handleBookingTapPKB(item),
                  ),
                ),
              ),
              child: _buildSearchBox('Pencarian PKB TUTUP'),
            );

            return SmartRefresher(
              controller: _refreshControllerPKBTutup,
              enablePullDown: true,
              header: const WaterDropHeader(),
              onRefresh: _onRefreshPKBTutup,
              onLoading: _onLoadingPKBTutup,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 10),
                    child: searchBox,
                  ),
                  Text(
                    'Total PKB TUTUP: ${filteredData.length}',
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: MyColors.appPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: AnimationLimiter(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        itemCount: filteredData.length,
                        itemBuilder: (context, index) {
                          final e = filteredData[index];
                          return AnimationConfiguration.staggeredList(
                            position: index,
                            duration: const Duration(milliseconds: 475),
                            child: SlideAnimation(
                              verticalOffset: 50.0,
                              child: FadeInAnimation(
                                child: PkbList(
                                  items: e,
                                  onTap: () => handleBookingTapPKB(e),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        }
      },
    );
  }

  // ------------------ TAB PLANNING ------------------
  Widget _buildListPlanningTab() {
    return FutureBuilder<ListPlanning>(
      future: API.ListPlanningService(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SingleChildScrollView(child: Loadingshammer());
        } else if (snapshot.hasError) {
          if (snapshot.error is SocketException) {
            return const Center(
              child: Text(
                'Tidak ada koneksi internet.\n'
                'Data Planning gagal dimuat. Periksa koneksi Anda.',
                textAlign: TextAlign.center,
              ),
            );
          } else {
            return const Center(
              child: Text(
                'Terjadi kesalahan. Data Planning gagal dimuat.\n'
                'Silakan coba beberapa saat lagi.',
                textAlign: TextAlign.center,
              ),
            );
          }
        } else {
          if (!snapshot.hasData ||
              snapshot.data?.dataPlanning == null ||
              snapshot.data!.dataPlanning!.isEmpty) {
            return _buildEmptyPKB();
          } else {
            final allPlanning = snapshot.data!.dataPlanning!;
            allPlanning.sort((a, b) {
              int extractNumber(String kode) {
                RegExp regex = RegExp(r'(\d+)$');
                Match? match = regex.firstMatch(kode);
                return match != null ? int.parse(match.group(0)!) : 0;
              }

              int aNumber = extractNumber(a.kodePlanning ?? '');
              int bNumber = extractNumber(b.kodePlanning ?? '');
              return bNumber.compareTo(aNumber);
            });

            final searchBox = InkWell(
              onTap: () => showSearch(
                context: context,
                delegate: SearchPage<DataPlanning>(
                  items: allPlanning,
                  searchLabel: 'Cari Planning',
                  searchStyle: GoogleFonts.nunito(color: Colors.black),
                  showItemsOnEmpty: true,
                  failure: Center(
                    child: Text(
                      'Data Planning tidak ditemukan :(',
                      style: GoogleFonts.nunito(),
                    ),
                  ),
                  filter: (item) => [
                    item.noPolisi,
                    item.namaPelanggan,
                    item.kodePlanning,
                  ],
                  builder: (item) => ListPlanningService(
                    items: item,
                    onTap: () {
                      // onTap jika diperlukan
                    },
                  ),
                ),
              ),
              child: _buildSearchBox('Pencarian Planning'),
            );

            return Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  child: searchBox,
                ),
                Text(
                  'Total Planning: ${allPlanning.length}',
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: MyColors.appPrimaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: AnimationLimiter(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemCount: allPlanning.length,
                      itemBuilder: (context, index) {
                        final e = allPlanning[index];
                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 475),
                          child: SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(
                              child: ListPlanningService(
                                items: e,
                                onTap: () {
                                  // onTap jika diperlukan
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          }
        }
      },
    );
  }

  // ------------------ SHEET FILTER BOOKING (MODIFIKASI) ------------------
  Widget _buildBookingFilterSheet() {
    // Variabel sementara untuk menampung pilihan user sebelum menerapkan filter
    String tempSelectedStatus = selectedStatus;
    String tempSelectedService = selectedService;

    // Gunakan SizedBox + Scaffold agar bisa menaruh bottomNavigationBar
    return StatefulBuilder(
      builder: (BuildContext context, setStateSheet) {
        return SizedBox(
          // Atur tinggi bottom sheet agar user bisa scroll
          height: MediaQuery.of(context).size.height * 0.8,
          child: Scaffold(
            // Supaya kelihatan seperti "judul", kita bisa tambahkan AppBar minimal
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: Text(
                'Filter Booking',
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: MyColors.appPrimaryColor,
                ),
              ),
              centerTitle: true,
              backgroundColor: Colors.white,
              elevation: 1,
              titleTextStyle: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: MyColors.appPrimaryColor,
              ),
              iconTheme: IconThemeData(color: MyColors.appPrimaryColor),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // -----------------------------------------
                  // Bagian Filter Status
                  // -----------------------------------------
                  Text(
                    'Pilih Status Booking',
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: MyColors.appPrimaryColor,
                    ),
                  ),
                  const Divider(),
                  ...statusOptions.map((status) {
                    return RadioListTile<String>(
                      title: Text(status),
                      value: status,
                      groupValue: tempSelectedStatus,
                      onChanged: (value) {
                        if (value != null) {
                          setStateSheet(() {
                            tempSelectedStatus = value;
                          });
                        }
                      },
                    );
                  }).toList(),
                  const SizedBox(height: 16),

                  // -----------------------------------------
                  // Bagian Filter Jenis Service
                  // -----------------------------------------
                  Text(
                    'Pilih Jenis Service',
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: MyColors.appPrimaryColor,
                    ),
                  ),
                  const Divider(),
                  ...serviceOptions.map((service) {
                    return RadioListTile<String>(
                      title: Text(service),
                      value: service,
                      groupValue: tempSelectedService,
                      onChanged: (value) {
                        if (value != null) {
                          setStateSheet(() {
                            tempSelectedService = value;
                          });
                        }
                      },
                    );
                  }).toList(),
                  const SizedBox(height: 16),
                  Text(
                    'Geser ke atas untuk melihat semua pilihan filter',
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(MyColors.appPrimaryColor),
                  ),
                  onPressed: () {
                    // Setelah user menekan "Pakai Filter", update nilai sebenarnya
                    setState(() {
                      selectedStatus = tempSelectedStatus;
                      selectedService = tempSelectedService;
                    });
                    // Tutup bottom sheet
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Pakai Filter',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchBox(String hintText) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 4,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            color: MyColors.appPrimaryColor.withOpacity(0.8),
          ),
          const SizedBox(width: 10),
          Text(
            hintText,
            style: GoogleFonts.nunito(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyPKB() {
    return Center(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/icons/booking.png',
              width: 120.0,
              height: 120.0,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 10),
            Text(
              'Belum ada data PKB',
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

  void logout() {
    LocalStorages.deleteToken();
    Get.offAllNamed(Routes.SIGNIN);
  }
}
