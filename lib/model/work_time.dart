class WorkTimeResult {
  int code;
  String message;
  List<WorkTimeData> response;

  WorkTimeResult({this.code, this.message, this.response});

  WorkTimeResult.fromJson(Map<String, dynamic> json) {
    code = json['Code'];
    message = json['Message'];
    if (json['Response'] != null) {
      response = new List<WorkTimeData>();
      json['Response'].forEach((v) {
        response.add(new WorkTimeData.fromJson(v));
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

class WorkTimeData {
  int transdate;
  String hrid;
  num regularhrs;
  String enterby;
  int enterdate;
  int startdate;
  int finishdate;
  int starttime;
  int finishtime;
  String trade;
  String refwo;
  String displayname;
  num actualhrs;
  int hrtransid;

  WorkTimeData(
      {this.transdate,
        this.hrid,
        this.regularhrs,
        this.enterby,
        this.enterdate,
        this.startdate,
        this.finishdate,
        this.starttime,
        this.finishtime,
        this.trade,
        this.displayname,
        this.actualhrs,
        this.hrtransid = 0,
        this.refwo});

  WorkTimeData.fromJson(Map<String, dynamic> json) {
    transdate = json['transdate'];
    hrid = json['hrid'];
    regularhrs = json['regularhrs'];
    enterby = json['enterby'];
    enterdate = json['enterdate'];
    startdate = json['startdate'];
    finishdate = json['finishdate'];
    starttime = json['starttime'];
    finishtime = json['finishtime'];
    trade = json['trade'];
    refwo = json['refwo'];
    displayname = json['displayname'];
    actualhrs = json['actualhrs'];
    this.hrtransid = json['hrtransid'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
//    data['transdate'] = this.transdate;
    data['hrid'] = this.hrid;
    data['regularhrs'] = this.regularhrs;
//    data['enterby'] = this.enterby;
    data['enterdate'] = this.enterdate;
    data['startdate'] = this.startdate;
    data['finishdate'] = this.finishdate;
    data['starttime'] = this.starttime;
    data['finishtime'] = this.finishtime;
    data['trade'] = this.trade;
    data['refwo'] = this.refwo;
    data['actualhrs'] = this.actualhrs;
    data['hrtransid'] = this.hrtransid;
//    data['displayname'] = this.displayname;
    return data;
  }
}