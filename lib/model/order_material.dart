class OrderMaterialResult {
  int code;
  String message;
  List<OrderMaterialData> response;

  OrderMaterialResult({this.code, this.message, this.response});

  OrderMaterialResult.fromJson(Map<String, dynamic> json) {
    code = json['Code'];
    message = json['Message'];
    if (json['Response'] != null) {
      response = new List<OrderMaterialData>();
      json['Response'].forEach((v) {
        response.add(new OrderMaterialData.fromJson(v));
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

class OrderMaterialData {
  int woitemid;
  String itemnum;
  String wonum;
  String location;
  String locationdescription;
  String description;
  int requiredate;
  num itemqty;
  String requestby;
  String site;
  String storelocsite;

  OrderMaterialData(
      {this.woitemid,
        this.itemnum,
        this.wonum,
        this.location,
        this.locationdescription,
        this.description,
        this.requiredate,
        this.itemqty,
        this.requestby,
        this.site,
        this.storelocsite});

  OrderMaterialData.fromJson(Map<String, dynamic> json) {
    woitemid = json['woitemid'];
    itemnum = json['itemnum'];
    wonum = json['wonum'];
    location = json['location'];
    locationdescription = json['locationdescription'];
    description = json['description'];
    requiredate = json['requiredate'];
    itemqty = json['itemqty'];
    requestby = json['requestby'];
    site = json['site'];
    storelocsite = json['storelocsite'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['woitemid'] = this.woitemid;
    data['itemnum'] = this.itemnum;
    data['wonum'] = this.wonum;
    data['location'] = this.location;
    data['locationdescription'] = this.locationdescription;
    data['description'] = this.description;
    data['requiredate'] = this.requiredate;
    data['itemqty'] = this.itemqty;
    data['requestby'] = this.requestby;
    data['site'] = this.site;
    data['storelocsite'] = this.storelocsite;
    return data;
  }
}