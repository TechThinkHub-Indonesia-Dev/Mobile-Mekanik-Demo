import 'package:flutter/material.dart';

import '../../../data/data_endpoint/listplanning.dart';

class ListPlanningService extends StatelessWidget {
  final DataPlanning items;
  final VoidCallback onTap;

  const ListPlanningService({
    Key? key,
    required this.items,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                // ICON
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
                      // VIN Number
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

            // SECTION: Kode Planning & Kode Booking
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Kode Planning
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _subTitleText('Kode Planning'),
                    const SizedBox(height: 4),
                    _boldText(items.kodePlanning),
                  ],
                ),
                // Kode Booking
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _subTitleText('Kode Booking'),
                    const SizedBox(height: 4),
                    _boldText(items.kodeBooking),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),

            // SECTION: Kode Svc & Kode Estimasi
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Kode Svc
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _subTitleText('Kode Svc'),
                    const SizedBox(height: 4),
                    _boldText(items.kodeSvc),
                  ],
                ),
                // Kode Estimasi
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _subTitleText('Kode Estimasi'),
                    const SizedBox(height: 4),
                    _boldText(items.kodeEstimasi),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),

            // SECTION: Nama Pelanggan & Kode Pelanggan
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Nama Pelanggan
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _subTitleText('Nama Pelanggan'),
                    const SizedBox(height: 4),
                    _boldText(items.namaPelanggan),
                  ],
                ),
                // Kode Pelanggan
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _subTitleText('Kode Pelanggan'),
                    const SizedBox(height: 4),
                    _boldText(items.kodePelanggan),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),

            // SECTION: Odometer & Nama Jenis SVC
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Odometer
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _subTitleText('Odometer'),
                    const SizedBox(height: 4),
                    _boldText(items.odometer),
                  ],
                ),
                // Nama Jenis Service
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _subTitleText('Nama Jenis Service'),
                    const SizedBox(height: 4),
                    _boldText(items.namaJenissvc),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),

            // SECTION: No Polisi & Kode Kendaraan
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // No Polisi
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _subTitleText('No. Polisi'),
                    const SizedBox(height: 4),
                    _boldText(items.noPolisi),
                  ],
                ),
                // Kode Kendaraan
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _subTitleText('Kode Kendaraan'),
                    const SizedBox(height: 4),
                    _boldText(items.kodeKendaraan),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),

            // SECTION: Alamat & Referensi
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Alamat
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _subTitleText('Alamat Pelanggan'),
                      const SizedBox(height: 4),
                      _boldText(items.alamat),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                // Referensi
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _subTitleText('Referensi'),
                      const SizedBox(height: 4),
                      _boldText(items.referensi),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),

            // SECTION: Konfirmasi & Created At
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Konfirmasi
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _subTitleText('Konfirmasi'),
                    const SizedBox(height: 4),
                    _boldText(items.konfirmasi),
                  ],
                ),
                // Created At
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _subTitleText('Created At'),
                    const SizedBox(height: 4),
                    _boldText(items.createdAt),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Helper untuk teks label/subtitle (mis. "Kode Pelanggan", "No. Polisi", dsb).
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
