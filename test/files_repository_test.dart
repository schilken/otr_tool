import 'package:otr_tool/model/otr_data.dart';
import 'package:otr_tool/providers/files_repository.dart';
import 'package:test/test.dart';

void main() {
  final pathList = [
    'otrkey_TVOON_DE.mpg.HQ.avi.otrkey',
    'otrkey_cutlist_TVOON_DE.mpg.HQ.avi.otrkey',
    'otrkey_cutlist_TVOON_DE.mpg.HQ.avi.cutlist',
    'otrkey_cutlist_decoded_TVOON_DE.mpg.HQ.avi.otrkey',
    'otrkey_cutlist_decoded_TVOON_DE.mpg.HQ.avi.cutlist',
    'otrkey_cutlist_decoded_TVOON_DE.mpg.HQ.avi',
    'otrkey_cutlist_decoded_cut_TVOON_DE.mpg.HQ.avi.otrkey',
    'otrkey_cutlist_decoded_cut_TVOON_DE.mpg.HQ.avi.cutlist',
    'otrkey_cutlist_decoded_cut_TVOON_DE.mpg.HQ.avi',
    'otrkey_cutlist_decoded_cut_TVOON_DE-cut.mpg.HQ.avi',
    'otrkey_not_exact_cutlist_decoded_TVOON_DE.mpg.HQ.avi',
    'otrkey_not_exact_cutlist_decoded_TVOON_DE.mpg.HD.avi.cutlist',
  ];

  group('FilesRepository', () {
    test('test consolidateOtrFiles', () {
      final sut = FilesRepository();
      final otrDataList = sut.consolidateOtrFiles(pathList);
      expect(
          otrDataList[0],
          OtrData(
            name: 'otrkey',
            otrkeyBasename: 'otrkey_TVOON_DE.mpg.HQ.avi.otrkey',
            cutlistBasename: null,
            decodedBasename: null,
            cuttedBasename: null,
          ));
      expect(
          otrDataList[1],
          OtrData(
            name: 'otrkey_cutlist',
            otrkeyBasename: 'otrkey_cutlist_TVOON_DE.mpg.HQ.avi.otrkey',
            cutlistBasename: 'otrkey_cutlist_TVOON_DE.mpg.HQ.avi.cutlist',
            decodedBasename: null,
            cuttedBasename: null,
          ));
      expect(
          otrDataList[2],
          OtrData(
            name: 'otrkey_cutlist_decoded',
            otrkeyBasename: 'otrkey_cutlist_decoded_TVOON_DE.mpg.HQ.avi.otrkey',
            cutlistBasename:
                'otrkey_cutlist_decoded_TVOON_DE.mpg.HQ.avi.cutlist',
            decodedBasename: 'otrkey_cutlist_decoded_TVOON_DE.mpg.HQ.avi',
            cuttedBasename: null,
          ));
      expect(
          otrDataList[3],
          OtrData(
            name: 'otrkey_cutlist_decoded_cut',
            otrkeyBasename:
                'otrkey_cutlist_decoded_cut_TVOON_DE.mpg.HQ.avi.otrkey',
            cutlistBasename:
                'otrkey_cutlist_decoded_cut_TVOON_DE.mpg.HQ.avi.cutlist',
            decodedBasename: 'otrkey_cutlist_decoded_cut_TVOON_DE.mpg.HQ.avi',
            cuttedBasename:
                'otrkey_cutlist_decoded_cut_TVOON_DE-cut.mpg.HQ.avi',
          ));
      expect(otrDataList[3].isExactCutlist, true, reason: 'isExactCutlist');
      expect(
          otrDataList[4],
          OtrData(
            name: 'otrkey_not_exact_cutlist_decoded',
            otrkeyBasename: null,
            cutlistBasename:
                'otrkey_not_exact_cutlist_decoded_TVOON_DE.mpg.HD.avi.cutlist',
            decodedBasename:
                'otrkey_not_exact_cutlist_decoded_TVOON_DE.mpg.HQ.avi',
            cuttedBasename: null,
          ));
      expect(otrDataList[4].isExactCutlist, false,
          reason: 'is not ExactCutlist');
    });
  });
}
