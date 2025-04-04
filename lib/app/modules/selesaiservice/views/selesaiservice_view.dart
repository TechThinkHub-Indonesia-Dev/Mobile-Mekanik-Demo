import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';

import '../../../componen/color.dart';
import '../../../componen/loading_shammer_booking.dart';
import '../../../data/data_endpoint/boking.dart';
import '../../../data/data_endpoint/kategory.dart';
import '../../../data/endpoint.dart';
import '../../../routes/app_pages.dart';
import '../../boking/componen/card_booking.dart';

class SelesaidikerjakanView extends StatefulWidget {
  const SelesaidikerjakanView({super.key});

  @override
  State<SelesaidikerjakanView> createState() => _SelesaidikerjakanViewState();
}

class _SelesaidikerjakanViewState extends State<SelesaidikerjakanView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        forceMaterialTransparency: true,
        title: Text('Sedang Dikerjakan'),
      ),
      body: SingleChildScrollView(
        child: FutureBuilder<Boking>(
          future: API.bokingid(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SingleChildScrollView(
                child: Loadingshammer(),
              );
            } else if (snapshot.hasError) {
              return SingleChildScrollView(
                child: Loadingshammer(),
              );
            } else if (snapshot.hasData) {
              Boking getDataAcc = snapshot.data!;
              if (getDataAcc.status == false) {
                return SizedBox(
                  height: 400,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/icons/booking.png',
                          width: 100.0,
                          height: 100.0,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Belum ada data Service yang dikerjakan',
                          style: TextStyle(
                            color: MyColors.appPrimaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              } else if (getDataAcc.message == 'Invalid token: Expired') {
                Get.offAllNamed(Routes.SIGNIN);
                return const SizedBox.shrink();
              }
              // Hanya mengambil data dengan bookingStatus == 'selesai dikerjakan'
              List<DataBooking> filteredList = getDataAcc.dataBooking!
                  .where((item) =>
                      item.bookingStatus != null &&
                      item.bookingStatus!.toLowerCase() == 'selesai dikerjakan')
                  .toList();
              // Sort data berdasarkan tgl_booking dan jam_booking (terbaru ke terlama)
              filteredList.sort((a, b) {
                DateTime? aDateTime;
                DateTime? bDateTime;

                try {
                  aDateTime = DateTime.parse('${a.tglBooking} ${a.jamBooking}');
                } catch (e) {
                  aDateTime = null;
                }

                try {
                  bDateTime = DateTime.parse('${b.tglBooking} ${b.jamBooking}');
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
                  height: 400,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/icons/booking.png',
                          width: 100.0,
                          height: 100.0,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Belum ada data Service yang dikerjakan',
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

              return Column(
                children: AnimationConfiguration.toStaggeredList(
                  duration: const Duration(milliseconds: 475),
                  childAnimationBuilder: (widget) => SlideAnimation(
                    child: FadeInAnimation(
                      child: widget,
                    ),
                  ),
                  children: filteredList
                      .map(
                        (e) => BokingList(
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
                              final generalData = await API.kategoriID();
                              if (generalData != null) {
                                final matchingKategori = generalData
                                    .dataKategoriKendaraan
                                    ?.firstWhere(
                                  (kategori) =>
                                      kategori.kategoriKendaraan ==
                                      e.kategoriKendaraan,
                                  orElse: () => DataKategoriKendaraan(
                                    kategoriKendaraanId: '',
                                    kategoriKendaraan: '',
                                  ),
                                );
                                if (matchingKategori != null &&
                                    matchingKategori is DataKategoriKendaraan) {
                                  kategoriKendaraanId =
                                      matchingKategori.kategoriKendaraanId ??
                                          '';
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

                              if (e.bookingStatus!.toLowerCase() == 'booking') {
                                Get.toNamed(
                                  Routes.APPROVE,
                                  arguments: arguments,
                                );
                              } else if (e.bookingStatus!.toLowerCase() ==
                                  'approve') {
                                // Penanganan lainnya
                              } else {
                                Get.toNamed(
                                  Routes.DetailBooking,
                                  arguments: arguments,
                                );
                              }
                            } else {
                              print(
                                  'Booking status atau namaService bernilai null');
                            }
                          },
                        ),
                      )
                      .toList(),
                ),
              );
            } else {
              return const Center(
                child: Text('No data'),
              );
            }
          },
        ),
      ),
    );
  }
}
