
## Prasyarat

Pastikan Anda sudah menginstal perangkat lunak berikut:

1. **Flutter 3.19.5**  
   Unduh Flutter [di sini](https://flutter.dev/docs/get-started/install).

2. **OpenJDK 17 (versi 17.0.13)**  
   Unduh OpenJDK [di sini](https://openjdk.java.net/).

3. **Terapkan Getx**
   ```bash
   flutter pub global activate -s git https://github.com/jonataslaw/get_cli
   ```
4. **Android Studio**

   Unduh Android Studio [di sini](https://developer.android.com/studio).

5. **Xcode** (untuk pengembangan iOS, jika diperlukan).

## Menyiapkan Keystore (JKS) untuk Signing Aplikasi

1. **Dapatkan file JKS dan Key**  
   File JKS dan key ada di **Google Drive TechThinkHub**. Pastikan Anda punya akses dan unduh file tersebut.

2. **Tempatkan File JKS di Proyek**  
   Setelah mengunduh file JKS, simpan di folder `android/app` pada proyek Flutter Anda.

3. **Konfigurasi Signing di Proyek Flutter**
   - Buat file baru bernama `key.properties` di dalam folder `android/` dan isi dengan informasi berikut:

     ```properties
     storePassword=Tth@bengkelly
     keyPassword=Tth@bengkelly
     keyAlias=bengkellyalias
     storeFile=bengkelly.jks
     ```

   - Ubah file `android/app/build.gradle` dengan menambahkan konfigurasi berikut:

     ```groovy
     signingConfigs {
       debug {

       }

       release {
           keyAlias keystoreProperties['keyAlias']
           keyPassword keystoreProperties['keyPassword']
           storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
           storePassword keystoreProperties['storePassword']
           applicationVariants.all { variant ->
               variant.outputs.all {
                   def appName = "Bengkelly"
                   def buildType = variant.buildType.name
                   def newName
                   if (buildType == 'debug'){
                       newName = "app-${flutterVersionName}-debug.apk"
                   } else {
                       newName = "${appName}${flutterVersionName}_${variant.getFlavorName()}.apk"
                   }
                   outputFileName = newName
               }
           }
       }
   }
      ```

4. **Membangun Aplikasi**  
   Jalankan perintah berikut untuk menghasilkan APK atau AAB:

   - Untuk APK:
     ```bash
     flutter build apk --flavor prod --target lib/main.dart
     ```

   - Untuk AAB:
     ```bash
     flutter build appbundle --flavor prod --target lib/main.dart
     ```

## Menjalankan Proyek

1. **Clone Repository**  
   Clone repositori ini ke komputer Anda:

   ```bash
   git clone <URL_REPOSITORI>
   cd <nama-folder-proyek>
   ```

2. **Instal Dependensi**  
   Instal semua dependensi yang diperlukan:

   ```bash
   flutter pub get
   ```

3. **Jalankan Aplikasi**  
   Jalankan aplikasi di emulator atau perangkat Android/iOS:

   ```bash
   flutter run
   ```

---

Cukup ganti placeholder `<password_keystore_anda>`, `<alias_key_anda>`, `<path_keystore_anda>`, dan `<URL_REPOSITORI>` dengan nilai yang sesuai.
