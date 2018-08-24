class UpdateResult {
  int code;
  String message;
  UpdateData response;

  UpdateResult({this.code, this.message, this.response});

  UpdateResult.fromJson(Map<String, dynamic> json) {
    code = json['Code'];
    message = json['Message'];
    response = json['Response'] != null
        ? new UpdateData.fromJson(json['Response'])
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

class UpdateData {
  int versionCode;
  String url;
  String news;

  UpdateData({this.versionCode, this.url, this.news});

  UpdateData.fromJson(Map<String, dynamic> json) {
    versionCode = json['versionCode'];
    url = json['url'];
    news = json['news'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['versionCode'] = this.versionCode;
    data['url'] = this.url;
    return data;
  }
}