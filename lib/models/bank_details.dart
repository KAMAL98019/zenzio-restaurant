class BankDetails {
  final String bankName;
  final String accountNumber;
  final String ifscCode;
  final String accountType;

  BankDetails({
    required this.bankName,
    required this.accountNumber,
    required this.ifscCode,
    required this.accountType,
  });

  factory BankDetails.fromJson(Map<String, dynamic> json) {
    return BankDetails(
      bankName: json['bank_name'] ?? 'yes bank',
      accountNumber: json['account_number'] ?? '',
      ifscCode: json['ifsc_code'] ?? '',
      accountType: json['account_type'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bank_name': bankName,
      'account_number': accountNumber,
      'ifsc_code': ifscCode,
      'account_type': accountType,
    };
  }

  BankDetails copyWith({
    String? bankName,
    String? accountNumber,
    String? ifscCode,
    String? accountType,
  }) {
    return BankDetails(
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
      ifscCode: ifscCode ?? this.ifscCode,
      accountType: accountType ?? this.accountType,
    );
  }
}