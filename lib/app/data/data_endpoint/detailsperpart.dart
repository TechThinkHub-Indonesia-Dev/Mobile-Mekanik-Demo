class DetailSpertpart {
  bool? status;
  String? message;
  DataPhotosparepart? dataPhotosparepart;

  DetailSpertpart({this.status, this.message, this.dataPhotosparepart});

  DetailSpertpart.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    dataPhotosparepart = json['dataPhotosparepart'] != null
        ? DataPhotosparepart.fromJson(json['dataPhotosparepart'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (dataPhotosparepart != null) {
      data['dataPhotosparepart'] = dataPhotosparepart!.toJson();
    }
    return data;
  }
}

class DataPhotosparepart {
  List<String>? kontak;
  DataSvc? dataSvc;
  List<DetailSparepart>? detailSparepart;
  List<PhotoSparepart>? photoSparepart;

  DataPhotosparepart({
    this.kontak,
    this.dataSvc,
    this.detailSparepart,
    this.photoSparepart,
  });

  DataPhotosparepart.fromJson(Map<String, dynamic> json) {
    kontak = json['kontak']?.cast<String>();
    dataSvc =
        json['data_svc'] != null ? DataSvc.fromJson(json['data_svc']) : null;
    if (json['detailSparepart'] != null) {
      detailSparepart = <DetailSparepart>[];
      json['detailSparepart'].forEach((v) {
        detailSparepart!.add(DetailSparepart.fromJson(v));
      });
    }
    if (json['photoSparepart'] != null) {
      photoSparepart = <PhotoSparepart>[];
      json['photoSparepart'].forEach((v) {
        photoSparepart!.add(PhotoSparepart.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['kontak'] = kontak;
    if (dataSvc != null) {
      data['data_svc'] = dataSvc!.toJson();
    }
    if (detailSparepart != null) {
      data['detailSparepart'] =
          detailSparepart!.map((v) => v.toJson()).toList();
    }
    if (photoSparepart != null) {
      data['photoSparepart'] = photoSparepart!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class DataSvc {
  int? id;
  String? kodeBooking;
  int? cabangId;
  String? kodeSvc;
  String? kodeEstimasi;
  String? kodePkb;
  String? kodePelanggan;
  String? kodeKendaraan;
  String? odometer;
  String? pic;
  String? hpPic;
  String? kodeMembership;
  String? kodePaketmember;
  String? tipeSvc;
  String? tipePelanggan;
  String? referensi;
  String? referensiTeman;
  String? poNumber;
  String? paketSvc;
  String? tglKeluar;
  String? tglKembali;
  String? kmKeluar;
  String? kmKembali;
  String? keluhan;
  String? perintahKerja;
  String? pergantianPart;
  String? saran;
  String? ppn;
  String? penanggungJawab;
  String? tglEstimasi;
  String? tglPkb;
  String? tglTutup;
  String? jamEstimasiSelesai;
  String? jamSelesai;
  String? datetimeSelesai;
  int? pkb;
  int? tutup;
  int? faktur;
  int? deleted;
  int? notab;
  int? planning;
  String? statusApproval;
  String? createdBy;
  String? createdByPkb;
  String? createdAt;
  String? updatedBy;
  String? updatedAt;
  String? kode;
  String? noPolisi;
  int? idMerk;
  int? idTipe;
  String? tahun;
  String? warna;
  String? transmisi;
  String? noRangka;
  String? noMesin;
  String? modelKaroseri;
  String? drivingMode;
  String? power;
  String? kategoriKendaraan;
  String? jenisKontrak;
  String? jenisUnit;
  int? idPicPerusahaan;
  int? picIdPelanggan;
  int? idCustomer;
  String? vinNumber;
  String? expiredStnk;
  String? nama;
  String? alamat;
  String? telp;
  String? hp;
  String? email;
  String? kontak;
  int? due;
  String? jenisKontrakX;
  String? namaTagihan;
  String? alamatTagihan;
  String? telpTagihan;
  String? npwpTagihan;
  String? picTagihan;
  String? password;
  String? rememberToken;
  String? emailVerifiedAt;
  String? otp;
  String? otpExpiry;
  String? gambar;
  String? fcmToken;
  String? namaMerk;
  String? namaTipe;
  String? namaCabang;
  int? svcId;

  DataSvc({
    this.id,
    this.kodeBooking,
    this.cabangId,
    this.kodeSvc,
    this.kodeEstimasi,
    this.kodePkb,
    this.kodePelanggan,
    this.kodeKendaraan,
    this.odometer,
    this.pic,
    this.hpPic,
    this.kodeMembership,
    this.kodePaketmember,
    this.tipeSvc,
    this.tipePelanggan,
    this.referensi,
    this.referensiTeman,
    this.poNumber,
    this.paketSvc,
    this.tglKeluar,
    this.tglKembali,
    this.kmKeluar,
    this.kmKembali,
    this.keluhan,
    this.perintahKerja,
    this.pergantianPart,
    this.saran,
    this.ppn,
    this.penanggungJawab,
    this.tglEstimasi,
    this.tglPkb,
    this.tglTutup,
    this.jamEstimasiSelesai,
    this.jamSelesai,
    this.datetimeSelesai,
    this.pkb,
    this.tutup,
    this.faktur,
    this.deleted,
    this.notab,
    this.planning,
    this.statusApproval,
    this.createdBy,
    this.createdByPkb,
    this.createdAt,
    this.updatedBy,
    this.updatedAt,
    this.kode,
    this.noPolisi,
    this.idMerk,
    this.idTipe,
    this.tahun,
    this.warna,
    this.transmisi,
    this.noRangka,
    this.noMesin,
    this.modelKaroseri,
    this.drivingMode,
    this.power,
    this.kategoriKendaraan,
    this.jenisKontrak,
    this.jenisUnit,
    this.idPicPerusahaan,
    this.picIdPelanggan,
    this.idCustomer,
    this.vinNumber,
    this.expiredStnk,
    this.nama,
    this.alamat,
    this.telp,
    this.hp,
    this.email,
    this.kontak,
    this.due,
    this.jenisKontrakX,
    this.namaTagihan,
    this.alamatTagihan,
    this.telpTagihan,
    this.npwpTagihan,
    this.picTagihan,
    this.password,
    this.rememberToken,
    this.emailVerifiedAt,
    this.otp,
    this.otpExpiry,
    this.gambar,
    this.fcmToken,
    this.namaMerk,
    this.namaTipe,
    this.namaCabang,
    this.svcId,
  });

  DataSvc.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    kodeBooking = json['kode_booking'];
    cabangId = json['cabang_id'];
    kodeSvc = json['kode_svc'];
    kodeEstimasi = json['kode_estimasi'];
    kodePkb = json['kode_pkb'];
    kodePelanggan = json['kode_pelanggan'];
    kodeKendaraan = json['kode_kendaraan'];
    odometer = json['odometer'];
    pic = json['pic'];
    hpPic = json['hp_pic'];
    kodeMembership = json['kode_membership'];
    kodePaketmember = json['kode_paketmember'];
    tipeSvc = json['tipe_svc'];
    tipePelanggan = json['tipe_pelanggan'];
    referensi = json['referensi'];
    referensiTeman = json['referensi_teman'];
    poNumber = json['po_number'];
    paketSvc = json['paket_svc'];
    tglKeluar = json['tgl_keluar'];
    tglKembali = json['tgl_kembali'];
    kmKeluar = json['km_keluar'];
    kmKembali = json['km_kembali'];
    keluhan = json['keluhan'];
    perintahKerja = json['perintah_kerja'];
    pergantianPart = json['pergantian_part'];
    saran = json['saran'];
    ppn = json['ppn'];
    penanggungJawab = json['penanggung_jawab'];
    tglEstimasi = json['tgl_estimasi'];
    tglPkb = json['tgl_pkb'];
    tglTutup = json['tgl_tutup'];
    jamEstimasiSelesai = json['jam_estimasi_selesai'];
    jamSelesai = json['jam_selesai'];
    datetimeSelesai = json['datetime_selesai'];
    pkb = json['pkb'];
    tutup = json['tutup'];
    faktur = json['faktur'];
    deleted = json['deleted'];
    notab = json['notab'];
    planning = json['planning'];
    statusApproval = json['status_approval'];
    createdBy = json['created_by'];
    createdByPkb = json['created_by_pkb'];
    createdAt = json['created_at'];
    updatedBy = json['updated_by'];
    updatedAt = json['updated_at'];
    kode = json['kode'];
    noPolisi = json['no_polisi'];
    idMerk = json['id_merk'];
    idTipe = json['id_tipe'];
    tahun = json['tahun'];
    warna = json['warna'];
    transmisi = json['transmisi'];
    noRangka = json['no_rangka'];
    noMesin = json['no_mesin'];
    modelKaroseri = json['model_karoseri'];
    drivingMode = json['driving_mode'];
    power = json['power'];
    kategoriKendaraan = json['kategori_kendaraan'];
    jenisKontrak = json['jenis_kontrak'];
    jenisUnit = json['jenis_unit'];
    idPicPerusahaan = json['id_pic_perusahaan'];
    picIdPelanggan = json['pic_id_pelanggan'];
    idCustomer = json['id_customer'];
    vinNumber = json['vin_number'];
    expiredStnk = json['expired_stnk'];
    nama = json['nama'];
    alamat = json['alamat'];
    telp = json['telp'];
    hp = json['hp'];
    email = json['email'];
    kontak = json['kontak'];
    due = json['due'];
    jenisKontrakX = json['jenis_kontrak_x'];
    namaTagihan = json['nama_tagihan'];
    alamatTagihan = json['alamat_tagihan'];
    telpTagihan = json['telp_tagihan'];
    npwpTagihan = json['npwp_tagihan'];
    picTagihan = json['pic_tagihan'];
    password = json['password'];
    rememberToken = json['remember_token'];
    emailVerifiedAt = json['email_verified_at'];
    otp = json['otp'];
    otpExpiry = json['otp_expiry'];
    gambar = json['gambar'];
    fcmToken = json['fcm_token'];
    namaMerk = json['nama_merk'];
    namaTipe = json['nama_tipe'];
    namaCabang = json['nama_cabang'];
    svcId = json['svc_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['kode_booking'] = kodeBooking;
    data['cabang_id'] = cabangId;
    data['kode_svc'] = kodeSvc;
    data['kode_estimasi'] = kodeEstimasi;
    data['kode_pkb'] = kodePkb;
    data['kode_pelanggan'] = kodePelanggan;
    data['kode_kendaraan'] = kodeKendaraan;
    data['odometer'] = odometer;
    data['pic'] = pic;
    data['hp_pic'] = hpPic;
    data['kode_membership'] = kodeMembership;
    data['kode_paketmember'] = kodePaketmember;
    data['tipe_svc'] = tipeSvc;
    data['tipe_pelanggan'] = tipePelanggan;
    data['referensi'] = referensi;
    data['referensi_teman'] = referensiTeman;
    data['po_number'] = poNumber;
    data['paket_svc'] = paketSvc;
    data['tgl_keluar'] = tglKeluar;
    data['tgl_kembali'] = tglKembali;
    data['km_keluar'] = kmKeluar;
    data['km_kembali'] = kmKembali;
    data['keluhan'] = keluhan;
    data['perintah_kerja'] = perintahKerja;
    data['pergantian_part'] = pergantianPart;
    data['saran'] = saran;
    data['ppn'] = ppn;
    data['penanggung_jawab'] = penanggungJawab;
    data['tgl_estimasi'] = tglEstimasi;
    data['tgl_pkb'] = tglPkb;
    data['tgl_tutup'] = tglTutup;
    data['jam_estimasi_selesai'] = jamEstimasiSelesai;
    data['jam_selesai'] = jamSelesai;
    data['datetime_selesai'] = datetimeSelesai;
    data['pkb'] = pkb;
    data['tutup'] = tutup;
    data['faktur'] = faktur;
    data['deleted'] = deleted;
    data['notab'] = notab;
    data['planning'] = planning;
    data['status_approval'] = statusApproval;
    data['created_by'] = createdBy;
    data['created_by_pkb'] = createdByPkb;
    data['created_at'] = createdAt;
    data['updated_by'] = updatedBy;
    data['updated_at'] = updatedAt;
    data['kode'] = kode;
    data['no_polisi'] = noPolisi;
    data['id_merk'] = idMerk;
    data['id_tipe'] = idTipe;
    data['tahun'] = tahun;
    data['warna'] = warna;
    data['transmisi'] = transmisi;
    data['no_rangka'] = noRangka;
    data['no_mesin'] = noMesin;
    data['model_karoseri'] = modelKaroseri;
    data['driving_mode'] = drivingMode;
    data['power'] = power;
    data['kategori_kendaraan'] = kategoriKendaraan;
    data['jenis_kontrak'] = jenisKontrak;
    data['jenis_unit'] = jenisUnit;
    data['id_pic_perusahaan'] = idPicPerusahaan;
    data['pic_id_pelanggan'] = picIdPelanggan;
    data['id_customer'] = idCustomer;
    data['vin_number'] = vinNumber;
    data['expired_stnk'] = expiredStnk;
    data['nama'] = nama;
    data['alamat'] = alamat;
    data['telp'] = telp;
    data['hp'] = hp;
    data['email'] = email;
    data['kontak'] = kontak;
    data['due'] = due;
    data['jenis_kontrak_x'] = jenisKontrakX;
    data['nama_tagihan'] = namaTagihan;
    data['alamat_tagihan'] = alamatTagihan;
    data['telp_tagihan'] = telpTagihan;
    data['npwp_tagihan'] = npwpTagihan;
    data['pic_tagihan'] = picTagihan;
    data['password'] = password;
    data['remember_token'] = rememberToken;
    data['email_verified_at'] = emailVerifiedAt;
    data['otp'] = otp;
    data['otp_expiry'] = otpExpiry;
    data['gambar'] = gambar;
    data['fcm_token'] = fcmToken;
    data['nama_merk'] = namaMerk;
    data['nama_tipe'] = namaTipe;
    data['nama_cabang'] = namaCabang;
    data['svc_id'] = svcId;
    return data;
  }
}

class DetailSparepart {
  int? id;
  String? kodeSvc;
  String? kodeSparepart;
  String? namaSparepart;

  // ==> Berikut field-field yang diubah menjadi double? <==
  double? qtySparepart; // dari int? ke double?
  int? hargaSparepart; // tetap int? (tidak ada di referensi)
  double? diskonSparepart; // dari int? ke double?

  String? hidSparepart;
  int? nota;
  int? pengajuan;
  String? createdAt;
  String? updatedAt;
  String? kodeMaster;
  String? kode;
  String? kode2;
  String? nama;
  String? divisi;
  String? brand;

  // ==> Juga diubah menjadi double? <==
  double? qty; // dari int? ke double?

  int? hargaBeli; // tetap int? (tidak ada di referensi)
  int? hargaJual; // tetap int? (tidak ada di referensi)
  String? barcode;
  String? satuan;
  String? noStock;
  String? lokasi;
  String? note;
  String? tipe;
  String? kodeSupplier;

  // ==> Juga diubah menjadi double? <==
  double? qtyMin; // dari int? ke double?
  double? qtyMax; // dari int? ke double?
  String? ukuran;
  String? kualitas;
  double? demandBulanan; // dari int? ke double?

  String? emergency;
  String? jenis;
  int? deleted;
  String? createdBy;
  String? gudang;
  int? cabangId;

  DetailSparepart({
    this.id,
    this.kodeSvc,
    this.kodeSparepart,
    this.namaSparepart,
    this.qtySparepart,
    this.hargaSparepart,
    this.diskonSparepart,
    this.hidSparepart,
    this.nota,
    this.pengajuan,
    this.createdAt,
    this.updatedAt,
    this.kodeMaster,
    this.kode,
    this.kode2,
    this.nama,
    this.divisi,
    this.brand,
    this.qty,
    this.hargaBeli,
    this.hargaJual,
    this.barcode,
    this.satuan,
    this.noStock,
    this.lokasi,
    this.note,
    this.tipe,
    this.kodeSupplier,
    this.qtyMin,
    this.qtyMax,
    this.ukuran,
    this.kualitas,
    this.demandBulanan,
    this.emergency,
    this.jenis,
    this.deleted,
    this.createdBy,
    this.gudang,
    this.cabangId,
  });

  DetailSparepart.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    kodeSvc = json['kode_svc'];
    kodeSparepart = json['kode_sparepart'];
    namaSparepart = json['nama_sparepart'];

    // Ubah ke double? dengan tryParse agar tidak error jika string
    qtySparepart = (json['qty_sparepart'] == null)
        ? null
        : double.tryParse(json['qty_sparepart'].toString());

    // hargaSparepart tetap int? (tidak ada di daftar referensi, bisa dibiarkan)
    hargaSparepart = json['harga_sparepart'];

    diskonSparepart = (json['diskon_sparepart'] == null)
        ? null
        : double.tryParse(json['diskon_sparepart'].toString());

    hidSparepart = json['hid_sparepart'];
    nota = json['nota'];
    pengajuan = json['pengajuan'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    kodeMaster = json['kode_master'];
    kode = json['kode'];
    kode2 = json['kode_2'];
    nama = json['nama'];
    divisi = json['divisi'];
    brand = json['brand'];

    qty =
        (json['qty'] == null) ? null : double.tryParse(json['qty'].toString());

    hargaBeli = json['harga_beli'];
    hargaJual = json['harga_jual'];
    barcode = json['barcode'];
    satuan = json['satuan'];
    noStock = json['no_stock'];
    lokasi = json['lokasi'];
    note = json['note'];
    tipe = json['tipe'];
    kodeSupplier = json['kode_supplier'];

    qtyMin = (json['qty_min'] == null)
        ? null
        : double.tryParse(json['qty_min'].toString());
    qtyMax = (json['qty_max'] == null)
        ? null
        : double.tryParse(json['qty_max'].toString());

    ukuran = json['ukuran'];
    kualitas = json['kualitas'];

    demandBulanan = (json['demand_bulanan'] == null)
        ? null
        : double.tryParse(json['demand_bulanan'].toString());

    emergency = json['emergency'];
    jenis = json['jenis'];
    deleted = json['deleted'];
    createdBy = json['created_by'];
    gudang = json['gudang'];
    cabangId = json['cabang_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['kode_svc'] = kodeSvc;
    data['kode_sparepart'] = kodeSparepart;
    data['nama_sparepart'] = namaSparepart;
    data['qty_sparepart'] = qtySparepart;
    data['harga_sparepart'] = hargaSparepart;
    data['diskon_sparepart'] = diskonSparepart;
    data['hid_sparepart'] = hidSparepart;
    data['nota'] = nota;
    data['pengajuan'] = pengajuan;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['kode_master'] = kodeMaster;
    data['kode'] = kode;
    data['kode_2'] = kode2;
    data['nama'] = nama;
    data['divisi'] = divisi;
    data['brand'] = brand;
    data['qty'] = qty;
    data['harga_beli'] = hargaBeli;
    data['harga_jual'] = hargaJual;
    data['barcode'] = barcode;
    data['satuan'] = satuan;
    data['no_stock'] = noStock;
    data['lokasi'] = lokasi;
    data['note'] = note;
    data['tipe'] = tipe;
    data['kode_supplier'] = kodeSupplier;
    data['qty_min'] = qtyMin;
    data['qty_max'] = qtyMax;
    data['ukuran'] = ukuran;
    data['kualitas'] = kualitas;
    data['demand_bulanan'] = demandBulanan;
    data['emergency'] = emergency;
    data['jenis'] = jenis;
    data['deleted'] = deleted;
    data['created_by'] = createdBy;
    data['gudang'] = gudang;
    data['cabang_id'] = cabangId;
    return data;
  }
}

class PhotoSparepart {
  int? id;
  int? svcId;
  String? photoType;
  String? photoUrl;
  String? createdAt;
  String? updatedAt;
  String? kodeSparepart;

  PhotoSparepart({
    this.id,
    this.svcId,
    this.photoType,
    this.photoUrl,
    this.createdAt,
    this.updatedAt,
    this.kodeSparepart,
  });

  PhotoSparepart.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    svcId = json['svc_id'];
    photoType = json['photo_type'];
    photoUrl = json['photo_url'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    kodeSparepart = json['kode_sparepart'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['svc_id'] = svcId;
    data['photo_type'] = photoType;
    data['photo_url'] = photoUrl;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['kode_sparepart'] = kodeSparepart;
    return data;
  }
}
