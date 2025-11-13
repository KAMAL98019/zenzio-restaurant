class Documents {
  final String fssaiNumber;
  final String fssaiCertificateUrl;
  final String gstNumber;
  final String gstCertificateUrl;
  final String? tradeLicenseNumber;
  final String? tradeLicenseUrl;
  final String? otherDocumentType;
  final String? otherDocumentUrl;

  Documents({
    required this.fssaiNumber,
    required this.fssaiCertificateUrl,
    required this.gstNumber,
    required this.gstCertificateUrl,
    this.tradeLicenseNumber,
    this.tradeLicenseUrl,
    this.otherDocumentType,
    this.otherDocumentUrl,
  });

  factory Documents.fromJson(Map<String, dynamic> json) {
    return Documents(
      fssaiNumber: json['fssaiNumber'] ?? '',
      fssaiCertificateUrl: json['fssaiCertificateUrl'] ?? '',
      gstNumber: json['gstNumber'] ?? '',
      gstCertificateUrl: json['gstCertificateUrl'] ?? '',
      tradeLicenseNumber: json['tradeLicenseNumber'],
      tradeLicenseUrl: json['tradeLicenseUrl'],
      otherDocumentType: json['otherDocumentType'],
      otherDocumentUrl: json['otherDocumentUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fssaiNumber': fssaiNumber,
      'fssaiCertificateUrl': fssaiCertificateUrl,
      'gstNumber': gstNumber,
      'gstCertificateUrl': gstCertificateUrl,
      'tradeLicenseNumber': tradeLicenseNumber,
      'tradeLicenseUrl': tradeLicenseUrl,
      'otherDocumentType': otherDocumentType,
      'otherDocumentUrl': otherDocumentUrl,
    };
  }
}