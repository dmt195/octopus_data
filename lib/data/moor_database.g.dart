// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moor_database.dart';

// **************************************************************************
// MoorGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps, unnecessary_this
class EnergyData extends DataClass implements Insertable<EnergyData> {
  final DateTime intervalStart;
  final DateTime intervalEnd;
  final double tariffWithVat;
  final double tariffExVat;
  final double consumption;
  final double costWithVat;
  EnergyData(
      {this.intervalStart,
      this.intervalEnd,
      this.tariffWithVat,
      this.tariffExVat,
      this.consumption,
      this.costWithVat});
  factory EnergyData.fromData(Map<String, dynamic> data, GeneratedDatabase db,
      {String prefix}) {
    final effectivePrefix = prefix ?? '';
    final dateTimeType = db.typeSystem.forDartType<DateTime>();
    final doubleType = db.typeSystem.forDartType<double>();
    return EnergyData(
      intervalStart: dateTimeType
          .mapFromDatabaseResponse(data['${effectivePrefix}interval_start']),
      intervalEnd: dateTimeType
          .mapFromDatabaseResponse(data['${effectivePrefix}interval_end']),
      tariffWithVat: doubleType
          .mapFromDatabaseResponse(data['${effectivePrefix}tariff_with_vat']),
      tariffExVat: doubleType
          .mapFromDatabaseResponse(data['${effectivePrefix}tariff_ex_vat']),
      consumption: doubleType
          .mapFromDatabaseResponse(data['${effectivePrefix}consumption']),
      costWithVat: doubleType
          .mapFromDatabaseResponse(data['${effectivePrefix}cost_with_vat']),
    );
  }
  factory EnergyData.fromJson(Map<String, dynamic> json,
      {ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return EnergyData(
      intervalStart: serializer.fromJson<DateTime>(json['intervalStart']),
      intervalEnd: serializer.fromJson<DateTime>(json['intervalEnd']),
      tariffWithVat: serializer.fromJson<double>(json['tariffWithVat']),
      tariffExVat: serializer.fromJson<double>(json['tariffExVat']),
      consumption: serializer.fromJson<double>(json['consumption']),
      costWithVat: serializer.fromJson<double>(json['costWithVat']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'intervalStart': serializer.toJson<DateTime>(intervalStart),
      'intervalEnd': serializer.toJson<DateTime>(intervalEnd),
      'tariffWithVat': serializer.toJson<double>(tariffWithVat),
      'tariffExVat': serializer.toJson<double>(tariffExVat),
      'consumption': serializer.toJson<double>(consumption),
      'costWithVat': serializer.toJson<double>(costWithVat),
    };
  }

  @override
  EnergyCompanion createCompanion(bool nullToAbsent) {
    return EnergyCompanion(
      intervalStart: intervalStart == null && nullToAbsent
          ? const Value.absent()
          : Value(intervalStart),
      intervalEnd: intervalEnd == null && nullToAbsent
          ? const Value.absent()
          : Value(intervalEnd),
      tariffWithVat: tariffWithVat == null && nullToAbsent
          ? const Value.absent()
          : Value(tariffWithVat),
      tariffExVat: tariffExVat == null && nullToAbsent
          ? const Value.absent()
          : Value(tariffExVat),
      consumption: consumption == null && nullToAbsent
          ? const Value.absent()
          : Value(consumption),
      costWithVat: costWithVat == null && nullToAbsent
          ? const Value.absent()
          : Value(costWithVat),
    );
  }

  EnergyData copyWith(
          {DateTime intervalStart,
          DateTime intervalEnd,
          double tariffWithVat,
          double tariffExVat,
          double consumption,
          double costWithVat}) =>
      EnergyData(
        intervalStart: intervalStart ?? this.intervalStart,
        intervalEnd: intervalEnd ?? this.intervalEnd,
        tariffWithVat: tariffWithVat ?? this.tariffWithVat,
        tariffExVat: tariffExVat ?? this.tariffExVat,
        consumption: consumption ?? this.consumption,
        costWithVat: costWithVat ?? this.costWithVat,
      );
  @override
  String toString() {
    return (StringBuffer('EnergyData(')
          ..write('intervalStart: $intervalStart, ')
          ..write('intervalEnd: $intervalEnd, ')
          ..write('tariffWithVat: $tariffWithVat, ')
          ..write('tariffExVat: $tariffExVat, ')
          ..write('consumption: $consumption, ')
          ..write('costWithVat: $costWithVat')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => $mrjf($mrjc(
      intervalStart.hashCode,
      $mrjc(
          intervalEnd.hashCode,
          $mrjc(
              tariffWithVat.hashCode,
              $mrjc(tariffExVat.hashCode,
                  $mrjc(consumption.hashCode, costWithVat.hashCode))))));
  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      (other is EnergyData &&
          other.intervalStart == this.intervalStart &&
          other.intervalEnd == this.intervalEnd &&
          other.tariffWithVat == this.tariffWithVat &&
          other.tariffExVat == this.tariffExVat &&
          other.consumption == this.consumption &&
          other.costWithVat == this.costWithVat);
}

class EnergyCompanion extends UpdateCompanion<EnergyData> {
  final Value<DateTime> intervalStart;
  final Value<DateTime> intervalEnd;
  final Value<double> tariffWithVat;
  final Value<double> tariffExVat;
  final Value<double> consumption;
  final Value<double> costWithVat;
  const EnergyCompanion({
    this.intervalStart = const Value.absent(),
    this.intervalEnd = const Value.absent(),
    this.tariffWithVat = const Value.absent(),
    this.tariffExVat = const Value.absent(),
    this.consumption = const Value.absent(),
    this.costWithVat = const Value.absent(),
  });
  EnergyCompanion.insert({
    this.intervalStart = const Value.absent(),
    this.intervalEnd = const Value.absent(),
    this.tariffWithVat = const Value.absent(),
    this.tariffExVat = const Value.absent(),
    this.consumption = const Value.absent(),
    this.costWithVat = const Value.absent(),
  });
  EnergyCompanion copyWith(
      {Value<DateTime> intervalStart,
      Value<DateTime> intervalEnd,
      Value<double> tariffWithVat,
      Value<double> tariffExVat,
      Value<double> consumption,
      Value<double> costWithVat}) {
    return EnergyCompanion(
      intervalStart: intervalStart ?? this.intervalStart,
      intervalEnd: intervalEnd ?? this.intervalEnd,
      tariffWithVat: tariffWithVat ?? this.tariffWithVat,
      tariffExVat: tariffExVat ?? this.tariffExVat,
      consumption: consumption ?? this.consumption,
      costWithVat: costWithVat ?? this.costWithVat,
    );
  }
}

class $EnergyTable extends Energy with TableInfo<$EnergyTable, EnergyData> {
  final GeneratedDatabase _db;
  final String _alias;
  $EnergyTable(this._db, [this._alias]);
  final VerificationMeta _intervalStartMeta =
      const VerificationMeta('intervalStart');
  GeneratedDateTimeColumn _intervalStart;
  @override
  GeneratedDateTimeColumn get intervalStart =>
      _intervalStart ??= _constructIntervalStart();
  GeneratedDateTimeColumn _constructIntervalStart() {
    return GeneratedDateTimeColumn(
      'interval_start',
      $tableName,
      true,
    );
  }

  final VerificationMeta _intervalEndMeta =
      const VerificationMeta('intervalEnd');
  GeneratedDateTimeColumn _intervalEnd;
  @override
  GeneratedDateTimeColumn get intervalEnd =>
      _intervalEnd ??= _constructIntervalEnd();
  GeneratedDateTimeColumn _constructIntervalEnd() {
    return GeneratedDateTimeColumn(
      'interval_end',
      $tableName,
      true,
    );
  }

  final VerificationMeta _tariffWithVatMeta =
      const VerificationMeta('tariffWithVat');
  GeneratedRealColumn _tariffWithVat;
  @override
  GeneratedRealColumn get tariffWithVat =>
      _tariffWithVat ??= _constructTariffWithVat();
  GeneratedRealColumn _constructTariffWithVat() {
    return GeneratedRealColumn(
      'tariff_with_vat',
      $tableName,
      true,
    );
  }

  final VerificationMeta _tariffExVatMeta =
      const VerificationMeta('tariffExVat');
  GeneratedRealColumn _tariffExVat;
  @override
  GeneratedRealColumn get tariffExVat =>
      _tariffExVat ??= _constructTariffExVat();
  GeneratedRealColumn _constructTariffExVat() {
    return GeneratedRealColumn(
      'tariff_ex_vat',
      $tableName,
      true,
    );
  }

  final VerificationMeta _consumptionMeta =
      const VerificationMeta('consumption');
  GeneratedRealColumn _consumption;
  @override
  GeneratedRealColumn get consumption =>
      _consumption ??= _constructConsumption();
  GeneratedRealColumn _constructConsumption() {
    return GeneratedRealColumn(
      'consumption',
      $tableName,
      true,
    );
  }

  final VerificationMeta _costWithVatMeta =
      const VerificationMeta('costWithVat');
  GeneratedRealColumn _costWithVat;
  @override
  GeneratedRealColumn get costWithVat =>
      _costWithVat ??= _constructCostWithVat();
  GeneratedRealColumn _constructCostWithVat() {
    return GeneratedRealColumn(
      'cost_with_vat',
      $tableName,
      true,
    );
  }

  @override
  List<GeneratedColumn> get $columns => [
        intervalStart,
        intervalEnd,
        tariffWithVat,
        tariffExVat,
        consumption,
        costWithVat
      ];
  @override
  $EnergyTable get asDslTable => this;
  @override
  String get $tableName => _alias ?? 'energy';
  @override
  final String actualTableName = 'energy';
  @override
  VerificationContext validateIntegrity(EnergyCompanion d,
      {bool isInserting = false}) {
    final context = VerificationContext();
    if (d.intervalStart.present) {
      context.handle(
          _intervalStartMeta,
          intervalStart.isAcceptableValue(
              d.intervalStart.value, _intervalStartMeta));
    }
    if (d.intervalEnd.present) {
      context.handle(_intervalEndMeta,
          intervalEnd.isAcceptableValue(d.intervalEnd.value, _intervalEndMeta));
    }
    if (d.tariffWithVat.present) {
      context.handle(
          _tariffWithVatMeta,
          tariffWithVat.isAcceptableValue(
              d.tariffWithVat.value, _tariffWithVatMeta));
    }
    if (d.tariffExVat.present) {
      context.handle(_tariffExVatMeta,
          tariffExVat.isAcceptableValue(d.tariffExVat.value, _tariffExVatMeta));
    }
    if (d.consumption.present) {
      context.handle(_consumptionMeta,
          consumption.isAcceptableValue(d.consumption.value, _consumptionMeta));
    }
    if (d.costWithVat.present) {
      context.handle(_costWithVatMeta,
          costWithVat.isAcceptableValue(d.costWithVat.value, _costWithVatMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {intervalStart};
  @override
  EnergyData map(Map<String, dynamic> data, {String tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : null;
    return EnergyData.fromData(data, _db, prefix: effectivePrefix);
  }

  @override
  Map<String, Variable> entityToSql(EnergyCompanion d) {
    final map = <String, Variable>{};
    if (d.intervalStart.present) {
      map['interval_start'] =
          Variable<DateTime, DateTimeType>(d.intervalStart.value);
    }
    if (d.intervalEnd.present) {
      map['interval_end'] =
          Variable<DateTime, DateTimeType>(d.intervalEnd.value);
    }
    if (d.tariffWithVat.present) {
      map['tariff_with_vat'] =
          Variable<double, RealType>(d.tariffWithVat.value);
    }
    if (d.tariffExVat.present) {
      map['tariff_ex_vat'] = Variable<double, RealType>(d.tariffExVat.value);
    }
    if (d.consumption.present) {
      map['consumption'] = Variable<double, RealType>(d.consumption.value);
    }
    if (d.costWithVat.present) {
      map['cost_with_vat'] = Variable<double, RealType>(d.costWithVat.value);
    }
    return map;
  }

  @override
  $EnergyTable createAlias(String alias) {
    return $EnergyTable(_db, alias);
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(SqlTypeSystem.defaultInstance, e);
  $EnergyTable _energy;
  $EnergyTable get energy => _energy ??= $EnergyTable(this);
  @override
  Iterable<TableInfo> get allTables => allSchemaEntities.whereType<TableInfo>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [energy];
}
