// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'performance_models.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPerformanceDataPointCollection on Isar {
  IsarCollection<PerformanceDataPoint> get performanceDataPoints =>
      this.collection();
}

const PerformanceDataPointSchema = CollectionSchema(
  name: r'PerformanceDataPoint',
  id: -5337332618494183790,
  properties: {
    r'accuracy': PropertySchema(
      id: 0,
      name: r'accuracy',
      type: IsarType.double,
    ),
    r'averageTime': PropertySchema(
      id: 1,
      name: r'averageTime',
      type: IsarType.long,
    ),
    r'streak': PropertySchema(
      id: 2,
      name: r'streak',
      type: IsarType.long,
    ),
    r'timestamp': PropertySchema(
      id: 3,
      name: r'timestamp',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _performanceDataPointEstimateSize,
  serialize: _performanceDataPointSerialize,
  deserialize: _performanceDataPointDeserialize,
  deserializeProp: _performanceDataPointDeserializeProp,
  idName: r'id',
  indexes: {
    r'timestamp': IndexSchema(
      id: 1852253767416892198,
      name: r'timestamp',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'timestamp',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _performanceDataPointGetId,
  getLinks: _performanceDataPointGetLinks,
  attach: _performanceDataPointAttach,
  version: '3.1.0+1',
);

int _performanceDataPointEstimateSize(
  PerformanceDataPoint object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _performanceDataPointSerialize(
  PerformanceDataPoint object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.accuracy);
  writer.writeLong(offsets[1], object.averageTime);
  writer.writeLong(offsets[2], object.streak);
  writer.writeDateTime(offsets[3], object.timestamp);
}

PerformanceDataPoint _performanceDataPointDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PerformanceDataPoint(
    accuracy: reader.readDouble(offsets[0]),
    averageTime: reader.readLong(offsets[1]),
    streak: reader.readLong(offsets[2]),
    timestamp: reader.readDateTime(offsets[3]),
  );
  object.id = id;
  return object;
}

P _performanceDataPointDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _performanceDataPointGetId(PerformanceDataPoint object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _performanceDataPointGetLinks(
    PerformanceDataPoint object) {
  return [];
}

void _performanceDataPointAttach(
    IsarCollection<dynamic> col, Id id, PerformanceDataPoint object) {
  object.id = id;
}

extension PerformanceDataPointQueryWhereSort
    on QueryBuilder<PerformanceDataPoint, PerformanceDataPoint, QWhere> {
  QueryBuilder<PerformanceDataPoint, PerformanceDataPoint, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<PerformanceDataPoint, PerformanceDataPoint, QAfterWhere>
      anyTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'timestamp'),
      );
    });
  }
}

extension PerformanceDataPointQueryWhere
    on QueryBuilder<PerformanceDataPoint, PerformanceDataPoint, QWhereClause> {
  QueryBuilder<PerformanceDataPoint, PerformanceDataPoint, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<PerformanceDataPoint, PerformanceDataPoint, QAfterWhereClause>
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

  QueryBuilder<PerformanceDataPoint, PerformanceDataPoint, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PerformanceDataPoint, PerformanceDataPoint, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PerformanceDataPoint, PerformanceDataPoint, QAfterWhereClause>
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

  QueryBuilder<PerformanceDataPoint, PerformanceDataPoint, QAfterWhereClause>
      timestampEqualTo(DateTime timestamp) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'timestamp',
        value: [timestamp],
      ));
    });
  }

  QueryBuilder<PerformanceDataPoint, PerformanceDataPoint, QAfterWhereClause>
      timestampNotEqualTo(DateTime timestamp) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'timestamp',
              lower: [],
              upper: [timestamp],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'timestamp',
              lower: [timestamp],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'timestamp',
              lower: [timestamp],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'timestamp',
              lower: [],
              upper: [timestamp],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<PerformanceDataPoint, PerformanceDataPoint, QAfterWhereClause>
      timestampGreaterThan(
    DateTime timestamp, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'timestamp',
        lower: [timestamp],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<PerformanceDataPoint, PerformanceDataPoint, QAfterWhereClause>
      timestampLessThan(
    DateTime timestamp, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'timestamp',
        lower: [],
        upper: [timestamp],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<PerformanceDataPoint, PerformanceDataPoint, QAfterWhereClause>
      timestampBetween(
    DateTime lowerTimestamp,
    DateTime upperTimestamp, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'timestamp',
        lower: [lowerTimestamp],
        includeLower: includeLower,
        upper: [upperTimestamp],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension PerformanceDataPointQueryFilter on QueryBuilder<PerformanceDataPoint,
    PerformanceDataPoint, QFilterCondition> {
  QueryBuilder<PerformanceDataPoint, PerformanceDataPoint,
      QAfterFilterCondition> accuracyEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'accuracy',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PerformanceDataPoint, PerformanceDataPoint,
      QAfterFilterCondition> accuracyGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'accuracy',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PerformanceDataPoint, PerformanceDataPoint,
      QAfterFilterCondition> accuracyLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'accuracy',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PerformanceDataPoint, PerformanceDataPoint,
      QAfterFilterCondition> accuracyBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'accuracy',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PerformanceDataPoint, PerformanceDataPoint,
      QAfterFilterCondition> averageTimeEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'averageTime',
        value: value,
      ));
    });
  }

  QueryBuilder<PerformanceDataPoint, PerformanceDataPoint,
      QAfterFilterCondition> averageTimeGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'averageTime',
        value: value,
      ));
    });
  }

  QueryBuilder<PerformanceDataPoint, PerformanceDataPoint,
      QAfterFilterCondition> averageTimeLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'averageTime',
        value: value,
      ));
    });
  }

  QueryBuilder<PerformanceDataPoint, PerformanceDataPoint,
      QAfterFilterCondition> averageTimeBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'averageTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PerformanceDataPoint, PerformanceDataPoint,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PerformanceDataPoint, PerformanceDataPoint,
      QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<PerformanceDataPoint, PerformanceDataPoint,
      QAfterFilterCondition> idLessThan(
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

  QueryBuilder<PerformanceDataPoint, PerformanceDataPoint,
      QAfterFilterCondition> idBetween(
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

  QueryBuilder<PerformanceDataPoint, PerformanceDataPoint,
      QAfterFilterCondition> streakEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'streak',
        value: value,
      ));
    });
  }

  QueryBuilder<PerformanceDataPoint, PerformanceDataPoint,
      QAfterFilterCondition> streakGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'streak',
        value: value,
      ));
    });
  }

  QueryBuilder<PerformanceDataPoint, PerformanceDataPoint,
      QAfterFilterCondition> streakLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'streak',
        value: value,
      ));
    });
  }

  QueryBuilder<PerformanceDataPoint, PerformanceDataPoint,
      QAfterFilterCondition> streakBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'streak',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PerformanceDataPoint, PerformanceDataPoint,
      QAfterFilterCondition> timestampEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<PerformanceDataPoint, PerformanceDataPoint,
      QAfterFilterCondition> timestampGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<PerformanceDataPoint, PerformanceDataPoint,
      QAfterFilterCondition> timestampLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<PerformanceDataPoint, PerformanceDataPoint,
      QAfterFilterCondition> timestampBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'timestamp',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension PerformanceDataPointQueryObject on QueryBuilder<PerformanceDataPoint,
    PerformanceDataPoint, QFilterCondition> {}

extension PerformanceDataPointQueryLinks on QueryBuilder<PerformanceDataPoint,
    PerformanceDataPoint, QFilterCondition> {}

extension PerformanceDataPointQuerySortBy
    on QueryBuilder<PerformanceDataPoint, PerformanceDataPoint, QSortBy> {
  QueryBuilder<PerformanceDataPoint, PerformanceDataPoint, QAfterSortBy>
      sortByAccuracy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accuracy', Sort.asc);
    });
  }

  QueryBuilder<PerformanceDataPoint, PerformanceDataPoint, QAfterSortBy>
      sortByAccuracyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accuracy', Sort.desc);
    });
  }

  QueryBuilder<PerformanceDataPoint, PerformanceDataPoint, QAfterSortBy>
      sortByAverageTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'averageTime', Sort.asc);
    });
  }

  QueryBuilder<PerformanceDataPoint, PerformanceDataPoint, QAfterSortBy>
      sortByAverageTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'averageTime', Sort.desc);
    });
  }

  QueryBuilder<PerformanceDataPoint, PerformanceDataPoint, QAfterSortBy>
      sortByStreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streak', Sort.asc);
    });
  }

  QueryBuilder<PerformanceDataPoint, PerformanceDataPoint, QAfterSortBy>
      sortByStreakDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streak', Sort.desc);
    });
  }

  QueryBuilder<PerformanceDataPoint, PerformanceDataPoint, QAfterSortBy>
      sortByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<PerformanceDataPoint, PerformanceDataPoint, QAfterSortBy>
      sortByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }
}

extension PerformanceDataPointQuerySortThenBy
    on QueryBuilder<PerformanceDataPoint, PerformanceDataPoint, QSortThenBy> {
  QueryBuilder<PerformanceDataPoint, PerformanceDataPoint, QAfterSortBy>
      thenByAccuracy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accuracy', Sort.asc);
    });
  }

  QueryBuilder<PerformanceDataPoint, PerformanceDataPoint, QAfterSortBy>
      thenByAccuracyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accuracy', Sort.desc);
    });
  }

  QueryBuilder<PerformanceDataPoint, PerformanceDataPoint, QAfterSortBy>
      thenByAverageTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'averageTime', Sort.asc);
    });
  }

  QueryBuilder<PerformanceDataPoint, PerformanceDataPoint, QAfterSortBy>
      thenByAverageTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'averageTime', Sort.desc);
    });
  }

  QueryBuilder<PerformanceDataPoint, PerformanceDataPoint, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PerformanceDataPoint, PerformanceDataPoint, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PerformanceDataPoint, PerformanceDataPoint, QAfterSortBy>
      thenByStreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streak', Sort.asc);
    });
  }

  QueryBuilder<PerformanceDataPoint, PerformanceDataPoint, QAfterSortBy>
      thenByStreakDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'streak', Sort.desc);
    });
  }

  QueryBuilder<PerformanceDataPoint, PerformanceDataPoint, QAfterSortBy>
      thenByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<PerformanceDataPoint, PerformanceDataPoint, QAfterSortBy>
      thenByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }
}

extension PerformanceDataPointQueryWhereDistinct
    on QueryBuilder<PerformanceDataPoint, PerformanceDataPoint, QDistinct> {
  QueryBuilder<PerformanceDataPoint, PerformanceDataPoint, QDistinct>
      distinctByAccuracy() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'accuracy');
    });
  }

  QueryBuilder<PerformanceDataPoint, PerformanceDataPoint, QDistinct>
      distinctByAverageTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'averageTime');
    });
  }

  QueryBuilder<PerformanceDataPoint, PerformanceDataPoint, QDistinct>
      distinctByStreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'streak');
    });
  }

  QueryBuilder<PerformanceDataPoint, PerformanceDataPoint, QDistinct>
      distinctByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'timestamp');
    });
  }
}

extension PerformanceDataPointQueryProperty on QueryBuilder<
    PerformanceDataPoint, PerformanceDataPoint, QQueryProperty> {
  QueryBuilder<PerformanceDataPoint, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PerformanceDataPoint, double, QQueryOperations>
      accuracyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'accuracy');
    });
  }

  QueryBuilder<PerformanceDataPoint, int, QQueryOperations>
      averageTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'averageTime');
    });
  }

  QueryBuilder<PerformanceDataPoint, int, QQueryOperations> streakProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'streak');
    });
  }

  QueryBuilder<PerformanceDataPoint, DateTime, QQueryOperations>
      timestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'timestamp');
    });
  }
}
