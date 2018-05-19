class User {
  int code;
  String message;
  UserData response;

  User({this.code, this.message, this.response});

  User.fromJson(Map<String, dynamic> json) {
    code = json['Code'];
    message = json['Message'];
    response = json['Response'] != null
        ? new UserData.fromJson(json['Response'])
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

class UserData {
  String displayname;
  String icon;
  String defsite;
  String descrition;
  int orders;
  Permission permission;

  UserData(
      {this.displayname,
        this.icon,
        this.defsite,
        this.descrition,
        this.orders,
        this.permission});

  UserData.fromJson(Map<String, dynamic> json) {
    displayname = json['displayname'];
    icon = json['icon'];
    defsite = json['defsite'];
    descrition = json['descrition'];
    orders = json['orders'];
    permission = json['permission'] != null
        ? new Permission.fromJson(json['permission'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['displayname'] = this.displayname;
    data['icon'] = this.icon;
    data['defsite'] = this.defsite;
    data['descrition'] = this.descrition;
    data['orders'] = this.orders;
    if (this.permission != null) {
      data['permission'] = this.permission.toJson();
    }
    return data;
  }
}

class Permission {
  List<String> bXWO;
  List<String> pMWO;
  List<String> xJ2WO;
  List<String> xJ3WO;
  List<String> xJ4WO;
  List<String> xJWO;

  Permission(
      {this.bXWO, this.pMWO, this.xJ2WO, this.xJ3WO, this.xJ4WO, this.xJWO});

  Permission.fromJson(Map<String, dynamic> json) {
    bXWO = json['BXWO'];
    pMWO = json['PMWO'];
    xJ2WO = json['XJ2WO'];
    xJ3WO = json['XJ3WO'];
    xJ4WO = json['XJ4WO'];
    xJWO = json['XJWO'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['BXWO'] = this.bXWO;
    data['PMWO'] = this.pMWO;
    data['XJ2WO'] = this.xJ2WO;
    data['XJ3WO'] = this.xJ3WO;
    data['XJ4WO'] = this.xJ4WO;
    data['XJWO'] = this.xJWO;
    return data;
  }
}
