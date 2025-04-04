import 'package:flutter/material.dart';

import '../../../data/data_endpoint/uploadperpart.dart';

class PkbListSperpart extends StatelessWidget {
  final DataPhotosparepart items;
  final VoidCallback onTap;

  const PkbListSperpart({
    Key? key,
    required this.items,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Jika Anda punya status, Anda dapat menggunakan baris berikut
    // final Color statusColor = StatusColor.getColor(items.status ?? '');

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              spreadRadius: 3,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SECTION: HEADER (Nama Cabang & VIN Number)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ICON: opsional, ganti sesuai kebutuhan
                CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.green.shade100,
                  child: Icon(
                    Icons.home_repair_service_outlined,
                    color: Colors.green.shade700,
                  ),
                ),
                const SizedBox(width: 12),
                // Nama Cabang & VIN Number
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        items.namaCabang ?? 'Nama Cabang',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // VIN Number (Badge)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'VIN Number',
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            items.vinNumber ?? 'Tidak ada data VIN Number',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),

            // SECTION: TANGGAL & JAM ESTIMASI
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Tanggal Estimasi
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _subTitleText('Tanggal Estimasi'),
                    const SizedBox(height: 4),
                    _boldText(items.tglEstimasi?.split(" ")[0]),
                  ],
                ),
                // Jam Estimasi
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _subTitleText('Jam Estimasi'),
                    const SizedBox(height: 4),
                    _boldText(items.tglEstimasi?.split(" ")[1]),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),

            // SECTION: TANGGAL PKB & KODE PKB
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Tanggal PKB
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _subTitleText('Tanggal PKB'),
                    const SizedBox(height: 4),
                    _boldText(items.tglPkb?.split(" ")[0]),
                  ],
                ),
                // Kode PKB
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _subTitleText('Kode PKB'),
                    const SizedBox(height: 4),
                    _boldText(items.kodePkb),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),

            // SECTION: PELANGGAN
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Nama Pelanggan
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _subTitleText('Pelanggan'),
                    const SizedBox(height: 4),
                    _boldText(items.nama),
                  ],
                ),
                // Kode Pelanggan
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _subTitleText('Kode Pelanggan'),
                    const SizedBox(height: 4),
                    Text(
                      items.kodePelanggan?.toString() ?? '-',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // SECTION: DETAIL KENDARAAN
            const Text(
              'Detail Kendaraaan Pelanggan',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Kolom Kiri: Merek & Warna
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _subTitleText('Merek'),
                      const SizedBox(height: 4),
                      _boldText(items.namaMerk),
                      const SizedBox(height: 8),
                      _subTitleText('Warna'),
                      const SizedBox(height: 4),
                      _boldText(items.warna),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                // Kolom Kanan: Type & NoPol
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _subTitleText('Type'),
                      const SizedBox(height: 4),
                      _boldText(items.namaTipe),
                      const SizedBox(height: 8),
                      _subTitleText('NoPol'),
                      const SizedBox(height: 4),
                      _boldText(items.noPolisi),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Helper untuk teks label/subtitle (mis. "Tanggal PKB", "Jam Estimasi").
  Widget _subTitleText(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: Colors.grey,
        fontSize: 13,
      ),
    );
  }

  /// Helper untuk teks data utama agar menonjol (bold).
  Widget _boldText(String? text) {
    return Text(
      text ?? '-',
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }
}

class StatusColor {
  static Color getColor(String status) {
    switch (status.toLowerCase()) {
      case 'booking':
        return Colors.blue;
      case 'approve':
        return Colors.green;
      case 'diproses':
        return Colors.orange;
      case 'estimasi':
        return Colors.lime;
      case 'selesai dikerjakan':
        return Colors.blue;
      case 'pkb':
        return Colors.green;
      case 'pkb tutup':
        return Colors.yellow;
      case 'invoice':
        return Colors.yellow;
      case 'lunas':
        return Colors.yellow;
      case 'ditolak by sistem':
      case 'ditolak':
        return Colors.red;
      default:
        return Colors.transparent;
    }
  }
}
