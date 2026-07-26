// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'aladin_channel_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetChannelModelCollection on Isar {
  IsarCollection<ChannelModel> get channelModels => this.collection();
}

const ChannelModelSchema = CollectionSchema(
  name: r'ChannelModel',
  id: -3737772631768065944,
  properties: {
    r'catchupDays': PropertySchema(
      id: 0,
      name: r'catchupDays',
      type: IsarType.long,
    ),
    r'catchupType': PropertySchema(
      id: 1,
      name: r'catchupType',
      type: IsarType.string,
    ),
    r'categoryName': PropertySchema(
      id: 2,
      name: r'categoryName',
      type: IsarType.string,
    ),
    r'contentType': PropertySchema(
      id: 3,
      name: r'contentType',
      type: IsarType.string,
    ),
    r'country': PropertySchema(
      id: 4,
      name: r'country',
      type: IsarType.string,
    ),
    r'epgLogoUrl': PropertySchema(
      id: 5,
      name: r'epgLogoUrl',
      type: IsarType.string,
    ),
    r'episode': PropertySchema(
      id: 6,
      name: r'episode',
      type: IsarType.long,
    ),
    r'episodesFetchedAt': PropertySchema(
      id: 7,
      name: r'episodesFetchedAt',
      type: IsarType.dateTime,
    ),
    r'groupTitle': PropertySchema(
      id: 8,
      name: r'groupTitle',
      type: IsarType.string,
    ),
    r'imdbRating': PropertySchema(
      id: 9,
      name: r'imdbRating',
      type: IsarType.string,
    ),
    r'isFavorite': PropertySchema(
      id: 10,
      name: r'isFavorite',
      type: IsarType.bool,
    ),
    r'language': PropertySchema(
      id: 11,
      name: r'language',
      type: IsarType.string,
    ),
    r'lastWatched': PropertySchema(
      id: 12,
      name: r'lastWatched',
      type: IsarType.dateTime,
    ),
    r'logoUrl': PropertySchema(
      id: 13,
      name: r'logoUrl',
      type: IsarType.string,
    ),
    r'name': PropertySchema(
      id: 14,
      name: r'name',
      type: IsarType.string,
    ),
    r'parentSeriesId': PropertySchema(
      id: 15,
      name: r'parentSeriesId',
      type: IsarType.string,
    ),
    r'playlistId': PropertySchema(
      id: 16,
      name: r'playlistId',
      type: IsarType.long,
    ),
    r'quality': PropertySchema(
      id: 17,
      name: r'quality',
      type: IsarType.string,
    ),
    r'season': PropertySchema(
      id: 18,
      name: r'season',
      type: IsarType.long,
    ),
    r'seriesName': PropertySchema(
      id: 19,
      name: r'seriesName',
      type: IsarType.string,
    ),
    r'shouldRefetchEpisodes': PropertySchema(
      id: 20,
      name: r'shouldRefetchEpisodes',
      type: IsarType.bool,
    ),
    r'sortOrder': PropertySchema(
      id: 21,
      name: r'sortOrder',
      type: IsarType.long,
    ),
    r'streamHeaders': PropertySchema(
      id: 22,
      name: r'streamHeaders',
      type: IsarType.string,
    ),
    r'streamPlatform': PropertySchema(
      id: 23,
      name: r'streamPlatform',
      type: IsarType.string,
    ),
    r'tmdbId': PropertySchema(
      id: 24,
      name: r'tmdbId',
      type: IsarType.string,
    ),
    r'tmdbOverview': PropertySchema(
      id: 25,
      name: r'tmdbOverview',
      type: IsarType.string,
    ),
    r'tmdbPoster': PropertySchema(
      id: 26,
      name: r'tmdbPoster',
      type: IsarType.string,
    ),
    r'tmdbYear': PropertySchema(
      id: 27,
      name: r'tmdbYear',
      type: IsarType.string,
    ),
    r'totalDurationSeconds': PropertySchema(
      id: 28,
      name: r'totalDurationSeconds',
      type: IsarType.long,
    ),
    r'tvgId': PropertySchema(
      id: 29,
      name: r'tvgId',
      type: IsarType.string,
    ),
    r'tvgName': PropertySchema(
      id: 30,
      name: r'tvgName',
      type: IsarType.string,
    ),
    r'url': PropertySchema(
      id: 31,
      name: r'url',
      type: IsarType.string,
    ),
    r'watchedSeconds': PropertySchema(
      id: 32,
      name: r'watchedSeconds',
      type: IsarType.long,
    )
  },
  estimateSize: _channelModelEstimateSize,
  serialize: _channelModelSerialize,
  deserialize: _channelModelDeserialize,
  deserializeProp: _channelModelDeserializeProp,
  idName: r'id',
  indexes: {
    r'playlistId': IndexSchema(
      id: 7921918076105486368,
      name: r'playlistId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'playlistId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'categoryName': IndexSchema(
      id: -7528967714848594133,
      name: r'categoryName',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'categoryName',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'contentType': IndexSchema(
      id: -4813096802902836239,
      name: r'contentType',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'contentType',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'seriesName': IndexSchema(
      id: 6569645326461766773,
      name: r'seriesName',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'seriesName',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'sortOrder': IndexSchema(
      id: -1119549396205841918,
      name: r'sortOrder',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'sortOrder',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'isFavorite': IndexSchema(
      id: 5742774614603939776,
      name: r'isFavorite',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'isFavorite',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'lastWatched': IndexSchema(
      id: -3939082614237404951,
      name: r'lastWatched',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'lastWatched',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _channelModelGetId,
  getLinks: _channelModelGetLinks,
  attach: _channelModelAttach,
  version: '3.3.2',
);

int _channelModelEstimateSize(
  ChannelModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.catchupType;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.categoryName.length * 3;
  bytesCount += 3 + object.contentType.length * 3;
  {
    final value = object.country;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.epgLogoUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.groupTitle;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.imdbRating;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.language;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.logoUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.name.length * 3;
  {
    final value = object.parentSeriesId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.quality;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.seriesName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.streamHeaders;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.streamPlatform;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.tmdbId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.tmdbOverview;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.tmdbPoster;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.tmdbYear;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.tvgId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.tvgName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.url.length * 3;
  return bytesCount;
}

void _channelModelSerialize(
  ChannelModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.catchupDays);
  writer.writeString(offsets[1], object.catchupType);
  writer.writeString(offsets[2], object.categoryName);
  writer.writeString(offsets[3], object.contentType);
  writer.writeString(offsets[4], object.country);
  writer.writeString(offsets[5], object.epgLogoUrl);
  writer.writeLong(offsets[6], object.episode);
  writer.writeDateTime(offsets[7], object.episodesFetchedAt);
  writer.writeString(offsets[8], object.groupTitle);
  writer.writeString(offsets[9], object.imdbRating);
  writer.writeBool(offsets[10], object.isFavorite);
  writer.writeString(offsets[11], object.language);
  writer.writeDateTime(offsets[12], object.lastWatched);
  writer.writeString(offsets[13], object.logoUrl);
  writer.writeString(offsets[14], object.name);
  writer.writeString(offsets[15], object.parentSeriesId);
  writer.writeLong(offsets[16], object.playlistId);
  writer.writeString(offsets[17], object.quality);
  writer.writeLong(offsets[18], object.season);
  writer.writeString(offsets[19], object.seriesName);
  writer.writeBool(offsets[20], object.shouldRefetchEpisodes);
  writer.writeLong(offsets[21], object.sortOrder);
  writer.writeString(offsets[22], object.streamHeaders);
  writer.writeString(offsets[23], object.streamPlatform);
  writer.writeString(offsets[24], object.tmdbId);
  writer.writeString(offsets[25], object.tmdbOverview);
  writer.writeString(offsets[26], object.tmdbPoster);
  writer.writeString(offsets[27], object.tmdbYear);
  writer.writeLong(offsets[28], object.totalDurationSeconds);
  writer.writeString(offsets[29], object.tvgId);
  writer.writeString(offsets[30], object.tvgName);
  writer.writeString(offsets[31], object.url);
  writer.writeLong(offsets[32], object.watchedSeconds);
}

ChannelModel _channelModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ChannelModel();
  object.catchupDays = reader.readLongOrNull(offsets[0]);
  object.catchupType = reader.readStringOrNull(offsets[1]);
  object.categoryName = reader.readString(offsets[2]);
  object.contentType = reader.readString(offsets[3]);
  object.country = reader.readStringOrNull(offsets[4]);
  object.epgLogoUrl = reader.readStringOrNull(offsets[5]);
  object.episode = reader.readLongOrNull(offsets[6]);
  object.episodesFetchedAt = reader.readDateTimeOrNull(offsets[7]);
  object.groupTitle = reader.readStringOrNull(offsets[8]);
  object.id = id;
  object.imdbRating = reader.readStringOrNull(offsets[9]);
  object.isFavorite = reader.readBool(offsets[10]);
  object.language = reader.readStringOrNull(offsets[11]);
  object.lastWatched = reader.readDateTimeOrNull(offsets[12]);
  object.logoUrl = reader.readStringOrNull(offsets[13]);
  object.name = reader.readString(offsets[14]);
  object.parentSeriesId = reader.readStringOrNull(offsets[15]);
  object.playlistId = reader.readLong(offsets[16]);
  object.quality = reader.readStringOrNull(offsets[17]);
  object.season = reader.readLongOrNull(offsets[18]);
  object.seriesName = reader.readStringOrNull(offsets[19]);
  object.sortOrder = reader.readLong(offsets[21]);
  object.streamHeaders = reader.readStringOrNull(offsets[22]);
  object.streamPlatform = reader.readStringOrNull(offsets[23]);
  object.tmdbId = reader.readStringOrNull(offsets[24]);
  object.tmdbOverview = reader.readStringOrNull(offsets[25]);
  object.tmdbPoster = reader.readStringOrNull(offsets[26]);
  object.tmdbYear = reader.readStringOrNull(offsets[27]);
  object.totalDurationSeconds = reader.readLong(offsets[28]);
  object.tvgId = reader.readStringOrNull(offsets[29]);
  object.tvgName = reader.readStringOrNull(offsets[30]);
  object.url = reader.readString(offsets[31]);
  object.watchedSeconds = reader.readLong(offsets[32]);
  return object;
}

P _channelModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLongOrNull(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readLongOrNull(offset)) as P;
    case 7:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    case 10:
      return (reader.readBool(offset)) as P;
    case 11:
      return (reader.readStringOrNull(offset)) as P;
    case 12:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 13:
      return (reader.readStringOrNull(offset)) as P;
    case 14:
      return (reader.readString(offset)) as P;
    case 15:
      return (reader.readStringOrNull(offset)) as P;
    case 16:
      return (reader.readLong(offset)) as P;
    case 17:
      return (reader.readStringOrNull(offset)) as P;
    case 18:
      return (reader.readLongOrNull(offset)) as P;
    case 19:
      return (reader.readStringOrNull(offset)) as P;
    case 20:
      return (reader.readBool(offset)) as P;
    case 21:
      return (reader.readLong(offset)) as P;
    case 22:
      return (reader.readStringOrNull(offset)) as P;
    case 23:
      return (reader.readStringOrNull(offset)) as P;
    case 24:
      return (reader.readStringOrNull(offset)) as P;
    case 25:
      return (reader.readStringOrNull(offset)) as P;
    case 26:
      return (reader.readStringOrNull(offset)) as P;
    case 27:
      return (reader.readStringOrNull(offset)) as P;
    case 28:
      return (reader.readLong(offset)) as P;
    case 29:
      return (reader.readStringOrNull(offset)) as P;
    case 30:
      return (reader.readStringOrNull(offset)) as P;
    case 31:
      return (reader.readString(offset)) as P;
    case 32:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _channelModelGetId(ChannelModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _channelModelGetLinks(ChannelModel object) {
  return [];
}

void _channelModelAttach(
    IsarCollection<dynamic> col, Id id, ChannelModel object) {
  object.id = id;
}

extension ChannelModelQueryWhereSort
    on QueryBuilder<ChannelModel, ChannelModel, QWhere> {
  QueryBuilder<ChannelModel, ChannelModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterWhere> anyPlaylistId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'playlistId'),
      );
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterWhere> anySortOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'sortOrder'),
      );
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterWhere> anyIsFavorite() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'isFavorite'),
      );
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterWhere> anyLastWatched() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'lastWatched'),
      );
    });
  }
}

extension ChannelModelQueryWhere
    on QueryBuilder<ChannelModel, ChannelModel, QWhereClause> {
  QueryBuilder<ChannelModel, ChannelModel, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterWhereClause> idNotEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterWhereClause> playlistIdEqualTo(
      int playlistId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'playlistId',
        value: [playlistId],
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterWhereClause>
      playlistIdNotEqualTo(int playlistId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'playlistId',
              lower: [],
              upper: [playlistId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'playlistId',
              lower: [playlistId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'playlistId',
              lower: [playlistId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'playlistId',
              lower: [],
              upper: [playlistId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterWhereClause>
      playlistIdGreaterThan(
    int playlistId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'playlistId',
        lower: [playlistId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterWhereClause>
      playlistIdLessThan(
    int playlistId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'playlistId',
        lower: [],
        upper: [playlistId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterWhereClause> playlistIdBetween(
    int lowerPlaylistId,
    int upperPlaylistId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'playlistId',
        lower: [lowerPlaylistId],
        includeLower: includeLower,
        upper: [upperPlaylistId],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterWhereClause>
      categoryNameEqualTo(String categoryName) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'categoryName',
        value: [categoryName],
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterWhereClause>
      categoryNameNotEqualTo(String categoryName) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'categoryName',
              lower: [],
              upper: [categoryName],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'categoryName',
              lower: [categoryName],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'categoryName',
              lower: [categoryName],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'categoryName',
              lower: [],
              upper: [categoryName],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterWhereClause>
      contentTypeEqualTo(String contentType) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'contentType',
        value: [contentType],
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterWhereClause>
      contentTypeNotEqualTo(String contentType) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'contentType',
              lower: [],
              upper: [contentType],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'contentType',
              lower: [contentType],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'contentType',
              lower: [contentType],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'contentType',
              lower: [],
              upper: [contentType],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterWhereClause>
      seriesNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'seriesName',
        value: [null],
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterWhereClause>
      seriesNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'seriesName',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterWhereClause> seriesNameEqualTo(
      String? seriesName) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'seriesName',
        value: [seriesName],
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterWhereClause>
      seriesNameNotEqualTo(String? seriesName) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'seriesName',
              lower: [],
              upper: [seriesName],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'seriesName',
              lower: [seriesName],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'seriesName',
              lower: [seriesName],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'seriesName',
              lower: [],
              upper: [seriesName],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterWhereClause> sortOrderEqualTo(
      int sortOrder) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'sortOrder',
        value: [sortOrder],
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterWhereClause>
      sortOrderNotEqualTo(int sortOrder) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sortOrder',
              lower: [],
              upper: [sortOrder],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sortOrder',
              lower: [sortOrder],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sortOrder',
              lower: [sortOrder],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sortOrder',
              lower: [],
              upper: [sortOrder],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterWhereClause>
      sortOrderGreaterThan(
    int sortOrder, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'sortOrder',
        lower: [sortOrder],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterWhereClause> sortOrderLessThan(
    int sortOrder, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'sortOrder',
        lower: [],
        upper: [sortOrder],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterWhereClause> sortOrderBetween(
    int lowerSortOrder,
    int upperSortOrder, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'sortOrder',
        lower: [lowerSortOrder],
        includeLower: includeLower,
        upper: [upperSortOrder],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterWhereClause> isFavoriteEqualTo(
      bool isFavorite) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'isFavorite',
        value: [isFavorite],
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterWhereClause>
      isFavoriteNotEqualTo(bool isFavorite) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isFavorite',
              lower: [],
              upper: [isFavorite],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isFavorite',
              lower: [isFavorite],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isFavorite',
              lower: [isFavorite],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isFavorite',
              lower: [],
              upper: [isFavorite],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterWhereClause>
      lastWatchedIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'lastWatched',
        value: [null],
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterWhereClause>
      lastWatchedIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'lastWatched',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterWhereClause>
      lastWatchedEqualTo(DateTime? lastWatched) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'lastWatched',
        value: [lastWatched],
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterWhereClause>
      lastWatchedNotEqualTo(DateTime? lastWatched) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'lastWatched',
              lower: [],
              upper: [lastWatched],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'lastWatched',
              lower: [lastWatched],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'lastWatched',
              lower: [lastWatched],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'lastWatched',
              lower: [],
              upper: [lastWatched],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterWhereClause>
      lastWatchedGreaterThan(
    DateTime? lastWatched, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'lastWatched',
        lower: [lastWatched],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterWhereClause>
      lastWatchedLessThan(
    DateTime? lastWatched, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'lastWatched',
        lower: [],
        upper: [lastWatched],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterWhereClause>
      lastWatchedBetween(
    DateTime? lowerLastWatched,
    DateTime? upperLastWatched, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'lastWatched',
        lower: [lowerLastWatched],
        includeLower: includeLower,
        upper: [upperLastWatched],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ChannelModelQueryFilter
    on QueryBuilder<ChannelModel, ChannelModel, QFilterCondition> {
  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      catchupDaysIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'catchupDays',
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      catchupDaysIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'catchupDays',
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      catchupDaysEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'catchupDays',
        value: value,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      catchupDaysGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'catchupDays',
        value: value,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      catchupDaysLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'catchupDays',
        value: value,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      catchupDaysBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'catchupDays',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      catchupTypeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'catchupType',
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      catchupTypeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'catchupType',
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      catchupTypeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'catchupType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      catchupTypeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'catchupType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      catchupTypeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'catchupType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      catchupTypeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'catchupType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      catchupTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'catchupType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      catchupTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'catchupType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      catchupTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'catchupType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      catchupTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'catchupType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      catchupTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'catchupType',
        value: '',
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      catchupTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'catchupType',
        value: '',
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      categoryNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'categoryName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      categoryNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'categoryName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      categoryNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'categoryName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      categoryNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'categoryName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      categoryNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'categoryName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      categoryNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'categoryName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      categoryNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'categoryName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      categoryNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'categoryName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      categoryNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'categoryName',
        value: '',
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      categoryNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'categoryName',
        value: '',
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      contentTypeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'contentType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      contentTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'contentType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      contentTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'contentType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      contentTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'contentType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      contentTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'contentType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      contentTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'contentType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      contentTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'contentType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      contentTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'contentType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      contentTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'contentType',
        value: '',
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      contentTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'contentType',
        value: '',
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      countryIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'country',
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      countryIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'country',
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      countryEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'country',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      countryGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'country',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      countryLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'country',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      countryBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'country',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      countryStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'country',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      countryEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'country',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      countryContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'country',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      countryMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'country',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      countryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'country',
        value: '',
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      countryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'country',
        value: '',
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      epgLogoUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'epgLogoUrl',
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      epgLogoUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'epgLogoUrl',
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      epgLogoUrlEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'epgLogoUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      epgLogoUrlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'epgLogoUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      epgLogoUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'epgLogoUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      epgLogoUrlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'epgLogoUrl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      epgLogoUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'epgLogoUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      epgLogoUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'epgLogoUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      epgLogoUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'epgLogoUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      epgLogoUrlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'epgLogoUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      epgLogoUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'epgLogoUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      epgLogoUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'epgLogoUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      episodeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'episode',
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      episodeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'episode',
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      episodeEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'episode',
        value: value,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      episodeGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'episode',
        value: value,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      episodeLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'episode',
        value: value,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      episodeBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'episode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      episodesFetchedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'episodesFetchedAt',
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      episodesFetchedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'episodesFetchedAt',
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      episodesFetchedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'episodesFetchedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      episodesFetchedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'episodesFetchedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      episodesFetchedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'episodesFetchedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      episodesFetchedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'episodesFetchedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      groupTitleIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'groupTitle',
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      groupTitleIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'groupTitle',
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      groupTitleEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'groupTitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      groupTitleGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'groupTitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      groupTitleLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'groupTitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      groupTitleBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'groupTitle',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      groupTitleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'groupTitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      groupTitleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'groupTitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      groupTitleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'groupTitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      groupTitleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'groupTitle',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      groupTitleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'groupTitle',
        value: '',
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      groupTitleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'groupTitle',
        value: '',
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      imdbRatingIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'imdbRating',
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      imdbRatingIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'imdbRating',
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      imdbRatingEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'imdbRating',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      imdbRatingGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'imdbRating',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      imdbRatingLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'imdbRating',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      imdbRatingBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'imdbRating',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      imdbRatingStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'imdbRating',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      imdbRatingEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'imdbRating',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      imdbRatingContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'imdbRating',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      imdbRatingMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'imdbRating',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      imdbRatingIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'imdbRating',
        value: '',
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      imdbRatingIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'imdbRating',
        value: '',
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      isFavoriteEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isFavorite',
        value: value,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      languageIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'language',
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      languageIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'language',
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      languageEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'language',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      languageGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'language',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      languageLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'language',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      languageBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'language',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      languageStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'language',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      languageEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'language',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      languageContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'language',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      languageMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'language',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      languageIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'language',
        value: '',
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      languageIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'language',
        value: '',
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      lastWatchedIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastWatched',
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      lastWatchedIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastWatched',
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      lastWatchedEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastWatched',
        value: value,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      lastWatchedGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastWatched',
        value: value,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      lastWatchedLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastWatched',
        value: value,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      lastWatchedBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastWatched',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      logoUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'logoUrl',
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      logoUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'logoUrl',
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      logoUrlEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'logoUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      logoUrlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'logoUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      logoUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'logoUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      logoUrlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'logoUrl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      logoUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'logoUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      logoUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'logoUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      logoUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'logoUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      logoUrlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'logoUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      logoUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'logoUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      logoUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'logoUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition> nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition> nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition> nameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition> nameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      parentSeriesIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'parentSeriesId',
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      parentSeriesIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'parentSeriesId',
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      parentSeriesIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'parentSeriesId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      parentSeriesIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'parentSeriesId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      parentSeriesIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'parentSeriesId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      parentSeriesIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'parentSeriesId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      parentSeriesIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'parentSeriesId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      parentSeriesIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'parentSeriesId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      parentSeriesIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'parentSeriesId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      parentSeriesIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'parentSeriesId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      parentSeriesIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'parentSeriesId',
        value: '',
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      parentSeriesIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'parentSeriesId',
        value: '',
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      playlistIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'playlistId',
        value: value,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      playlistIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'playlistId',
        value: value,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      playlistIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'playlistId',
        value: value,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      playlistIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'playlistId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      qualityIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'quality',
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      qualityIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'quality',
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      qualityEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'quality',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      qualityGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'quality',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      qualityLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'quality',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      qualityBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'quality',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      qualityStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'quality',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      qualityEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'quality',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      qualityContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'quality',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      qualityMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'quality',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      qualityIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'quality',
        value: '',
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      qualityIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'quality',
        value: '',
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      seasonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'season',
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      seasonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'season',
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition> seasonEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'season',
        value: value,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      seasonGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'season',
        value: value,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      seasonLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'season',
        value: value,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition> seasonBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'season',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      seriesNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'seriesName',
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      seriesNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'seriesName',
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      seriesNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'seriesName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      seriesNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'seriesName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      seriesNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'seriesName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      seriesNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'seriesName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      seriesNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'seriesName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      seriesNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'seriesName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      seriesNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'seriesName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      seriesNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'seriesName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      seriesNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'seriesName',
        value: '',
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      seriesNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'seriesName',
        value: '',
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      shouldRefetchEpisodesEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'shouldRefetchEpisodes',
        value: value,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      sortOrderEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sortOrder',
        value: value,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      sortOrderGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sortOrder',
        value: value,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      sortOrderLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sortOrder',
        value: value,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      sortOrderBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sortOrder',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      streamHeadersIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'streamHeaders',
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      streamHeadersIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'streamHeaders',
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      streamHeadersEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'streamHeaders',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      streamHeadersGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'streamHeaders',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      streamHeadersLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'streamHeaders',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      streamHeadersBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'streamHeaders',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      streamHeadersStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'streamHeaders',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      streamHeadersEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'streamHeaders',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      streamHeadersContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'streamHeaders',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      streamHeadersMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'streamHeaders',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      streamHeadersIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'streamHeaders',
        value: '',
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      streamHeadersIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'streamHeaders',
        value: '',
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      streamPlatformIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'streamPlatform',
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      streamPlatformIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'streamPlatform',
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      streamPlatformEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'streamPlatform',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      streamPlatformGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'streamPlatform',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      streamPlatformLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'streamPlatform',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      streamPlatformBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'streamPlatform',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      streamPlatformStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'streamPlatform',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      streamPlatformEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'streamPlatform',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      streamPlatformContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'streamPlatform',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      streamPlatformMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'streamPlatform',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      streamPlatformIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'streamPlatform',
        value: '',
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      streamPlatformIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'streamPlatform',
        value: '',
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      tmdbIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'tmdbId',
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      tmdbIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'tmdbId',
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition> tmdbIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tmdbId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      tmdbIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tmdbId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      tmdbIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tmdbId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition> tmdbIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tmdbId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      tmdbIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'tmdbId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      tmdbIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'tmdbId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      tmdbIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'tmdbId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition> tmdbIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'tmdbId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      tmdbIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tmdbId',
        value: '',
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      tmdbIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'tmdbId',
        value: '',
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      tmdbOverviewIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'tmdbOverview',
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      tmdbOverviewIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'tmdbOverview',
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      tmdbOverviewEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tmdbOverview',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      tmdbOverviewGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tmdbOverview',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      tmdbOverviewLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tmdbOverview',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      tmdbOverviewBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tmdbOverview',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      tmdbOverviewStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'tmdbOverview',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      tmdbOverviewEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'tmdbOverview',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      tmdbOverviewContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'tmdbOverview',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      tmdbOverviewMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'tmdbOverview',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      tmdbOverviewIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tmdbOverview',
        value: '',
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      tmdbOverviewIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'tmdbOverview',
        value: '',
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      tmdbPosterIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'tmdbPoster',
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      tmdbPosterIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'tmdbPoster',
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      tmdbPosterEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tmdbPoster',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      tmdbPosterGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tmdbPoster',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      tmdbPosterLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tmdbPoster',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      tmdbPosterBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tmdbPoster',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      tmdbPosterStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'tmdbPoster',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      tmdbPosterEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'tmdbPoster',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      tmdbPosterContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'tmdbPoster',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      tmdbPosterMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'tmdbPoster',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      tmdbPosterIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tmdbPoster',
        value: '',
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      tmdbPosterIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'tmdbPoster',
        value: '',
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      tmdbYearIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'tmdbYear',
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      tmdbYearIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'tmdbYear',
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      tmdbYearEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tmdbYear',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      tmdbYearGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tmdbYear',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      tmdbYearLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tmdbYear',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      tmdbYearBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tmdbYear',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      tmdbYearStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'tmdbYear',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      tmdbYearEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'tmdbYear',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      tmdbYearContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'tmdbYear',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      tmdbYearMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'tmdbYear',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      tmdbYearIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tmdbYear',
        value: '',
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      tmdbYearIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'tmdbYear',
        value: '',
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      totalDurationSecondsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalDurationSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      totalDurationSecondsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalDurationSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      totalDurationSecondsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalDurationSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      totalDurationSecondsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalDurationSeconds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      tvgIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'tvgId',
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      tvgIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'tvgId',
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition> tvgIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tvgId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      tvgIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tvgId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition> tvgIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tvgId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition> tvgIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tvgId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      tvgIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'tvgId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition> tvgIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'tvgId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition> tvgIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'tvgId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition> tvgIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'tvgId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      tvgIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tvgId',
        value: '',
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      tvgIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'tvgId',
        value: '',
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      tvgNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'tvgName',
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      tvgNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'tvgName',
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      tvgNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tvgName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      tvgNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tvgName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      tvgNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tvgName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      tvgNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tvgName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      tvgNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'tvgName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      tvgNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'tvgName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      tvgNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'tvgName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      tvgNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'tvgName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      tvgNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tvgName',
        value: '',
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      tvgNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'tvgName',
        value: '',
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition> urlEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'url',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      urlGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'url',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition> urlLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'url',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition> urlBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'url',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition> urlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'url',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition> urlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'url',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition> urlContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'url',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition> urlMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'url',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition> urlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'url',
        value: '',
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      urlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'url',
        value: '',
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      watchedSecondsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'watchedSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      watchedSecondsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'watchedSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      watchedSecondsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'watchedSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterFilterCondition>
      watchedSecondsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'watchedSeconds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ChannelModelQueryObject
    on QueryBuilder<ChannelModel, ChannelModel, QFilterCondition> {}

extension ChannelModelQueryLinks
    on QueryBuilder<ChannelModel, ChannelModel, QFilterCondition> {}

extension ChannelModelQuerySortBy
    on QueryBuilder<ChannelModel, ChannelModel, QSortBy> {
  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy> sortByCatchupDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'catchupDays', Sort.asc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy>
      sortByCatchupDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'catchupDays', Sort.desc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy> sortByCatchupType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'catchupType', Sort.asc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy>
      sortByCatchupTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'catchupType', Sort.desc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy> sortByCategoryName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryName', Sort.asc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy>
      sortByCategoryNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryName', Sort.desc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy> sortByContentType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contentType', Sort.asc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy>
      sortByContentTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contentType', Sort.desc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy> sortByCountry() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'country', Sort.asc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy> sortByCountryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'country', Sort.desc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy> sortByEpgLogoUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'epgLogoUrl', Sort.asc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy>
      sortByEpgLogoUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'epgLogoUrl', Sort.desc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy> sortByEpisode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episode', Sort.asc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy> sortByEpisodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episode', Sort.desc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy>
      sortByEpisodesFetchedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodesFetchedAt', Sort.asc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy>
      sortByEpisodesFetchedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodesFetchedAt', Sort.desc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy> sortByGroupTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'groupTitle', Sort.asc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy>
      sortByGroupTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'groupTitle', Sort.desc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy> sortByImdbRating() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imdbRating', Sort.asc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy>
      sortByImdbRatingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imdbRating', Sort.desc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy> sortByIsFavorite() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFavorite', Sort.asc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy>
      sortByIsFavoriteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFavorite', Sort.desc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy> sortByLanguage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'language', Sort.asc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy> sortByLanguageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'language', Sort.desc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy> sortByLastWatched() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastWatched', Sort.asc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy>
      sortByLastWatchedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastWatched', Sort.desc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy> sortByLogoUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'logoUrl', Sort.asc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy> sortByLogoUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'logoUrl', Sort.desc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy>
      sortByParentSeriesId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentSeriesId', Sort.asc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy>
      sortByParentSeriesIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentSeriesId', Sort.desc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy> sortByPlaylistId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playlistId', Sort.asc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy>
      sortByPlaylistIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playlistId', Sort.desc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy> sortByQuality() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quality', Sort.asc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy> sortByQualityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quality', Sort.desc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy> sortBySeason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'season', Sort.asc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy> sortBySeasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'season', Sort.desc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy> sortBySeriesName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seriesName', Sort.asc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy>
      sortBySeriesNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seriesName', Sort.desc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy>
      sortByShouldRefetchEpisodes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shouldRefetchEpisodes', Sort.asc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy>
      sortByShouldRefetchEpisodesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shouldRefetchEpisodes', Sort.desc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy> sortBySortOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOrder', Sort.asc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy> sortBySortOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOrder', Sort.desc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy> sortByStreamHeaders() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streamHeaders', Sort.asc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy>
      sortByStreamHeadersDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streamHeaders', Sort.desc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy>
      sortByStreamPlatform() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streamPlatform', Sort.asc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy>
      sortByStreamPlatformDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streamPlatform', Sort.desc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy> sortByTmdbId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tmdbId', Sort.asc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy> sortByTmdbIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tmdbId', Sort.desc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy> sortByTmdbOverview() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tmdbOverview', Sort.asc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy>
      sortByTmdbOverviewDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tmdbOverview', Sort.desc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy> sortByTmdbPoster() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tmdbPoster', Sort.asc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy>
      sortByTmdbPosterDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tmdbPoster', Sort.desc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy> sortByTmdbYear() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tmdbYear', Sort.asc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy> sortByTmdbYearDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tmdbYear', Sort.desc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy>
      sortByTotalDurationSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalDurationSeconds', Sort.asc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy>
      sortByTotalDurationSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalDurationSeconds', Sort.desc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy> sortByTvgId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tvgId', Sort.asc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy> sortByTvgIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tvgId', Sort.desc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy> sortByTvgName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tvgName', Sort.asc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy> sortByTvgNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tvgName', Sort.desc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy> sortByUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.asc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy> sortByUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.desc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy>
      sortByWatchedSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'watchedSeconds', Sort.asc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy>
      sortByWatchedSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'watchedSeconds', Sort.desc);
    });
  }
}

extension ChannelModelQuerySortThenBy
    on QueryBuilder<ChannelModel, ChannelModel, QSortThenBy> {
  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy> thenByCatchupDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'catchupDays', Sort.asc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy>
      thenByCatchupDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'catchupDays', Sort.desc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy> thenByCatchupType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'catchupType', Sort.asc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy>
      thenByCatchupTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'catchupType', Sort.desc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy> thenByCategoryName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryName', Sort.asc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy>
      thenByCategoryNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoryName', Sort.desc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy> thenByContentType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contentType', Sort.asc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy>
      thenByContentTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contentType', Sort.desc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy> thenByCountry() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'country', Sort.asc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy> thenByCountryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'country', Sort.desc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy> thenByEpgLogoUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'epgLogoUrl', Sort.asc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy>
      thenByEpgLogoUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'epgLogoUrl', Sort.desc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy> thenByEpisode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episode', Sort.asc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy> thenByEpisodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episode', Sort.desc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy>
      thenByEpisodesFetchedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodesFetchedAt', Sort.asc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy>
      thenByEpisodesFetchedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'episodesFetchedAt', Sort.desc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy> thenByGroupTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'groupTitle', Sort.asc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy>
      thenByGroupTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'groupTitle', Sort.desc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy> thenByImdbRating() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imdbRating', Sort.asc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy>
      thenByImdbRatingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imdbRating', Sort.desc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy> thenByIsFavorite() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFavorite', Sort.asc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy>
      thenByIsFavoriteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFavorite', Sort.desc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy> thenByLanguage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'language', Sort.asc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy> thenByLanguageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'language', Sort.desc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy> thenByLastWatched() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastWatched', Sort.asc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy>
      thenByLastWatchedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastWatched', Sort.desc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy> thenByLogoUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'logoUrl', Sort.asc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy> thenByLogoUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'logoUrl', Sort.desc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy>
      thenByParentSeriesId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentSeriesId', Sort.asc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy>
      thenByParentSeriesIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'parentSeriesId', Sort.desc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy> thenByPlaylistId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playlistId', Sort.asc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy>
      thenByPlaylistIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playlistId', Sort.desc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy> thenByQuality() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quality', Sort.asc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy> thenByQualityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quality', Sort.desc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy> thenBySeason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'season', Sort.asc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy> thenBySeasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'season', Sort.desc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy> thenBySeriesName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seriesName', Sort.asc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy>
      thenBySeriesNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'seriesName', Sort.desc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy>
      thenByShouldRefetchEpisodes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shouldRefetchEpisodes', Sort.asc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy>
      thenByShouldRefetchEpisodesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shouldRefetchEpisodes', Sort.desc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy> thenBySortOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOrder', Sort.asc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy> thenBySortOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOrder', Sort.desc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy> thenByStreamHeaders() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streamHeaders', Sort.asc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy>
      thenByStreamHeadersDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streamHeaders', Sort.desc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy>
      thenByStreamPlatform() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streamPlatform', Sort.asc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy>
      thenByStreamPlatformDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streamPlatform', Sort.desc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy> thenByTmdbId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tmdbId', Sort.asc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy> thenByTmdbIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tmdbId', Sort.desc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy> thenByTmdbOverview() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tmdbOverview', Sort.asc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy>
      thenByTmdbOverviewDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tmdbOverview', Sort.desc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy> thenByTmdbPoster() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tmdbPoster', Sort.asc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy>
      thenByTmdbPosterDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tmdbPoster', Sort.desc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy> thenByTmdbYear() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tmdbYear', Sort.asc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy> thenByTmdbYearDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tmdbYear', Sort.desc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy>
      thenByTotalDurationSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalDurationSeconds', Sort.asc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy>
      thenByTotalDurationSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalDurationSeconds', Sort.desc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy> thenByTvgId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tvgId', Sort.asc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy> thenByTvgIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tvgId', Sort.desc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy> thenByTvgName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tvgName', Sort.asc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy> thenByTvgNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tvgName', Sort.desc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy> thenByUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.asc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy> thenByUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.desc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy>
      thenByWatchedSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'watchedSeconds', Sort.asc);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QAfterSortBy>
      thenByWatchedSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'watchedSeconds', Sort.desc);
    });
  }
}

extension ChannelModelQueryWhereDistinct
    on QueryBuilder<ChannelModel, ChannelModel, QDistinct> {
  QueryBuilder<ChannelModel, ChannelModel, QDistinct> distinctByCatchupDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'catchupDays');
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QDistinct> distinctByCatchupType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'catchupType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QDistinct> distinctByCategoryName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'categoryName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QDistinct> distinctByContentType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'contentType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QDistinct> distinctByCountry(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'country', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QDistinct> distinctByEpgLogoUrl(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'epgLogoUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QDistinct> distinctByEpisode() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'episode');
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QDistinct>
      distinctByEpisodesFetchedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'episodesFetchedAt');
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QDistinct> distinctByGroupTitle(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'groupTitle', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QDistinct> distinctByImdbRating(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'imdbRating', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QDistinct> distinctByIsFavorite() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isFavorite');
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QDistinct> distinctByLanguage(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'language', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QDistinct> distinctByLastWatched() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastWatched');
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QDistinct> distinctByLogoUrl(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'logoUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QDistinct> distinctByParentSeriesId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'parentSeriesId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QDistinct> distinctByPlaylistId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'playlistId');
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QDistinct> distinctByQuality(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'quality', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QDistinct> distinctBySeason() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'season');
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QDistinct> distinctBySeriesName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'seriesName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QDistinct>
      distinctByShouldRefetchEpisodes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'shouldRefetchEpisodes');
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QDistinct> distinctBySortOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sortOrder');
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QDistinct> distinctByStreamHeaders(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'streamHeaders',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QDistinct> distinctByStreamPlatform(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'streamPlatform',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QDistinct> distinctByTmdbId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tmdbId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QDistinct> distinctByTmdbOverview(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tmdbOverview', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QDistinct> distinctByTmdbPoster(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tmdbPoster', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QDistinct> distinctByTmdbYear(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tmdbYear', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QDistinct>
      distinctByTotalDurationSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalDurationSeconds');
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QDistinct> distinctByTvgId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tvgId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QDistinct> distinctByTvgName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tvgName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QDistinct> distinctByUrl(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'url', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ChannelModel, ChannelModel, QDistinct>
      distinctByWatchedSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'watchedSeconds');
    });
  }
}

extension ChannelModelQueryProperty
    on QueryBuilder<ChannelModel, ChannelModel, QQueryProperty> {
  QueryBuilder<ChannelModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ChannelModel, int?, QQueryOperations> catchupDaysProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'catchupDays');
    });
  }

  QueryBuilder<ChannelModel, String?, QQueryOperations> catchupTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'catchupType');
    });
  }

  QueryBuilder<ChannelModel, String, QQueryOperations> categoryNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'categoryName');
    });
  }

  QueryBuilder<ChannelModel, String, QQueryOperations> contentTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'contentType');
    });
  }

  QueryBuilder<ChannelModel, String?, QQueryOperations> countryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'country');
    });
  }

  QueryBuilder<ChannelModel, String?, QQueryOperations> epgLogoUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'epgLogoUrl');
    });
  }

  QueryBuilder<ChannelModel, int?, QQueryOperations> episodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'episode');
    });
  }

  QueryBuilder<ChannelModel, DateTime?, QQueryOperations>
      episodesFetchedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'episodesFetchedAt');
    });
  }

  QueryBuilder<ChannelModel, String?, QQueryOperations> groupTitleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'groupTitle');
    });
  }

  QueryBuilder<ChannelModel, String?, QQueryOperations> imdbRatingProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'imdbRating');
    });
  }

  QueryBuilder<ChannelModel, bool, QQueryOperations> isFavoriteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isFavorite');
    });
  }

  QueryBuilder<ChannelModel, String?, QQueryOperations> languageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'language');
    });
  }

  QueryBuilder<ChannelModel, DateTime?, QQueryOperations>
      lastWatchedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastWatched');
    });
  }

  QueryBuilder<ChannelModel, String?, QQueryOperations> logoUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'logoUrl');
    });
  }

  QueryBuilder<ChannelModel, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<ChannelModel, String?, QQueryOperations>
      parentSeriesIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'parentSeriesId');
    });
  }

  QueryBuilder<ChannelModel, int, QQueryOperations> playlistIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'playlistId');
    });
  }

  QueryBuilder<ChannelModel, String?, QQueryOperations> qualityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'quality');
    });
  }

  QueryBuilder<ChannelModel, int?, QQueryOperations> seasonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'season');
    });
  }

  QueryBuilder<ChannelModel, String?, QQueryOperations> seriesNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'seriesName');
    });
  }

  QueryBuilder<ChannelModel, bool, QQueryOperations>
      shouldRefetchEpisodesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'shouldRefetchEpisodes');
    });
  }

  QueryBuilder<ChannelModel, int, QQueryOperations> sortOrderProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sortOrder');
    });
  }

  QueryBuilder<ChannelModel, String?, QQueryOperations>
      streamHeadersProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'streamHeaders');
    });
  }

  QueryBuilder<ChannelModel, String?, QQueryOperations>
      streamPlatformProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'streamPlatform');
    });
  }

  QueryBuilder<ChannelModel, String?, QQueryOperations> tmdbIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tmdbId');
    });
  }

  QueryBuilder<ChannelModel, String?, QQueryOperations> tmdbOverviewProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tmdbOverview');
    });
  }

  QueryBuilder<ChannelModel, String?, QQueryOperations> tmdbPosterProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tmdbPoster');
    });
  }

  QueryBuilder<ChannelModel, String?, QQueryOperations> tmdbYearProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tmdbYear');
    });
  }

  QueryBuilder<ChannelModel, int, QQueryOperations>
      totalDurationSecondsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalDurationSeconds');
    });
  }

  QueryBuilder<ChannelModel, String?, QQueryOperations> tvgIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tvgId');
    });
  }

  QueryBuilder<ChannelModel, String?, QQueryOperations> tvgNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tvgName');
    });
  }

  QueryBuilder<ChannelModel, String, QQueryOperations> urlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'url');
    });
  }

  QueryBuilder<ChannelModel, int, QQueryOperations> watchedSecondsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'watchedSeconds');
    });
  }
}
