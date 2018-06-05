class OrderListResult {
  int code;
  String message;
  List<OrderShortInfo> response;

  OrderListResult({this.code, this.message, this.response});

  OrderListResult.fromJson(Map<String, dynamic> json) {
    code = json['Code'];
    message = json['Message'];
    if (json['Response'] != null) {
      response = new List<OrderShortInfo>();
      json['Response'].forEach((v) {
        response.add(new OrderShortInfo.fromJson(v));
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

class OrderShortInfo {
  String wonum;
  String description;
  String location;
  String locationDescription;
  String assetnum;
  String assetDescription;
  String status;
  String worktype;
  String changeby;
  int reportDate;
  int actfinish;

  OrderShortInfo(
      {this.wonum,
        this.description,
        this.location,
        this.locationDescription,
        this.assetnum,
        this.assetDescription,
        this.status,
        this.actfinish = 0,
        this.changeby,
        this.worktype});

  OrderShortInfo.fromJson(Map<String, dynamic> json) {
    wonum = json['wonum'];
    description = json['description'];
    location = json['location'];
    locationDescription = json['location_description'];
    assetnum = json['assetnum'];
    assetDescription = json['asset_description'];
    status = json['status'];
    worktype = json['worktype'];
    reportDate = json['reportdate'];
    actfinish = json['actfinish'];
    changeby = json['changeby'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['wonum'] = this.wonum;
    data['description'] = this.description;
    data['location'] = this.location;
    data['location_description'] = this.locationDescription;
    data['assetnum'] = this.assetnum;
    data['asset_description'] = this.assetDescription;
    data['status'] = this.status;
    data['worktype'] = this.worktype;
    data['reportdate'] = this.reportDate;
    data['actfinish'] = this.actfinish;
    data['changeby'] = this.changeby;

    return data;
  }
}