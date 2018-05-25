class StepsResult {
  int code;
  String message;
  StepsData response;

  StepsResult({this.code, this.message, this.response});

  StepsResult.fromJson(Map<String, dynamic> json) {
    code = json['Code'];
    message = json['Message'];
    response = json['Response'] != null
        ? new StepsData.fromJson(json['Response'])
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

class StepsData {
  int changedate;
  List<OrderStep> steps;

  StepsData({this.changedate, this.steps});

  StepsData.fromJson(Map<String, dynamic> json) {
    changedate = json['changedate'];
    if (json['steps'] != null) {
      steps = new List<OrderStep>();
      json['steps'].forEach((v) {
        steps.add(new OrderStep.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['changedate'] = this.changedate;
    if (this.steps != null) {
      data['steps'] = this.steps.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class OrderStep {
  int setpno;
  String description;
  String wonum;
  String assetnum;
  String assetDescription;
  String status;
  int statusdate;
  String remark;
  String exectuor;
  List<String> images;

  OrderStep(
      {this.setpno,
        this.description,
        this.wonum,
        this.assetnum,
        this.assetDescription,
        this.status,
        this.statusdate,
        this.remark,
        this.exectuor,
        this.images});

  OrderStep.fromJson(Map<String, dynamic> json) {
    setpno = json['setpno'];
    description = json['description'];
    wonum = json['wonum'];
    assetnum = json['assetnum'];
    assetDescription = json['asset_description'];
    status = json['status'];
    statusdate = json['statusdate'];
    remark = json['remark'];
    exectuor = json['exectuor'];
    images = json['images'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['setpno'] = this.setpno;
    data['description'] = this.description;
    data['wonum'] = this.wonum;
    data['assetnum'] = this.assetnum;
    data['asset_description'] = this.assetDescription;
    data['status'] = this.status;
    data['statusdate'] = this.statusdate;
    data['remark'] = this.remark;
    data['exectuor'] = this.exectuor;
    data['images'] = this.images;
    return data;
  }
}