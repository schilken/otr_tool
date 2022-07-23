import 'package:dio/dio.dart';

import 'cutlist_item.dart';

class CutlistClient {

  Future<String> searchCutlists(String searchString) async {
    Dio dio = Dio();
    Map<String, String> headers = {
      "CONTENT_TYPE": 'application/json',
      "ACCEPT": 'application/json',
      "User-Agent": 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.3 Safari/605.1.15',
    };
    dio.options.baseUrl = 'http://cutlist.at';
    dio.options.headers = headers;
    Response response;
    String makePostData() {
      return '''
     {
      "conds":[
      {
        "query": "$searchString",
        "field": "name"
        }
        ],
        "isOrConnection":false,
        "sortBy": "date"
        ,"isAsc": false,
        "page":0
        }
     ''';
    } 

    response = await dio.post(
      '/api/search-by',
      data: makePostData(),
    );
    if(response.statusCode != 200) {
      return '';
    }
    print(response.data);
    final responseObject = CutlistResponse.fromJson(response.data);
    return response.data;
  }
}
