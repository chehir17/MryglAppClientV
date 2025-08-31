class Payment {
  String? id;
  String? status;
  String? method;

  Payment.init()
      : id = '',
        status = '',
        method = '';

  Payment(this.method)
      : id = '',
        status = '';

  Payment.fromJSON(Map<String, dynamic> jsonMap)
      : id = jsonMap['id']?.toString() ?? '',
        status = jsonMap['status'] ?? '',
        method = jsonMap['method'] ?? '' {
    // Optionally handle errors or log if needed
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'status': status,
      'method': method,
    };
  }
}
