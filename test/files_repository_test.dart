import 'package:otr_browser/model/otr_data.dart';
import 'package:test/test.dart';
import 'package:otr_browser/services/files_repository.dart';

main() {
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
            'otrkey',
            'otrkey_TVOON_DE.mpg.HQ.avi.otrkey',
            null,
            null,
            null,
          ));
      expect(
          otrDataList[1],
          OtrData(
            'otrkey_cutlist',
            'otrkey_cutlist_TVOON_DE.mpg.HQ.avi.otrkey',
            'otrkey_cutlist_TVOON_DE.mpg.HQ.avi.cutlist',
            null,
            null,
          ));
      expect(
          otrDataList[2],
          OtrData(
            'otrkey_cutlist_decoded',
            'otrkey_cutlist_decoded_TVOON_DE.mpg.HQ.avi.otrkey',
            'otrkey_cutlist_decoded_TVOON_DE.mpg.HQ.avi.cutlist',
            'otrkey_cutlist_decoded_TVOON_DE.mpg.HQ.avi',
            null,
          ));
      expect(
          otrDataList[3],
          OtrData(
            'otrkey_cutlist_decoded_cut',
            'otrkey_cutlist_decoded_cut_TVOON_DE.mpg.HQ.avi.otrkey',
            'otrkey_cutlist_decoded_cut_TVOON_DE.mpg.HQ.avi.cutlist',
            'otrkey_cutlist_decoded_cut_TVOON_DE.mpg.HQ.avi',
            'otrkey_cutlist_decoded_cut_TVOON_DE-cut.mpg.HQ.avi',
          ));
      expect(otrDataList[3].isExactCutlist, true, reason: 'isExactCutlist');
      expect(
          otrDataList[4],
          OtrData(
            'otrkey_not_exact_cutlist_decoded',
            null,
            'otrkey_not_exact_cutlist_decoded_TVOON_DE.mpg.HD.avi.cutlist',
            'otrkey_not_exact_cutlist_decoded_TVOON_DE.mpg.HQ.avi',
            null,
          ));
      expect(otrDataList[4].isExactCutlist, false,
          reason: 'is not ExactCutlist');   
    });
  });
}
