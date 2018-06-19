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
  List<HistoryError> error;

  HistoryData({this.wonum, this.changby, this.actfinish, this.error});

  HistoryData.fromJson(Map<String, dynamic> json) {
    wonum = json['wonum'];
    changby = json['changby'];
    actfinish = json['actfinish'];
    if (json['error'] != null) {
      error = new List<HistoryError>();
      json['error'].forEach((v) {
        error.add(new HistoryError.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['wonum'] = this.wonum;
    data['changby'] = this.changby;
    data['actfinish'] = this.actfinish;
    if (this.error != null) {
      data['error'] = this.error.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class HistoryError {
  int stepno;
  String description;
  String status;
  String remark;
  String assetnum;

  HistoryError(
      {this.stepno, this.description, this.status, this.remark, this.assetnum});

  HistoryError.fromJson(Map<String, dynamic> json) {
    stepno = json['stepno'];
    description = json['description'];
    status = json['status'];
    remark = json['remark'];
    assetnum = json['assetnum'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['stepno'] = this.stepno;
    data['description'] = this.description;
    data['status'] = this.status;
    data['remark'] = this.remark;
    data['assetnum'] = this.assetnum;
    return data;
  }
}
