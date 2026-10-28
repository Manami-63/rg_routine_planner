// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $RoutinesTable extends Routines
    with TableInfo<$RoutinesTable, RoutineRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoutinesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rulesetIdMeta = const VerificationMeta(
    'rulesetId',
  );
  @override
  late final GeneratedColumn<String> rulesetId = GeneratedColumn<String>(
    'ruleset_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _apparatusMeta = const VerificationMeta(
    'apparatus',
  );
  @override
  late final GeneratedColumn<String> apparatus = GeneratedColumn<String>(
    'apparatus',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _levelIdMeta = const VerificationMeta(
    'levelId',
  );
  @override
  late final GeneratedColumn<String> levelId = GeneratedColumn<String>(
    'level_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _customDbMinMeta = const VerificationMeta(
    'customDbMin',
  );
  @override
  late final GeneratedColumn<int> customDbMin = GeneratedColumn<int>(
    'custom_db_min',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _customDbMaxMeta = const VerificationMeta(
    'customDbMax',
  );
  @override
  late final GeneratedColumn<int> customDbMax = GeneratedColumn<int>(
    'custom_db_max',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _customRiskMinMeta = const VerificationMeta(
    'customRiskMin',
  );
  @override
  late final GeneratedColumn<int> customRiskMin = GeneratedColumn<int>(
    'custom_risk_min',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _customRiskMaxMeta = const VerificationMeta(
    'customRiskMax',
  );
  @override
  late final GeneratedColumn<int> customRiskMax = GeneratedColumn<int>(
    'custom_risk_max',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _customDaMinMeta = const VerificationMeta(
    'customDaMin',
  );
  @override
  late final GeneratedColumn<int> customDaMin = GeneratedColumn<int>(
    'custom_da_min',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _customDaMaxMeta = const VerificationMeta(
    'customDaMax',
  );
  @override
  late final GeneratedColumn<int> customDaMax = GeneratedColumn<int>(
    'custom_da_max',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _customRequiredBodyGroupsMeta =
      const VerificationMeta('customRequiredBodyGroups');
  @override
  late final GeneratedColumn<String> customRequiredBodyGroups =
      GeneratedColumn<String>(
        'custom_required_body_groups',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    rulesetId,
    apparatus,
    levelId,
    customDbMin,
    customDbMax,
    customRiskMin,
    customRiskMax,
    customDaMin,
    customDaMax,
    customRequiredBodyGroups,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'routines';
  @override
  VerificationContext validateIntegrity(
    Insertable<RoutineRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('ruleset_id')) {
      context.handle(
        _rulesetIdMeta,
        rulesetId.isAcceptableOrUnknown(data['ruleset_id']!, _rulesetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_rulesetIdMeta);
    }
    if (data.containsKey('apparatus')) {
      context.handle(
        _apparatusMeta,
        apparatus.isAcceptableOrUnknown(data['apparatus']!, _apparatusMeta),
      );
    }
    if (data.containsKey('level_id')) {
      context.handle(
        _levelIdMeta,
        levelId.isAcceptableOrUnknown(data['level_id']!, _levelIdMeta),
      );
    }
    if (data.containsKey('custom_db_min')) {
      context.handle(
        _customDbMinMeta,
        customDbMin.isAcceptableOrUnknown(
          data['custom_db_min']!,
          _customDbMinMeta,
        ),
      );
    }
    if (data.containsKey('custom_db_max')) {
      context.handle(
        _customDbMaxMeta,
        customDbMax.isAcceptableOrUnknown(
          data['custom_db_max']!,
          _customDbMaxMeta,
        ),
      );
    }
    if (data.containsKey('custom_risk_min')) {
      context.handle(
        _customRiskMinMeta,
        customRiskMin.isAcceptableOrUnknown(
          data['custom_risk_min']!,
          _customRiskMinMeta,
        ),
      );
    }
    if (data.containsKey('custom_risk_max')) {
      context.handle(
        _customRiskMaxMeta,
        customRiskMax.isAcceptableOrUnknown(
          data['custom_risk_max']!,
          _customRiskMaxMeta,
        ),
      );
    }
    if (data.containsKey('custom_da_min')) {
      context.handle(
        _customDaMinMeta,
        customDaMin.isAcceptableOrUnknown(
          data['custom_da_min']!,
          _customDaMinMeta,
        ),
      );
    }
    if (data.containsKey('custom_da_max')) {
      context.handle(
        _customDaMaxMeta,
        customDaMax.isAcceptableOrUnknown(
          data['custom_da_max']!,
          _customDaMaxMeta,
        ),
      );
    }
    if (data.containsKey('custom_required_body_groups')) {
      context.handle(
        _customRequiredBodyGroupsMeta,
        customRequiredBodyGroups.isAcceptableOrUnknown(
          data['custom_required_body_groups']!,
          _customRequiredBodyGroupsMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RoutineRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RoutineRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      rulesetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ruleset_id'],
      )!,
      apparatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}apparatus'],
      ),
      levelId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}level_id'],
      ),
      customDbMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}custom_db_min'],
      ),
      customDbMax: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}custom_db_max'],
      ),
      customRiskMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}custom_risk_min'],
      ),
      customRiskMax: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}custom_risk_max'],
      ),
      customDaMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}custom_da_min'],
      ),
      customDaMax: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}custom_da_max'],
      ),
      customRequiredBodyGroups: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}custom_required_body_groups'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $RoutinesTable createAlias(String alias) {
    return $RoutinesTable(attachedDatabase, alias);
  }
}

class RoutineRow extends DataClass implements Insertable<RoutineRow> {
  /// UUID, generated on the device.
  final String id;
  final String name;
  final String rulesetId;

  /// `Apparatus.name` (e.g. `hoop`), or null if none chosen. Added in v2.
  final String? apparatus;

  /// Preset level id (e.g. `fig-senior`), `custom`, or null for no level.
  final String? levelId;
  final int? customDbMin;
  final int? customDbMax;
  final int? customRiskMin;
  final int? customRiskMax;
  final int? customDaMin;
  final int? customDaMax;

  /// Required body groups, as comma-separated `DbElementGroup.name`s (e.g.
  /// `jump,balance`). Null or empty for none. Added in v2.
  final String? customRequiredBodyGroups;
  final DateTime createdAt;
  final DateTime updatedAt;
  const RoutineRow({
    required this.id,
    required this.name,
    required this.rulesetId,
    this.apparatus,
    this.levelId,
    this.customDbMin,
    this.customDbMax,
    this.customRiskMin,
    this.customRiskMax,
    this.customDaMin,
    this.customDaMax,
    this.customRequiredBodyGroups,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['ruleset_id'] = Variable<String>(rulesetId);
    if (!nullToAbsent || apparatus != null) {
      map['apparatus'] = Variable<String>(apparatus);
    }
    if (!nullToAbsent || levelId != null) {
      map['level_id'] = Variable<String>(levelId);
    }
    if (!nullToAbsent || customDbMin != null) {
      map['custom_db_min'] = Variable<int>(customDbMin);
    }
    if (!nullToAbsent || customDbMax != null) {
      map['custom_db_max'] = Variable<int>(customDbMax);
    }
    if (!nullToAbsent || customRiskMin != null) {
      map['custom_risk_min'] = Variable<int>(customRiskMin);
    }
    if (!nullToAbsent || customRiskMax != null) {
      map['custom_risk_max'] = Variable<int>(customRiskMax);
    }
    if (!nullToAbsent || customDaMin != null) {
      map['custom_da_min'] = Variable<int>(customDaMin);
    }
    if (!nullToAbsent || customDaMax != null) {
      map['custom_da_max'] = Variable<int>(customDaMax);
    }
    if (!nullToAbsent || customRequiredBodyGroups != null) {
      map['custom_required_body_groups'] = Variable<String>(
        customRequiredBodyGroups,
      );
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  RoutinesCompanion toCompanion(bool nullToAbsent) {
    return RoutinesCompanion(
      id: Value(id),
      name: Value(name),
      rulesetId: Value(rulesetId),
      apparatus: apparatus == null && nullToAbsent
          ? const Value.absent()
          : Value(apparatus),
      levelId: levelId == null && nullToAbsent
          ? const Value.absent()
          : Value(levelId),
      customDbMin: customDbMin == null && nullToAbsent
          ? const Value.absent()
          : Value(customDbMin),
      customDbMax: customDbMax == null && nullToAbsent
          ? const Value.absent()
          : Value(customDbMax),
      customRiskMin: customRiskMin == null && nullToAbsent
          ? const Value.absent()
          : Value(customRiskMin),
      customRiskMax: customRiskMax == null && nullToAbsent
          ? const Value.absent()
          : Value(customRiskMax),
      customDaMin: customDaMin == null && nullToAbsent
          ? const Value.absent()
          : Value(customDaMin),
      customDaMax: customDaMax == null && nullToAbsent
          ? const Value.absent()
          : Value(customDaMax),
      customRequiredBodyGroups: customRequiredBodyGroups == null && nullToAbsent
          ? const Value.absent()
          : Value(customRequiredBodyGroups),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory RoutineRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RoutineRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      rulesetId: serializer.fromJson<String>(json['rulesetId']),
      apparatus: serializer.fromJson<String?>(json['apparatus']),
      levelId: serializer.fromJson<String?>(json['levelId']),
      customDbMin: serializer.fromJson<int?>(json['customDbMin']),
      customDbMax: serializer.fromJson<int?>(json['customDbMax']),
      customRiskMin: serializer.fromJson<int?>(json['customRiskMin']),
      customRiskMax: serializer.fromJson<int?>(json['customRiskMax']),
      customDaMin: serializer.fromJson<int?>(json['customDaMin']),
      customDaMax: serializer.fromJson<int?>(json['customDaMax']),
      customRequiredBodyGroups: serializer.fromJson<String?>(
        json['customRequiredBodyGroups'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'rulesetId': serializer.toJson<String>(rulesetId),
      'apparatus': serializer.toJson<String?>(apparatus),
      'levelId': serializer.toJson<String?>(levelId),
      'customDbMin': serializer.toJson<int?>(customDbMin),
      'customDbMax': serializer.toJson<int?>(customDbMax),
      'customRiskMin': serializer.toJson<int?>(customRiskMin),
      'customRiskMax': serializer.toJson<int?>(customRiskMax),
      'customDaMin': serializer.toJson<int?>(customDaMin),
      'customDaMax': serializer.toJson<int?>(customDaMax),
      'customRequiredBodyGroups': serializer.toJson<String?>(
        customRequiredBodyGroups,
      ),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  RoutineRow copyWith({
    String? id,
    String? name,
    String? rulesetId,
    Value<String?> apparatus = const Value.absent(),
    Value<String?> levelId = const Value.absent(),
    Value<int?> customDbMin = const Value.absent(),
    Value<int?> customDbMax = const Value.absent(),
    Value<int?> customRiskMin = const Value.absent(),
    Value<int?> customRiskMax = const Value.absent(),
    Value<int?> customDaMin = const Value.absent(),
    Value<int?> customDaMax = const Value.absent(),
    Value<String?> customRequiredBodyGroups = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => RoutineRow(
    id: id ?? this.id,
    name: name ?? this.name,
    rulesetId: rulesetId ?? this.rulesetId,
    apparatus: apparatus.present ? apparatus.value : this.apparatus,
    levelId: levelId.present ? levelId.value : this.levelId,
    customDbMin: customDbMin.present ? customDbMin.value : this.customDbMin,
    customDbMax: customDbMax.present ? customDbMax.value : this.customDbMax,
    customRiskMin: customRiskMin.present
        ? customRiskMin.value
        : this.customRiskMin,
    customRiskMax: customRiskMax.present
        ? customRiskMax.value
        : this.customRiskMax,
    customDaMin: customDaMin.present ? customDaMin.value : this.customDaMin,
    customDaMax: customDaMax.present ? customDaMax.value : this.customDaMax,
    customRequiredBodyGroups: customRequiredBodyGroups.present
        ? customRequiredBodyGroups.value
        : this.customRequiredBodyGroups,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  RoutineRow copyWithCompanion(RoutinesCompanion data) {
    return RoutineRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      rulesetId: data.rulesetId.present ? data.rulesetId.value : this.rulesetId,
      apparatus: data.apparatus.present ? data.apparatus.value : this.apparatus,
      levelId: data.levelId.present ? data.levelId.value : this.levelId,
      customDbMin: data.customDbMin.present
          ? data.customDbMin.value
          : this.customDbMin,
      customDbMax: data.customDbMax.present
          ? data.customDbMax.value
          : this.customDbMax,
      customRiskMin: data.customRiskMin.present
          ? data.customRiskMin.value
          : this.customRiskMin,
      customRiskMax: data.customRiskMax.present
          ? data.customRiskMax.value
          : this.customRiskMax,
      customDaMin: data.customDaMin.present
          ? data.customDaMin.value
          : this.customDaMin,
      customDaMax: data.customDaMax.present
          ? data.customDaMax.value
          : this.customDaMax,
      customRequiredBodyGroups: data.customRequiredBodyGroups.present
          ? data.customRequiredBodyGroups.value
          : this.customRequiredBodyGroups,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RoutineRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('rulesetId: $rulesetId, ')
          ..write('apparatus: $apparatus, ')
          ..write('levelId: $levelId, ')
          ..write('customDbMin: $customDbMin, ')
          ..write('customDbMax: $customDbMax, ')
          ..write('customRiskMin: $customRiskMin, ')
          ..write('customRiskMax: $customRiskMax, ')
          ..write('customDaMin: $customDaMin, ')
          ..write('customDaMax: $customDaMax, ')
          ..write('customRequiredBodyGroups: $customRequiredBodyGroups, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    rulesetId,
    apparatus,
    levelId,
    customDbMin,
    customDbMax,
    customRiskMin,
    customRiskMax,
    customDaMin,
    customDaMax,
    customRequiredBodyGroups,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RoutineRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.rulesetId == this.rulesetId &&
          other.apparatus == this.apparatus &&
          other.levelId == this.levelId &&
          other.customDbMin == this.customDbMin &&
          other.customDbMax == this.customDbMax &&
          other.customRiskMin == this.customRiskMin &&
          other.customRiskMax == this.customRiskMax &&
          other.customDaMin == this.customDaMin &&
          other.customDaMax == this.customDaMax &&
          other.customRequiredBodyGroups == this.customRequiredBodyGroups &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class RoutinesCompanion extends UpdateCompanion<RoutineRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> rulesetId;
  final Value<String?> apparatus;
  final Value<String?> levelId;
  final Value<int?> customDbMin;
  final Value<int?> customDbMax;
  final Value<int?> customRiskMin;
  final Value<int?> customRiskMax;
  final Value<int?> customDaMin;
  final Value<int?> customDaMax;
  final Value<String?> customRequiredBodyGroups;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const RoutinesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.rulesetId = const Value.absent(),
    this.apparatus = const Value.absent(),
    this.levelId = const Value.absent(),
    this.customDbMin = const Value.absent(),
    this.customDbMax = const Value.absent(),
    this.customRiskMin = const Value.absent(),
    this.customRiskMax = const Value.absent(),
    this.customDaMin = const Value.absent(),
    this.customDaMax = const Value.absent(),
    this.customRequiredBodyGroups = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RoutinesCompanion.insert({
    required String id,
    required String name,
    required String rulesetId,
    this.apparatus = const Value.absent(),
    this.levelId = const Value.absent(),
    this.customDbMin = const Value.absent(),
    this.customDbMax = const Value.absent(),
    this.customRiskMin = const Value.absent(),
    this.customRiskMax = const Value.absent(),
    this.customDaMin = const Value.absent(),
    this.customDaMax = const Value.absent(),
    this.customRequiredBodyGroups = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       rulesetId = Value(rulesetId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<RoutineRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? rulesetId,
    Expression<String>? apparatus,
    Expression<String>? levelId,
    Expression<int>? customDbMin,
    Expression<int>? customDbMax,
    Expression<int>? customRiskMin,
    Expression<int>? customRiskMax,
    Expression<int>? customDaMin,
    Expression<int>? customDaMax,
    Expression<String>? customRequiredBodyGroups,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (rulesetId != null) 'ruleset_id': rulesetId,
      if (apparatus != null) 'apparatus': apparatus,
      if (levelId != null) 'level_id': levelId,
      if (customDbMin != null) 'custom_db_min': customDbMin,
      if (customDbMax != null) 'custom_db_max': customDbMax,
      if (customRiskMin != null) 'custom_risk_min': customRiskMin,
      if (customRiskMax != null) 'custom_risk_max': customRiskMax,
      if (customDaMin != null) 'custom_da_min': customDaMin,
      if (customDaMax != null) 'custom_da_max': customDaMax,
      if (customRequiredBodyGroups != null)
        'custom_required_body_groups': customRequiredBodyGroups,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RoutinesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? rulesetId,
    Value<String?>? apparatus,
    Value<String?>? levelId,
    Value<int?>? customDbMin,
    Value<int?>? customDbMax,
    Value<int?>? customRiskMin,
    Value<int?>? customRiskMax,
    Value<int?>? customDaMin,
    Value<int?>? customDaMax,
    Value<String?>? customRequiredBodyGroups,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return RoutinesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      rulesetId: rulesetId ?? this.rulesetId,
      apparatus: apparatus ?? this.apparatus,
      levelId: levelId ?? this.levelId,
      customDbMin: customDbMin ?? this.customDbMin,
      customDbMax: customDbMax ?? this.customDbMax,
      customRiskMin: customRiskMin ?? this.customRiskMin,
      customRiskMax: customRiskMax ?? this.customRiskMax,
      customDaMin: customDaMin ?? this.customDaMin,
      customDaMax: customDaMax ?? this.customDaMax,
      customRequiredBodyGroups:
          customRequiredBodyGroups ?? this.customRequiredBodyGroups,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (rulesetId.present) {
      map['ruleset_id'] = Variable<String>(rulesetId.value);
    }
    if (apparatus.present) {
      map['apparatus'] = Variable<String>(apparatus.value);
    }
    if (levelId.present) {
      map['level_id'] = Variable<String>(levelId.value);
    }
    if (customDbMin.present) {
      map['custom_db_min'] = Variable<int>(customDbMin.value);
    }
    if (customDbMax.present) {
      map['custom_db_max'] = Variable<int>(customDbMax.value);
    }
    if (customRiskMin.present) {
      map['custom_risk_min'] = Variable<int>(customRiskMin.value);
    }
    if (customRiskMax.present) {
      map['custom_risk_max'] = Variable<int>(customRiskMax.value);
    }
    if (customDaMin.present) {
      map['custom_da_min'] = Variable<int>(customDaMin.value);
    }
    if (customDaMax.present) {
      map['custom_da_max'] = Variable<int>(customDaMax.value);
    }
    if (customRequiredBodyGroups.present) {
      map['custom_required_body_groups'] = Variable<String>(
        customRequiredBodyGroups.value,
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoutinesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('rulesetId: $rulesetId, ')
          ..write('apparatus: $apparatus, ')
          ..write('levelId: $levelId, ')
          ..write('customDbMin: $customDbMin, ')
          ..write('customDbMax: $customDbMax, ')
          ..write('customRiskMin: $customRiskMin, ')
          ..write('customRiskMax: $customRiskMax, ')
          ..write('customDaMin: $customDaMin, ')
          ..write('customDaMax: $customDaMax, ')
          ..write('customRequiredBodyGroups: $customRequiredBodyGroups, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RoutineBodyElementsTable extends RoutineBodyElements
    with TableInfo<$RoutineBodyElementsTable, RoutineBodyElementRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoutineBodyElementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _routineIdMeta = const VerificationMeta(
    'routineId',
  );
  @override
  late final GeneratedColumn<String> routineId = GeneratedColumn<String>(
    'routine_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES routines (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _elementIdMeta = const VerificationMeta(
    'elementId',
  );
  @override
  late final GeneratedColumn<String> elementId = GeneratedColumn<String>(
    'element_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _flatFootMeta = const VerificationMeta(
    'flatFoot',
  );
  @override
  late final GeneratedColumn<bool> flatFoot = GeneratedColumn<bool>(
    'flat_foot',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("flat_foot" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _slowTurnMeta = const VerificationMeta(
    'slowTurn',
  );
  @override
  late final GeneratedColumn<bool> slowTurn = GeneratedColumn<bool>(
    'slow_turn',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("slow_turn" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _extraRotationsMeta = const VerificationMeta(
    'extraRotations',
  );
  @override
  late final GeneratedColumn<int> extraRotations = GeneratedColumn<int>(
    'extra_rotations',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _seriesCountMeta = const VerificationMeta(
    'seriesCount',
  );
  @override
  late final GeneratedColumn<int> seriesCount = GeneratedColumn<int>(
    'series_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _manualValueMeta = const VerificationMeta(
    'manualValue',
  );
  @override
  late final GeneratedColumn<int> manualValue = GeneratedColumn<int>(
    'manual_value',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _customNameMeta = const VerificationMeta(
    'customName',
  );
  @override
  late final GeneratedColumn<String> customName = GeneratedColumn<String>(
    'custom_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _customGroupMeta = const VerificationMeta(
    'customGroup',
  );
  @override
  late final GeneratedColumn<String> customGroup = GeneratedColumn<String>(
    'custom_group',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    routineId,
    elementId,
    position,
    flatFoot,
    slowTurn,
    extraRotations,
    seriesCount,
    manualValue,
    customName,
    customGroup,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'routine_body_elements';
  @override
  VerificationContext validateIntegrity(
    Insertable<RoutineBodyElementRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('routine_id')) {
      context.handle(
        _routineIdMeta,
        routineId.isAcceptableOrUnknown(data['routine_id']!, _routineIdMeta),
      );
    } else if (isInserting) {
      context.missing(_routineIdMeta);
    }
    if (data.containsKey('element_id')) {
      context.handle(
        _elementIdMeta,
        elementId.isAcceptableOrUnknown(data['element_id']!, _elementIdMeta),
      );
    } else if (isInserting) {
      context.missing(_elementIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('flat_foot')) {
      context.handle(
        _flatFootMeta,
        flatFoot.isAcceptableOrUnknown(data['flat_foot']!, _flatFootMeta),
      );
    }
    if (data.containsKey('slow_turn')) {
      context.handle(
        _slowTurnMeta,
        slowTurn.isAcceptableOrUnknown(data['slow_turn']!, _slowTurnMeta),
      );
    }
    if (data.containsKey('extra_rotations')) {
      context.handle(
        _extraRotationsMeta,
        extraRotations.isAcceptableOrUnknown(
          data['extra_rotations']!,
          _extraRotationsMeta,
        ),
      );
    }
    if (data.containsKey('series_count')) {
      context.handle(
        _seriesCountMeta,
        seriesCount.isAcceptableOrUnknown(
          data['series_count']!,
          _seriesCountMeta,
        ),
      );
    }
    if (data.containsKey('manual_value')) {
      context.handle(
        _manualValueMeta,
        manualValue.isAcceptableOrUnknown(
          data['manual_value']!,
          _manualValueMeta,
        ),
      );
    }
    if (data.containsKey('custom_name')) {
      context.handle(
        _customNameMeta,
        customName.isAcceptableOrUnknown(data['custom_name']!, _customNameMeta),
      );
    }
    if (data.containsKey('custom_group')) {
      context.handle(
        _customGroupMeta,
        customGroup.isAcceptableOrUnknown(
          data['custom_group']!,
          _customGroupMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RoutineBodyElementRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RoutineBodyElementRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      routineId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}routine_id'],
      )!,
      elementId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}element_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      flatFoot: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}flat_foot'],
      )!,
      slowTurn: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}slow_turn'],
      )!,
      extraRotations: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}extra_rotations'],
      )!,
      seriesCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}series_count'],
      )!,
      manualValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}manual_value'],
      ),
      customName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}custom_name'],
      ),
      customGroup: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}custom_group'],
      ),
    );
  }

  @override
  $RoutineBodyElementsTable createAlias(String alias) {
    return $RoutineBodyElementsTable(attachedDatabase, alias);
  }
}

class RoutineBodyElementRow extends DataClass
    implements Insertable<RoutineBodyElementRow> {
  final int id;
  final String routineId;

  /// Catalogue id, or `custom` for an element the user entered.
  final String elementId;
  final int position;
  final bool flatFoot;
  final bool slowTurn;
  final int extraRotations;

  /// Identical elements performed in a series (1 = none). Added in v5.
  final int seriesCount;

  /// A value entered by the user, in hundredths. Null when not set.
  final int? manualValue;
  final String? customName;
  final String? customGroup;
  const RoutineBodyElementRow({
    required this.id,
    required this.routineId,
    required this.elementId,
    required this.position,
    required this.flatFoot,
    required this.slowTurn,
    required this.extraRotations,
    required this.seriesCount,
    this.manualValue,
    this.customName,
    this.customGroup,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['routine_id'] = Variable<String>(routineId);
    map['element_id'] = Variable<String>(elementId);
    map['position'] = Variable<int>(position);
    map['flat_foot'] = Variable<bool>(flatFoot);
    map['slow_turn'] = Variable<bool>(slowTurn);
    map['extra_rotations'] = Variable<int>(extraRotations);
    map['series_count'] = Variable<int>(seriesCount);
    if (!nullToAbsent || manualValue != null) {
      map['manual_value'] = Variable<int>(manualValue);
    }
    if (!nullToAbsent || customName != null) {
      map['custom_name'] = Variable<String>(customName);
    }
    if (!nullToAbsent || customGroup != null) {
      map['custom_group'] = Variable<String>(customGroup);
    }
    return map;
  }

  RoutineBodyElementsCompanion toCompanion(bool nullToAbsent) {
    return RoutineBodyElementsCompanion(
      id: Value(id),
      routineId: Value(routineId),
      elementId: Value(elementId),
      position: Value(position),
      flatFoot: Value(flatFoot),
      slowTurn: Value(slowTurn),
      extraRotations: Value(extraRotations),
      seriesCount: Value(seriesCount),
      manualValue: manualValue == null && nullToAbsent
          ? const Value.absent()
          : Value(manualValue),
      customName: customName == null && nullToAbsent
          ? const Value.absent()
          : Value(customName),
      customGroup: customGroup == null && nullToAbsent
          ? const Value.absent()
          : Value(customGroup),
    );
  }

  factory RoutineBodyElementRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RoutineBodyElementRow(
      id: serializer.fromJson<int>(json['id']),
      routineId: serializer.fromJson<String>(json['routineId']),
      elementId: serializer.fromJson<String>(json['elementId']),
      position: serializer.fromJson<int>(json['position']),
      flatFoot: serializer.fromJson<bool>(json['flatFoot']),
      slowTurn: serializer.fromJson<bool>(json['slowTurn']),
      extraRotations: serializer.fromJson<int>(json['extraRotations']),
      seriesCount: serializer.fromJson<int>(json['seriesCount']),
      manualValue: serializer.fromJson<int?>(json['manualValue']),
      customName: serializer.fromJson<String?>(json['customName']),
      customGroup: serializer.fromJson<String?>(json['customGroup']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'routineId': serializer.toJson<String>(routineId),
      'elementId': serializer.toJson<String>(elementId),
      'position': serializer.toJson<int>(position),
      'flatFoot': serializer.toJson<bool>(flatFoot),
      'slowTurn': serializer.toJson<bool>(slowTurn),
      'extraRotations': serializer.toJson<int>(extraRotations),
      'seriesCount': serializer.toJson<int>(seriesCount),
      'manualValue': serializer.toJson<int?>(manualValue),
      'customName': serializer.toJson<String?>(customName),
      'customGroup': serializer.toJson<String?>(customGroup),
    };
  }

  RoutineBodyElementRow copyWith({
    int? id,
    String? routineId,
    String? elementId,
    int? position,
    bool? flatFoot,
    bool? slowTurn,
    int? extraRotations,
    int? seriesCount,
    Value<int?> manualValue = const Value.absent(),
    Value<String?> customName = const Value.absent(),
    Value<String?> customGroup = const Value.absent(),
  }) => RoutineBodyElementRow(
    id: id ?? this.id,
    routineId: routineId ?? this.routineId,
    elementId: elementId ?? this.elementId,
    position: position ?? this.position,
    flatFoot: flatFoot ?? this.flatFoot,
    slowTurn: slowTurn ?? this.slowTurn,
    extraRotations: extraRotations ?? this.extraRotations,
    seriesCount: seriesCount ?? this.seriesCount,
    manualValue: manualValue.present ? manualValue.value : this.manualValue,
    customName: customName.present ? customName.value : this.customName,
    customGroup: customGroup.present ? customGroup.value : this.customGroup,
  );
  RoutineBodyElementRow copyWithCompanion(RoutineBodyElementsCompanion data) {
    return RoutineBodyElementRow(
      id: data.id.present ? data.id.value : this.id,
      routineId: data.routineId.present ? data.routineId.value : this.routineId,
      elementId: data.elementId.present ? data.elementId.value : this.elementId,
      position: data.position.present ? data.position.value : this.position,
      flatFoot: data.flatFoot.present ? data.flatFoot.value : this.flatFoot,
      slowTurn: data.slowTurn.present ? data.slowTurn.value : this.slowTurn,
      extraRotations: data.extraRotations.present
          ? data.extraRotations.value
          : this.extraRotations,
      seriesCount: data.seriesCount.present
          ? data.seriesCount.value
          : this.seriesCount,
      manualValue: data.manualValue.present
          ? data.manualValue.value
          : this.manualValue,
      customName: data.customName.present
          ? data.customName.value
          : this.customName,
      customGroup: data.customGroup.present
          ? data.customGroup.value
          : this.customGroup,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RoutineBodyElementRow(')
          ..write('id: $id, ')
          ..write('routineId: $routineId, ')
          ..write('elementId: $elementId, ')
          ..write('position: $position, ')
          ..write('flatFoot: $flatFoot, ')
          ..write('slowTurn: $slowTurn, ')
          ..write('extraRotations: $extraRotations, ')
          ..write('seriesCount: $seriesCount, ')
          ..write('manualValue: $manualValue, ')
          ..write('customName: $customName, ')
          ..write('customGroup: $customGroup')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    routineId,
    elementId,
    position,
    flatFoot,
    slowTurn,
    extraRotations,
    seriesCount,
    manualValue,
    customName,
    customGroup,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RoutineBodyElementRow &&
          other.id == this.id &&
          other.routineId == this.routineId &&
          other.elementId == this.elementId &&
          other.position == this.position &&
          other.flatFoot == this.flatFoot &&
          other.slowTurn == this.slowTurn &&
          other.extraRotations == this.extraRotations &&
          other.seriesCount == this.seriesCount &&
          other.manualValue == this.manualValue &&
          other.customName == this.customName &&
          other.customGroup == this.customGroup);
}

class RoutineBodyElementsCompanion
    extends UpdateCompanion<RoutineBodyElementRow> {
  final Value<int> id;
  final Value<String> routineId;
  final Value<String> elementId;
  final Value<int> position;
  final Value<bool> flatFoot;
  final Value<bool> slowTurn;
  final Value<int> extraRotations;
  final Value<int> seriesCount;
  final Value<int?> manualValue;
  final Value<String?> customName;
  final Value<String?> customGroup;
  const RoutineBodyElementsCompanion({
    this.id = const Value.absent(),
    this.routineId = const Value.absent(),
    this.elementId = const Value.absent(),
    this.position = const Value.absent(),
    this.flatFoot = const Value.absent(),
    this.slowTurn = const Value.absent(),
    this.extraRotations = const Value.absent(),
    this.seriesCount = const Value.absent(),
    this.manualValue = const Value.absent(),
    this.customName = const Value.absent(),
    this.customGroup = const Value.absent(),
  });
  RoutineBodyElementsCompanion.insert({
    this.id = const Value.absent(),
    required String routineId,
    required String elementId,
    required int position,
    this.flatFoot = const Value.absent(),
    this.slowTurn = const Value.absent(),
    this.extraRotations = const Value.absent(),
    this.seriesCount = const Value.absent(),
    this.manualValue = const Value.absent(),
    this.customName = const Value.absent(),
    this.customGroup = const Value.absent(),
  }) : routineId = Value(routineId),
       elementId = Value(elementId),
       position = Value(position);
  static Insertable<RoutineBodyElementRow> custom({
    Expression<int>? id,
    Expression<String>? routineId,
    Expression<String>? elementId,
    Expression<int>? position,
    Expression<bool>? flatFoot,
    Expression<bool>? slowTurn,
    Expression<int>? extraRotations,
    Expression<int>? seriesCount,
    Expression<int>? manualValue,
    Expression<String>? customName,
    Expression<String>? customGroup,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (routineId != null) 'routine_id': routineId,
      if (elementId != null) 'element_id': elementId,
      if (position != null) 'position': position,
      if (flatFoot != null) 'flat_foot': flatFoot,
      if (slowTurn != null) 'slow_turn': slowTurn,
      if (extraRotations != null) 'extra_rotations': extraRotations,
      if (seriesCount != null) 'series_count': seriesCount,
      if (manualValue != null) 'manual_value': manualValue,
      if (customName != null) 'custom_name': customName,
      if (customGroup != null) 'custom_group': customGroup,
    });
  }

  RoutineBodyElementsCompanion copyWith({
    Value<int>? id,
    Value<String>? routineId,
    Value<String>? elementId,
    Value<int>? position,
    Value<bool>? flatFoot,
    Value<bool>? slowTurn,
    Value<int>? extraRotations,
    Value<int>? seriesCount,
    Value<int?>? manualValue,
    Value<String?>? customName,
    Value<String?>? customGroup,
  }) {
    return RoutineBodyElementsCompanion(
      id: id ?? this.id,
      routineId: routineId ?? this.routineId,
      elementId: elementId ?? this.elementId,
      position: position ?? this.position,
      flatFoot: flatFoot ?? this.flatFoot,
      slowTurn: slowTurn ?? this.slowTurn,
      extraRotations: extraRotations ?? this.extraRotations,
      seriesCount: seriesCount ?? this.seriesCount,
      manualValue: manualValue ?? this.manualValue,
      customName: customName ?? this.customName,
      customGroup: customGroup ?? this.customGroup,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (routineId.present) {
      map['routine_id'] = Variable<String>(routineId.value);
    }
    if (elementId.present) {
      map['element_id'] = Variable<String>(elementId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (flatFoot.present) {
      map['flat_foot'] = Variable<bool>(flatFoot.value);
    }
    if (slowTurn.present) {
      map['slow_turn'] = Variable<bool>(slowTurn.value);
    }
    if (extraRotations.present) {
      map['extra_rotations'] = Variable<int>(extraRotations.value);
    }
    if (seriesCount.present) {
      map['series_count'] = Variable<int>(seriesCount.value);
    }
    if (manualValue.present) {
      map['manual_value'] = Variable<int>(manualValue.value);
    }
    if (customName.present) {
      map['custom_name'] = Variable<String>(customName.value);
    }
    if (customGroup.present) {
      map['custom_group'] = Variable<String>(customGroup.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoutineBodyElementsCompanion(')
          ..write('id: $id, ')
          ..write('routineId: $routineId, ')
          ..write('elementId: $elementId, ')
          ..write('position: $position, ')
          ..write('flatFoot: $flatFoot, ')
          ..write('slowTurn: $slowTurn, ')
          ..write('extraRotations: $extraRotations, ')
          ..write('seriesCount: $seriesCount, ')
          ..write('manualValue: $manualValue, ')
          ..write('customName: $customName, ')
          ..write('customGroup: $customGroup')
          ..write(')'))
        .toString();
  }
}

class $RoutineRisksTable extends RoutineRisks
    with TableInfo<$RoutineRisksTable, RoutineRiskRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoutineRisksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _routineIdMeta = const VerificationMeta(
    'routineId',
  );
  @override
  late final GeneratedColumn<String> routineId = GeneratedColumn<String>(
    'routine_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES routines (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _rotationOptionIdMeta = const VerificationMeta(
    'rotationOptionId',
  );
  @override
  late final GeneratedColumn<String> rotationOptionId = GeneratedColumn<String>(
    'rotation_option_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    routineId,
    rotationOptionId,
    position,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'routine_risks';
  @override
  VerificationContext validateIntegrity(
    Insertable<RoutineRiskRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('routine_id')) {
      context.handle(
        _routineIdMeta,
        routineId.isAcceptableOrUnknown(data['routine_id']!, _routineIdMeta),
      );
    } else if (isInserting) {
      context.missing(_routineIdMeta);
    }
    if (data.containsKey('rotation_option_id')) {
      context.handle(
        _rotationOptionIdMeta,
        rotationOptionId.isAcceptableOrUnknown(
          data['rotation_option_id']!,
          _rotationOptionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_rotationOptionIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RoutineRiskRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RoutineRiskRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      routineId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}routine_id'],
      )!,
      rotationOptionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rotation_option_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
    );
  }

  @override
  $RoutineRisksTable createAlias(String alias) {
    return $RoutineRisksTable(attachedDatabase, alias);
  }
}

class RoutineRiskRow extends DataClass implements Insertable<RoutineRiskRow> {
  final int id;
  final String routineId;
  final String rotationOptionId;
  final int position;
  const RoutineRiskRow({
    required this.id,
    required this.routineId,
    required this.rotationOptionId,
    required this.position,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['routine_id'] = Variable<String>(routineId);
    map['rotation_option_id'] = Variable<String>(rotationOptionId);
    map['position'] = Variable<int>(position);
    return map;
  }

  RoutineRisksCompanion toCompanion(bool nullToAbsent) {
    return RoutineRisksCompanion(
      id: Value(id),
      routineId: Value(routineId),
      rotationOptionId: Value(rotationOptionId),
      position: Value(position),
    );
  }

  factory RoutineRiskRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RoutineRiskRow(
      id: serializer.fromJson<int>(json['id']),
      routineId: serializer.fromJson<String>(json['routineId']),
      rotationOptionId: serializer.fromJson<String>(json['rotationOptionId']),
      position: serializer.fromJson<int>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'routineId': serializer.toJson<String>(routineId),
      'rotationOptionId': serializer.toJson<String>(rotationOptionId),
      'position': serializer.toJson<int>(position),
    };
  }

  RoutineRiskRow copyWith({
    int? id,
    String? routineId,
    String? rotationOptionId,
    int? position,
  }) => RoutineRiskRow(
    id: id ?? this.id,
    routineId: routineId ?? this.routineId,
    rotationOptionId: rotationOptionId ?? this.rotationOptionId,
    position: position ?? this.position,
  );
  RoutineRiskRow copyWithCompanion(RoutineRisksCompanion data) {
    return RoutineRiskRow(
      id: data.id.present ? data.id.value : this.id,
      routineId: data.routineId.present ? data.routineId.value : this.routineId,
      rotationOptionId: data.rotationOptionId.present
          ? data.rotationOptionId.value
          : this.rotationOptionId,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RoutineRiskRow(')
          ..write('id: $id, ')
          ..write('routineId: $routineId, ')
          ..write('rotationOptionId: $rotationOptionId, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, routineId, rotationOptionId, position);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RoutineRiskRow &&
          other.id == this.id &&
          other.routineId == this.routineId &&
          other.rotationOptionId == this.rotationOptionId &&
          other.position == this.position);
}

class RoutineRisksCompanion extends UpdateCompanion<RoutineRiskRow> {
  final Value<int> id;
  final Value<String> routineId;
  final Value<String> rotationOptionId;
  final Value<int> position;
  const RoutineRisksCompanion({
    this.id = const Value.absent(),
    this.routineId = const Value.absent(),
    this.rotationOptionId = const Value.absent(),
    this.position = const Value.absent(),
  });
  RoutineRisksCompanion.insert({
    this.id = const Value.absent(),
    required String routineId,
    required String rotationOptionId,
    required int position,
  }) : routineId = Value(routineId),
       rotationOptionId = Value(rotationOptionId),
       position = Value(position);
  static Insertable<RoutineRiskRow> custom({
    Expression<int>? id,
    Expression<String>? routineId,
    Expression<String>? rotationOptionId,
    Expression<int>? position,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (routineId != null) 'routine_id': routineId,
      if (rotationOptionId != null) 'rotation_option_id': rotationOptionId,
      if (position != null) 'position': position,
    });
  }

  RoutineRisksCompanion copyWith({
    Value<int>? id,
    Value<String>? routineId,
    Value<String>? rotationOptionId,
    Value<int>? position,
  }) {
    return RoutineRisksCompanion(
      id: id ?? this.id,
      routineId: routineId ?? this.routineId,
      rotationOptionId: rotationOptionId ?? this.rotationOptionId,
      position: position ?? this.position,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (routineId.present) {
      map['routine_id'] = Variable<String>(routineId.value);
    }
    if (rotationOptionId.present) {
      map['rotation_option_id'] = Variable<String>(rotationOptionId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoutineRisksCompanion(')
          ..write('id: $id, ')
          ..write('routineId: $routineId, ')
          ..write('rotationOptionId: $rotationOptionId, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }
}

class $RoutineRiskCriteriaTable extends RoutineRiskCriteria
    with TableInfo<$RoutineRiskCriteriaTable, RoutineRiskCriterionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoutineRiskCriteriaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _routineRiskIdMeta = const VerificationMeta(
    'routineRiskId',
  );
  @override
  late final GeneratedColumn<int> routineRiskId = GeneratedColumn<int>(
    'routine_risk_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES routine_risks (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _criterionIdMeta = const VerificationMeta(
    'criterionId',
  );
  @override
  late final GeneratedColumn<String> criterionId = GeneratedColumn<String>(
    'criterion_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    routineRiskId,
    criterionId,
    position,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'routine_risk_criteria';
  @override
  VerificationContext validateIntegrity(
    Insertable<RoutineRiskCriterionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('routine_risk_id')) {
      context.handle(
        _routineRiskIdMeta,
        routineRiskId.isAcceptableOrUnknown(
          data['routine_risk_id']!,
          _routineRiskIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_routineRiskIdMeta);
    }
    if (data.containsKey('criterion_id')) {
      context.handle(
        _criterionIdMeta,
        criterionId.isAcceptableOrUnknown(
          data['criterion_id']!,
          _criterionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_criterionIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RoutineRiskCriterionRow map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RoutineRiskCriterionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      routineRiskId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}routine_risk_id'],
      )!,
      criterionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}criterion_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
    );
  }

  @override
  $RoutineRiskCriteriaTable createAlias(String alias) {
    return $RoutineRiskCriteriaTable(attachedDatabase, alias);
  }
}

class RoutineRiskCriterionRow extends DataClass
    implements Insertable<RoutineRiskCriterionRow> {
  final int id;
  final int routineRiskId;
  final String criterionId;
  final int position;
  const RoutineRiskCriterionRow({
    required this.id,
    required this.routineRiskId,
    required this.criterionId,
    required this.position,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['routine_risk_id'] = Variable<int>(routineRiskId);
    map['criterion_id'] = Variable<String>(criterionId);
    map['position'] = Variable<int>(position);
    return map;
  }

  RoutineRiskCriteriaCompanion toCompanion(bool nullToAbsent) {
    return RoutineRiskCriteriaCompanion(
      id: Value(id),
      routineRiskId: Value(routineRiskId),
      criterionId: Value(criterionId),
      position: Value(position),
    );
  }

  factory RoutineRiskCriterionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RoutineRiskCriterionRow(
      id: serializer.fromJson<int>(json['id']),
      routineRiskId: serializer.fromJson<int>(json['routineRiskId']),
      criterionId: serializer.fromJson<String>(json['criterionId']),
      position: serializer.fromJson<int>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'routineRiskId': serializer.toJson<int>(routineRiskId),
      'criterionId': serializer.toJson<String>(criterionId),
      'position': serializer.toJson<int>(position),
    };
  }

  RoutineRiskCriterionRow copyWith({
    int? id,
    int? routineRiskId,
    String? criterionId,
    int? position,
  }) => RoutineRiskCriterionRow(
    id: id ?? this.id,
    routineRiskId: routineRiskId ?? this.routineRiskId,
    criterionId: criterionId ?? this.criterionId,
    position: position ?? this.position,
  );
  RoutineRiskCriterionRow copyWithCompanion(RoutineRiskCriteriaCompanion data) {
    return RoutineRiskCriterionRow(
      id: data.id.present ? data.id.value : this.id,
      routineRiskId: data.routineRiskId.present
          ? data.routineRiskId.value
          : this.routineRiskId,
      criterionId: data.criterionId.present
          ? data.criterionId.value
          : this.criterionId,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RoutineRiskCriterionRow(')
          ..write('id: $id, ')
          ..write('routineRiskId: $routineRiskId, ')
          ..write('criterionId: $criterionId, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, routineRiskId, criterionId, position);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RoutineRiskCriterionRow &&
          other.id == this.id &&
          other.routineRiskId == this.routineRiskId &&
          other.criterionId == this.criterionId &&
          other.position == this.position);
}

class RoutineRiskCriteriaCompanion
    extends UpdateCompanion<RoutineRiskCriterionRow> {
  final Value<int> id;
  final Value<int> routineRiskId;
  final Value<String> criterionId;
  final Value<int> position;
  const RoutineRiskCriteriaCompanion({
    this.id = const Value.absent(),
    this.routineRiskId = const Value.absent(),
    this.criterionId = const Value.absent(),
    this.position = const Value.absent(),
  });
  RoutineRiskCriteriaCompanion.insert({
    this.id = const Value.absent(),
    required int routineRiskId,
    required String criterionId,
    required int position,
  }) : routineRiskId = Value(routineRiskId),
       criterionId = Value(criterionId),
       position = Value(position);
  static Insertable<RoutineRiskCriterionRow> custom({
    Expression<int>? id,
    Expression<int>? routineRiskId,
    Expression<String>? criterionId,
    Expression<int>? position,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (routineRiskId != null) 'routine_risk_id': routineRiskId,
      if (criterionId != null) 'criterion_id': criterionId,
      if (position != null) 'position': position,
    });
  }

  RoutineRiskCriteriaCompanion copyWith({
    Value<int>? id,
    Value<int>? routineRiskId,
    Value<String>? criterionId,
    Value<int>? position,
  }) {
    return RoutineRiskCriteriaCompanion(
      id: id ?? this.id,
      routineRiskId: routineRiskId ?? this.routineRiskId,
      criterionId: criterionId ?? this.criterionId,
      position: position ?? this.position,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (routineRiskId.present) {
      map['routine_risk_id'] = Variable<int>(routineRiskId.value);
    }
    if (criterionId.present) {
      map['criterion_id'] = Variable<String>(criterionId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoutineRiskCriteriaCompanion(')
          ..write('id: $id, ')
          ..write('routineRiskId: $routineRiskId, ')
          ..write('criterionId: $criterionId, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }
}

class $RoutineApparatusDifficultiesTable extends RoutineApparatusDifficulties
    with
        TableInfo<
          $RoutineApparatusDifficultiesTable,
          RoutineApparatusDifficultyRow
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoutineApparatusDifficultiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _routineIdMeta = const VerificationMeta(
    'routineId',
  );
  @override
  late final GeneratedColumn<String> routineId = GeneratedColumn<String>(
    'routine_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES routines (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _baseIdMeta = const VerificationMeta('baseId');
  @override
  late final GeneratedColumn<String> baseId = GeneratedColumn<String>(
    'base_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _secondBaseIdMeta = const VerificationMeta(
    'secondBaseId',
  );
  @override
  late final GeneratedColumn<String> secondBaseId = GeneratedColumn<String>(
    'second_base_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _criteriaMeta = const VerificationMeta(
    'criteria',
  );
  @override
  late final GeneratedColumn<String> criteria = GeneratedColumn<String>(
    'criteria',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _preAcrobaticMeta = const VerificationMeta(
    'preAcrobatic',
  );
  @override
  late final GeneratedColumn<bool> preAcrobatic = GeneratedColumn<bool>(
    'pre_acrobatic',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pre_acrobatic" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _manualValueMeta = const VerificationMeta(
    'manualValue',
  );
  @override
  late final GeneratedColumn<int> manualValue = GeneratedColumn<int>(
    'manual_value',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _customNameMeta = const VerificationMeta(
    'customName',
  );
  @override
  late final GeneratedColumn<String> customName = GeneratedColumn<String>(
    'custom_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    routineId,
    position,
    baseId,
    secondBaseId,
    criteria,
    preAcrobatic,
    manualValue,
    customName,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'routine_apparatus_difficulties';
  @override
  VerificationContext validateIntegrity(
    Insertable<RoutineApparatusDifficultyRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('routine_id')) {
      context.handle(
        _routineIdMeta,
        routineId.isAcceptableOrUnknown(data['routine_id']!, _routineIdMeta),
      );
    } else if (isInserting) {
      context.missing(_routineIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('base_id')) {
      context.handle(
        _baseIdMeta,
        baseId.isAcceptableOrUnknown(data['base_id']!, _baseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_baseIdMeta);
    }
    if (data.containsKey('second_base_id')) {
      context.handle(
        _secondBaseIdMeta,
        secondBaseId.isAcceptableOrUnknown(
          data['second_base_id']!,
          _secondBaseIdMeta,
        ),
      );
    }
    if (data.containsKey('criteria')) {
      context.handle(
        _criteriaMeta,
        criteria.isAcceptableOrUnknown(data['criteria']!, _criteriaMeta),
      );
    }
    if (data.containsKey('pre_acrobatic')) {
      context.handle(
        _preAcrobaticMeta,
        preAcrobatic.isAcceptableOrUnknown(
          data['pre_acrobatic']!,
          _preAcrobaticMeta,
        ),
      );
    }
    if (data.containsKey('manual_value')) {
      context.handle(
        _manualValueMeta,
        manualValue.isAcceptableOrUnknown(
          data['manual_value']!,
          _manualValueMeta,
        ),
      );
    }
    if (data.containsKey('custom_name')) {
      context.handle(
        _customNameMeta,
        customName.isAcceptableOrUnknown(data['custom_name']!, _customNameMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RoutineApparatusDifficultyRow map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RoutineApparatusDifficultyRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      routineId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}routine_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      baseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}base_id'],
      )!,
      secondBaseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}second_base_id'],
      ),
      criteria: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}criteria'],
      )!,
      preAcrobatic: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pre_acrobatic'],
      )!,
      manualValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}manual_value'],
      ),
      customName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}custom_name'],
      ),
    );
  }

  @override
  $RoutineApparatusDifficultiesTable createAlias(String alias) {
    return $RoutineApparatusDifficultiesTable(attachedDatabase, alias);
  }
}

class RoutineApparatusDifficultyRow extends DataClass
    implements Insertable<RoutineApparatusDifficultyRow> {
  final int id;
  final String routineId;
  final int position;

  /// Catalogue id of the base, or `custom` for a DA the user entered.
  final String baseId;

  /// Catalogue id of a 2nd base after a catch from a high throw, or null.
  final String? secondBaseId;

  /// Criteria performed, as comma-separated `DaCriterion.name`s (e.g.
  /// `outsideVisualField,rotation`). Empty for none.
  final String criteria;

  /// The "rotation" criterion is a pre-acrobatic element.
  final bool preAcrobatic;

  /// A value entered by the user, in hundredths. Null when not set.
  final int? manualValue;

  /// Name of a custom DA. Null otherwise.
  final String? customName;
  const RoutineApparatusDifficultyRow({
    required this.id,
    required this.routineId,
    required this.position,
    required this.baseId,
    this.secondBaseId,
    required this.criteria,
    required this.preAcrobatic,
    this.manualValue,
    this.customName,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['routine_id'] = Variable<String>(routineId);
    map['position'] = Variable<int>(position);
    map['base_id'] = Variable<String>(baseId);
    if (!nullToAbsent || secondBaseId != null) {
      map['second_base_id'] = Variable<String>(secondBaseId);
    }
    map['criteria'] = Variable<String>(criteria);
    map['pre_acrobatic'] = Variable<bool>(preAcrobatic);
    if (!nullToAbsent || manualValue != null) {
      map['manual_value'] = Variable<int>(manualValue);
    }
    if (!nullToAbsent || customName != null) {
      map['custom_name'] = Variable<String>(customName);
    }
    return map;
  }

  RoutineApparatusDifficultiesCompanion toCompanion(bool nullToAbsent) {
    return RoutineApparatusDifficultiesCompanion(
      id: Value(id),
      routineId: Value(routineId),
      position: Value(position),
      baseId: Value(baseId),
      secondBaseId: secondBaseId == null && nullToAbsent
          ? const Value.absent()
          : Value(secondBaseId),
      criteria: Value(criteria),
      preAcrobatic: Value(preAcrobatic),
      manualValue: manualValue == null && nullToAbsent
          ? const Value.absent()
          : Value(manualValue),
      customName: customName == null && nullToAbsent
          ? const Value.absent()
          : Value(customName),
    );
  }

  factory RoutineApparatusDifficultyRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RoutineApparatusDifficultyRow(
      id: serializer.fromJson<int>(json['id']),
      routineId: serializer.fromJson<String>(json['routineId']),
      position: serializer.fromJson<int>(json['position']),
      baseId: serializer.fromJson<String>(json['baseId']),
      secondBaseId: serializer.fromJson<String?>(json['secondBaseId']),
      criteria: serializer.fromJson<String>(json['criteria']),
      preAcrobatic: serializer.fromJson<bool>(json['preAcrobatic']),
      manualValue: serializer.fromJson<int?>(json['manualValue']),
      customName: serializer.fromJson<String?>(json['customName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'routineId': serializer.toJson<String>(routineId),
      'position': serializer.toJson<int>(position),
      'baseId': serializer.toJson<String>(baseId),
      'secondBaseId': serializer.toJson<String?>(secondBaseId),
      'criteria': serializer.toJson<String>(criteria),
      'preAcrobatic': serializer.toJson<bool>(preAcrobatic),
      'manualValue': serializer.toJson<int?>(manualValue),
      'customName': serializer.toJson<String?>(customName),
    };
  }

  RoutineApparatusDifficultyRow copyWith({
    int? id,
    String? routineId,
    int? position,
    String? baseId,
    Value<String?> secondBaseId = const Value.absent(),
    String? criteria,
    bool? preAcrobatic,
    Value<int?> manualValue = const Value.absent(),
    Value<String?> customName = const Value.absent(),
  }) => RoutineApparatusDifficultyRow(
    id: id ?? this.id,
    routineId: routineId ?? this.routineId,
    position: position ?? this.position,
    baseId: baseId ?? this.baseId,
    secondBaseId: secondBaseId.present ? secondBaseId.value : this.secondBaseId,
    criteria: criteria ?? this.criteria,
    preAcrobatic: preAcrobatic ?? this.preAcrobatic,
    manualValue: manualValue.present ? manualValue.value : this.manualValue,
    customName: customName.present ? customName.value : this.customName,
  );
  RoutineApparatusDifficultyRow copyWithCompanion(
    RoutineApparatusDifficultiesCompanion data,
  ) {
    return RoutineApparatusDifficultyRow(
      id: data.id.present ? data.id.value : this.id,
      routineId: data.routineId.present ? data.routineId.value : this.routineId,
      position: data.position.present ? data.position.value : this.position,
      baseId: data.baseId.present ? data.baseId.value : this.baseId,
      secondBaseId: data.secondBaseId.present
          ? data.secondBaseId.value
          : this.secondBaseId,
      criteria: data.criteria.present ? data.criteria.value : this.criteria,
      preAcrobatic: data.preAcrobatic.present
          ? data.preAcrobatic.value
          : this.preAcrobatic,
      manualValue: data.manualValue.present
          ? data.manualValue.value
          : this.manualValue,
      customName: data.customName.present
          ? data.customName.value
          : this.customName,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RoutineApparatusDifficultyRow(')
          ..write('id: $id, ')
          ..write('routineId: $routineId, ')
          ..write('position: $position, ')
          ..write('baseId: $baseId, ')
          ..write('secondBaseId: $secondBaseId, ')
          ..write('criteria: $criteria, ')
          ..write('preAcrobatic: $preAcrobatic, ')
          ..write('manualValue: $manualValue, ')
          ..write('customName: $customName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    routineId,
    position,
    baseId,
    secondBaseId,
    criteria,
    preAcrobatic,
    manualValue,
    customName,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RoutineApparatusDifficultyRow &&
          other.id == this.id &&
          other.routineId == this.routineId &&
          other.position == this.position &&
          other.baseId == this.baseId &&
          other.secondBaseId == this.secondBaseId &&
          other.criteria == this.criteria &&
          other.preAcrobatic == this.preAcrobatic &&
          other.manualValue == this.manualValue &&
          other.customName == this.customName);
}

class RoutineApparatusDifficultiesCompanion
    extends UpdateCompanion<RoutineApparatusDifficultyRow> {
  final Value<int> id;
  final Value<String> routineId;
  final Value<int> position;
  final Value<String> baseId;
  final Value<String?> secondBaseId;
  final Value<String> criteria;
  final Value<bool> preAcrobatic;
  final Value<int?> manualValue;
  final Value<String?> customName;
  const RoutineApparatusDifficultiesCompanion({
    this.id = const Value.absent(),
    this.routineId = const Value.absent(),
    this.position = const Value.absent(),
    this.baseId = const Value.absent(),
    this.secondBaseId = const Value.absent(),
    this.criteria = const Value.absent(),
    this.preAcrobatic = const Value.absent(),
    this.manualValue = const Value.absent(),
    this.customName = const Value.absent(),
  });
  RoutineApparatusDifficultiesCompanion.insert({
    this.id = const Value.absent(),
    required String routineId,
    required int position,
    required String baseId,
    this.secondBaseId = const Value.absent(),
    this.criteria = const Value.absent(),
    this.preAcrobatic = const Value.absent(),
    this.manualValue = const Value.absent(),
    this.customName = const Value.absent(),
  }) : routineId = Value(routineId),
       position = Value(position),
       baseId = Value(baseId);
  static Insertable<RoutineApparatusDifficultyRow> custom({
    Expression<int>? id,
    Expression<String>? routineId,
    Expression<int>? position,
    Expression<String>? baseId,
    Expression<String>? secondBaseId,
    Expression<String>? criteria,
    Expression<bool>? preAcrobatic,
    Expression<int>? manualValue,
    Expression<String>? customName,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (routineId != null) 'routine_id': routineId,
      if (position != null) 'position': position,
      if (baseId != null) 'base_id': baseId,
      if (secondBaseId != null) 'second_base_id': secondBaseId,
      if (criteria != null) 'criteria': criteria,
      if (preAcrobatic != null) 'pre_acrobatic': preAcrobatic,
      if (manualValue != null) 'manual_value': manualValue,
      if (customName != null) 'custom_name': customName,
    });
  }

  RoutineApparatusDifficultiesCompanion copyWith({
    Value<int>? id,
    Value<String>? routineId,
    Value<int>? position,
    Value<String>? baseId,
    Value<String?>? secondBaseId,
    Value<String>? criteria,
    Value<bool>? preAcrobatic,
    Value<int?>? manualValue,
    Value<String?>? customName,
  }) {
    return RoutineApparatusDifficultiesCompanion(
      id: id ?? this.id,
      routineId: routineId ?? this.routineId,
      position: position ?? this.position,
      baseId: baseId ?? this.baseId,
      secondBaseId: secondBaseId ?? this.secondBaseId,
      criteria: criteria ?? this.criteria,
      preAcrobatic: preAcrobatic ?? this.preAcrobatic,
      manualValue: manualValue ?? this.manualValue,
      customName: customName ?? this.customName,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (routineId.present) {
      map['routine_id'] = Variable<String>(routineId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (baseId.present) {
      map['base_id'] = Variable<String>(baseId.value);
    }
    if (secondBaseId.present) {
      map['second_base_id'] = Variable<String>(secondBaseId.value);
    }
    if (criteria.present) {
      map['criteria'] = Variable<String>(criteria.value);
    }
    if (preAcrobatic.present) {
      map['pre_acrobatic'] = Variable<bool>(preAcrobatic.value);
    }
    if (manualValue.present) {
      map['manual_value'] = Variable<int>(manualValue.value);
    }
    if (customName.present) {
      map['custom_name'] = Variable<String>(customName.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoutineApparatusDifficultiesCompanion(')
          ..write('id: $id, ')
          ..write('routineId: $routineId, ')
          ..write('position: $position, ')
          ..write('baseId: $baseId, ')
          ..write('secondBaseId: $secondBaseId, ')
          ..write('criteria: $criteria, ')
          ..write('preAcrobatic: $preAcrobatic, ')
          ..write('manualValue: $manualValue, ')
          ..write('customName: $customName')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $RoutinesTable routines = $RoutinesTable(this);
  late final $RoutineBodyElementsTable routineBodyElements =
      $RoutineBodyElementsTable(this);
  late final $RoutineRisksTable routineRisks = $RoutineRisksTable(this);
  late final $RoutineRiskCriteriaTable routineRiskCriteria =
      $RoutineRiskCriteriaTable(this);
  late final $RoutineApparatusDifficultiesTable routineApparatusDifficulties =
      $RoutineApparatusDifficultiesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    routines,
    routineBodyElements,
    routineRisks,
    routineRiskCriteria,
    routineApparatusDifficulties,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'routines',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('routine_body_elements', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'routines',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('routine_risks', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'routine_risks',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('routine_risk_criteria', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'routines',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [
        TableUpdate('routine_apparatus_difficulties', kind: UpdateKind.delete),
      ],
    ),
  ]);
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$RoutinesTableCreateCompanionBuilder = RoutinesCompanion Function({
  required String id,
  required String name,
  required String rulesetId,
  Value<String?> apparatus,
  Value<String?> levelId,
  Value<int?> customDbMin,
  Value<int?> customDbMax,
  Value<int?> customRiskMin,
  Value<int?> customRiskMax,
  Value<int?> customDaMin,
  Value<int?> customDaMax,
  Value<String?> customRequiredBodyGroups,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$RoutinesTableUpdateCompanionBuilder = RoutinesCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> rulesetId,
  Value<String?> apparatus,
  Value<String?> levelId,
  Value<int?> customDbMin,
  Value<int?> customDbMax,
  Value<int?> customRiskMin,
  Value<int?> customRiskMax,
  Value<int?> customDaMin,
  Value<int?> customDaMax,
  Value<String?> customRequiredBodyGroups,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$RoutinesTableReferences
    extends BaseReferences<_$AppDatabase, $RoutinesTable, RoutineRow> {
  $$RoutinesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<
    $RoutineBodyElementsTable,
    List<RoutineBodyElementRow>
  >
  _routineBodyElementsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.routineBodyElements,
        aliasName: 'routines__id__routine_body_elements__routine_id',
      );

  $$RoutineBodyElementsTableProcessedTableManager get routineBodyElementsRefs {
    final manager = $$RoutineBodyElementsTableTableManager(
      $_db,
      $_db.routineBodyElements,
    ).filter((f) => f.routineId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _routineBodyElementsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RoutineRisksTable, List<RoutineRiskRow>>
  _routineRisksRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.routineRisks,
    aliasName: 'routines__id__routine_risks__routine_id',
  );

  $$RoutineRisksTableProcessedTableManager get routineRisksRefs {
    final manager = $$RoutineRisksTableTableManager(
      $_db,
      $_db.routineRisks,
    ).filter((f) => f.routineId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_routineRisksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $RoutineApparatusDifficultiesTable,
    List<RoutineApparatusDifficultyRow>
  >
  _routineApparatusDifficultiesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.routineApparatusDifficulties,
        aliasName: 'routines__id__routine_apparatus_difficulties__routine_id',
      );

  $$RoutineApparatusDifficultiesTableProcessedTableManager
  get routineApparatusDifficultiesRefs {
    final manager = $$RoutineApparatusDifficultiesTableTableManager(
      $_db,
      $_db.routineApparatusDifficulties,
    ).filter((f) => f.routineId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _routineApparatusDifficultiesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RoutinesTableFilterComposer
    extends Composer<_$AppDatabase, $RoutinesTable> {
  $$RoutinesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rulesetId => $composableBuilder(
    column: $table.rulesetId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get apparatus => $composableBuilder(
    column: $table.apparatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get levelId => $composableBuilder(
    column: $table.levelId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get customDbMin => $composableBuilder(
    column: $table.customDbMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get customDbMax => $composableBuilder(
    column: $table.customDbMax,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get customRiskMin => $composableBuilder(
    column: $table.customRiskMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get customRiskMax => $composableBuilder(
    column: $table.customRiskMax,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get customDaMin => $composableBuilder(
    column: $table.customDaMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get customDaMax => $composableBuilder(
    column: $table.customDaMax,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customRequiredBodyGroups => $composableBuilder(
    column: $table.customRequiredBodyGroups,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> routineBodyElementsRefs(
    Expression<bool> Function($$RoutineBodyElementsTableFilterComposer f) f,
  ) {
    final $$RoutineBodyElementsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.routineBodyElements,
      getReferencedColumn: (t) => t.routineId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutineBodyElementsTableFilterComposer(
            $db: $db,
            $table: $db.routineBodyElements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> routineRisksRefs(
    Expression<bool> Function($$RoutineRisksTableFilterComposer f) f,
  ) {
    final $$RoutineRisksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.routineRisks,
      getReferencedColumn: (t) => t.routineId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutineRisksTableFilterComposer(
            $db: $db,
            $table: $db.routineRisks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> routineApparatusDifficultiesRefs(
    Expression<bool> Function(
      $$RoutineApparatusDifficultiesTableFilterComposer f,
    )
    f,
  ) {
    final $$RoutineApparatusDifficultiesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.routineApparatusDifficulties,
          getReferencedColumn: (t) => t.routineId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RoutineApparatusDifficultiesTableFilterComposer(
                $db: $db,
                $table: $db.routineApparatusDifficulties,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$RoutinesTableOrderingComposer
    extends Composer<_$AppDatabase, $RoutinesTable> {
  $$RoutinesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rulesetId => $composableBuilder(
    column: $table.rulesetId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get apparatus => $composableBuilder(
    column: $table.apparatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get levelId => $composableBuilder(
    column: $table.levelId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get customDbMin => $composableBuilder(
    column: $table.customDbMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get customDbMax => $composableBuilder(
    column: $table.customDbMax,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get customRiskMin => $composableBuilder(
    column: $table.customRiskMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get customRiskMax => $composableBuilder(
    column: $table.customRiskMax,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get customDaMin => $composableBuilder(
    column: $table.customDaMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get customDaMax => $composableBuilder(
    column: $table.customDaMax,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customRequiredBodyGroups => $composableBuilder(
    column: $table.customRequiredBodyGroups,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RoutinesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RoutinesTable> {
  $$RoutinesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get rulesetId =>
      $composableBuilder(column: $table.rulesetId, builder: (column) => column);

  GeneratedColumn<String> get apparatus =>
      $composableBuilder(column: $table.apparatus, builder: (column) => column);

  GeneratedColumn<String> get levelId =>
      $composableBuilder(column: $table.levelId, builder: (column) => column);

  GeneratedColumn<int> get customDbMin => $composableBuilder(
    column: $table.customDbMin,
    builder: (column) => column,
  );

  GeneratedColumn<int> get customDbMax => $composableBuilder(
    column: $table.customDbMax,
    builder: (column) => column,
  );

  GeneratedColumn<int> get customRiskMin => $composableBuilder(
    column: $table.customRiskMin,
    builder: (column) => column,
  );

  GeneratedColumn<int> get customRiskMax => $composableBuilder(
    column: $table.customRiskMax,
    builder: (column) => column,
  );

  GeneratedColumn<int> get customDaMin => $composableBuilder(
    column: $table.customDaMin,
    builder: (column) => column,
  );

  GeneratedColumn<int> get customDaMax => $composableBuilder(
    column: $table.customDaMax,
    builder: (column) => column,
  );

  GeneratedColumn<String> get customRequiredBodyGroups => $composableBuilder(
    column: $table.customRequiredBodyGroups,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> routineBodyElementsRefs<T extends Object>(
    Expression<T> Function($$RoutineBodyElementsTableAnnotationComposer a) f,
  ) {
    final $$RoutineBodyElementsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.routineBodyElements,
          getReferencedColumn: (t) => t.routineId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RoutineBodyElementsTableAnnotationComposer(
                $db: $db,
                $table: $db.routineBodyElements,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> routineRisksRefs<T extends Object>(
    Expression<T> Function($$RoutineRisksTableAnnotationComposer a) f,
  ) {
    final $$RoutineRisksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.routineRisks,
      getReferencedColumn: (t) => t.routineId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutineRisksTableAnnotationComposer(
            $db: $db,
            $table: $db.routineRisks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> routineApparatusDifficultiesRefs<T extends Object>(
    Expression<T> Function(
      $$RoutineApparatusDifficultiesTableAnnotationComposer a,
    )
    f,
  ) {
    final $$RoutineApparatusDifficultiesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.routineApparatusDifficulties,
          getReferencedColumn: (t) => t.routineId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RoutineApparatusDifficultiesTableAnnotationComposer(
                $db: $db,
                $table: $db.routineApparatusDifficulties,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$RoutinesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RoutinesTable,
          RoutineRow,
          $$RoutinesTableFilterComposer,
          $$RoutinesTableOrderingComposer,
          $$RoutinesTableAnnotationComposer,
          $$RoutinesTableCreateCompanionBuilder,
          $$RoutinesTableUpdateCompanionBuilder,
          (RoutineRow, $$RoutinesTableReferences),
          RoutineRow,
          PrefetchHooks Function({
            bool routineBodyElementsRefs,
            bool routineRisksRefs,
            bool routineApparatusDifficultiesRefs,
          })
        > {
  $$RoutinesTableTableManager(_$AppDatabase db, $RoutinesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoutinesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RoutinesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoutinesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> rulesetId = const Value.absent(),
                Value<String?> apparatus = const Value.absent(),
                Value<String?> levelId = const Value.absent(),
                Value<int?> customDbMin = const Value.absent(),
                Value<int?> customDbMax = const Value.absent(),
                Value<int?> customRiskMin = const Value.absent(),
                Value<int?> customRiskMax = const Value.absent(),
                Value<int?> customDaMin = const Value.absent(),
                Value<int?> customDaMax = const Value.absent(),
                Value<String?> customRequiredBodyGroups = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RoutinesCompanion(
                id: id,
                name: name,
                rulesetId: rulesetId,
                apparatus: apparatus,
                levelId: levelId,
                customDbMin: customDbMin,
                customDbMax: customDbMax,
                customRiskMin: customRiskMin,
                customRiskMax: customRiskMax,
                customDaMin: customDaMin,
                customDaMax: customDaMax,
                customRequiredBodyGroups: customRequiredBodyGroups,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String rulesetId,
                Value<String?> apparatus = const Value.absent(),
                Value<String?> levelId = const Value.absent(),
                Value<int?> customDbMin = const Value.absent(),
                Value<int?> customDbMax = const Value.absent(),
                Value<int?> customRiskMin = const Value.absent(),
                Value<int?> customRiskMax = const Value.absent(),
                Value<int?> customDaMin = const Value.absent(),
                Value<int?> customDaMax = const Value.absent(),
                Value<String?> customRequiredBodyGroups = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => RoutinesCompanion.insert(
                id: id,
                name: name,
                rulesetId: rulesetId,
                apparatus: apparatus,
                levelId: levelId,
                customDbMin: customDbMin,
                customDbMax: customDbMax,
                customRiskMin: customRiskMin,
                customRiskMax: customRiskMax,
                customDaMin: customDaMin,
                customDaMax: customDaMax,
                customRequiredBodyGroups: customRequiredBodyGroups,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RoutinesTable, RoutineRow>(table),
                  $$RoutinesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                routineBodyElementsRefs = false,
                routineRisksRefs = false,
                routineApparatusDifficultiesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (routineBodyElementsRefs) db.routineBodyElements,
                    if (routineRisksRefs) db.routineRisks,
                    if (routineApparatusDifficultiesRefs)
                      db.routineApparatusDifficulties,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (routineBodyElementsRefs)
                        await $_getPrefetchedDataByColumns<
                          RoutineRow,
                          $RoutinesTable,
                          RoutineBodyElementRow,
                          $RoutineBodyElementsTable
                        >(
                          currentTable: table,
                          referencedTable: $$RoutinesTableReferences
                              ._routineBodyElementsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RoutinesTableReferences(
                                db,
                                table,
                                p0,
                              ).routineBodyElementsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'routine_id',
                          typedResults: items,
                        ),
                      if (routineRisksRefs)
                        await $_getPrefetchedDataByColumns<
                          RoutineRow,
                          $RoutinesTable,
                          RoutineRiskRow,
                          $RoutineRisksTable
                        >(
                          currentTable: table,
                          referencedTable: $$RoutinesTableReferences
                              ._routineRisksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RoutinesTableReferences(
                                db,
                                table,
                                p0,
                              ).routineRisksRefs,
                          currentColumn: 'id',
                          referencedColumn: 'routine_id',
                          typedResults: items,
                        ),
                      if (routineApparatusDifficultiesRefs)
                        await $_getPrefetchedDataByColumns<
                          RoutineRow,
                          $RoutinesTable,
                          RoutineApparatusDifficultyRow,
                          $RoutineApparatusDifficultiesTable
                        >(
                          currentTable: table,
                          referencedTable: $$RoutinesTableReferences
                              ._routineApparatusDifficultiesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RoutinesTableReferences(
                                db,
                                table,
                                p0,
                              ).routineApparatusDifficultiesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'routine_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$RoutinesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RoutinesTable,
      RoutineRow,
      $$RoutinesTableFilterComposer,
      $$RoutinesTableOrderingComposer,
      $$RoutinesTableAnnotationComposer,
      $$RoutinesTableCreateCompanionBuilder,
      $$RoutinesTableUpdateCompanionBuilder,
      (RoutineRow, $$RoutinesTableReferences),
      RoutineRow,
      PrefetchHooks Function({
        bool routineBodyElementsRefs,
        bool routineRisksRefs,
        bool routineApparatusDifficultiesRefs,
      })
    >;
typedef $$RoutineBodyElementsTableCreateCompanionBuilder =
    RoutineBodyElementsCompanion Function({
      Value<int> id,
      required String routineId,
      required String elementId,
      required int position,
      Value<bool> flatFoot,
      Value<bool> slowTurn,
      Value<int> extraRotations,
      Value<int> seriesCount,
      Value<int?> manualValue,
      Value<String?> customName,
      Value<String?> customGroup,
    });
typedef $$RoutineBodyElementsTableUpdateCompanionBuilder =
    RoutineBodyElementsCompanion Function({
      Value<int> id,
      Value<String> routineId,
      Value<String> elementId,
      Value<int> position,
      Value<bool> flatFoot,
      Value<bool> slowTurn,
      Value<int> extraRotations,
      Value<int> seriesCount,
      Value<int?> manualValue,
      Value<String?> customName,
      Value<String?> customGroup,
    });

final class $$RoutineBodyElementsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $RoutineBodyElementsTable,
          RoutineBodyElementRow
        > {
  $$RoutineBodyElementsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $RoutinesTable _routineIdTable(_$AppDatabase db) => db.routines
      .createAlias('routine_body_elements__routine_id__routines__id');

  $$RoutinesTableProcessedTableManager get routineId {
    final $_column = $_itemColumn<String>('routine_id')!;

    final manager = $$RoutinesTableTableManager(
      $_db,
      $_db.routines,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_routineIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RoutineBodyElementsTableFilterComposer
    extends Composer<_$AppDatabase, $RoutineBodyElementsTable> {
  $$RoutineBodyElementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get elementId => $composableBuilder(
    column: $table.elementId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get flatFoot => $composableBuilder(
    column: $table.flatFoot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get slowTurn => $composableBuilder(
    column: $table.slowTurn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get extraRotations => $composableBuilder(
    column: $table.extraRotations,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get seriesCount => $composableBuilder(
    column: $table.seriesCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get manualValue => $composableBuilder(
    column: $table.manualValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customName => $composableBuilder(
    column: $table.customName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customGroup => $composableBuilder(
    column: $table.customGroup,
    builder: (column) => ColumnFilters(column),
  );

  $$RoutinesTableFilterComposer get routineId {
    final $$RoutinesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routineId,
      referencedTable: $db.routines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutinesTableFilterComposer(
            $db: $db,
            $table: $db.routines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RoutineBodyElementsTableOrderingComposer
    extends Composer<_$AppDatabase, $RoutineBodyElementsTable> {
  $$RoutineBodyElementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get elementId => $composableBuilder(
    column: $table.elementId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get flatFoot => $composableBuilder(
    column: $table.flatFoot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get slowTurn => $composableBuilder(
    column: $table.slowTurn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get extraRotations => $composableBuilder(
    column: $table.extraRotations,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get seriesCount => $composableBuilder(
    column: $table.seriesCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get manualValue => $composableBuilder(
    column: $table.manualValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customName => $composableBuilder(
    column: $table.customName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customGroup => $composableBuilder(
    column: $table.customGroup,
    builder: (column) => ColumnOrderings(column),
  );

  $$RoutinesTableOrderingComposer get routineId {
    final $$RoutinesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routineId,
      referencedTable: $db.routines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutinesTableOrderingComposer(
            $db: $db,
            $table: $db.routines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RoutineBodyElementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RoutineBodyElementsTable> {
  $$RoutineBodyElementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get elementId =>
      $composableBuilder(column: $table.elementId, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<bool> get flatFoot =>
      $composableBuilder(column: $table.flatFoot, builder: (column) => column);

  GeneratedColumn<bool> get slowTurn =>
      $composableBuilder(column: $table.slowTurn, builder: (column) => column);

  GeneratedColumn<int> get extraRotations => $composableBuilder(
    column: $table.extraRotations,
    builder: (column) => column,
  );

  GeneratedColumn<int> get seriesCount => $composableBuilder(
    column: $table.seriesCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get manualValue => $composableBuilder(
    column: $table.manualValue,
    builder: (column) => column,
  );

  GeneratedColumn<String> get customName => $composableBuilder(
    column: $table.customName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get customGroup => $composableBuilder(
    column: $table.customGroup,
    builder: (column) => column,
  );

  $$RoutinesTableAnnotationComposer get routineId {
    final $$RoutinesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routineId,
      referencedTable: $db.routines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutinesTableAnnotationComposer(
            $db: $db,
            $table: $db.routines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RoutineBodyElementsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RoutineBodyElementsTable,
          RoutineBodyElementRow,
          $$RoutineBodyElementsTableFilterComposer,
          $$RoutineBodyElementsTableOrderingComposer,
          $$RoutineBodyElementsTableAnnotationComposer,
          $$RoutineBodyElementsTableCreateCompanionBuilder,
          $$RoutineBodyElementsTableUpdateCompanionBuilder,
          (RoutineBodyElementRow, $$RoutineBodyElementsTableReferences),
          RoutineBodyElementRow,
          PrefetchHooks Function({bool routineId})
        > {
  $$RoutineBodyElementsTableTableManager(
    _$AppDatabase db,
    $RoutineBodyElementsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoutineBodyElementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RoutineBodyElementsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$RoutineBodyElementsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> routineId = const Value.absent(),
                Value<String> elementId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<bool> flatFoot = const Value.absent(),
                Value<bool> slowTurn = const Value.absent(),
                Value<int> extraRotations = const Value.absent(),
                Value<int> seriesCount = const Value.absent(),
                Value<int?> manualValue = const Value.absent(),
                Value<String?> customName = const Value.absent(),
                Value<String?> customGroup = const Value.absent(),
              }) => RoutineBodyElementsCompanion(
                id: id,
                routineId: routineId,
                elementId: elementId,
                position: position,
                flatFoot: flatFoot,
                slowTurn: slowTurn,
                extraRotations: extraRotations,
                seriesCount: seriesCount,
                manualValue: manualValue,
                customName: customName,
                customGroup: customGroup,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String routineId,
                required String elementId,
                required int position,
                Value<bool> flatFoot = const Value.absent(),
                Value<bool> slowTurn = const Value.absent(),
                Value<int> extraRotations = const Value.absent(),
                Value<int> seriesCount = const Value.absent(),
                Value<int?> manualValue = const Value.absent(),
                Value<String?> customName = const Value.absent(),
                Value<String?> customGroup = const Value.absent(),
              }) => RoutineBodyElementsCompanion.insert(
                id: id,
                routineId: routineId,
                elementId: elementId,
                position: position,
                flatFoot: flatFoot,
                slowTurn: slowTurn,
                extraRotations: extraRotations,
                seriesCount: seriesCount,
                manualValue: manualValue,
                customName: customName,
                customGroup: customGroup,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RoutineBodyElementsTable, RoutineBodyElementRow>(
                    table,
                  ),
                  $$RoutineBodyElementsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({routineId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (routineId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.routineId,
                        referencedTable: $$RoutineBodyElementsTableReferences
                            ._routineIdTable(db),
                        referencedColumn: $$RoutineBodyElementsTableReferences
                            ._routineIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RoutineBodyElementsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RoutineBodyElementsTable,
      RoutineBodyElementRow,
      $$RoutineBodyElementsTableFilterComposer,
      $$RoutineBodyElementsTableOrderingComposer,
      $$RoutineBodyElementsTableAnnotationComposer,
      $$RoutineBodyElementsTableCreateCompanionBuilder,
      $$RoutineBodyElementsTableUpdateCompanionBuilder,
      (RoutineBodyElementRow, $$RoutineBodyElementsTableReferences),
      RoutineBodyElementRow,
      PrefetchHooks Function({bool routineId})
    >;
typedef $$RoutineRisksTableCreateCompanionBuilder =
    RoutineRisksCompanion Function({
      Value<int> id,
      required String routineId,
      required String rotationOptionId,
      required int position,
    });
typedef $$RoutineRisksTableUpdateCompanionBuilder =
    RoutineRisksCompanion Function({
      Value<int> id,
      Value<String> routineId,
      Value<String> rotationOptionId,
      Value<int> position,
    });

final class $$RoutineRisksTableReferences
    extends BaseReferences<_$AppDatabase, $RoutineRisksTable, RoutineRiskRow> {
  $$RoutineRisksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $RoutinesTable _routineIdTable(_$AppDatabase db) =>
      db.routines.createAlias('routine_risks__routine_id__routines__id');

  $$RoutinesTableProcessedTableManager get routineId {
    final $_column = $_itemColumn<String>('routine_id')!;

    final manager = $$RoutinesTableTableManager(
      $_db,
      $_db.routines,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_routineIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $RoutineRiskCriteriaTable,
    List<RoutineRiskCriterionRow>
  >
  _routineRiskCriteriaRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.routineRiskCriteria,
        aliasName: 'routine_risks__id__routine_risk_criteria__routine_risk_id',
      );

  $$RoutineRiskCriteriaTableProcessedTableManager get routineRiskCriteriaRefs {
    final manager = $$RoutineRiskCriteriaTableTableManager(
      $_db,
      $_db.routineRiskCriteria,
    ).filter((f) => f.routineRiskId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _routineRiskCriteriaRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RoutineRisksTableFilterComposer
    extends Composer<_$AppDatabase, $RoutineRisksTable> {
  $$RoutineRisksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rotationOptionId => $composableBuilder(
    column: $table.rotationOptionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  $$RoutinesTableFilterComposer get routineId {
    final $$RoutinesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routineId,
      referencedTable: $db.routines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutinesTableFilterComposer(
            $db: $db,
            $table: $db.routines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> routineRiskCriteriaRefs(
    Expression<bool> Function($$RoutineRiskCriteriaTableFilterComposer f) f,
  ) {
    final $$RoutineRiskCriteriaTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.routineRiskCriteria,
      getReferencedColumn: (t) => t.routineRiskId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutineRiskCriteriaTableFilterComposer(
            $db: $db,
            $table: $db.routineRiskCriteria,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RoutineRisksTableOrderingComposer
    extends Composer<_$AppDatabase, $RoutineRisksTable> {
  $$RoutineRisksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rotationOptionId => $composableBuilder(
    column: $table.rotationOptionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  $$RoutinesTableOrderingComposer get routineId {
    final $$RoutinesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routineId,
      referencedTable: $db.routines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutinesTableOrderingComposer(
            $db: $db,
            $table: $db.routines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RoutineRisksTableAnnotationComposer
    extends Composer<_$AppDatabase, $RoutineRisksTable> {
  $$RoutineRisksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get rotationOptionId => $composableBuilder(
    column: $table.rotationOptionId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  $$RoutinesTableAnnotationComposer get routineId {
    final $$RoutinesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routineId,
      referencedTable: $db.routines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutinesTableAnnotationComposer(
            $db: $db,
            $table: $db.routines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> routineRiskCriteriaRefs<T extends Object>(
    Expression<T> Function($$RoutineRiskCriteriaTableAnnotationComposer a) f,
  ) {
    final $$RoutineRiskCriteriaTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.routineRiskCriteria,
          getReferencedColumn: (t) => t.routineRiskId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RoutineRiskCriteriaTableAnnotationComposer(
                $db: $db,
                $table: $db.routineRiskCriteria,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$RoutineRisksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RoutineRisksTable,
          RoutineRiskRow,
          $$RoutineRisksTableFilterComposer,
          $$RoutineRisksTableOrderingComposer,
          $$RoutineRisksTableAnnotationComposer,
          $$RoutineRisksTableCreateCompanionBuilder,
          $$RoutineRisksTableUpdateCompanionBuilder,
          (RoutineRiskRow, $$RoutineRisksTableReferences),
          RoutineRiskRow,
          PrefetchHooks Function({bool routineId, bool routineRiskCriteriaRefs})
        > {
  $$RoutineRisksTableTableManager(_$AppDatabase db, $RoutineRisksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoutineRisksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RoutineRisksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoutineRisksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> routineId = const Value.absent(),
                Value<String> rotationOptionId = const Value.absent(),
                Value<int> position = const Value.absent(),
              }) => RoutineRisksCompanion(
                id: id,
                routineId: routineId,
                rotationOptionId: rotationOptionId,
                position: position,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String routineId,
                required String rotationOptionId,
                required int position,
              }) => RoutineRisksCompanion.insert(
                id: id,
                routineId: routineId,
                rotationOptionId: rotationOptionId,
                position: position,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RoutineRisksTable, RoutineRiskRow>(table),
                  $$RoutineRisksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({routineId = false, routineRiskCriteriaRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (routineRiskCriteriaRefs) db.routineRiskCriteria,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (routineId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.routineId,
                            referencedTable: $$RoutineRisksTableReferences
                                ._routineIdTable(db),
                            referencedColumn: $$RoutineRisksTableReferences
                                ._routineIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (routineRiskCriteriaRefs)
                        await $_getPrefetchedDataByColumns<
                          RoutineRiskRow,
                          $RoutineRisksTable,
                          RoutineRiskCriterionRow,
                          $RoutineRiskCriteriaTable
                        >(
                          currentTable: table,
                          referencedTable: $$RoutineRisksTableReferences
                              ._routineRiskCriteriaRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RoutineRisksTableReferences(
                                db,
                                table,
                                p0,
                              ).routineRiskCriteriaRefs,
                          currentColumn: 'id',
                          referencedColumn: 'routine_risk_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$RoutineRisksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RoutineRisksTable,
      RoutineRiskRow,
      $$RoutineRisksTableFilterComposer,
      $$RoutineRisksTableOrderingComposer,
      $$RoutineRisksTableAnnotationComposer,
      $$RoutineRisksTableCreateCompanionBuilder,
      $$RoutineRisksTableUpdateCompanionBuilder,
      (RoutineRiskRow, $$RoutineRisksTableReferences),
      RoutineRiskRow,
      PrefetchHooks Function({bool routineId, bool routineRiskCriteriaRefs})
    >;
typedef $$RoutineRiskCriteriaTableCreateCompanionBuilder =
    RoutineRiskCriteriaCompanion Function({
      Value<int> id,
      required int routineRiskId,
      required String criterionId,
      required int position,
    });
typedef $$RoutineRiskCriteriaTableUpdateCompanionBuilder =
    RoutineRiskCriteriaCompanion Function({
      Value<int> id,
      Value<int> routineRiskId,
      Value<String> criterionId,
      Value<int> position,
    });

final class $$RoutineRiskCriteriaTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $RoutineRiskCriteriaTable,
          RoutineRiskCriterionRow
        > {
  $$RoutineRiskCriteriaTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $RoutineRisksTable _routineRiskIdTable(_$AppDatabase db) => db
      .routineRisks
      .createAlias('routine_risk_criteria__routine_risk_id__routine_risks__id');

  $$RoutineRisksTableProcessedTableManager get routineRiskId {
    final $_column = $_itemColumn<int>('routine_risk_id')!;

    final manager = $$RoutineRisksTableTableManager(
      $_db,
      $_db.routineRisks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_routineRiskIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RoutineRiskCriteriaTableFilterComposer
    extends Composer<_$AppDatabase, $RoutineRiskCriteriaTable> {
  $$RoutineRiskCriteriaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get criterionId => $composableBuilder(
    column: $table.criterionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  $$RoutineRisksTableFilterComposer get routineRiskId {
    final $$RoutineRisksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routineRiskId,
      referencedTable: $db.routineRisks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutineRisksTableFilterComposer(
            $db: $db,
            $table: $db.routineRisks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RoutineRiskCriteriaTableOrderingComposer
    extends Composer<_$AppDatabase, $RoutineRiskCriteriaTable> {
  $$RoutineRiskCriteriaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get criterionId => $composableBuilder(
    column: $table.criterionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  $$RoutineRisksTableOrderingComposer get routineRiskId {
    final $$RoutineRisksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routineRiskId,
      referencedTable: $db.routineRisks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutineRisksTableOrderingComposer(
            $db: $db,
            $table: $db.routineRisks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RoutineRiskCriteriaTableAnnotationComposer
    extends Composer<_$AppDatabase, $RoutineRiskCriteriaTable> {
  $$RoutineRiskCriteriaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get criterionId => $composableBuilder(
    column: $table.criterionId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  $$RoutineRisksTableAnnotationComposer get routineRiskId {
    final $$RoutineRisksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routineRiskId,
      referencedTable: $db.routineRisks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutineRisksTableAnnotationComposer(
            $db: $db,
            $table: $db.routineRisks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RoutineRiskCriteriaTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RoutineRiskCriteriaTable,
          RoutineRiskCriterionRow,
          $$RoutineRiskCriteriaTableFilterComposer,
          $$RoutineRiskCriteriaTableOrderingComposer,
          $$RoutineRiskCriteriaTableAnnotationComposer,
          $$RoutineRiskCriteriaTableCreateCompanionBuilder,
          $$RoutineRiskCriteriaTableUpdateCompanionBuilder,
          (RoutineRiskCriterionRow, $$RoutineRiskCriteriaTableReferences),
          RoutineRiskCriterionRow,
          PrefetchHooks Function({bool routineRiskId})
        > {
  $$RoutineRiskCriteriaTableTableManager(
    _$AppDatabase db,
    $RoutineRiskCriteriaTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoutineRiskCriteriaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RoutineRiskCriteriaTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$RoutineRiskCriteriaTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> routineRiskId = const Value.absent(),
                Value<String> criterionId = const Value.absent(),
                Value<int> position = const Value.absent(),
              }) => RoutineRiskCriteriaCompanion(
                id: id,
                routineRiskId: routineRiskId,
                criterionId: criterionId,
                position: position,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int routineRiskId,
                required String criterionId,
                required int position,
              }) => RoutineRiskCriteriaCompanion.insert(
                id: id,
                routineRiskId: routineRiskId,
                criterionId: criterionId,
                position: position,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $RoutineRiskCriteriaTable,
                    RoutineRiskCriterionRow
                  >(table),
                  $$RoutineRiskCriteriaTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({routineRiskId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (routineRiskId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.routineRiskId,
                        referencedTable: $$RoutineRiskCriteriaTableReferences
                            ._routineRiskIdTable(db),
                        referencedColumn: $$RoutineRiskCriteriaTableReferences
                            ._routineRiskIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RoutineRiskCriteriaTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RoutineRiskCriteriaTable,
      RoutineRiskCriterionRow,
      $$RoutineRiskCriteriaTableFilterComposer,
      $$RoutineRiskCriteriaTableOrderingComposer,
      $$RoutineRiskCriteriaTableAnnotationComposer,
      $$RoutineRiskCriteriaTableCreateCompanionBuilder,
      $$RoutineRiskCriteriaTableUpdateCompanionBuilder,
      (RoutineRiskCriterionRow, $$RoutineRiskCriteriaTableReferences),
      RoutineRiskCriterionRow,
      PrefetchHooks Function({bool routineRiskId})
    >;
typedef $$RoutineApparatusDifficultiesTableCreateCompanionBuilder =
    RoutineApparatusDifficultiesCompanion Function({
      Value<int> id,
      required String routineId,
      required int position,
      required String baseId,
      Value<String?> secondBaseId,
      Value<String> criteria,
      Value<bool> preAcrobatic,
      Value<int?> manualValue,
      Value<String?> customName,
    });
typedef $$RoutineApparatusDifficultiesTableUpdateCompanionBuilder =
    RoutineApparatusDifficultiesCompanion Function({
      Value<int> id,
      Value<String> routineId,
      Value<int> position,
      Value<String> baseId,
      Value<String?> secondBaseId,
      Value<String> criteria,
      Value<bool> preAcrobatic,
      Value<int?> manualValue,
      Value<String?> customName,
    });

final class $$RoutineApparatusDifficultiesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $RoutineApparatusDifficultiesTable,
          RoutineApparatusDifficultyRow
        > {
  $$RoutineApparatusDifficultiesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $RoutinesTable _routineIdTable(_$AppDatabase db) => db.routines
      .createAlias('routine_apparatus_difficulties__routine_id__routines__id');

  $$RoutinesTableProcessedTableManager get routineId {
    final $_column = $_itemColumn<String>('routine_id')!;

    final manager = $$RoutinesTableTableManager(
      $_db,
      $_db.routines,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_routineIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RoutineApparatusDifficultiesTableFilterComposer
    extends Composer<_$AppDatabase, $RoutineApparatusDifficultiesTable> {
  $$RoutineApparatusDifficultiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get baseId => $composableBuilder(
    column: $table.baseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get secondBaseId => $composableBuilder(
    column: $table.secondBaseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get criteria => $composableBuilder(
    column: $table.criteria,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get preAcrobatic => $composableBuilder(
    column: $table.preAcrobatic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get manualValue => $composableBuilder(
    column: $table.manualValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customName => $composableBuilder(
    column: $table.customName,
    builder: (column) => ColumnFilters(column),
  );

  $$RoutinesTableFilterComposer get routineId {
    final $$RoutinesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routineId,
      referencedTable: $db.routines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutinesTableFilterComposer(
            $db: $db,
            $table: $db.routines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RoutineApparatusDifficultiesTableOrderingComposer
    extends Composer<_$AppDatabase, $RoutineApparatusDifficultiesTable> {
  $$RoutineApparatusDifficultiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get baseId => $composableBuilder(
    column: $table.baseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get secondBaseId => $composableBuilder(
    column: $table.secondBaseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get criteria => $composableBuilder(
    column: $table.criteria,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get preAcrobatic => $composableBuilder(
    column: $table.preAcrobatic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get manualValue => $composableBuilder(
    column: $table.manualValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customName => $composableBuilder(
    column: $table.customName,
    builder: (column) => ColumnOrderings(column),
  );

  $$RoutinesTableOrderingComposer get routineId {
    final $$RoutinesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routineId,
      referencedTable: $db.routines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutinesTableOrderingComposer(
            $db: $db,
            $table: $db.routines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RoutineApparatusDifficultiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RoutineApparatusDifficultiesTable> {
  $$RoutineApparatusDifficultiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get baseId =>
      $composableBuilder(column: $table.baseId, builder: (column) => column);

  GeneratedColumn<String> get secondBaseId => $composableBuilder(
    column: $table.secondBaseId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get criteria =>
      $composableBuilder(column: $table.criteria, builder: (column) => column);

  GeneratedColumn<bool> get preAcrobatic => $composableBuilder(
    column: $table.preAcrobatic,
    builder: (column) => column,
  );

  GeneratedColumn<int> get manualValue => $composableBuilder(
    column: $table.manualValue,
    builder: (column) => column,
  );

  GeneratedColumn<String> get customName => $composableBuilder(
    column: $table.customName,
    builder: (column) => column,
  );

  $$RoutinesTableAnnotationComposer get routineId {
    final $$RoutinesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routineId,
      referencedTable: $db.routines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutinesTableAnnotationComposer(
            $db: $db,
            $table: $db.routines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RoutineApparatusDifficultiesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RoutineApparatusDifficultiesTable,
          RoutineApparatusDifficultyRow,
          $$RoutineApparatusDifficultiesTableFilterComposer,
          $$RoutineApparatusDifficultiesTableOrderingComposer,
          $$RoutineApparatusDifficultiesTableAnnotationComposer,
          $$RoutineApparatusDifficultiesTableCreateCompanionBuilder,
          $$RoutineApparatusDifficultiesTableUpdateCompanionBuilder,
          (
            RoutineApparatusDifficultyRow,
            $$RoutineApparatusDifficultiesTableReferences,
          ),
          RoutineApparatusDifficultyRow,
          PrefetchHooks Function({bool routineId})
        > {
  $$RoutineApparatusDifficultiesTableTableManager(
    _$AppDatabase db,
    $RoutineApparatusDifficultiesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoutineApparatusDifficultiesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$RoutineApparatusDifficultiesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$RoutineApparatusDifficultiesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> routineId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<String> baseId = const Value.absent(),
                Value<String?> secondBaseId = const Value.absent(),
                Value<String> criteria = const Value.absent(),
                Value<bool> preAcrobatic = const Value.absent(),
                Value<int?> manualValue = const Value.absent(),
                Value<String?> customName = const Value.absent(),
              }) => RoutineApparatusDifficultiesCompanion(
                id: id,
                routineId: routineId,
                position: position,
                baseId: baseId,
                secondBaseId: secondBaseId,
                criteria: criteria,
                preAcrobatic: preAcrobatic,
                manualValue: manualValue,
                customName: customName,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String routineId,
                required int position,
                required String baseId,
                Value<String?> secondBaseId = const Value.absent(),
                Value<String> criteria = const Value.absent(),
                Value<bool> preAcrobatic = const Value.absent(),
                Value<int?> manualValue = const Value.absent(),
                Value<String?> customName = const Value.absent(),
              }) => RoutineApparatusDifficultiesCompanion.insert(
                id: id,
                routineId: routineId,
                position: position,
                baseId: baseId,
                secondBaseId: secondBaseId,
                criteria: criteria,
                preAcrobatic: preAcrobatic,
                manualValue: manualValue,
                customName: customName,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $RoutineApparatusDifficultiesTable,
                    RoutineApparatusDifficultyRow
                  >(table),
                  $$RoutineApparatusDifficultiesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({routineId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (routineId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.routineId,
                        referencedTable:
                            $$RoutineApparatusDifficultiesTableReferences
                                ._routineIdTable(db),
                        referencedColumn:
                            $$RoutineApparatusDifficultiesTableReferences
                                ._routineIdTable(db)
                                .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RoutineApparatusDifficultiesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RoutineApparatusDifficultiesTable,
      RoutineApparatusDifficultyRow,
      $$RoutineApparatusDifficultiesTableFilterComposer,
      $$RoutineApparatusDifficultiesTableOrderingComposer,
      $$RoutineApparatusDifficultiesTableAnnotationComposer,
      $$RoutineApparatusDifficultiesTableCreateCompanionBuilder,
      $$RoutineApparatusDifficultiesTableUpdateCompanionBuilder,
      (
        RoutineApparatusDifficultyRow,
        $$RoutineApparatusDifficultiesTableReferences,
      ),
      RoutineApparatusDifficultyRow,
      PrefetchHooks Function({bool routineId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$RoutinesTableTableManager get routines =>
      $$RoutinesTableTableManager(_db, _db.routines);
  $$RoutineBodyElementsTableTableManager get routineBodyElements =>
      $$RoutineBodyElementsTableTableManager(_db, _db.routineBodyElements);
  $$RoutineRisksTableTableManager get routineRisks =>
      $$RoutineRisksTableTableManager(_db, _db.routineRisks);
  $$RoutineRiskCriteriaTableTableManager get routineRiskCriteria =>
      $$RoutineRiskCriteriaTableTableManager(_db, _db.routineRiskCriteria);
  $$RoutineApparatusDifficultiesTableTableManager
  get routineApparatusDifficulties =>
      $$RoutineApparatusDifficultiesTableTableManager(
        _db,
        _db.routineApparatusDifficulties,
      );
}
