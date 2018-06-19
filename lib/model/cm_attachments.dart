class CMAttachmentsResult {
  int code;
  String message;
  List<String> response;

  CMAttachmentsResult({this.code, this.message, this.response});

  CMAttachmentsResult.fromJson(Map<String, dynamic> json) {
    code = json['Code'];
    message = json['Message'];

    List<dynamic> list = json['Response'];

    list?.forEach((f){
      if(response == null){
        response = new  List();
      }
      response.add(f.toString());
    });

    if(response == null){
      response = [];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Code'] = this.code;
    data['Message'] = this.message;
    data['Response'] = this.response;
    return data;
  }
}