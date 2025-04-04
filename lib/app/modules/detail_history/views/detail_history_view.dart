import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mekanik/app/componen/color.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../data/data_endpoint/detailhistory.dart';
import '../../../data/endpoint.dart';

class DetailHistoryView extends StatefulWidget {
  const DetailHistoryView({super.key});

  @override
  State<DetailHistoryView> createState() => _DetailHistoryViewState();
}

class _DetailHistoryViewState extends State<DetailHistoryView> {
  late RefreshController _refreshController;

  @override
  void initState() {
    _refreshController = RefreshController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? arguments =
        Get.arguments as Map<String, dynamic>?;
    final String kodeSvc = arguments?['kode_svc'] ?? '';

    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
          systemNavigationBarColor: Colors.white,
        ),
        title: Text(
          'Detail',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: MyColors.appPrimaryColor,
          ),
        ),
        centerTitle: false,
      ),
      body: SmartRefresher(
        controller: _refreshController,
        enablePullDown: true,
        header: const WaterDropHeader(),
        onLoading: _onLoading,
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          child: FutureBuilder<DetailHistory>(
            future: API.DetailhistoryID(kodesvc: kodeSvc),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // Sedang loading
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                // Ada error
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (snapshot.hasData) {
                // Data sudah ada, tapi perlu dicek lagi isinya
                final detailHistory = snapshot.data;
                if (detailHistory == null) {
                  // Jika data keseluruhan masih null
                  return const Center(child: Text('Data tidak tersedia.'));
                }

                final dataSvc = detailHistory.dataSvc;
                if (dataSvc == null) {
                  // Jika dataSvc null, tampilkan info
                  return const Center(child: Text('Data Svc tidak tersedia.'));
                }

                // Jika dataSvc tersedia
                final dataSvcDtlJasa = detailHistory.dataSvcDtlJasa;

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.15),
                        spreadRadius: 5,
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Bagian judul/tipenya
                      Text(
                        '${dataSvc.tipeSvc}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: MyColors.appPrimaryColor,
                          fontSize: 15,
                        ),
                      ),

                      // Contoh detail bagian atas
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.15),
                              spreadRadius: 5,
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Text('Tanggal & Jam Estimasi :'),
                                    Text(
                                      '${dataSvc.tglEstimasi}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Text('Jam Selesai'),
                                    Text(
                                      '${dataSvc.jamSelesai ?? '-'}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Row Cabang - Kode Estimasi
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Cabang'),
                              Text(
                                '${dataSvc.namaCabang}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text('Kode Estimasi'),
                              Text(
                                '${dataSvc.kodeEstimasi}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Tipe Pelanggan
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Tipe Pelanggan :'),
                              Text(
                                '${dataSvc.tipePelanggan ?? '-'}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Divider(color: Colors.grey),
                      const SizedBox(height: 10),

                      // Detail Pelanggan
                      Text(
                        'Detail Pelanggan',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: MyColors.appPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Nama :'),
                          Text(
                            '${dataSvc.nama}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          const Text('No Handphone :'),
                          Text(
                            '${dataSvc.hp}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          const Text('Alamat :'),
                          Text(
                            '${dataSvc.alamat}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Divider(color: Colors.grey),
                      const SizedBox(height: 10),

                      // Kendaraan Pelanggan
                      Text(
                        'Kendaraan Pelanggan',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: MyColors.appPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Merk :'),
                              Text(
                                '${dataSvc.namaMerk}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('Tipe :'),
                              Text(
                                '${dataSvc.namaTipe}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Tahun :'),
                              Text(
                                '${dataSvc.tahun}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('Warna :'),
                              Text(
                                '${dataSvc.warna}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Kategori Kendaraan :'),
                              Text(
                                '${dataSvc.kategoriKendaraan}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('Transmisi :'),
                              Text(
                                '${dataSvc.transmisi}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('No Polisi :'),
                          Text(
                            '${dataSvc.noPolisi}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      const Divider(color: Colors.grey),

                      // Keluhan
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Keluhan :',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Container(
                            padding: const EdgeInsets.all(5),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(5)),
                              border: Border.all(color: Colors.grey),
                            ),
                            child: Text(
                              '${dataSvc.keluhan ?? '-'}',
                              style: const TextStyle(
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          )
                        ],
                      ),
                      const Divider(color: Colors.grey),
                      const SizedBox(height: 10),

                      // Bagian Paket / Jasa
                      Text(
                        'Paket',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: MyColors.appPrimaryColor,
                        ),
                      ),

                      // FutureBuilder kedua (mengambil data jasa)
                      FutureBuilder<DetailHistory>(
                        future: API.DetailhistoryID(kodesvc: kodeSvc),
                        builder: (context, snapshot2) {
                          if (snapshot2.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (snapshot2.hasError) {
                            return Center(
                                child: Text('Error: ${snapshot2.error}'));
                          } else if (snapshot2.hasData) {
                            final detailHistory2 = snapshot2.data;
                            if (detailHistory2 == null) {
                              return const Center(
                                  child: Text('Data jasa tidak tersedia.'));
                            }

                            final dataSvcDtlJasa2 =
                                detailHistory2.dataSvcDtlJasa;
                            if (dataSvcDtlJasa2 == null ||
                                dataSvcDtlJasa2.isEmpty) {
                              return const Center(
                                  child: Text('Tidak ada data jasa.'));
                            }

                            // Tampilkan list jasa
                            return Column(
                              children: [
                                for (var jasa in dataSvcDtlJasa2)
                                  Column(
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text('Nama Jasa :'),
                                                Text(
                                                  '${jasa.namaJasa}',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          // Di sini bisa Anda kembalikan
                                          // jika ingin menampilkan harga, diskon, dll
                                          // contohnya:
                                          // Column(
                                          //   mainAxisAlignment: MainAxisAlignment.end,
                                          //   crossAxisAlignment: CrossAxisAlignment.end,
                                          //   children: [
                                          //     Text('${formatCurrency(jasa.hargaJasa)}')
                                          //   ],
                                          // ),
                                        ],
                                      ),
                                      const Divider(color: Colors.grey),
                                      const SizedBox(height: 10),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [],
                                          ),
                                          // Column(
                                          //   mainAxisAlignment:
                                          //       MainAxisAlignment.end,
                                          //   crossAxisAlignment:
                                          //       CrossAxisAlignment.end,
                                          //   children: [
                                          //     Text(
                                          //       'TOTAL',
                                          //       style: TextStyle(
                                          //         color:
                                          //             MyColors.appPrimaryColor,
                                          //         fontWeight: FontWeight.bold,
                                          //       ),
                                          //     ),
                                          //     Text(
                                          //       '${formatCurrency(jasa.biaya)}',
                                          //       style: const TextStyle(
                                          //         fontWeight: FontWeight.bold,
                                          //       ),
                                          //     ),
                                          //   ],
                                          // ),
                                        ],
                                      ),
                                      const Divider(color: Colors.transparent),
                                      const SizedBox(height: 10),
                                    ],
                                  ),
                              ],
                            );
                          } else {
                            return const Center(
                                child: Text('No data available'));
                          }
                        },
                      ),
                    ],
                  ),
                );
              } else {
                // Jika snapshot tidak memiliki data sama sekali
                return const Center(child: Text('No data available'));
              }
            },
          ),
        ),
      ),
    );
  }

  String formatCurrency(int? amount) {
    if (amount == null) {
      return 'Rp. -'; // atau nilai default lainnya
    }
    var format = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp. ');
    return format.format(amount);
  }

  _onLoading() {
    _refreshController.loadComplete();
  }

  _onRefresh() {
    HapticFeedback.lightImpact();
    setState(() {
      // Memicu build ulang
      const DetailHistoryView();
      _refreshController.refreshCompleted();
    });
  }
}
