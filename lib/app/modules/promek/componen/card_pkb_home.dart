import 'package:flutter/material.dart';

import '../../../data/data_endpoint/pkb.dart';

class PkbListHome extends StatelessWidget {
  final DataPKB items;
  final VoidCallback onTap;

  const PkbListHome({Key? key, required this.items, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color statusColor = StatusColor.getColor(items.status ?? '');

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          // boxShadow: [
          //   BoxShadow(
          //     color: Colors.grey.withOpacity(0.15),
          //     spreadRadius: 3,
          //     blurRadius: 6,
          //     offset: const Offset(0, 3),
          //   ),
          // ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SECTION: Header (Nama Cabang & Status)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ICON / Gambar Samping (Opsional)
                CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.blue.shade100,
                  child: Icon(
                    Icons.home_repair_service,
                    color: Colors.blue.shade700,
                  ),
                ),
                const SizedBox(width: 12),
                // Nama Cabang
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
                      // VIN Number Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Vin Number',
                              style: TextStyle(color: Colors.white),
                            ),
                            Text(
                              items.vinNumber ?? 'Vin Number kosong',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Status
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    (items.status ?? '').toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),

            // SECTION: Tanggal Estimasi & Jam Estimasi
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

            // SECTION: Tanggal PKB & Kode PKB
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

            // SECTION: Pelanggan & Kode Pelanggan
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Pelanggan
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
                      items.kodePelanggan.toString(),
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

            // SECTION: Detail Kendaraan Pelanggan
            const Text(
              'Detail Kendaraan Pelanggan',
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

  /// Helper untuk teks label/subtitle.
  Widget _subTitleText(String? text) {
    return Text(
      text ?? '',
      style: const TextStyle(
        fontSize: 13,
        color: Colors.grey,
      ),
    );
  }

  /// Helper untuk teks data yang lebih menonjol.
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
        return Colors.green;
      case 'selesai dikerjakan':
        return Colors.blue;
      case 'pkb':
        return Colors.green;
      case 'pkb tutup':
        return Colors.redAccent;
      case 'invoice':
        return Colors.blue;
      case 'lunas':
        return Colors.green;
      case 'ditolak by sistem':
        return Colors.red;
      case 'cancel booking':
        return Colors.red;
      case 'ditolak':
        return Colors.red;
      default:
        return Colors.grey; // Warna default jika tidak terdefinisi
    }
  }
}
