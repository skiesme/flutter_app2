class UserResult {
  int code;
  String message;
  UserInfo response;

  UserResult({this.code, this.message, this.response});

  UserResult.fromJson(Map<String, dynamic> json) {
    code = json['Code'];
    message = json['Message'];
    response = json['Response'] != null
        ? new UserInfo.fromJson(json['Response'])
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

class UserInfo {
  String displayname;
  String icon;
  String defsite;
  String description;
  String title;
  String department;
  int orders;
  Permission permission;
  String phone;

  UserInfo(
      {this.displayname,
        this.icon,
        this.defsite,
        this.description,
        this.orders,
        this.title,
        this.department,
        this.phone,
        this.permission});

  UserInfo.fromJson(Map<String, dynamic> json) {
    displayname = json['displayname'];
    icon = json['icon'];
    defsite = json['defsite'];
    description = json['description'];
    orders = json['orders'];
    title = json['title'] ??'';
    department = json['department'] ??'';
    phone = json['phone'] ?? '';
    permission = json['permission'] != null
        ? new Permission.fromJson(json['permission'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['displayname'] = this.displayname;
    data['icon'] = this.icon;
    data['defsite'] = this.defsite;
    data['description'] = this.description;
    data['orders'] = this.orders;
    data['title'] = this.title;
    data['department'] = this.department;
    data['phone'] = this.phone;
    if (this.permission != null) {
      data['permission'] = this.permission.toJson();
    }
    return data;
  }
}

class Permission {
  List<dynamic> bXWO;
  List<dynamic> pMWO;
  List<dynamic> xJ2WO;
  List<dynamic> xJ3WO;
  List<dynamic> xJ4WO;
  List<dynamic> xJWO;

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
