class HistoryResult {
  int code;
  String message;
  List<HistoryData> response;

  HistoryResult({this.code, this.message, this.response});

  HistoryResult.fromJson(Map<String, dynamic> json) {
    code = json['Code'];
    message = json['Message'];
    if (json['Response'] != null) {
      response = new List<HistoryData>();
      json['Response'].forEach((v) {
        response.add(new HistoryData.fromJson(v));
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

class HistoryData {
  String wonum;
  String changby;
  int actfinish;
  Null error;

  HistoryData({this.wonum, this.changby, this.actfinish, this.error});

  HistoryData.fromJson(Map<String, dynamic> json) {
    wonum = json['wonum'];
    changby = json['changby'];
    actfinish = json['actfinish'];
    error = json['error'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['wonum'] = this.wonum;
    data['changby'] = this.changby;
    data['actfinish'] = this.actfinish;
    data['error'] = this.error;
    return data;
  }
}