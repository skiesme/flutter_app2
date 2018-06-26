class OrderStatusResult {
  int code;
  String message;
  List<OrderStatusData> response;

  OrderStatusResult({this.code, this.message, this.response});

  OrderStatusResult.fromJson(Map<String, dynamic> json) {
    code = json['Code'];
    message = json['Message'];
    if (json['Response'] != null) {
      response = new List<OrderStatusData>();
      json['Response'].forEach((v) {
        response.add(new OrderStatusData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Code'] = this.code;
    data['Message'] = this.message;
    if (this.response != null) {
      data['Response'] = this.response.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class OrderStatusData {
  String changeby;
  String status;
  int statusdate;

  OrderStatusData({this.changeby, this.status, this.statusdate});

  OrderStatusData.fromJson(Map<String, dynamic> json) {
    changeby = json['changeby']??'';
    status = json['status'];
    statusdate = json['statusdate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['changeby'] = this.changeby;
    data['status'] = this.status;
    data['statusdate'] = this.statusdate;
    return data;
  }
}