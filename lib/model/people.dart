class PeopleResult {
  int code;
  String message;
  List<PeopleData> response;

  PeopleResult({this.code, this.message, this.response});

  PeopleResult.fromJson(Map<String, dynamic> json) {
    code = json['Code'];
    message = json['Message'];
    if (json['Response'] != null) {
      response = new List<PeopleData>();
      json['Response'].forEach((v) {
        response.add(new PeopleData.fromJson(v));
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

class PeopleData {
  String hrid;
  String displayname;
  int statusdate;
  String title;
  String department;
  String trade;

  PeopleData(
      {this.hrid,
        this.displayname,
        this.statusdate,
        this.title,
        this.trade,
        this.department});

  PeopleData.fromJson(Map<String, dynamic> json) {
    hrid = json['hrid'];
    displayname = json['displayname'];
    statusdate = json['statusdate'];
    title = json['title'];
    department = json['department'];
    trade = json['trade'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['hrid'] = this.hrid;
    data['displayname'] = this.displayname;
    data['statusdate'] = this.statusdate;
    data['title'] = this.title;
    data['department'] = this.department;
    data['trade'] = this.trade;
    return data;
  }
}