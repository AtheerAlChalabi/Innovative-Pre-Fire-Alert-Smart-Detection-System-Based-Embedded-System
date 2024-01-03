class DataInfo {
  String? smk;
  String? gaz;
  String? amp;
  String? oTmp;
  String? iTmp;

  DataInfo({this.smk, this.gaz, this.amp, this.oTmp, this.iTmp});

  DataInfo.fromJson(Map<String, dynamic> json) {
    smk = json['Smk'];
    gaz = json['Gaz'];
    amp = json['Amp'];
    oTmp = json['oTmp'];
    iTmp = json['iTmp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Smk'] = this.smk;
    data['Gaz'] = this.gaz;
    data['Amp'] = this.amp;
    data['oTmp'] = this.oTmp;
    data['iTmp'] = this.iTmp;
    return data;
  }
}