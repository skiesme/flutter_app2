class OrderDetailResult {
  int code;
  String message;
  OrderDetailData response;

  OrderDetailResult({this.code, this.message, this.response});

  OrderDetailResult.fromJson(Map<String, dynamic> json) {
    code = json['Code'];
    message = json['Message'];
    response = json['Response'] != null
        ? new OrderDetailData.fromJson(json['Response'])
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

class OrderDetailData {
  String wonum;
  String description;
  String location;
  String locationDescription;
  String assetnum;
  String assetDescription;
  String status;
  String worktype;
  String site;
  int reportdate;
  int changedate;
  int targstartdate;
  int targcompdate;
  int actstart;
  int actfinish;
  String lead;
  String reportedby;
  String phone;
  String wopriority;
  String supervisor;
  String sopnum;

  OrderDetailData(
      {this.wonum,
        this.description,
        this.location,
        this.locationDescription,
        this.assetnum,
        this.assetDescription,
        this.status,
        this.worktype,
        this.site,
        this.reportdate,
        this.changedate,
        this.targstartdate,
        this.targcompdate,
        this.actstart,
        this.actfinish,
        this.lead,
        this.reportedby,
        this.phone,
        this.wopriority,
        this.supervisor,
        this.sopnum});

  OrderDetailData.fromJson(Map<String, dynamic> json) {
    wonum = json['wonum'];
    description = json['description'];
    location = json['location'];
    locationDescription = json['location_description'];
    assetnum = json['assetnum'];
    assetDescription = json['asset_description'];
    status = json['status'];
    worktype = json['worktype'];
    site = json['site'];
    reportdate = json['reportdate'];
    changedate = json['changedate'];
    targstartdate = json['targstartdate'];
    targcompdate = json['targcompdate'];
    actstart = json['actstart'];
    actfinish = json['actfinish'];
    lead = json['lead'];
    reportedby = json['reportedby'];
    phone = json['phone'];
    wopriority = json['wopriority'];
    supervisor = json['supervisor'];
    sopnum = json['sopnum'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['wonum'] = this.wonum;
    data['description'] = this.description;
    data['location'] = this.location;
    data['location_description'] = this.locationDescription;
    data['assetnum'] = this.assetnum;
    data['asset_description'] = this.assetDescription;
    data['status'] = this.status;
    data['worktype'] = this.worktype;
    data['site'] = this.site;
    data['reportdate'] = this.reportdate;
    data['changedate'] = this.changedate;
    data['targstartdate'] = this.targstartdate;
    data['targcompdate'] = this.targcompdate;
    data['actstart'] = this.actstart;
    data['actfinish'] = this.actfinish;
    data['lead'] = this.lead;
    data['reportedby'] = this.reportedby;
    data['phone'] = this.phone;
    data['wopriority'] = this.wopriority;
    data['supervisor'] = this.supervisor;
    data['sopnum'] = this.sopnum;
    return data;
  }
}
