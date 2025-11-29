class Documents {
  final String fssaiNumber;
  final List<String> fileFssai;
  final String gstNumber;
  final List<String> fileGst;
  final String? tradeLicenseNumber;
  final List<String>? fileTradeLicense;
  final String? otherDocumentType;
  final List<String>? fileOtherDoc;

  Documents({
    required this.fssaiNumber,
    required this.fileFssai,
    required this.gstNumber,
    required this.fileGst,
    this.tradeLicenseNumber,
    this.fileTradeLicense,
    this.otherDocumentType,
    this.fileOtherDoc,
  });

  factory Documents.fromJson(Map<String, dynamic> json) {
    return Documents(
      fssaiNumber: json['fssai_number'] ?? json['fssaiNumber'] ?? '', // Handle old and new key
      fileFssai: (json['file_fssai'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? (json['fssaiCertificateUrl'] != null ? [json['fssaiCertificateUrl']] : []),
      gstNumber: json['gsg_number'] ?? json['gstNumber'] ?? '', // Handle old and new key
      fileGst: (json['file_gst'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? (json['gstCertificateUrl'] != null ? [json['gstCertificateUrl']] : []),
      tradeLicenseNumber: json['trade_license_number'] ?? json['tradeLicenseNumber'],
      fileTradeLicense: (json['file_trade_license'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? (json['tradeLicenseUrl'] != null ? [json['tradeLicenseUrl']!] : null),
      otherDocumentType: json['otherDocumentType'],
      fileOtherDoc: (json['file_other_doc'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? (json['otherDocumentUrl'] != null ? [json['otherDocumentUrl']!] : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fssai_number': fssaiNumber,
      'file_fssai': fileFssai,
      'gsg_number': gstNumber,
      'file_gst': fileGst,
      'trade_license_number': tradeLicenseNumber,
      'file_trade_license': fileTradeLicense,
      'otherDocumentType': otherDocumentType,
      'file_other_doc': fileOtherDoc,
    };
  }
}