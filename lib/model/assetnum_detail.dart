class AssetNumDetailResult {
  int code;
  String message;
  AssetNumDetail response;

  AssetNumDetailResult({this.code, this.message, this.response});

  AssetNumDetailResult.fromJson(Map<String, dynamic> json) {
    code = json['Code'];
    message = json['Message'];
    response = json['Response'] != null
        ? new AssetNumDetail.fromJson(json['Response'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Code'] = this.code;
    data['Message'] = this.message;
    if (this.response != null) {
      data['Response'] = this.response.toJson();
    }
    return data;
  }
}

class AssetNumDetail {
  String assetnum;
  String location;
  String locationDescription;
  String description;
  int changedate;
  String changeby;
  String assettype;
  String funclass;
  String serialnum;
  String parent;
  String status;
  String specific;
  List<String> pic;

  AssetNumDetail(
      {this.assetnum,
        this.location,
        this.locationDescription,
        this.description,
        this.changedate,
        this.changeby,
        this.assettype,
        this.funclass,
        this.serialnum,
        this.parent,
        this.status,
        this.specific,
        this.pic
      });

  AssetNumDetail.fromJson(Map<String, dynamic> json) {
    assetnum = json['assetnum'];
    location = json['location'];
    locationDescription = json['locationDescription'];
    description = json['description'];
    changedate = json['changedate'];
    changeby = json['changeby'];
    assettype = json['assettype']??'';
    funclass = json['funclass']??'';
    serialnum = json['serialnum']??'';
    parent = json['parent']??'';
    status = json['status']??'';
    specific = json['specific']??'';
    pic = json['pic']?.cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['assetnum'] = this.assetnum;
    data['location'] = this.location;
    data['locationDescription'] = this.locationDescription;
    data['description'] = this.description;
    data['changedate'] = this.changedate;
    data['changeby'] = this.changeby;
    data['assettype'] = this.assettype;
    data['funclass'] = this.funclass;
    data['serialnum'] = this.serialnum;
    data['parent'] = this.parent;
    data['status'] = this.status;
    data['specific'] = this.specific;
    data['pic'] = this.pic;
    return data;
  }
}