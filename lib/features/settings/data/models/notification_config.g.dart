// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_config.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetNotificationConfigCollection on Isar {
  IsarCollection<NotificationConfig> get notificationConfigs =>
      this.collection();
}

const NotificationConfigSchema = CollectionSchema(
  name: r'NotificationConfig',
  id: 5475683209893487294,
  properties: {
    r'hour': PropertySchema(
      id: 0,
      name: r'hour',
      type: IsarType.long,
    ),
    r'isEnabled': PropertySchema(
      id: 1,
      name: r'isEnabled',
      type: IsarType.bool,
    ),
    r'minute': PropertySchema(
      id: 2,
      name: r'minute',
      type: IsarType.long,
    )
  },
  estimateSize: _notificationConfigEstimateSize,
  serialize: _notificationConfigSerialize,
  deserialize: _notificationConfigDeserialize,
  deserializeProp: _notificationConfigDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _notificationConfigGetId,
  getLinks: _notificationConfigGetLinks,
  attach: _notificationConfigAttach,
  version: '3.1.0+1',
);

int _notificationConfigEstimateSize(
  NotificationConfig object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _notificationConfigSerialize(
  NotificationConfig object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.hour);
  writer.writeBool(offsets[1], object.isEnabled);
  writer.writeLong(offsets[2], object.minute);
}

NotificationConfig _notificationConfigDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = NotificationConfig();
  object.hour = reader.readLong(offsets[0]);
  object.id = id;
  object.isEnabled = reader.readBool(offsets[1]);
  object.minute = reader.readLong(offsets[2]);
  return object;
}

P _notificationConfigDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _notificationConfigGetId(NotificationConfig object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _notificationConfigGetLinks(
    NotificationConfig object) {
  return [];
}

void _notificationConfigAttach(
    IsarCollection<dynamic> col, Id id, NotificationConfig object) {
  object.id = id;
}

extension NotificationConfigQueryWhereSort
    on QueryBuilder<NotificationConfig, NotificationConfig, QWhere> {
  QueryBuilder<NotificationConfig, NotificationConfig, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension NotificationConfigQueryWhere
    on QueryBuilder<NotificationConfig, NotificationConfig, QWhereClause> {
  QueryBuilder<NotificationConfig, NotificationConfig, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<NotificationConfig, NotificationConfig, QAfterWhereClause>
      idNotEqualTo(Id id) {
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

  QueryBuilder<NotificationConfig, NotificationConfig, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<NotificationConfig, NotificationConfig, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<NotificationConfig, NotificationConfig, QAfterWhereClause>
      idBetween(
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
}

extension NotificationConfigQueryFilter
    on QueryBuilder<NotificationConfig, NotificationConfig, QFilterCondition> {
  QueryBuilder<NotificationConfig, NotificationConfig, QAfterFilterCondition>
      hourEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hour',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationConfig, NotificationConfig, QAfterFilterCondition>
      hourGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'hour',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationConfig, NotificationConfig, QAfterFilterCondition>
      hourLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'hour',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationConfig, NotificationConfig, QAfterFilterCondition>
      hourBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'hour',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<NotificationConfig, NotificationConfig, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationConfig, NotificationConfig, QAfterFilterCondition>
      idGreaterThan(
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

  QueryBuilder<NotificationConfig, NotificationConfig, QAfterFilterCondition>
      idLessThan(
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

  QueryBuilder<NotificationConfig, NotificationConfig, QAfterFilterCondition>
      idBetween(
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

  QueryBuilder<NotificationConfig, NotificationConfig, QAfterFilterCondition>
      isEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isEnabled',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationConfig, NotificationConfig, QAfterFilterCondition>
      minuteEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'minute',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationConfig, NotificationConfig, QAfterFilterCondition>
      minuteGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'minute',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationConfig, NotificationConfig, QAfterFilterCondition>
      minuteLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'minute',
        value: value,
      ));
    });
  }

  QueryBuilder<NotificationConfig, NotificationConfig, QAfterFilterCondition>
      minuteBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'minute',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension NotificationConfigQueryObject
    on QueryBuilder<NotificationConfig, NotificationConfig, QFilterCondition> {}

extension NotificationConfigQueryLinks
    on QueryBuilder<NotificationConfig, NotificationConfig, QFilterCondition> {}

extension NotificationConfigQuerySortBy
    on QueryBuilder<NotificationConfig, NotificationConfig, QSortBy> {
  QueryBuilder<NotificationConfig, NotificationConfig, QAfterSortBy>
      sortByHour() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hour', Sort.asc);
    });
  }

  QueryBuilder<NotificationConfig, NotificationConfig, QAfterSortBy>
      sortByHourDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hour', Sort.desc);
    });
  }

  QueryBuilder<NotificationConfig, NotificationConfig, QAfterSortBy>
      sortByIsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isEnabled', Sort.asc);
    });
  }

  QueryBuilder<NotificationConfig, NotificationConfig, QAfterSortBy>
      sortByIsEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isEnabled', Sort.desc);
    });
  }

  QueryBuilder<NotificationConfig, NotificationConfig, QAfterSortBy>
      sortByMinute() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'minute', Sort.asc);
    });
  }

  QueryBuilder<NotificationConfig, NotificationConfig, QAfterSortBy>
      sortByMinuteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'minute', Sort.desc);
    });
  }
}

extension NotificationConfigQuerySortThenBy
    on QueryBuilder<NotificationConfig, NotificationConfig, QSortThenBy> {
  QueryBuilder<NotificationConfig, NotificationConfig, QAfterSortBy>
      thenByHour() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hour', Sort.asc);
    });
  }

  QueryBuilder<NotificationConfig, NotificationConfig, QAfterSortBy>
      thenByHourDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hour', Sort.desc);
    });
  }

  QueryBuilder<NotificationConfig, NotificationConfig, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<NotificationConfig, NotificationConfig, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<NotificationConfig, NotificationConfig, QAfterSortBy>
      thenByIsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isEnabled', Sort.asc);
    });
  }

  QueryBuilder<NotificationConfig, NotificationConfig, QAfterSortBy>
      thenByIsEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isEnabled', Sort.desc);
    });
  }

  QueryBuilder<NotificationConfig, NotificationConfig, QAfterSortBy>
      thenByMinute() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'minute', Sort.asc);
    });
  }

  QueryBuilder<NotificationConfig, NotificationConfig, QAfterSortBy>
      thenByMinuteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'minute', Sort.desc);
    });
  }
}

extension NotificationConfigQueryWhereDistinct
    on QueryBuilder<NotificationConfig, NotificationConfig, QDistinct> {
  QueryBuilder<NotificationConfig, NotificationConfig, QDistinct>
      distinctByHour() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hour');
    });
  }

  QueryBuilder<NotificationConfig, NotificationConfig, QDistinct>
      distinctByIsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isEnabled');
    });
  }

  QueryBuilder<NotificationConfig, NotificationConfig, QDistinct>
      distinctByMinute() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'minute');
    });
  }
}

extension NotificationConfigQueryProperty
    on QueryBuilder<NotificationConfig, NotificationConfig, QQueryProperty> {
  QueryBuilder<NotificationConfig, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<NotificationConfig, int, QQueryOperations> hourProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hour');
    });
  }

  QueryBuilder<NotificationConfig, bool, QQueryOperations> isEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isEnabled');
    });
  }

  QueryBuilder<NotificationConfig, int, QQueryOperations> minuteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'minute');
    });
  }
}
