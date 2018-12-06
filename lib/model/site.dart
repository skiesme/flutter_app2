class SiteResult {
  int code;
  String message;
  List<Site> response;

  SiteResult({this.code, this.message, this.response});

  SiteResult.fromJson(Map<String, dynamic> json) {
    code = json['Code'];
    message = json['Message'];

    if (json['Response'] != null) {
      response = new List<Site>();
      json['Response'].forEach((v) {
        response.add(new Site.fromJson(v));
      });
    } else {
      response = null;
    }
  }
}

class Site {
  String siteid;
  String description;

  Site(
      {this.siteid,
        this.description,});

  Site.fromJson(Map<String, dynamic> json) {
    siteid = json['siteid'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['siteid'] = this.siteid;
    data['description'] = this.description;
    return data;
  }
}