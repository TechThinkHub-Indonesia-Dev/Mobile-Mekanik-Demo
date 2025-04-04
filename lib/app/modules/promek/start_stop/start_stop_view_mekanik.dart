import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

// GANTI: pakai file LocalStorages yang Anda miliki

import '../../../componen/color.dart';
import '../../../data/data_endpoint/mekanik_pkb.dart';
import '../../../data/data_endpoint/prosesspromaxpkb.dart';
import '../../../data/endpoint.dart';
import '../../../data/localstorage.dart';
import '../controllers/promek_controller.dart';

class StartStopViewMekanik extends StatefulWidget {
  const StartStopViewMekanik({Key? key}) : super(key: key);

  @override
  State<StartStopViewMekanik> createState() => _StartStopViewMekanikState();
}

class _StartStopViewMekanikState extends State<StartStopViewMekanik>
    with AutomaticKeepAliveClientMixin<StartStopViewMekanik> {
  String? selectedItemJasa;
  String? selectedItemKodeJasa;
  bool showDetails = false;
  final PromekController controller = Get.put(PromekController());

  // Data mekanik yang disimpan: karna hanya satu ID, kita jadikan list 1 elemen
  List<String> idmekanikList = [];

  // Map status Start/Stop untuk setiap mekanik
  Map<String, bool> isStartedMap = {};
  // Kontroller keterangan tambahan (kalau user mau menambahkan alasan saat stop)
  Map<String, TextEditingController> additionalInputControllers = {};

  Timer? _timer;
  late Map args;
  late RefreshController _refreshController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _refreshController = RefreshController();

    additionalInputControllers.values.forEach((c) => c.dispose());
    _timer?.cancel();

    args = Get.arguments;
    controller.setInitialValues(args);

    // Ganti: Ambil ID Mekanik dari LocalStorages (GetStorage).
    _loadSelectedMechanics();
  }

  Future<void> _loadSelectedMechanics() async {
    // Contoh jika hanya satu ID:
    final String karyawanId = LocalStorages.getKaryawanId;
    // Jika karyawanId kosong, berarti user belum login atau belum di-set
    if (karyawanId.isNotEmpty) {
      setState(() {
        idmekanikList = [karyawanId];
      });
    }
    // else: tetap kosong => "Belum ada mekanik tersimpan."
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        forceMaterialTransparency: true,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
          systemNavigationBarColor: Colors.white,
        ),
        title: Text(
          'Mekanik',
          style: TextStyle(
            color: MyColors.appPrimaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SmartRefresher(
        controller: _refreshController,
        enablePullDown: true,
        header: const WaterDropHeader(),
        onLoading: _onLoading,
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // -------------------------
              // Bagian Pilih Jasa
              // -------------------------
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.all(10),
                child: FutureBuilder<MekanikPKB>(
                  future: API.MeknaikPKBID(kodesvc: args['kode_svc'] ?? ''),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else {
                      final jasaList =
                          snapshot.data?.dataJasaMekanik?.jasa ?? [];
                      if (jasaList.isEmpty) {
                        return SizedBox(
                          height: 500,
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
                                'Belum ada Jasa',
                                style: TextStyle(
                                  color: MyColors.appPrimaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            ],
                          ),
                        );
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Pilih Jasa',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: jasaList.length,
                            itemBuilder: (context, index) {
                              final jasa = jasaList[index];
                              return InkWell(
                                onTap: () async {
                                  setState(() {
                                    selectedItemJasa = jasa.namaJasa;
                                    selectedItemKodeJasa = jasa.kodeJasa;
                                    showDetails = true;
                                  });
                                  // Kalau mau auto-START:
                                  // for (String id in idmekanikList) {
                                  //   await handlePressStartStop(id, false); // false = menekan 'start'
                                  // }
                                  // setState(() {});
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 20),
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 5),
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.15),
                                        spreadRadius: 5,
                                        blurRadius: 10,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                    color:
                                        (selectedItemKodeJasa == jasa.kodeJasa)
                                            ? MyColors.appPrimaryColor
                                            : Colors.white,
                                    border: Border.all(
                                      color: (selectedItemKodeJasa ==
                                              jasa.kodeJasa)
                                          ? MyColors.appPrimaryColor
                                          : Colors.transparent,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    jasa.namaJasa ?? '',
                                    style: TextStyle(
                                      color: (selectedItemKodeJasa ==
                                              jasa.kodeJasa)
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    }
                  },
                ),
              ),

              // -------------------------------------------
              // Bagian History + Tombol Start/Stop per Mekanik
              // -------------------------------------------
              if (showDetails) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Mekanik yang terdaftar',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 5),
                if (idmekanikList.isNotEmpty)
                  Column(
                    children: idmekanikList.map((id) {
                      if (!additionalInputControllers.containsKey(id)) {
                        additionalInputControllers[id] =
                            TextEditingController();
                      }
                      return FutureBuilder(
                        future: API.PromekProsesPKBID(
                          kodesvc: args['kode_svc'] ?? '',
                          kodejasa: selectedItemKodeJasa ?? '',
                          idmekanik: id,
                        ),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(),
                            );
                          } else if (snapshot.hasError) {
                            return Center(
                              child: Text("Error: ${snapshot.error}"),
                            );
                          } else if (snapshot.hasData &&
                              snapshot.data != null) {
                            ProsesPromex getDataAcc =
                                snapshot.data as ProsesPromex;
                            List<Proses> prosesList =
                                getDataAcc.dataProsesMekanik?.proses ?? [];

                            if (prosesList.isEmpty) {
                              // Belum ada history, tampilkan container agar bisa Start
                              return buildStartStopContainer(
                                id: id,
                                prosesList: [],
                                isStopped: false,
                              );
                            }

                            Proses firstItem = prosesList[0];
                            bool isStopped = (firstItem.stopPromek == null ||
                                firstItem.stopPromek == 'N/A');

                            return buildStartStopContainer(
                              id: id,
                              prosesList: prosesList,
                              isStopped: isStopped,
                            );
                          } else {
                            return const Center(
                              child: Text("Error loading data"),
                            );
                          }
                        },
                      );
                    }).toList(),
                  )
                else
                  const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text('Belum ada mekanik tersimpan.'),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget buildStartStopContainer({
    required String id,
    required List<Proses> prosesList,
    required bool isStopped,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(right: 20, left: 20, bottom: 20),
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
          Text(
            'Mekanik $id',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          if (prosesList.isNotEmpty) ...[
            const Text(
              'Riwayat Start/Stop:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Column(
              children: prosesList.map((proses) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('Start: ',
                            style: TextStyle(color: Colors.green)),
                        Text(proses.startPromek ?? 'N/A'),
                      ],
                    ),
                    Row(
                      children: [
                        const Text('Stop: ',
                            style: TextStyle(color: Colors.red)),
                        Text(proses.stopPromek ?? 'N/A'),
                      ],
                    ),
                    Text('Keterangan: ${proses.keterangan ?? '-'}'),
                    const Divider(),
                  ],
                );
              }).toList(),
            ),
          ],
          if (isStopped)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: const BorderRadius.all(Radius.circular(10)),
              ),
              child: TextField(
                controller: additionalInputControllers[id],
                decoration: const InputDecoration(
                  labelText: 'Isi keterangan sebelum Stop (opsional)',
                  border: InputBorder.none,
                ),
              ),
            ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                await handlePressStartStop(id, isStopped);
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: isStopped ? Colors.red : Colors.green,
              ),
              child: Text(isStopped ? 'Stop' : 'Start'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> handlePressStartStop(String id, bool isStopped) async {
    String role = isStopped ? 'stop' : 'start';
    String kodesvc = args['kode_svc'] ?? '';
    String kodejasa = selectedItemKodeJasa ?? '';

    try {
      if (isStopped) {
        String keterangan = additionalInputControllers[id]?.text.trim() ?? '';
        if (keterangan.isEmpty) {
          QuickAlert.show(
            context: context,
            type: QuickAlertType.warning,
            title: 'Warning !!',
            text: 'Keterangan tambahan tidak boleh kosong sebelum Stop.',
            confirmBtnText: 'Oke',
            confirmBtnColor: Colors.orange,
          );
          return;
        }
        var updateResponse = await API.updateketeranganPKBID(
          kodesvc: kodesvc,
          kodejasa: kodejasa,
          idmekanik: id,
          keteranganpromek: keterangan,
        );
        if (updateResponse.status != 200) {
          QuickAlert.show(
            context: context,
            type: QuickAlertType.error,
            title: 'Gagal Update Keterangan',
            text: 'Tidak bisa menyimpan keterangan stop.',
            confirmBtnText: 'Oke',
          );
        }
      }

      var response = await API.InsertPromexoPKBID(
        role: role,
        kodejasa: kodejasa,
        idmekanik: id,
        kodesvc: kodesvc,
      );

      if (response.status == 200) {
        setState(() {
          if (!isStopped) {
            additionalInputControllers[id]?.clear();
          }
        });
        setState(() {});
      } else {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Error !!',
          text: 'Gagal memperbarui status Start/Stop. Coba lagi.',
          confirmBtnText: 'Oke',
          confirmBtnColor: Colors.red,
        );
      }
    } catch (e) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Error',
        text: 'Terjadi kesalahan: $e',
        confirmBtnText: 'Oke',
        confirmBtnColor: Colors.red,
      );
    }
  }

  void _onLoading() {
    _refreshController.loadComplete();
  }

  void _onRefresh() {
    HapticFeedback.lightImpact();
    setState(() {
      // Memicu build ulang
    });
    _refreshController.refreshCompleted();
  }
}
