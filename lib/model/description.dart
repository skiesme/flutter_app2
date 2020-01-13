class DescriptionResult {
  int code;
  String message;
  List<DescriptionData> response;

  DescriptionResult({this.code, this.message, this.response});

  DescriptionResult.fromJson(Map<String, dynamic> json) {
    code = json['Code'];
    message = json['Message'];
    if (json['Response'] != null) {
      response = new List<DescriptionData>();
      json['Response'].forEach((v) {
        response.add(new DescriptionData.fromJson(v));
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

class DescriptionData {
  String assetnum;
  String description;
  String location;
  String locationDescription;
  String status;

  DescriptionData(
      {this.assetnum,
      this.description,
      this.location,
      this.locationDescription,
      this.status});

  DescriptionData.fromJson(Map<String, dynamic> json) {
    assetnum = json['assetnum'];
    description = json['description'];
    location = json['location'];
    locationDescription = json['locationDescription'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['assetnum'] = this.assetnum;
    data['description'] = this.description;
    data['location'] = this.location;
    data['locationDescription'] = this.locationDescription;
    data['status'] = this.status;
    return data;
  }

  bool containsLoc(String str) {
    bool filter = (this.location ?? '').contains(str);
    filter = filter || (this.description ?? '').contains(str);

    // 强制大小写切换
    if (filter == false) {
      String ustr = str.toUpperCase();
      filter = (this.location ?? '').contains(ustr);
      filter = filter || (this.description ?? '').contains(ustr);
    }

    if (filter == false) {
      String ustr = str.toLowerCase();
      filter = (this.location ?? '').contains(ustr);
      filter = filter || (this.description ?? '').contains(ustr);
    }
    return filter;
  }

  bool containsAssets(String str) {
    bool filter = this.assetnum.contains(str);
    filter = filter || (this.description ?? '').contains(str);

    if (filter == false) {
      String ustr = str.toUpperCase();
      filter = this.assetnum.contains(ustr);
      filter = filter || (this.description ?? '').contains(ustr);
    }

    if (filter == false) {
      String ustr = str.toLowerCase();
      filter = this.assetnum.contains(ustr);
      filter = filter || (this.description ?? '').contains(ustr);
    }
    return filter;
  }

  bool containsAssetsLoc(String str) {
    bool filter = (this.location ?? '').contains(str);
    filter = filter || (this.locationDescription ?? '').contains(str);

    if (filter == false) {
      String ustr = str.toUpperCase();
      filter = (this.location ?? '').contains(ustr);
      filter = filter || (this.locationDescription ?? '').contains(ustr);
    }

    if (filter == false) {
      String ustr = str.toLowerCase();
      filter = (this.location ?? '').contains(ustr);
      filter = filter || (this.locationDescription ?? '').contains(ustr);
    }
    return filter;
  }
}
