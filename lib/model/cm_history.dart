class CMHistoryResult {
  int code;
  String message;
  List<CMHistoryData> response;

  CMHistoryResult({this.code, this.message, this.response});

  CMHistoryResult.fromJson(Map<String, dynamic> json) {
    code = json['Code'];
    message = json['Message'];
    if (json['Response'] != null) {
      response = new List<CMHistoryData>();
      json['Response'].forEach((v) {
        response.add(new CMHistoryData.fromJson(v));
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

class CMHistoryData {
  String wonum;
  String lead;
  String status;
  String description;
  String worktype;
  int actfinish;

  CMHistoryData({this.wonum, this.lead, this.status, this.actfinish});

  CMHistoryData.fromJson(Map<String, dynamic> json) {
    wonum = json['wonum'];
    lead = json['lead'];
    status = json['status'];
    actfinish = json['actfinish'];
    worktype = json['worktype'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['wonum'] = this.wonum;
    data['lead'] = this.lead;
    data['status'] = this.status;
    data['actfinish'] = this.actfinish;
    return data;
  }
}