// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $OutboxEntriesTable extends OutboxEntries
    with TableInfo<$OutboxEntriesTable, OutboxRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutboxEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 36, maxTextLength: 36),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _createdByMeta =
      const VerificationMeta('createdBy');
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
      'created_by', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _updatedByMeta =
      const VerificationMeta('updatedBy');
  @override
  late final GeneratedColumn<String> updatedBy = GeneratedColumn<String>(
      'updated_by', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _aggregateTypeMeta =
      const VerificationMeta('aggregateType');
  @override
  late final GeneratedColumn<String> aggregateType = GeneratedColumn<String>(
      'aggregate_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _aggregateIdMeta =
      const VerificationMeta('aggregateId');
  @override
  late final GeneratedColumn<String> aggregateId = GeneratedColumn<String>(
      'aggregate_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _opTypeMeta = const VerificationMeta('opType');
  @override
  late final GeneratedColumn<String> opType = GeneratedColumn<String>(
      'op_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadMeta =
      const VerificationMeta('payload');
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
      'payload', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _localSeqMeta =
      const VerificationMeta('localSeq');
  @override
  late final GeneratedColumn<int> localSeq = GeneratedColumn<int>(
      'local_seq', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
      'device_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _actorIdMeta =
      const VerificationMeta('actorId');
  @override
  late final GeneratedColumn<String> actorId = GeneratedColumn<String>(
      'actor_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _baseVersionMeta =
      const VerificationMeta('baseVersion');
  @override
  late final GeneratedColumn<int> baseVersion = GeneratedColumn<int>(
      'base_version', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        createdAt,
        updatedAt,
        deletedAt,
        createdBy,
        updatedBy,
        version,
        aggregateType,
        aggregateId,
        opType,
        payload,
        localSeq,
        deviceId,
        actorId,
        status,
        baseVersion
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outbox_entries';
  @override
  VerificationContext validateIntegrity(Insertable<OutboxRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('created_by')) {
      context.handle(_createdByMeta,
          createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta));
    }
    if (data.containsKey('updated_by')) {
      context.handle(_updatedByMeta,
          updatedBy.isAcceptableOrUnknown(data['updated_by']!, _updatedByMeta));
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    }
    if (data.containsKey('aggregate_type')) {
      context.handle(
          _aggregateTypeMeta,
          aggregateType.isAcceptableOrUnknown(
              data['aggregate_type']!, _aggregateTypeMeta));
    } else if (isInserting) {
      context.missing(_aggregateTypeMeta);
    }
    if (data.containsKey('aggregate_id')) {
      context.handle(
          _aggregateIdMeta,
          aggregateId.isAcceptableOrUnknown(
              data['aggregate_id']!, _aggregateIdMeta));
    } else if (isInserting) {
      context.missing(_aggregateIdMeta);
    }
    if (data.containsKey('op_type')) {
      context.handle(_opTypeMeta,
          opType.isAcceptableOrUnknown(data['op_type']!, _opTypeMeta));
    } else if (isInserting) {
      context.missing(_opTypeMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(_payloadMeta,
          payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta));
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('local_seq')) {
      context.handle(_localSeqMeta,
          localSeq.isAcceptableOrUnknown(data['local_seq']!, _localSeqMeta));
    } else if (isInserting) {
      context.missing(_localSeqMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('actor_id')) {
      context.handle(_actorIdMeta,
          actorId.isAcceptableOrUnknown(data['actor_id']!, _actorIdMeta));
    } else if (isInserting) {
      context.missing(_actorIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('base_version')) {
      context.handle(
          _baseVersionMeta,
          baseVersion.isAcceptableOrUnknown(
              data['base_version']!, _baseVersionMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OutboxRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutboxRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      createdBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_by']),
      updatedBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}updated_by']),
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
      aggregateType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}aggregate_type'])!,
      aggregateId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}aggregate_id'])!,
      opType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}op_type'])!,
      payload: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload'])!,
      localSeq: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}local_seq'])!,
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id'])!,
      actorId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}actor_id'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      baseVersion: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}base_version']),
    );
  }

  @override
  $OutboxEntriesTable createAlias(String alias) {
    return $OutboxEntriesTable(attachedDatabase, alias);
  }
}

class OutboxRow extends DataClass implements Insertable<OutboxRow> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String? createdBy;
  final String? updatedBy;
  final int version;
  final String aggregateType;
  final String aggregateId;
  final String opType;
  final String payload;
  final int localSeq;
  final String deviceId;
  final String actorId;
  final String status;
  final int? baseVersion;
  const OutboxRow(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt,
      this.createdBy,
      this.updatedBy,
      required this.version,
      required this.aggregateType,
      required this.aggregateId,
      required this.opType,
      required this.payload,
      required this.localSeq,
      required this.deviceId,
      required this.actorId,
      required this.status,
      this.baseVersion});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<String>(createdBy);
    }
    if (!nullToAbsent || updatedBy != null) {
      map['updated_by'] = Variable<String>(updatedBy);
    }
    map['version'] = Variable<int>(version);
    map['aggregate_type'] = Variable<String>(aggregateType);
    map['aggregate_id'] = Variable<String>(aggregateId);
    map['op_type'] = Variable<String>(opType);
    map['payload'] = Variable<String>(payload);
    map['local_seq'] = Variable<int>(localSeq);
    map['device_id'] = Variable<String>(deviceId);
    map['actor_id'] = Variable<String>(actorId);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || baseVersion != null) {
      map['base_version'] = Variable<int>(baseVersion);
    }
    return map;
  }

  OutboxEntriesCompanion toCompanion(bool nullToAbsent) {
    return OutboxEntriesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      createdBy: createdBy == null && nullToAbsent
          ? const Value.absent()
          : Value(createdBy),
      updatedBy: updatedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedBy),
      version: Value(version),
      aggregateType: Value(aggregateType),
      aggregateId: Value(aggregateId),
      opType: Value(opType),
      payload: Value(payload),
      localSeq: Value(localSeq),
      deviceId: Value(deviceId),
      actorId: Value(actorId),
      status: Value(status),
      baseVersion: baseVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(baseVersion),
    );
  }

  factory OutboxRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutboxRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
      updatedBy: serializer.fromJson<String?>(json['updatedBy']),
      version: serializer.fromJson<int>(json['version']),
      aggregateType: serializer.fromJson<String>(json['aggregateType']),
      aggregateId: serializer.fromJson<String>(json['aggregateId']),
      opType: serializer.fromJson<String>(json['opType']),
      payload: serializer.fromJson<String>(json['payload']),
      localSeq: serializer.fromJson<int>(json['localSeq']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      actorId: serializer.fromJson<String>(json['actorId']),
      status: serializer.fromJson<String>(json['status']),
      baseVersion: serializer.fromJson<int?>(json['baseVersion']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'createdBy': serializer.toJson<String?>(createdBy),
      'updatedBy': serializer.toJson<String?>(updatedBy),
      'version': serializer.toJson<int>(version),
      'aggregateType': serializer.toJson<String>(aggregateType),
      'aggregateId': serializer.toJson<String>(aggregateId),
      'opType': serializer.toJson<String>(opType),
      'payload': serializer.toJson<String>(payload),
      'localSeq': serializer.toJson<int>(localSeq),
      'deviceId': serializer.toJson<String>(deviceId),
      'actorId': serializer.toJson<String>(actorId),
      'status': serializer.toJson<String>(status),
      'baseVersion': serializer.toJson<int?>(baseVersion),
    };
  }

  OutboxRow copyWith(
          {String? id,
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          Value<String?> createdBy = const Value.absent(),
          Value<String?> updatedBy = const Value.absent(),
          int? version,
          String? aggregateType,
          String? aggregateId,
          String? opType,
          String? payload,
          int? localSeq,
          String? deviceId,
          String? actorId,
          String? status,
          Value<int?> baseVersion = const Value.absent()}) =>
      OutboxRow(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        createdBy: createdBy.present ? createdBy.value : this.createdBy,
        updatedBy: updatedBy.present ? updatedBy.value : this.updatedBy,
        version: version ?? this.version,
        aggregateType: aggregateType ?? this.aggregateType,
        aggregateId: aggregateId ?? this.aggregateId,
        opType: opType ?? this.opType,
        payload: payload ?? this.payload,
        localSeq: localSeq ?? this.localSeq,
        deviceId: deviceId ?? this.deviceId,
        actorId: actorId ?? this.actorId,
        status: status ?? this.status,
        baseVersion: baseVersion.present ? baseVersion.value : this.baseVersion,
      );
  OutboxRow copyWithCompanion(OutboxEntriesCompanion data) {
    return OutboxRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      version: data.version.present ? data.version.value : this.version,
      aggregateType: data.aggregateType.present
          ? data.aggregateType.value
          : this.aggregateType,
      aggregateId:
          data.aggregateId.present ? data.aggregateId.value : this.aggregateId,
      opType: data.opType.present ? data.opType.value : this.opType,
      payload: data.payload.present ? data.payload.value : this.payload,
      localSeq: data.localSeq.present ? data.localSeq.value : this.localSeq,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      actorId: data.actorId.present ? data.actorId.value : this.actorId,
      status: data.status.present ? data.status.value : this.status,
      baseVersion:
          data.baseVersion.present ? data.baseVersion.value : this.baseVersion,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutboxRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('version: $version, ')
          ..write('aggregateType: $aggregateType, ')
          ..write('aggregateId: $aggregateId, ')
          ..write('opType: $opType, ')
          ..write('payload: $payload, ')
          ..write('localSeq: $localSeq, ')
          ..write('deviceId: $deviceId, ')
          ..write('actorId: $actorId, ')
          ..write('status: $status, ')
          ..write('baseVersion: $baseVersion')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      createdAt,
      updatedAt,
      deletedAt,
      createdBy,
      updatedBy,
      version,
      aggregateType,
      aggregateId,
      opType,
      payload,
      localSeq,
      deviceId,
      actorId,
      status,
      baseVersion);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutboxRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.createdBy == this.createdBy &&
          other.updatedBy == this.updatedBy &&
          other.version == this.version &&
          other.aggregateType == this.aggregateType &&
          other.aggregateId == this.aggregateId &&
          other.opType == this.opType &&
          other.payload == this.payload &&
          other.localSeq == this.localSeq &&
          other.deviceId == this.deviceId &&
          other.actorId == this.actorId &&
          other.status == this.status &&
          other.baseVersion == this.baseVersion);
}

class OutboxEntriesCompanion extends UpdateCompanion<OutboxRow> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String?> createdBy;
  final Value<String?> updatedBy;
  final Value<int> version;
  final Value<String> aggregateType;
  final Value<String> aggregateId;
  final Value<String> opType;
  final Value<String> payload;
  final Value<int> localSeq;
  final Value<String> deviceId;
  final Value<String> actorId;
  final Value<String> status;
  final Value<int?> baseVersion;
  final Value<int> rowid;
  const OutboxEntriesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.version = const Value.absent(),
    this.aggregateType = const Value.absent(),
    this.aggregateId = const Value.absent(),
    this.opType = const Value.absent(),
    this.payload = const Value.absent(),
    this.localSeq = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.actorId = const Value.absent(),
    this.status = const Value.absent(),
    this.baseVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OutboxEntriesCompanion.insert({
    required String id,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.version = const Value.absent(),
    required String aggregateType,
    required String aggregateId,
    required String opType,
    required String payload,
    required int localSeq,
    required String deviceId,
    required String actorId,
    this.status = const Value.absent(),
    this.baseVersion = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        aggregateType = Value(aggregateType),
        aggregateId = Value(aggregateId),
        opType = Value(opType),
        payload = Value(payload),
        localSeq = Value(localSeq),
        deviceId = Value(deviceId),
        actorId = Value(actorId);
  static Insertable<OutboxRow> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? createdBy,
    Expression<String>? updatedBy,
    Expression<int>? version,
    Expression<String>? aggregateType,
    Expression<String>? aggregateId,
    Expression<String>? opType,
    Expression<String>? payload,
    Expression<int>? localSeq,
    Expression<String>? deviceId,
    Expression<String>? actorId,
    Expression<String>? status,
    Expression<int>? baseVersion,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (createdBy != null) 'created_by': createdBy,
      if (updatedBy != null) 'updated_by': updatedBy,
      if (version != null) 'version': version,
      if (aggregateType != null) 'aggregate_type': aggregateType,
      if (aggregateId != null) 'aggregate_id': aggregateId,
      if (opType != null) 'op_type': opType,
      if (payload != null) 'payload': payload,
      if (localSeq != null) 'local_seq': localSeq,
      if (deviceId != null) 'device_id': deviceId,
      if (actorId != null) 'actor_id': actorId,
      if (status != null) 'status': status,
      if (baseVersion != null) 'base_version': baseVersion,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OutboxEntriesCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<String?>? createdBy,
      Value<String?>? updatedBy,
      Value<int>? version,
      Value<String>? aggregateType,
      Value<String>? aggregateId,
      Value<String>? opType,
      Value<String>? payload,
      Value<int>? localSeq,
      Value<String>? deviceId,
      Value<String>? actorId,
      Value<String>? status,
      Value<int?>? baseVersion,
      Value<int>? rowid}) {
    return OutboxEntriesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      version: version ?? this.version,
      aggregateType: aggregateType ?? this.aggregateType,
      aggregateId: aggregateId ?? this.aggregateId,
      opType: opType ?? this.opType,
      payload: payload ?? this.payload,
      localSeq: localSeq ?? this.localSeq,
      deviceId: deviceId ?? this.deviceId,
      actorId: actorId ?? this.actorId,
      status: status ?? this.status,
      baseVersion: baseVersion ?? this.baseVersion,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (updatedBy.present) {
      map['updated_by'] = Variable<String>(updatedBy.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (aggregateType.present) {
      map['aggregate_type'] = Variable<String>(aggregateType.value);
    }
    if (aggregateId.present) {
      map['aggregate_id'] = Variable<String>(aggregateId.value);
    }
    if (opType.present) {
      map['op_type'] = Variable<String>(opType.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (localSeq.present) {
      map['local_seq'] = Variable<int>(localSeq.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (actorId.present) {
      map['actor_id'] = Variable<String>(actorId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (baseVersion.present) {
      map['base_version'] = Variable<int>(baseVersion.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutboxEntriesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('version: $version, ')
          ..write('aggregateType: $aggregateType, ')
          ..write('aggregateId: $aggregateId, ')
          ..write('opType: $opType, ')
          ..write('payload: $payload, ')
          ..write('localSeq: $localSeq, ')
          ..write('deviceId: $deviceId, ')
          ..write('actorId: $actorId, ')
          ..write('status: $status, ')
          ..write('baseVersion: $baseVersion, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedProfilesTable extends CachedProfiles
    with TableInfo<$CachedProfilesTable, CachedProfileRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _usernameMeta =
      const VerificationMeta('username');
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
      'username', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _displayNameMeta =
      const VerificationMeta('displayName');
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
      'display_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _defaultBranchIdMeta =
      const VerificationMeta('defaultBranchId');
  @override
  late final GeneratedColumn<String> defaultBranchId = GeneratedColumn<String>(
      'default_branch_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _branchesMeta =
      const VerificationMeta('branches');
  @override
  late final GeneratedColumn<String> branches = GeneratedColumn<String>(
      'branches', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _cachedAtMeta =
      const VerificationMeta('cachedAt');
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
      'cached_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [userId, username, displayName, defaultBranchId, branches, cachedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_profiles';
  @override
  VerificationContext validateIntegrity(Insertable<CachedProfileRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('username')) {
      context.handle(_usernameMeta,
          username.isAcceptableOrUnknown(data['username']!, _usernameMeta));
    } else if (isInserting) {
      context.missing(_usernameMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
          _displayNameMeta,
          displayName.isAcceptableOrUnknown(
              data['display_name']!, _displayNameMeta));
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('default_branch_id')) {
      context.handle(
          _defaultBranchIdMeta,
          defaultBranchId.isAcceptableOrUnknown(
              data['default_branch_id']!, _defaultBranchIdMeta));
    }
    if (data.containsKey('branches')) {
      context.handle(_branchesMeta,
          branches.isAcceptableOrUnknown(data['branches']!, _branchesMeta));
    } else if (isInserting) {
      context.missing(_branchesMeta);
    }
    if (data.containsKey('cached_at')) {
      context.handle(_cachedAtMeta,
          cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId};
  @override
  CachedProfileRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedProfileRow(
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      username: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}username'])!,
      displayName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}display_name'])!,
      defaultBranchId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}default_branch_id']),
      branches: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}branches'])!,
      cachedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}cached_at'])!,
    );
  }

  @override
  $CachedProfilesTable createAlias(String alias) {
    return $CachedProfilesTable(attachedDatabase, alias);
  }
}

class CachedProfileRow extends DataClass
    implements Insertable<CachedProfileRow> {
  final String userId;
  final String username;
  final String displayName;
  final String? defaultBranchId;
  final String branches;
  final DateTime cachedAt;
  const CachedProfileRow(
      {required this.userId,
      required this.username,
      required this.displayName,
      this.defaultBranchId,
      required this.branches,
      required this.cachedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['username'] = Variable<String>(username);
    map['display_name'] = Variable<String>(displayName);
    if (!nullToAbsent || defaultBranchId != null) {
      map['default_branch_id'] = Variable<String>(defaultBranchId);
    }
    map['branches'] = Variable<String>(branches);
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  CachedProfilesCompanion toCompanion(bool nullToAbsent) {
    return CachedProfilesCompanion(
      userId: Value(userId),
      username: Value(username),
      displayName: Value(displayName),
      defaultBranchId: defaultBranchId == null && nullToAbsent
          ? const Value.absent()
          : Value(defaultBranchId),
      branches: Value(branches),
      cachedAt: Value(cachedAt),
    );
  }

  factory CachedProfileRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedProfileRow(
      userId: serializer.fromJson<String>(json['userId']),
      username: serializer.fromJson<String>(json['username']),
      displayName: serializer.fromJson<String>(json['displayName']),
      defaultBranchId: serializer.fromJson<String?>(json['defaultBranchId']),
      branches: serializer.fromJson<String>(json['branches']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'username': serializer.toJson<String>(username),
      'displayName': serializer.toJson<String>(displayName),
      'defaultBranchId': serializer.toJson<String?>(defaultBranchId),
      'branches': serializer.toJson<String>(branches),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  CachedProfileRow copyWith(
          {String? userId,
          String? username,
          String? displayName,
          Value<String?> defaultBranchId = const Value.absent(),
          String? branches,
          DateTime? cachedAt}) =>
      CachedProfileRow(
        userId: userId ?? this.userId,
        username: username ?? this.username,
        displayName: displayName ?? this.displayName,
        defaultBranchId: defaultBranchId.present
            ? defaultBranchId.value
            : this.defaultBranchId,
        branches: branches ?? this.branches,
        cachedAt: cachedAt ?? this.cachedAt,
      );
  CachedProfileRow copyWithCompanion(CachedProfilesCompanion data) {
    return CachedProfileRow(
      userId: data.userId.present ? data.userId.value : this.userId,
      username: data.username.present ? data.username.value : this.username,
      displayName:
          data.displayName.present ? data.displayName.value : this.displayName,
      defaultBranchId: data.defaultBranchId.present
          ? data.defaultBranchId.value
          : this.defaultBranchId,
      branches: data.branches.present ? data.branches.value : this.branches,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedProfileRow(')
          ..write('userId: $userId, ')
          ..write('username: $username, ')
          ..write('displayName: $displayName, ')
          ..write('defaultBranchId: $defaultBranchId, ')
          ..write('branches: $branches, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      userId, username, displayName, defaultBranchId, branches, cachedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedProfileRow &&
          other.userId == this.userId &&
          other.username == this.username &&
          other.displayName == this.displayName &&
          other.defaultBranchId == this.defaultBranchId &&
          other.branches == this.branches &&
          other.cachedAt == this.cachedAt);
}

class CachedProfilesCompanion extends UpdateCompanion<CachedProfileRow> {
  final Value<String> userId;
  final Value<String> username;
  final Value<String> displayName;
  final Value<String?> defaultBranchId;
  final Value<String> branches;
  final Value<DateTime> cachedAt;
  final Value<int> rowid;
  const CachedProfilesCompanion({
    this.userId = const Value.absent(),
    this.username = const Value.absent(),
    this.displayName = const Value.absent(),
    this.defaultBranchId = const Value.absent(),
    this.branches = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedProfilesCompanion.insert({
    required String userId,
    required String username,
    required String displayName,
    this.defaultBranchId = const Value.absent(),
    required String branches,
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : userId = Value(userId),
        username = Value(username),
        displayName = Value(displayName),
        branches = Value(branches);
  static Insertable<CachedProfileRow> custom({
    Expression<String>? userId,
    Expression<String>? username,
    Expression<String>? displayName,
    Expression<String>? defaultBranchId,
    Expression<String>? branches,
    Expression<DateTime>? cachedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (username != null) 'username': username,
      if (displayName != null) 'display_name': displayName,
      if (defaultBranchId != null) 'default_branch_id': defaultBranchId,
      if (branches != null) 'branches': branches,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedProfilesCompanion copyWith(
      {Value<String>? userId,
      Value<String>? username,
      Value<String>? displayName,
      Value<String?>? defaultBranchId,
      Value<String>? branches,
      Value<DateTime>? cachedAt,
      Value<int>? rowid}) {
    return CachedProfilesCompanion(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      defaultBranchId: defaultBranchId ?? this.defaultBranchId,
      branches: branches ?? this.branches,
      cachedAt: cachedAt ?? this.cachedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (defaultBranchId.present) {
      map['default_branch_id'] = Variable<String>(defaultBranchId.value);
    }
    if (branches.present) {
      map['branches'] = Variable<String>(branches.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedProfilesCompanion(')
          ..write('userId: $userId, ')
          ..write('username: $username, ')
          ..write('displayName: $displayName, ')
          ..write('defaultBranchId: $defaultBranchId, ')
          ..write('branches: $branches, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $OutboxEntriesTable outboxEntries = $OutboxEntriesTable(this);
  late final $CachedProfilesTable cachedProfiles = $CachedProfilesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [outboxEntries, cachedProfiles];
}

typedef $$OutboxEntriesTableCreateCompanionBuilder = OutboxEntriesCompanion
    Function({
  required String id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String?> createdBy,
  Value<String?> updatedBy,
  Value<int> version,
  required String aggregateType,
  required String aggregateId,
  required String opType,
  required String payload,
  required int localSeq,
  required String deviceId,
  required String actorId,
  Value<String> status,
  Value<int?> baseVersion,
  Value<int> rowid,
});
typedef $$OutboxEntriesTableUpdateCompanionBuilder = OutboxEntriesCompanion
    Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String?> createdBy,
  Value<String?> updatedBy,
  Value<int> version,
  Value<String> aggregateType,
  Value<String> aggregateId,
  Value<String> opType,
  Value<String> payload,
  Value<int> localSeq,
  Value<String> deviceId,
  Value<String> actorId,
  Value<String> status,
  Value<int?> baseVersion,
  Value<int> rowid,
});

class $$OutboxEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $OutboxEntriesTable> {
  $$OutboxEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdBy => $composableBuilder(
      column: $table.createdBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedBy => $composableBuilder(
      column: $table.updatedBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get aggregateType => $composableBuilder(
      column: $table.aggregateType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get aggregateId => $composableBuilder(
      column: $table.aggregateId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get opType => $composableBuilder(
      column: $table.opType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get localSeq => $composableBuilder(
      column: $table.localSeq, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get actorId => $composableBuilder(
      column: $table.actorId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get baseVersion => $composableBuilder(
      column: $table.baseVersion, builder: (column) => ColumnFilters(column));
}

class $$OutboxEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $OutboxEntriesTable> {
  $$OutboxEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdBy => $composableBuilder(
      column: $table.createdBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedBy => $composableBuilder(
      column: $table.updatedBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get aggregateType => $composableBuilder(
      column: $table.aggregateType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get aggregateId => $composableBuilder(
      column: $table.aggregateId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get opType => $composableBuilder(
      column: $table.opType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get localSeq => $composableBuilder(
      column: $table.localSeq, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get actorId => $composableBuilder(
      column: $table.actorId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get baseVersion => $composableBuilder(
      column: $table.baseVersion, builder: (column) => ColumnOrderings(column));
}

class $$OutboxEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $OutboxEntriesTable> {
  $$OutboxEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<String> get updatedBy =>
      $composableBuilder(column: $table.updatedBy, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get aggregateType => $composableBuilder(
      column: $table.aggregateType, builder: (column) => column);

  GeneratedColumn<String> get aggregateId => $composableBuilder(
      column: $table.aggregateId, builder: (column) => column);

  GeneratedColumn<String> get opType =>
      $composableBuilder(column: $table.opType, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<int> get localSeq =>
      $composableBuilder(column: $table.localSeq, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get actorId =>
      $composableBuilder(column: $table.actorId, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get baseVersion => $composableBuilder(
      column: $table.baseVersion, builder: (column) => column);
}

class $$OutboxEntriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $OutboxEntriesTable,
    OutboxRow,
    $$OutboxEntriesTableFilterComposer,
    $$OutboxEntriesTableOrderingComposer,
    $$OutboxEntriesTableAnnotationComposer,
    $$OutboxEntriesTableCreateCompanionBuilder,
    $$OutboxEntriesTableUpdateCompanionBuilder,
    (OutboxRow, BaseReferences<_$AppDatabase, $OutboxEntriesTable, OutboxRow>),
    OutboxRow,
    PrefetchHooks Function()> {
  $$OutboxEntriesTableTableManager(_$AppDatabase db, $OutboxEntriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OutboxEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OutboxEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OutboxEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String?> createdBy = const Value.absent(),
            Value<String?> updatedBy = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<String> aggregateType = const Value.absent(),
            Value<String> aggregateId = const Value.absent(),
            Value<String> opType = const Value.absent(),
            Value<String> payload = const Value.absent(),
            Value<int> localSeq = const Value.absent(),
            Value<String> deviceId = const Value.absent(),
            Value<String> actorId = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int?> baseVersion = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              OutboxEntriesCompanion(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            createdBy: createdBy,
            updatedBy: updatedBy,
            version: version,
            aggregateType: aggregateType,
            aggregateId: aggregateId,
            opType: opType,
            payload: payload,
            localSeq: localSeq,
            deviceId: deviceId,
            actorId: actorId,
            status: status,
            baseVersion: baseVersion,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String?> createdBy = const Value.absent(),
            Value<String?> updatedBy = const Value.absent(),
            Value<int> version = const Value.absent(),
            required String aggregateType,
            required String aggregateId,
            required String opType,
            required String payload,
            required int localSeq,
            required String deviceId,
            required String actorId,
            Value<String> status = const Value.absent(),
            Value<int?> baseVersion = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              OutboxEntriesCompanion.insert(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            createdBy: createdBy,
            updatedBy: updatedBy,
            version: version,
            aggregateType: aggregateType,
            aggregateId: aggregateId,
            opType: opType,
            payload: payload,
            localSeq: localSeq,
            deviceId: deviceId,
            actorId: actorId,
            status: status,
            baseVersion: baseVersion,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$OutboxEntriesTable, OutboxRow>(table),
                    BaseReferences<_$AppDatabase, $OutboxEntriesTable,
                        OutboxRow>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$OutboxEntriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $OutboxEntriesTable,
    OutboxRow,
    $$OutboxEntriesTableFilterComposer,
    $$OutboxEntriesTableOrderingComposer,
    $$OutboxEntriesTableAnnotationComposer,
    $$OutboxEntriesTableCreateCompanionBuilder,
    $$OutboxEntriesTableUpdateCompanionBuilder,
    (OutboxRow, BaseReferences<_$AppDatabase, $OutboxEntriesTable, OutboxRow>),
    OutboxRow,
    PrefetchHooks Function()>;
typedef $$CachedProfilesTableCreateCompanionBuilder = CachedProfilesCompanion
    Function({
  required String userId,
  required String username,
  required String displayName,
  Value<String?> defaultBranchId,
  required String branches,
  Value<DateTime> cachedAt,
  Value<int> rowid,
});
typedef $$CachedProfilesTableUpdateCompanionBuilder = CachedProfilesCompanion
    Function({
  Value<String> userId,
  Value<String> username,
  Value<String> displayName,
  Value<String?> defaultBranchId,
  Value<String> branches,
  Value<DateTime> cachedAt,
  Value<int> rowid,
});

class $$CachedProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $CachedProfilesTable> {
  $$CachedProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get username => $composableBuilder(
      column: $table.username, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get defaultBranchId => $composableBuilder(
      column: $table.defaultBranchId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get branches => $composableBuilder(
      column: $table.branches, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
      column: $table.cachedAt, builder: (column) => ColumnFilters(column));
}

class $$CachedProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedProfilesTable> {
  $$CachedProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get username => $composableBuilder(
      column: $table.username, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get defaultBranchId => $composableBuilder(
      column: $table.defaultBranchId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get branches => $composableBuilder(
      column: $table.branches, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
      column: $table.cachedAt, builder: (column) => ColumnOrderings(column));
}

class $$CachedProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedProfilesTable> {
  $$CachedProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => column);

  GeneratedColumn<String> get defaultBranchId => $composableBuilder(
      column: $table.defaultBranchId, builder: (column) => column);

  GeneratedColumn<String> get branches =>
      $composableBuilder(column: $table.branches, builder: (column) => column);

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $$CachedProfilesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CachedProfilesTable,
    CachedProfileRow,
    $$CachedProfilesTableFilterComposer,
    $$CachedProfilesTableOrderingComposer,
    $$CachedProfilesTableAnnotationComposer,
    $$CachedProfilesTableCreateCompanionBuilder,
    $$CachedProfilesTableUpdateCompanionBuilder,
    (
      CachedProfileRow,
      BaseReferences<_$AppDatabase, $CachedProfilesTable, CachedProfileRow>
    ),
    CachedProfileRow,
    PrefetchHooks Function()> {
  $$CachedProfilesTableTableManager(
      _$AppDatabase db, $CachedProfilesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> userId = const Value.absent(),
            Value<String> username = const Value.absent(),
            Value<String> displayName = const Value.absent(),
            Value<String?> defaultBranchId = const Value.absent(),
            Value<String> branches = const Value.absent(),
            Value<DateTime> cachedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CachedProfilesCompanion(
            userId: userId,
            username: username,
            displayName: displayName,
            defaultBranchId: defaultBranchId,
            branches: branches,
            cachedAt: cachedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String userId,
            required String username,
            required String displayName,
            Value<String?> defaultBranchId = const Value.absent(),
            required String branches,
            Value<DateTime> cachedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CachedProfilesCompanion.insert(
            userId: userId,
            username: username,
            displayName: displayName,
            defaultBranchId: defaultBranchId,
            branches: branches,
            cachedAt: cachedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$CachedProfilesTable, CachedProfileRow>(table),
                    BaseReferences<_$AppDatabase, $CachedProfilesTable,
                        CachedProfileRow>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CachedProfilesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CachedProfilesTable,
    CachedProfileRow,
    $$CachedProfilesTableFilterComposer,
    $$CachedProfilesTableOrderingComposer,
    $$CachedProfilesTableAnnotationComposer,
    $$CachedProfilesTableCreateCompanionBuilder,
    $$CachedProfilesTableUpdateCompanionBuilder,
    (
      CachedProfileRow,
      BaseReferences<_$AppDatabase, $CachedProfilesTable, CachedProfileRow>
    ),
    CachedProfileRow,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$OutboxEntriesTableTableManager get outboxEntries =>
      $$OutboxEntriesTableTableManager(_db, _db.outboxEntries);
  $$CachedProfilesTableTableManager get cachedProfiles =>
      $$CachedProfilesTableTableManager(_db, _db.cachedProfiles);
}
