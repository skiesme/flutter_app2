class OrderNewResult {
  int code;
  String message;
  OrderNewData response;

  OrderNewResult({this.code, this.message, this.response});

  OrderNewResult.fromJson(Map<String, dynamic> json) {
    code = json['Code'];
    message = json['Message'];
    response = json['OrderNewData'] != null
        ? new OrderNewData.fromJson(json['OrderNewData'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Code'] = this.code;
    data['Message'] = this.message;
    if (this.response != null) {
      data['OrderNewData'] = this.response.toJson();
    }
    return data;
  }
}

class OrderNewData {
  int workorderid;
  String wonum;

  OrderNewData({this.workorderid, this.wonum});

  OrderNewData.fromJson(Map<String, dynamic> json) {
    workorderid = json['workorderid'];
    wonum = json['wonum'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['workorderid'] = this.workorderid;
    data['wonum'] = this.wonum;
    return data;
  }
}