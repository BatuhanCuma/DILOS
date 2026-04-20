// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_entry.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSessionEntryCollection on Isar {
  IsarCollection<SessionEntry> get sessionEntrys => this.collection();
}

const SessionEntrySchema = CollectionSchema(
  name: r'SessionEntry',
  id: 2192611445069189373,
  properties: {
    r'answersJson': PropertySchema(
      id: 0,
      name: r'answersJson',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 1,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'questionCount': PropertySchema(
      id: 2,
      name: r'questionCount',
      type: IsarType.long,
    ),
    r'status': PropertySchema(
      id: 3,
      name: r'status',
      type: IsarType.string,
    ),
    r'tagsJson': PropertySchema(
      id: 4,
      name: r'tagsJson',
      type: IsarType.string,
    )
  },
  estimateSize: _sessionEntryEstimateSize,
  serialize: _sessionEntrySerialize,
  deserialize: _sessionEntryDeserialize,
  deserializeProp: _sessionEntryDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _sessionEntryGetId,
  getLinks: _sessionEntryGetLinks,
  attach: _sessionEntryAttach,
  version: '3.1.0+1',
);

int _sessionEntryEstimateSize(
  SessionEntry object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.answersJson.length * 3;
  bytesCount += 3 + object.status.length * 3;
  {
    final value = object.tagsJson;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _sessionEntrySerialize(
  SessionEntry object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.answersJson);
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeLong(offsets[2], object.questionCount);
  writer.writeString(offsets[3], object.status);
  writer.writeString(offsets[4], object.tagsJson);
}

SessionEntry _sessionEntryDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SessionEntry();
  object.answersJson = reader.readString(offsets[0]);
  object.createdAt = reader.readDateTime(offsets[1]);
  object.id = id;
  object.questionCount = reader.readLong(offsets[2]);
  object.status = reader.readString(offsets[3]);
  object.tagsJson = reader.readStringOrNull(offsets[4]);
  return object;
}

P _sessionEntryDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _sessionEntryGetId(SessionEntry object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _sessionEntryGetLinks(SessionEntry object) {
  return [];
}

void _sessionEntryAttach(
    IsarCollection<dynamic> col, Id id, SessionEntry object) {
  object.id = id;
}

extension SessionEntryQueryWhereSort
    on QueryBuilder<SessionEntry, SessionEntry, QWhere> {
  QueryBuilder<SessionEntry, SessionEntry, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SessionEntryQueryWhere
    on QueryBuilder<SessionEntry, SessionEntry, QWhereClause> {
  QueryBuilder<SessionEntry, SessionEntry, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<SessionEntry, SessionEntry, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<SessionEntry, SessionEntry, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SessionEntry, SessionEntry, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SessionEntry, SessionEntry, QAfterWhereClause> idBetween(
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

extension SessionEntryQueryFilter
    on QueryBuilder<SessionEntry, SessionEntry, QFilterCondition> {
  QueryBuilder<SessionEntry, SessionEntry, QAfterFilterCondition>
      answersJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'answersJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SessionEntry, SessionEntry, QAfterFilterCondition>
      answersJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'answersJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SessionEntry, SessionEntry, QAfterFilterCondition>
      answersJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'answersJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SessionEntry, SessionEntry, QAfterFilterCondition>
      answersJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'answersJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SessionEntry, SessionEntry, QAfterFilterCondition>
      answersJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'answersJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SessionEntry, SessionEntry, QAfterFilterCondition>
      answersJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'answersJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SessionEntry, SessionEntry, QAfterFilterCondition>
      answersJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'answersJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SessionEntry, SessionEntry, QAfterFilterCondition>
      answersJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'answersJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SessionEntry, SessionEntry, QAfterFilterCondition>
      answersJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'answersJson',
        value: '',
      ));
    });
  }

  QueryBuilder<SessionEntry, SessionEntry, QAfterFilterCondition>
      answersJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'answersJson',
        value: '',
      ));
    });
  }

  QueryBuilder<SessionEntry, SessionEntry, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SessionEntry, SessionEntry, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SessionEntry, SessionEntry, QAfterFilterCondition>
      createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SessionEntry, SessionEntry, QAfterFilterCondition>
      createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SessionEntry, SessionEntry, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SessionEntry, SessionEntry, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<SessionEntry, SessionEntry, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<SessionEntry, SessionEntry, QAfterFilterCondition> idBetween(
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

  QueryBuilder<SessionEntry, SessionEntry, QAfterFilterCondition>
      questionCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'questionCount',
        value: value,
      ));
    });
  }

  QueryBuilder<SessionEntry, SessionEntry, QAfterFilterCondition>
      questionCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'questionCount',
        value: value,
      ));
    });
  }

  QueryBuilder<SessionEntry, SessionEntry, QAfterFilterCondition>
      questionCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'questionCount',
        value: value,
      ));
    });
  }

  QueryBuilder<SessionEntry, SessionEntry, QAfterFilterCondition>
      questionCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'questionCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SessionEntry, SessionEntry, QAfterFilterCondition> statusEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SessionEntry, SessionEntry, QAfterFilterCondition>
      statusGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SessionEntry, SessionEntry, QAfterFilterCondition>
      statusLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SessionEntry, SessionEntry, QAfterFilterCondition> statusBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'status',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SessionEntry, SessionEntry, QAfterFilterCondition>
      statusStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SessionEntry, SessionEntry, QAfterFilterCondition>
      statusEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SessionEntry, SessionEntry, QAfterFilterCondition>
      statusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SessionEntry, SessionEntry, QAfterFilterCondition> statusMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'status',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SessionEntry, SessionEntry, QAfterFilterCondition>
      statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<SessionEntry, SessionEntry, QAfterFilterCondition>
      statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<SessionEntry, SessionEntry, QAfterFilterCondition>
      tagsJsonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'tagsJson',
      ));
    });
  }

  QueryBuilder<SessionEntry, SessionEntry, QAfterFilterCondition>
      tagsJsonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'tagsJson',
      ));
    });
  }

  QueryBuilder<SessionEntry, SessionEntry, QAfterFilterCondition>
      tagsJsonEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tagsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SessionEntry, SessionEntry, QAfterFilterCondition>
      tagsJsonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tagsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SessionEntry, SessionEntry, QAfterFilterCondition>
      tagsJsonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tagsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SessionEntry, SessionEntry, QAfterFilterCondition>
      tagsJsonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tagsJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SessionEntry, SessionEntry, QAfterFilterCondition>
      tagsJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'tagsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SessionEntry, SessionEntry, QAfterFilterCondition>
      tagsJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'tagsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SessionEntry, SessionEntry, QAfterFilterCondition>
      tagsJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'tagsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SessionEntry, SessionEntry, QAfterFilterCondition>
      tagsJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'tagsJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SessionEntry, SessionEntry, QAfterFilterCondition>
      tagsJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tagsJson',
        value: '',
      ));
    });
  }

  QueryBuilder<SessionEntry, SessionEntry, QAfterFilterCondition>
      tagsJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'tagsJson',
        value: '',
      ));
    });
  }
}

extension SessionEntryQueryObject
    on QueryBuilder<SessionEntry, SessionEntry, QFilterCondition> {}

extension SessionEntryQueryLinks
    on QueryBuilder<SessionEntry, SessionEntry, QFilterCondition> {}

extension SessionEntryQuerySortBy
    on QueryBuilder<SessionEntry, SessionEntry, QSortBy> {
  QueryBuilder<SessionEntry, SessionEntry, QAfterSortBy> sortByAnswersJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'answersJson', Sort.asc);
    });
  }

  QueryBuilder<SessionEntry, SessionEntry, QAfterSortBy>
      sortByAnswersJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'answersJson', Sort.desc);
    });
  }

  QueryBuilder<SessionEntry, SessionEntry, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<SessionEntry, SessionEntry, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<SessionEntry, SessionEntry, QAfterSortBy> sortByQuestionCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'questionCount', Sort.asc);
    });
  }

  QueryBuilder<SessionEntry, SessionEntry, QAfterSortBy>
      sortByQuestionCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'questionCount', Sort.desc);
    });
  }

  QueryBuilder<SessionEntry, SessionEntry, QAfterSortBy> sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<SessionEntry, SessionEntry, QAfterSortBy> sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<SessionEntry, SessionEntry, QAfterSortBy> sortByTagsJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tagsJson', Sort.asc);
    });
  }

  QueryBuilder<SessionEntry, SessionEntry, QAfterSortBy> sortByTagsJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tagsJson', Sort.desc);
    });
  }
}

extension SessionEntryQuerySortThenBy
    on QueryBuilder<SessionEntry, SessionEntry, QSortThenBy> {
  QueryBuilder<SessionEntry, SessionEntry, QAfterSortBy> thenByAnswersJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'answersJson', Sort.asc);
    });
  }

  QueryBuilder<SessionEntry, SessionEntry, QAfterSortBy>
      thenByAnswersJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'answersJson', Sort.desc);
    });
  }

  QueryBuilder<SessionEntry, SessionEntry, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<SessionEntry, SessionEntry, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<SessionEntry, SessionEntry, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SessionEntry, SessionEntry, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SessionEntry, SessionEntry, QAfterSortBy> thenByQuestionCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'questionCount', Sort.asc);
    });
  }

  QueryBuilder<SessionEntry, SessionEntry, QAfterSortBy>
      thenByQuestionCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'questionCount', Sort.desc);
    });
  }

  QueryBuilder<SessionEntry, SessionEntry, QAfterSortBy> thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<SessionEntry, SessionEntry, QAfterSortBy> thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<SessionEntry, SessionEntry, QAfterSortBy> thenByTagsJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tagsJson', Sort.asc);
    });
  }

  QueryBuilder<SessionEntry, SessionEntry, QAfterSortBy> thenByTagsJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tagsJson', Sort.desc);
    });
  }
}

extension SessionEntryQueryWhereDistinct
    on QueryBuilder<SessionEntry, SessionEntry, QDistinct> {
  QueryBuilder<SessionEntry, SessionEntry, QDistinct> distinctByAnswersJson(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'answersJson', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SessionEntry, SessionEntry, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<SessionEntry, SessionEntry, QDistinct>
      distinctByQuestionCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'questionCount');
    });
  }

  QueryBuilder<SessionEntry, SessionEntry, QDistinct> distinctByStatus(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SessionEntry, SessionEntry, QDistinct> distinctByTagsJson(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tagsJson', caseSensitive: caseSensitive);
    });
  }
}

extension SessionEntryQueryProperty
    on QueryBuilder<SessionEntry, SessionEntry, QQueryProperty> {
  QueryBuilder<SessionEntry, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SessionEntry, String, QQueryOperations> answersJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'answersJson');
    });
  }

  QueryBuilder<SessionEntry, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<SessionEntry, int, QQueryOperations> questionCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'questionCount');
    });
  }

  QueryBuilder<SessionEntry, String, QQueryOperations> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<SessionEntry, String?, QQueryOperations> tagsJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tagsJson');
    });
  }
}
