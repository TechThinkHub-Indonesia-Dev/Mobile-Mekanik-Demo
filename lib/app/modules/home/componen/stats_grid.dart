import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer_animation/shimmer_animation.dart';

import '../../../data/data_endpoint/bookingmasuk.dart';
import '../../../data/data_endpoint/invoicehome.dart';
import '../../../data/data_endpoint/servicedikerjakan.dart';
import '../../../data/data_endpoint/serviceselesai.dart';
import '../../../data/endpoint.dart';
import '../../../routes/app_pages.dart';

class StatsGrid extends StatefulWidget {
  @override
  _StatsGridState createState() => _StatsGridState();
}

class _StatsGridState extends State<StatsGrid> {
  Map<String, dynamic>? _weatherData;
  bool _loading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchWeatherData();
  }

  Future<void> _fetchWeatherData() async {
    setState(() {
      _loading = true;
      _errorMessage = '';
    });

    try {
      // Mendapatkan lokasi saat ini
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final apiKey = '386eb373e3c1000f7963b990a826686d';
      final url =
          'https://api.openweathermap.org/data/2.5/weather?lat=${position.latitude}&lon=${position.longitude}&appid=$apiKey&units=metric';

      final response = await http.get(Uri.parse(url));

      // Print respons untuk debugging
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        setState(() {
          _weatherData = jsonDecode(response.body);
          _loading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Error: ${response.statusCode} - ${response.body}';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Exception: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.30,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(left: 10),
            margin: EdgeInsets.only(bottom: 10),
            child: Text(
              'Menu',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.blueGrey[800],
              ),
            ),
          ),
          Flexible(
            child: Row(
              children: <Widget>[
                _buildFutureStatCardBooking<MasukBooking>(
                  future: API.BookingMasukID(),
                  color: Colors.orange,
                  onTapRoute: Routes.BOOKINGMASUK,
                  dataLabel: "Booking Masuk",
                ),
                _buildFutureStatCard<ServiceSelesaiHome>(
                  future: API.ServiceSelesaiID(),
                  color: Colors.blue,
                  onTapRoute: '',
                  dataLabel: "Service Selesai",
                ),
              ],
            ),
          ),
          Flexible(
            child: Row(
              children: <Widget>[
                _buildFutureStatCard2<ServiceDikerjakan>(
                  future: API.DikerjakanID(),
                  color: Colors.green,
                  onTapRoute: Routes.SELESAIDIKERJAKAN,
                  dataLabel: "Service Dikerjakan",
                ),
                _buildFutureStatCardServiceDikerjakan<InvoiceHome>(
                  future: API.InvoiceID(),
                  color: Colors.purple,
                  onTapRoute: Routes.INVOICEMASUK,
                  dataLabel: "PKB Service",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFutureStatCardBooking<T>({
    required Future<T> future,
    required Color color,
    required String onTapRoute,
    required String dataLabel,
  }) {
    return Expanded(
      child: FutureBuilder<T>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingCard(color, icon: Icons.event_available);
          } else if (snapshot.hasError) {
            return Shimmer(
              child: Container(
                margin: const EdgeInsets.all(8.0),
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: const [
                        Icon(Icons.event_available,
                            color: Colors.white, size: 24),
                        SizedBox(width: 8),
                        Text(
                          'Tidak ada Internet',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const Text(
                      'Hari ini',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      '0',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            var data = snapshot.data;
            var count = '0';
            var label = dataLabel;

            if (data is MasukBooking) {
              count = data.countBookingMasuk?.toString() ?? '0';
            } else if (data is ServiceSelesaiHome) {
              count = data.countBookingMasuk?.toString() ?? '0';
            } else if (data is ServiceDikerjakan) {
              count = data.countDikerjakan?.toString() ?? '0';
            } else if (data is InvoiceHome) {
              count = data.countInvoice?.toString() ?? '0';
            }

            return InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                Get.toNamed(Routes.BOKING);
              },
              child: Container(
                margin: const EdgeInsets.all(8.0),
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: [
                        Icon(Icons.event_available,
                            color: Colors.white, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const Text(
                      'Hari ini',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      count,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildFutureStatCard<T>({
    required Future<T> future,
    required Color color,
    required String onTapRoute,
    required String dataLabel,
  }) {
    return Expanded(
      child: FutureBuilder<T>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingCard(color, icon: Icons.check_circle_outline);
          } else if (snapshot.hasError) {
            return Shimmer(
              child: Container(
                margin: const EdgeInsets.all(8.0),
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: const [
                        Icon(Icons.check_circle_outline,
                            color: Colors.white, size: 24),
                        SizedBox(width: 8),
                        Text(
                          'Tidak ada Internet',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const Text(
                      'Hari ini',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      '0',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            var data = snapshot.data;
            var count = '0';
            var label = dataLabel;

            if (data is MasukBooking) {
              count = data.countBookingMasuk?.toString() ?? '0';
            } else if (data is ServiceSelesaiHome) {
              count = data.countBookingMasuk?.toString() ?? '0';
            } else if (data is ServiceDikerjakan) {
              count = data.countDikerjakan?.toString() ?? '0';
            } else if (data is InvoiceHome) {
              count = data.countInvoice?.toString() ?? '0';
            }

            return InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                Get.toNamed(Routes.SELESAISERVICE);
              },
              child: Container(
                margin: const EdgeInsets.all(8.0),
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: [
                        Icon(Icons.check_circle_outline,
                            color: Colors.white, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const Text(
                      'Hari ini',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      count,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildFutureStatCard2<T>({
    required Future<T> future,
    required Color color,
    required String onTapRoute,
    required String dataLabel,
  }) {
    return Expanded(
      child: FutureBuilder<T>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingCard(color, icon: Icons.build);
          } else if (snapshot.hasError) {
            return Shimmer(
              child: Container(
                margin: const EdgeInsets.all(8.0),
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: const [
                        Icon(Icons.build, color: Colors.white, size: 24),
                        SizedBox(width: 8),
                        Text(
                          'Tidak ada Internet',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const Text(
                      'Hari ini',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      '0',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            var data = snapshot.data;
            var count = '0';
            var label = dataLabel;

            if (data is MasukBooking) {
              count = data.countBookingMasuk?.toString() ?? '0';
            } else if (data is ServiceSelesaiHome) {
              count = data.countBookingMasuk?.toString() ?? '0';
            } else if (data is ServiceDikerjakan) {
              count = data.countDikerjakan?.toString() ?? '0';
            }

            return InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                Get.toNamed(Routes.SELESAIDIKERJAKAN);
              },
              child: Container(
                margin: const EdgeInsets.all(8.0),
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: [
                        Icon(Icons.build, color: Colors.white, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const Text(
                      'Hari ini',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      count,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildFutureStatCardServiceDikerjakan<T>({
    required Future<T> future,
    required Color color,
    required String onTapRoute,
    required String dataLabel,
  }) {
    return Expanded(
      child: FutureBuilder<T>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingCard(color, icon: Icons.receipt_long);
          } else if (snapshot.hasError) {
            return Shimmer(
              child: Container(
                margin: const EdgeInsets.all(8.0),
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: const [
                        Icon(Icons.receipt_long, color: Colors.white, size: 24),
                        SizedBox(width: 8),
                        Text(
                          'Tidak ada Internet',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const Text(
                      'Hari ini',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      '0',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            var data = snapshot.data;
            var count = '0';
            var label = dataLabel;

            if (data is MasukBooking) {
              count = data.countBookingMasuk?.toString() ?? '0';
            } else if (data is ServiceSelesaiHome) {
              count = data.countBookingMasuk?.toString() ?? '0';
            } else if (data is ServiceDikerjakan) {
              count = data.countDikerjakan?.toString() ?? '0';
            }

            return InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                Get.toNamed(Routes.PROMEX);
              },
              child: Container(
                margin: const EdgeInsets.all(8.0),
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: [
                        Icon(Icons.receipt_long, color: Colors.white, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const Text(
                      'Hari ini',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      count,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildLoadingCard(Color color, {required IconData icon}) {
    return Shimmer(
      child: Container(
        margin: const EdgeInsets.all(8.0),
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: color.withOpacity(0.5),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: [
                Icon(icon, color: Colors.white, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Loading...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const Text(
              'Hari ini',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              '0',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(8.0),
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: [
                Icon(Icons.menu, color: Colors.white, size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const Text(
              'Hari ini',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
