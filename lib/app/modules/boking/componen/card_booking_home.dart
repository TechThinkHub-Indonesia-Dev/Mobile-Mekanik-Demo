import 'package:flutter/material.dart';

import '../../../data/data_endpoint/boking.dart';

class BokingListHome extends StatelessWidget {
  final DataBooking items;
  final VoidCallback onTap;

  const BokingListHome({Key? key, required this.items, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color statusColor = StatusColor.getColor(items.bookingStatus ?? '');

    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // SECTION: Header / Judul Layanan & Emergency Tag
              Row(
                children: [
                  // Icon & Nama Service
                  CircleAvatar(
                    backgroundColor: Colors.greenAccent,
                    child: Icon(
                      Icons.car_repair,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      items.namaService ?? 'Nama Service',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (items.typeOrder == 'Emergency Service') ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Emergency',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    )
                  ],
                ],
              ),

              const SizedBox(height: 12),

              // SECTION: Status & Vin Number
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Vin Number
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
                        items.vinNumber ?? 'Tidak ada data VIN',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  // Status Booking
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      items.bookingStatus?.toUpperCase() ?? 'UNKNOWN',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                ],
              ),

              const SizedBox(height: 12),
              const Divider(thickness: 1, color: Colors.grey),

              // SECTION: Tanggal & Jam Booking
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Tanggal Booking
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tanggal Booking',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        items.tglBooking.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  // Jam Booking
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Jam Booking',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        items.jamBooking.toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),
              const Divider(thickness: 1, color: Colors.grey),

              // SECTION: Pelanggan & Kode Booking
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Pelanggan
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pelanggan',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        items.nama ?? '',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  // Kode Booking
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Kode Booking',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        items.kodeBooking.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),
              const Text(
                'Detail Kendaraan Pelanggan',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 8),
              // SECTION: Info Kendaraan
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
                  // Kolom Kanan: Tipe & NoPol
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _subTitleText('Tipe'),
                        const SizedBox(height: 4),
                        _boldText(items.namaTipe),
                        const SizedBox(height: 8),
                        _subTitleText('No. Polisi'),
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
      ),
    );
  }

  Widget _subTitleText(String? text) {
    return Text(
      text ?? '',
      style: const TextStyle(
        fontSize: 12,
        color: Colors.grey,
      ),
    );
  }

  Widget _boldText(String? text) {
    return Text(
      text ?? '-',
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 14,
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
        return Colors.grey.shade400;
    }
  }
}
