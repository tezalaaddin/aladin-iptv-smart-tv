import 'package:isar_community/isar.dart';

part 'aladin_epg_model.g.dart';

@collection
class EpgProgramModel {
  Id id = Isar.autoIncrement;

  @Index()
  late String channelId;

  @Index()
  late String normalizedChannelId;

  late String title;
  String? description;
  String? category;
  String? icon;

  late DateTime startTime;
  late DateTime endTime;

  @Index()
  int? syncSession;

  bool get isNow {
    final now = DateTime.now();
    return now.isAfter(startTime) && now.isBefore(endTime);
  }

  int get durationMinutes => endTime.difference(startTime).inMinutes;
}
