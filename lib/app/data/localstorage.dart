import 'package:get_storage/get_storage.dart';
import 'package:mekanik/app/data/publik.dart';

class LocalStorages {
  static GetStorage boxToken = GetStorage('token-mekanik');
  static GetStorage boxPreferences = GetStorage('preferences-mekanik');

  // -- Token handling --
  static Future<bool> hasToken() async {
    String token = getToken;
    return token.isNotEmpty;
  }

  static Future<void> setToken(String token) async {
    await boxToken.write('token', token);
    Publics.controller.getToken.value = getToken;
  }

  static String get getToken => boxToken.read('token') ?? '';

  static Future<void> deleteToken() async {
    await boxToken.remove('token');
    Publics.controller.getToken.value = '';
  }

  // -- Posisi handling --
  static Future<void> setPosisi(dynamic posisi) async {
    await boxPreferences.write('posisi', posisi);
  }

  static dynamic get getPosisi => boxPreferences.read('posisi');

  static Future<void> deletePosisi() async {
    await boxPreferences.remove('posisi');
  }

  // -- ID karyawan handling --
  static Future<void> setKaryawanId(String karyawanId) async {
    await boxPreferences.write('karyawanId', karyawanId);
  }

  static String get getKaryawanId => boxPreferences.read('karyawanId') ?? '';

  static Future<void> deleteKaryawanId() async {
    await boxPreferences.remove('karyawanId');
  }

  // -- Keep me signed in handling --
  static Future<void> setKeepMeSignedIn(bool keepSignedIn) async {
    await boxPreferences.write('keepMeSignedIn', keepSignedIn);
  }

  static Future<bool> getKeepMeSignedIn() async {
    return boxPreferences.read('keepMeSignedIn') ?? false;
  }

  static Future<void> deleteKeepMeSignedIn() async {
    await boxPreferences.remove('keepMeSignedIn');
  }

  // -- Mekanik ID handling (jika diperlukan) --
  static Future<void> setSelectedMechanicIds(List<String> ids) async {
    await boxPreferences.write('selectedMechanicIds', ids);
  }

  static List<String> getSelectedMechanicIds() {
    return boxPreferences.read('selectedMechanicIds')?.cast<String>() ?? [];
  }

  static Future<void> deleteSelectedMechanicIds() async {
    await boxPreferences.remove('selectedMechanicIds');
  }

  // -- Logout (bersihkan semuanya) --
  static Future<void> logout() async {
    await deleteToken();
    await deletePosisi();
    await deleteKaryawanId();
    await deleteKeepMeSignedIn();
    await deleteSelectedMechanicIds();
    // tambahkan logika tambahan jika diperlukan
  }
}
