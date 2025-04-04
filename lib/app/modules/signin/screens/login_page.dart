import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../data/data_endpoint/login.dart';
import '../../../data/endpoint.dart';
import '../../../data/localstorage.dart';
import '../../../routes/app_pages.dart';
import 'fade_animationtest.dart';
import 'forget_password.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool obscureText = true;
  late TextEditingController _passwordController;
  late TextEditingController _emailController;
  bool isChecked = false;
  bool isLoading = false; // Variabel untuk loading

  @override
  void initState() {
    super.initState();
    _passwordController = TextEditingController();
    _emailController = TextEditingController();

    // Cek apakah pengguna memilih untuk tetap masuk
    _checkKeepMeSignedIn();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void togglePasswordVisibility() {
    setState(() {
      obscureText = !obscureText;
    });
  }

  // Cek status 'Keep me signed in'
  void _checkKeepMeSignedIn() async {
    bool keepSignedIn = await LocalStorages.getKeepMeSignedIn();
    if (keepSignedIn) {
      String? token = await LocalStorages.getToken;
      if (token != null && token.isNotEmpty) {
        Get.offAllNamed(Routes.HOME); // Langsung navigasi ke halaman beranda
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        toolbarHeight: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
          systemNavigationBarColor: Colors.white,
        ),
      ),
      body: WillPopScope(
        onWillPop: () async {
          SystemNavigator.pop();
          return true;
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.07),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: screenHeight * 0.1),
                Text(
                  'Login',
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Welcome back to the app',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                FadeInAnimation(
                  delay: 1.6,
                  child: Builder(
                    builder: (context) {
                      double screenWidth = MediaQuery.of(context).size.width;
                      double imageSize = screenWidth > 600
                          ? screenWidth * 0.2
                          : screenWidth * 0.5;
                      return Image.asset(
                        'assets/logo_tech.png',
                        height: imageSize,
                        width: imageSize,
                      );
                    },
                  ),
                ),
                SizedBox(height: 10),
                Form(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        // style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Email Address',
                          labelStyle:
                              TextStyle(color: Colors.grey), // Warna label
                          hintText: 'hello@example.com',
                          hintStyle:
                              TextStyle(color: Colors.grey), // Warna hint
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: obscureText,
                        // style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelStyle: TextStyle(color: Colors.grey),
                          labelText: 'Password',
                          suffixIcon: IconButton(
                            onPressed: togglePasswordVisibility,
                            icon: Icon(
                              obscureText
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Get.to(ForgetPasswordPage());
                          },
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                      ),
                      CheckboxListTile(
                        value: isChecked,
                        onChanged: (value) {
                          setState(() {
                            isChecked = value ?? false;
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          'Keep me signed in',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () async {
                                HapticFeedback.lightImpact();
                                if (_emailController.text.isNotEmpty &&
                                    _passwordController.text.isNotEmpty) {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  try {
                                    Token aksesPX = await API.login(
                                      email: _emailController.text,
                                      password: _passwordController.text,
                                    );

                                    if (aksesPX.status != false) {
                                      if (aksesPX.token != null) {
                                        // Simpan token dan status 'Keep me signed in'
                                        await LocalStorages.setToken(
                                            aksesPX.token!);
                                        await LocalStorages.setKeepMeSignedIn(
                                            isChecked);

                                        Get.offAllNamed(Routes.HOME);
                                      }
                                    } else {
                                      String errorMessage = aksesPX.message ??
                                          'Terjadi kesalahan saat login';
                                      Object errorDetail = aksesPX.data ?? '';
                                      Get.snackbar('Error',
                                          '$errorMessage: $errorDetail',
                                          backgroundColor: Colors.redAccent,
                                          colorText: Colors.white);
                                    }
                                  } catch (e) {
                                    print('Error during login: $e');
                                    Get.snackbar('Gagal Login',
                                        'Terjadi kesalahan saat login',
                                        backgroundColor: Colors.redAccent,
                                        colorText: Colors.white);
                                  }
                                  setState(() {
                                    isLoading = false;
                                  });
                                } else {
                                  Get.snackbar('Gagal Login',
                                      'Username dan Password harus diisi',
                                      backgroundColor: Colors.redAccent,
                                      colorText: Colors.white);
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 50),
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isLoading
                            ? SizedBox(
                                height: 24.0,
                                width: 24.0,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                  strokeWidth: 2.0,
                                ),
                              )
                            : Text(
                                'Login',
                                style: TextStyle(color: Colors.white),
                              ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
