import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class CutlistItem {
  int id;
  String name;
  String otrkey;
  String? comment;
  String channel;
  String? author;
  int hits;
  String quality;
  int cutCount;
  String duration;
  CutlistItem({
    required this.id,
    required this.name,
    required this.otrkey,
    required this.comment,
    required this.channel,
    required this.author,
    required this.hits,
    required this.quality,
    required this.cutCount,
    required this.duration,
  });

  factory CutlistItem.fromMap(Map<String, dynamic> map) {
    return CutlistItem(
      id: map['id'] as int,
      name: map['name'] as String,
      otrkey: map['otrkey'] as String,
      comment: map['comment'] as String?,
      channel: map['channel'] as String,
      author: map['author'] as String?,
      hits: map['hits'] as int,
      quality: map['quality'] as String,
      cutCount: map['cutCount'] as int,
      duration: map['duration'] as String,
    );
  }

  factory CutlistItem.fromJson(String source) =>
      CutlistItem.fromMap(json.decode(source) as Map<String, dynamic>);
}

class CutlistResponse {
  List<CutlistItem> items;
  bool hasMore;
  int currentPage;
  CutlistResponse({
    required this.items,
    required this.hasMore,
    required this.currentPage,
  });

  factory CutlistResponse.fromMap(Map<String, dynamic> map) {
    return CutlistResponse(
      items: List<CutlistItem>.from(
        (map['items'] as List).map<CutlistItem>(
          (x) => CutlistItem.fromMap(x as Map<String, dynamic>),
        ),
      ),
      hasMore: map['hasMore'] as bool,
      currentPage: map['currentPage'] as int,
    );
  }

  factory CutlistResponse.fromJson(String source) =>
      CutlistResponse.fromMap(json.decode(source) as Map<String, dynamic>);

  static String testResponse = '''
{"items":[{"id":1619110,"name":"Ocean s 13","airDate":"2010-12-30T20:15:00+01:00","uploadDate":"2010-12-31T16:08:22+01:00","otrkey":"Ocean_s_13_10.12.30_20-15_sat1_140_TVOON_DE.mpg.HQ.avi","comment":"Mit Vor-, ohne Abspann, mit ColdCut framegenau geschnitten, 16:9AR","suggestedName":"Ocean's 13","channel":"Sat1","author":"MenneSi","rating":{"avg":"4.95","avgRounded":5,"ratings":44,"fillPercent":100,"author":5},"registeredDownloads":"0","hits":1051,"duration":"01:51:47","quality":"hq","cutCount":4,"errors":{"start":false,"end":false,"video":false,"audio":false,"other":false,"epg":false,"epgDesc":null,"otherDesc":null},"_my":{"canRate":true}},{"id":1596139,"name":"Ocean s 13","airDate":"2010-12-30T20:15:00+01:00","uploadDate":"2010-12-31T10:45:06+01:00","otrkey":"Ocean_s_13_10.12.30_20-15_sat1_140_TVOON_DE.mpg.avi","comment":"Mit ColdCut geschnittenMit Vorspann, keine doppelte Szenen enthalten, Werbung entfernt,  kein Abspann, framegenau, mit CC gepr\u00fcft","suggestedName":"Ocean_s_13_10.12.30_20-15_sat1_140_","channel":"Sat1","author":"gaebby","rating":{"avg":"4.88","avgRounded":5,"ratings":41,"fillPercent":100,"author":5},"registeredDownloads":"0","hits":823,"duration":"01:51:46","quality":"avi","cutCount":4,"errors":{"start":false,"end":false,"video":false,"audio":false,"other":false,"epg":false,"epgDesc":null,"otherDesc":null},"_my":{"canRate":true}},{"id":1618865,"name":"Ocean s 13","airDate":"2010-12-30T20:15:00+01:00","uploadDate":"2010-12-31T07:42:03+01:00","otrkey":"Ocean_s_13_10.12.30_20-15_sat1_140_TVOON_DE.mpg.avi","comment":null,"suggestedName":null,"channel":"Sat1","author":null,"rating":{"avg":"0.00","avgRounded":0,"ratings":0,"fillPercent":0,"author":4},"registeredDownloads":"0","hits":29,"duration":"01:51:46","quality":"avi","cutCount":4,"errors":{"start":false,"end":false,"video":false,"audio":false,"other":false,"epg":false,"epgDesc":null,"otherDesc":null},"_my":{"canRate":true}}],"hasMore":false,"currentPage":0}
''';
}
