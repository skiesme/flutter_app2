
Map<String, String> locationSite = new Map();

class MaterialResult {
  int code;
  String message;
  List<MaterialData> response;

  MaterialResult({this.code, this.message, this.response});

  MaterialResult.fromJson(Map<String, dynamic> json) {
    code = json['Code'];
    message = json['Message'];
    if (json['Response'] != null) {
      response = new List<MaterialData>();
      json['Response'].forEach((v) {
        response.add(new MaterialData.fromJson(v));
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

class MaterialData {
  num curbal;
  String description;
  String in26;
  String in27;
  String itemnum;
  String location;
  String locationdescription;
  String orderunit;
  String site;
  int physcntdate;

  MaterialData(
      {this.curbal,
        this.description,
        this.in26,
        this.in27,
        this.itemnum,
        this.location,
        this.locationdescription,
        this.orderunit,
        this.site,
        this.physcntdate});

  MaterialData.fromJson(Map<String, dynamic> json) {
    curbal = json['curbal'];
    description = json['description'];
    in26 = json['in26'];
    in27 = json['in27'];
    itemnum = json['itemnum'];
    location = json['location']??'';
    locationdescription = json['locationdescription'];
    orderunit = json['orderunit'];
    physcntdate = json['physcntdate'];
    site = json['site'];

    if(!locationSite.containsKey(location) && location.isNotEmpty){
      locationSite[location] = locationdescription;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['curbal'] = this.curbal;
    data['description'] = this.description;
    data['in26'] = this.in26;
    data['in27'] = this.in27;
    data['itemnum'] = this.itemnum;
    data['location'] = this.location;
    data['locationdescription'] = this.locationdescription;
    data['orderunit'] = this.orderunit;
    data['physcntdate'] = this.physcntdate;
    data['site'] = this.site;
    return data;
  }
}