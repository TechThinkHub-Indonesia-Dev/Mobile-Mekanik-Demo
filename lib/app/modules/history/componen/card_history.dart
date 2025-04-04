import 'package:flutter/material.dart';

import '../../../data/data_endpoint/history.dart';

class HistoryList extends StatelessWidget {
  final DataHistory items;
  final VoidCallback onTap;

  const HistoryList({Key? key, required this.items, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color statusColor = StatusColor.getColor(items.status ?? '');

    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoItem(Icons.car_repair, 'Tipe Service', items.tipeSvc),
                _buildStatusBadge(statusColor, items.status ?? 'Unknown'),
              ],
            ),
            const Divider(color: Colors.grey),
            _buildDateGrid(context),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoItem(Icons.person, 'Pelanggan', items.nama),
                _buildInfoItem(Icons.receipt, 'Kode Estimasi',
                    items.kodeEstimasi.toString(),
                    color: Colors.green),
              ],
            ),
            const SizedBox(height: 10),
            _buildInfoItem(
                Icons.assignment_ind, 'PIC Estimasi', items.createdBy),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String? value,
      {Color color = Colors.black}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey),
            const SizedBox(width: 5),
            Text(label,
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        Text(
          value ?? '-',
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 14, color: color),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(Color color, String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildDateGrid(BuildContext context) {
    List<Map<String, dynamic>> dateItems = [
      {
        'label': 'Tgl Estimasi',
        'value': items.tglEstimasi,
        'color': Colors.orange
      },
      {'label': 'Tgl PKB', 'value': items.tglPkb, 'color': Colors.blueGrey},
      {'label': 'Tgl Kembali', 'value': items.tglKembali, 'color': Colors.blue},
      {'label': 'Tgl Keluar', 'value': items.tglKeluar, 'color': Colors.green},
      {'label': 'Tgl Tutup', 'value': items.tglTutup, 'color': Colors.red},
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: dateItems
          .map((date) =>
              _buildDateContainer(date['label'], date['value'], date['color']))
          .toList(),
    );
  }

  Widget _buildDateContainer(String label, String? value, Color color) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label,
              style: const TextStyle(color: Colors.white, fontSize: 10)),
          const SizedBox(height: 5),
          Text(
            value ?? '-',
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class StatusColor {
  static Color getColor(String status) {
    switch (status.toLowerCase()) {
      case 'diproses':
        return Colors.orange;
      case 'estimasi':
        return Colors.lime;
      case 'dikerjakan':
        return Colors.orange;
      case 'invoice':
        return Colors.blue;
      case 'pkb':
        return Colors.green;
      case 'ditolak':
        return Colors.red;
      case 'selesai dikerjakan':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
