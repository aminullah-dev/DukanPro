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

class $UnitsTable extends Units with TableInfo<$UnitsTable, UnitRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UnitsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _decimalPlacesMeta =
      const VerificationMeta('decimalPlaces');
  @override
  late final GeneratedColumn<int> decimalPlaces = GeneratedColumn<int>(
      'decimal_places', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        createdAt,
        updatedAt,
        deletedAt,
        createdBy,
        updatedBy,
        version,
        name,
        decimalPlaces
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'units';
  @override
  VerificationContext validateIntegrity(Insertable<UnitRow> instance,
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
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('decimal_places')) {
      context.handle(
          _decimalPlacesMeta,
          decimalPlaces.isAcceptableOrUnknown(
              data['decimal_places']!, _decimalPlacesMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UnitRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UnitRow(
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
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      decimalPlaces: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}decimal_places'])!,
    );
  }

  @override
  $UnitsTable createAlias(String alias) {
    return $UnitsTable(attachedDatabase, alias);
  }
}

class UnitRow extends DataClass implements Insertable<UnitRow> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String? createdBy;
  final String? updatedBy;
  final int version;
  final String name;
  final int decimalPlaces;
  const UnitRow(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt,
      this.createdBy,
      this.updatedBy,
      required this.version,
      required this.name,
      required this.decimalPlaces});
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
    map['name'] = Variable<String>(name);
    map['decimal_places'] = Variable<int>(decimalPlaces);
    return map;
  }

  UnitsCompanion toCompanion(bool nullToAbsent) {
    return UnitsCompanion(
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
      name: Value(name),
      decimalPlaces: Value(decimalPlaces),
    );
  }

  factory UnitRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UnitRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
      updatedBy: serializer.fromJson<String?>(json['updatedBy']),
      version: serializer.fromJson<int>(json['version']),
      name: serializer.fromJson<String>(json['name']),
      decimalPlaces: serializer.fromJson<int>(json['decimalPlaces']),
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
      'name': serializer.toJson<String>(name),
      'decimalPlaces': serializer.toJson<int>(decimalPlaces),
    };
  }

  UnitRow copyWith(
          {String? id,
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          Value<String?> createdBy = const Value.absent(),
          Value<String?> updatedBy = const Value.absent(),
          int? version,
          String? name,
          int? decimalPlaces}) =>
      UnitRow(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        createdBy: createdBy.present ? createdBy.value : this.createdBy,
        updatedBy: updatedBy.present ? updatedBy.value : this.updatedBy,
        version: version ?? this.version,
        name: name ?? this.name,
        decimalPlaces: decimalPlaces ?? this.decimalPlaces,
      );
  UnitRow copyWithCompanion(UnitsCompanion data) {
    return UnitRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      version: data.version.present ? data.version.value : this.version,
      name: data.name.present ? data.name.value : this.name,
      decimalPlaces: data.decimalPlaces.present
          ? data.decimalPlaces.value
          : this.decimalPlaces,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UnitRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('version: $version, ')
          ..write('name: $name, ')
          ..write('decimalPlaces: $decimalPlaces')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, createdAt, updatedAt, deletedAt,
      createdBy, updatedBy, version, name, decimalPlaces);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UnitRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.createdBy == this.createdBy &&
          other.updatedBy == this.updatedBy &&
          other.version == this.version &&
          other.name == this.name &&
          other.decimalPlaces == this.decimalPlaces);
}

class UnitsCompanion extends UpdateCompanion<UnitRow> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String?> createdBy;
  final Value<String?> updatedBy;
  final Value<int> version;
  final Value<String> name;
  final Value<int> decimalPlaces;
  final Value<int> rowid;
  const UnitsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.version = const Value.absent(),
    this.name = const Value.absent(),
    this.decimalPlaces = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UnitsCompanion.insert({
    required String id,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.version = const Value.absent(),
    required String name,
    this.decimalPlaces = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name);
  static Insertable<UnitRow> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? createdBy,
    Expression<String>? updatedBy,
    Expression<int>? version,
    Expression<String>? name,
    Expression<int>? decimalPlaces,
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
      if (name != null) 'name': name,
      if (decimalPlaces != null) 'decimal_places': decimalPlaces,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UnitsCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<String?>? createdBy,
      Value<String?>? updatedBy,
      Value<int>? version,
      Value<String>? name,
      Value<int>? decimalPlaces,
      Value<int>? rowid}) {
    return UnitsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      version: version ?? this.version,
      name: name ?? this.name,
      decimalPlaces: decimalPlaces ?? this.decimalPlaces,
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
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (decimalPlaces.present) {
      map['decimal_places'] = Variable<int>(decimalPlaces.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UnitsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('version: $version, ')
          ..write('name: $name, ')
          ..write('decimalPlaces: $decimalPlaces, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, CategoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _parentIdMeta =
      const VerificationMeta('parentId');
  @override
  late final GeneratedColumn<String> parentId = GeneratedColumn<String>(
      'parent_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        createdAt,
        updatedAt,
        deletedAt,
        createdBy,
        updatedBy,
        version,
        name,
        parentId
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(Insertable<CategoryRow> instance,
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
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('parent_id')) {
      context.handle(_parentIdMeta,
          parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CategoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoryRow(
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
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      parentId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}parent_id']),
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class CategoryRow extends DataClass implements Insertable<CategoryRow> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String? createdBy;
  final String? updatedBy;
  final int version;
  final String name;
  final String? parentId;
  const CategoryRow(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt,
      this.createdBy,
      this.updatedBy,
      required this.version,
      required this.name,
      this.parentId});
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
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<String>(parentId);
    }
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
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
      name: Value(name),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
    );
  }

  factory CategoryRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoryRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
      updatedBy: serializer.fromJson<String?>(json['updatedBy']),
      version: serializer.fromJson<int>(json['version']),
      name: serializer.fromJson<String>(json['name']),
      parentId: serializer.fromJson<String?>(json['parentId']),
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
      'name': serializer.toJson<String>(name),
      'parentId': serializer.toJson<String?>(parentId),
    };
  }

  CategoryRow copyWith(
          {String? id,
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          Value<String?> createdBy = const Value.absent(),
          Value<String?> updatedBy = const Value.absent(),
          int? version,
          String? name,
          Value<String?> parentId = const Value.absent()}) =>
      CategoryRow(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        createdBy: createdBy.present ? createdBy.value : this.createdBy,
        updatedBy: updatedBy.present ? updatedBy.value : this.updatedBy,
        version: version ?? this.version,
        name: name ?? this.name,
        parentId: parentId.present ? parentId.value : this.parentId,
      );
  CategoryRow copyWithCompanion(CategoriesCompanion data) {
    return CategoryRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      version: data.version.present ? data.version.value : this.version,
      name: data.name.present ? data.name.value : this.name,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoryRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('version: $version, ')
          ..write('name: $name, ')
          ..write('parentId: $parentId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, createdAt, updatedAt, deletedAt,
      createdBy, updatedBy, version, name, parentId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoryRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.createdBy == this.createdBy &&
          other.updatedBy == this.updatedBy &&
          other.version == this.version &&
          other.name == this.name &&
          other.parentId == this.parentId);
}

class CategoriesCompanion extends UpdateCompanion<CategoryRow> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String?> createdBy;
  final Value<String?> updatedBy;
  final Value<int> version;
  final Value<String> name;
  final Value<String?> parentId;
  final Value<int> rowid;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.version = const Value.absent(),
    this.name = const Value.absent(),
    this.parentId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoriesCompanion.insert({
    required String id,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.version = const Value.absent(),
    required String name,
    this.parentId = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name);
  static Insertable<CategoryRow> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? createdBy,
    Expression<String>? updatedBy,
    Expression<int>? version,
    Expression<String>? name,
    Expression<String>? parentId,
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
      if (name != null) 'name': name,
      if (parentId != null) 'parent_id': parentId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoriesCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<String?>? createdBy,
      Value<String?>? updatedBy,
      Value<int>? version,
      Value<String>? name,
      Value<String?>? parentId,
      Value<int>? rowid}) {
    return CategoriesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      version: version ?? this.version,
      name: name ?? this.name,
      parentId: parentId ?? this.parentId,
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
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<String>(parentId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('version: $version, ')
          ..write('name: $name, ')
          ..write('parentId: $parentId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProductsTable extends Products
    with TableInfo<$ProductsTable, ProductRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _skuMeta = const VerificationMeta('sku');
  @override
  late final GeneratedColumn<String> sku = GeneratedColumn<String>(
      'sku', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _unitIdMeta = const VerificationMeta('unitId');
  @override
  late final GeneratedColumn<String> unitId = GeneratedColumn<String>(
      'unit_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
      'category_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sellPriceMinorMeta =
      const VerificationMeta('sellPriceMinor');
  @override
  late final GeneratedColumn<int> sellPriceMinor = GeneratedColumn<int>(
      'sell_price_minor', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _sellCurrencyMeta =
      const VerificationMeta('sellCurrency');
  @override
  late final GeneratedColumn<String> sellCurrency = GeneratedColumn<String>(
      'sell_currency', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('AFN'));
  static const VerificationMeta _costMinorMeta =
      const VerificationMeta('costMinor');
  @override
  late final GeneratedColumn<int> costMinor = GeneratedColumn<int>(
      'cost_minor', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _costCurrencyMeta =
      const VerificationMeta('costCurrency');
  @override
  late final GeneratedColumn<String> costCurrency = GeneratedColumn<String>(
      'cost_currency', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _trackStockMeta =
      const VerificationMeta('trackStock');
  @override
  late final GeneratedColumn<bool> trackStock = GeneratedColumn<bool>(
      'track_stock', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("track_stock" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        createdAt,
        updatedAt,
        deletedAt,
        createdBy,
        updatedBy,
        version,
        sku,
        name,
        unitId,
        categoryId,
        sellPriceMinor,
        sellCurrency,
        costMinor,
        costCurrency,
        trackStock,
        isActive
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'products';
  @override
  VerificationContext validateIntegrity(Insertable<ProductRow> instance,
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
    if (data.containsKey('sku')) {
      context.handle(
          _skuMeta, sku.isAcceptableOrUnknown(data['sku']!, _skuMeta));
    } else if (isInserting) {
      context.missing(_skuMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('unit_id')) {
      context.handle(_unitIdMeta,
          unitId.isAcceptableOrUnknown(data['unit_id']!, _unitIdMeta));
    } else if (isInserting) {
      context.missing(_unitIdMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    }
    if (data.containsKey('sell_price_minor')) {
      context.handle(
          _sellPriceMinorMeta,
          sellPriceMinor.isAcceptableOrUnknown(
              data['sell_price_minor']!, _sellPriceMinorMeta));
    }
    if (data.containsKey('sell_currency')) {
      context.handle(
          _sellCurrencyMeta,
          sellCurrency.isAcceptableOrUnknown(
              data['sell_currency']!, _sellCurrencyMeta));
    }
    if (data.containsKey('cost_minor')) {
      context.handle(_costMinorMeta,
          costMinor.isAcceptableOrUnknown(data['cost_minor']!, _costMinorMeta));
    }
    if (data.containsKey('cost_currency')) {
      context.handle(
          _costCurrencyMeta,
          costCurrency.isAcceptableOrUnknown(
              data['cost_currency']!, _costCurrencyMeta));
    }
    if (data.containsKey('track_stock')) {
      context.handle(
          _trackStockMeta,
          trackStock.isAcceptableOrUnknown(
              data['track_stock']!, _trackStockMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProductRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProductRow(
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
      sku: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sku'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      unitId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}unit_id'])!,
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category_id']),
      sellPriceMinor: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sell_price_minor'])!,
      sellCurrency: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sell_currency'])!,
      costMinor: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}cost_minor']),
      costCurrency: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cost_currency']),
      trackStock: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}track_stock'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
    );
  }

  @override
  $ProductsTable createAlias(String alias) {
    return $ProductsTable(attachedDatabase, alias);
  }
}

class ProductRow extends DataClass implements Insertable<ProductRow> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String? createdBy;
  final String? updatedBy;
  final int version;
  final String sku;
  final String name;
  final String unitId;
  final String? categoryId;
  final int sellPriceMinor;
  final String sellCurrency;
  final int? costMinor;
  final String? costCurrency;
  final bool trackStock;
  final bool isActive;
  const ProductRow(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt,
      this.createdBy,
      this.updatedBy,
      required this.version,
      required this.sku,
      required this.name,
      required this.unitId,
      this.categoryId,
      required this.sellPriceMinor,
      required this.sellCurrency,
      this.costMinor,
      this.costCurrency,
      required this.trackStock,
      required this.isActive});
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
    map['sku'] = Variable<String>(sku);
    map['name'] = Variable<String>(name);
    map['unit_id'] = Variable<String>(unitId);
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<String>(categoryId);
    }
    map['sell_price_minor'] = Variable<int>(sellPriceMinor);
    map['sell_currency'] = Variable<String>(sellCurrency);
    if (!nullToAbsent || costMinor != null) {
      map['cost_minor'] = Variable<int>(costMinor);
    }
    if (!nullToAbsent || costCurrency != null) {
      map['cost_currency'] = Variable<String>(costCurrency);
    }
    map['track_stock'] = Variable<bool>(trackStock);
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  ProductsCompanion toCompanion(bool nullToAbsent) {
    return ProductsCompanion(
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
      sku: Value(sku),
      name: Value(name),
      unitId: Value(unitId),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      sellPriceMinor: Value(sellPriceMinor),
      sellCurrency: Value(sellCurrency),
      costMinor: costMinor == null && nullToAbsent
          ? const Value.absent()
          : Value(costMinor),
      costCurrency: costCurrency == null && nullToAbsent
          ? const Value.absent()
          : Value(costCurrency),
      trackStock: Value(trackStock),
      isActive: Value(isActive),
    );
  }

  factory ProductRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProductRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
      updatedBy: serializer.fromJson<String?>(json['updatedBy']),
      version: serializer.fromJson<int>(json['version']),
      sku: serializer.fromJson<String>(json['sku']),
      name: serializer.fromJson<String>(json['name']),
      unitId: serializer.fromJson<String>(json['unitId']),
      categoryId: serializer.fromJson<String?>(json['categoryId']),
      sellPriceMinor: serializer.fromJson<int>(json['sellPriceMinor']),
      sellCurrency: serializer.fromJson<String>(json['sellCurrency']),
      costMinor: serializer.fromJson<int?>(json['costMinor']),
      costCurrency: serializer.fromJson<String?>(json['costCurrency']),
      trackStock: serializer.fromJson<bool>(json['trackStock']),
      isActive: serializer.fromJson<bool>(json['isActive']),
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
      'sku': serializer.toJson<String>(sku),
      'name': serializer.toJson<String>(name),
      'unitId': serializer.toJson<String>(unitId),
      'categoryId': serializer.toJson<String?>(categoryId),
      'sellPriceMinor': serializer.toJson<int>(sellPriceMinor),
      'sellCurrency': serializer.toJson<String>(sellCurrency),
      'costMinor': serializer.toJson<int?>(costMinor),
      'costCurrency': serializer.toJson<String?>(costCurrency),
      'trackStock': serializer.toJson<bool>(trackStock),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  ProductRow copyWith(
          {String? id,
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          Value<String?> createdBy = const Value.absent(),
          Value<String?> updatedBy = const Value.absent(),
          int? version,
          String? sku,
          String? name,
          String? unitId,
          Value<String?> categoryId = const Value.absent(),
          int? sellPriceMinor,
          String? sellCurrency,
          Value<int?> costMinor = const Value.absent(),
          Value<String?> costCurrency = const Value.absent(),
          bool? trackStock,
          bool? isActive}) =>
      ProductRow(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        createdBy: createdBy.present ? createdBy.value : this.createdBy,
        updatedBy: updatedBy.present ? updatedBy.value : this.updatedBy,
        version: version ?? this.version,
        sku: sku ?? this.sku,
        name: name ?? this.name,
        unitId: unitId ?? this.unitId,
        categoryId: categoryId.present ? categoryId.value : this.categoryId,
        sellPriceMinor: sellPriceMinor ?? this.sellPriceMinor,
        sellCurrency: sellCurrency ?? this.sellCurrency,
        costMinor: costMinor.present ? costMinor.value : this.costMinor,
        costCurrency:
            costCurrency.present ? costCurrency.value : this.costCurrency,
        trackStock: trackStock ?? this.trackStock,
        isActive: isActive ?? this.isActive,
      );
  ProductRow copyWithCompanion(ProductsCompanion data) {
    return ProductRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      version: data.version.present ? data.version.value : this.version,
      sku: data.sku.present ? data.sku.value : this.sku,
      name: data.name.present ? data.name.value : this.name,
      unitId: data.unitId.present ? data.unitId.value : this.unitId,
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
      sellPriceMinor: data.sellPriceMinor.present
          ? data.sellPriceMinor.value
          : this.sellPriceMinor,
      sellCurrency: data.sellCurrency.present
          ? data.sellCurrency.value
          : this.sellCurrency,
      costMinor: data.costMinor.present ? data.costMinor.value : this.costMinor,
      costCurrency: data.costCurrency.present
          ? data.costCurrency.value
          : this.costCurrency,
      trackStock:
          data.trackStock.present ? data.trackStock.value : this.trackStock,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProductRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('version: $version, ')
          ..write('sku: $sku, ')
          ..write('name: $name, ')
          ..write('unitId: $unitId, ')
          ..write('categoryId: $categoryId, ')
          ..write('sellPriceMinor: $sellPriceMinor, ')
          ..write('sellCurrency: $sellCurrency, ')
          ..write('costMinor: $costMinor, ')
          ..write('costCurrency: $costCurrency, ')
          ..write('trackStock: $trackStock, ')
          ..write('isActive: $isActive')
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
      sku,
      name,
      unitId,
      categoryId,
      sellPriceMinor,
      sellCurrency,
      costMinor,
      costCurrency,
      trackStock,
      isActive);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProductRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.createdBy == this.createdBy &&
          other.updatedBy == this.updatedBy &&
          other.version == this.version &&
          other.sku == this.sku &&
          other.name == this.name &&
          other.unitId == this.unitId &&
          other.categoryId == this.categoryId &&
          other.sellPriceMinor == this.sellPriceMinor &&
          other.sellCurrency == this.sellCurrency &&
          other.costMinor == this.costMinor &&
          other.costCurrency == this.costCurrency &&
          other.trackStock == this.trackStock &&
          other.isActive == this.isActive);
}

class ProductsCompanion extends UpdateCompanion<ProductRow> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String?> createdBy;
  final Value<String?> updatedBy;
  final Value<int> version;
  final Value<String> sku;
  final Value<String> name;
  final Value<String> unitId;
  final Value<String?> categoryId;
  final Value<int> sellPriceMinor;
  final Value<String> sellCurrency;
  final Value<int?> costMinor;
  final Value<String?> costCurrency;
  final Value<bool> trackStock;
  final Value<bool> isActive;
  final Value<int> rowid;
  const ProductsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.version = const Value.absent(),
    this.sku = const Value.absent(),
    this.name = const Value.absent(),
    this.unitId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.sellPriceMinor = const Value.absent(),
    this.sellCurrency = const Value.absent(),
    this.costMinor = const Value.absent(),
    this.costCurrency = const Value.absent(),
    this.trackStock = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProductsCompanion.insert({
    required String id,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.version = const Value.absent(),
    required String sku,
    required String name,
    required String unitId,
    this.categoryId = const Value.absent(),
    this.sellPriceMinor = const Value.absent(),
    this.sellCurrency = const Value.absent(),
    this.costMinor = const Value.absent(),
    this.costCurrency = const Value.absent(),
    this.trackStock = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        sku = Value(sku),
        name = Value(name),
        unitId = Value(unitId);
  static Insertable<ProductRow> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? createdBy,
    Expression<String>? updatedBy,
    Expression<int>? version,
    Expression<String>? sku,
    Expression<String>? name,
    Expression<String>? unitId,
    Expression<String>? categoryId,
    Expression<int>? sellPriceMinor,
    Expression<String>? sellCurrency,
    Expression<int>? costMinor,
    Expression<String>? costCurrency,
    Expression<bool>? trackStock,
    Expression<bool>? isActive,
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
      if (sku != null) 'sku': sku,
      if (name != null) 'name': name,
      if (unitId != null) 'unit_id': unitId,
      if (categoryId != null) 'category_id': categoryId,
      if (sellPriceMinor != null) 'sell_price_minor': sellPriceMinor,
      if (sellCurrency != null) 'sell_currency': sellCurrency,
      if (costMinor != null) 'cost_minor': costMinor,
      if (costCurrency != null) 'cost_currency': costCurrency,
      if (trackStock != null) 'track_stock': trackStock,
      if (isActive != null) 'is_active': isActive,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProductsCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<String?>? createdBy,
      Value<String?>? updatedBy,
      Value<int>? version,
      Value<String>? sku,
      Value<String>? name,
      Value<String>? unitId,
      Value<String?>? categoryId,
      Value<int>? sellPriceMinor,
      Value<String>? sellCurrency,
      Value<int?>? costMinor,
      Value<String?>? costCurrency,
      Value<bool>? trackStock,
      Value<bool>? isActive,
      Value<int>? rowid}) {
    return ProductsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      version: version ?? this.version,
      sku: sku ?? this.sku,
      name: name ?? this.name,
      unitId: unitId ?? this.unitId,
      categoryId: categoryId ?? this.categoryId,
      sellPriceMinor: sellPriceMinor ?? this.sellPriceMinor,
      sellCurrency: sellCurrency ?? this.sellCurrency,
      costMinor: costMinor ?? this.costMinor,
      costCurrency: costCurrency ?? this.costCurrency,
      trackStock: trackStock ?? this.trackStock,
      isActive: isActive ?? this.isActive,
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
    if (sku.present) {
      map['sku'] = Variable<String>(sku.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (unitId.present) {
      map['unit_id'] = Variable<String>(unitId.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (sellPriceMinor.present) {
      map['sell_price_minor'] = Variable<int>(sellPriceMinor.value);
    }
    if (sellCurrency.present) {
      map['sell_currency'] = Variable<String>(sellCurrency.value);
    }
    if (costMinor.present) {
      map['cost_minor'] = Variable<int>(costMinor.value);
    }
    if (costCurrency.present) {
      map['cost_currency'] = Variable<String>(costCurrency.value);
    }
    if (trackStock.present) {
      map['track_stock'] = Variable<bool>(trackStock.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('version: $version, ')
          ..write('sku: $sku, ')
          ..write('name: $name, ')
          ..write('unitId: $unitId, ')
          ..write('categoryId: $categoryId, ')
          ..write('sellPriceMinor: $sellPriceMinor, ')
          ..write('sellCurrency: $sellCurrency, ')
          ..write('costMinor: $costMinor, ')
          ..write('costCurrency: $costCurrency, ')
          ..write('trackStock: $trackStock, ')
          ..write('isActive: $isActive, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BarcodesTable extends Barcodes
    with TableInfo<$BarcodesTable, BarcodeRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BarcodesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _productIdMeta =
      const VerificationMeta('productId');
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
      'product_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
      'code', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _symbologyMeta =
      const VerificationMeta('symbology');
  @override
  late final GeneratedColumn<String> symbology = GeneratedColumn<String>(
      'symbology', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('ean13'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        createdAt,
        updatedAt,
        deletedAt,
        createdBy,
        updatedBy,
        version,
        productId,
        code,
        symbology
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'barcodes';
  @override
  VerificationContext validateIntegrity(Insertable<BarcodeRow> instance,
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
    if (data.containsKey('product_id')) {
      context.handle(_productIdMeta,
          productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta));
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
          _codeMeta, code.isAcceptableOrUnknown(data['code']!, _codeMeta));
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('symbology')) {
      context.handle(_symbologyMeta,
          symbology.isAcceptableOrUnknown(data['symbology']!, _symbologyMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BarcodeRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BarcodeRow(
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
      productId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}product_id'])!,
      code: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}code'])!,
      symbology: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}symbology'])!,
    );
  }

  @override
  $BarcodesTable createAlias(String alias) {
    return $BarcodesTable(attachedDatabase, alias);
  }
}

class BarcodeRow extends DataClass implements Insertable<BarcodeRow> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String? createdBy;
  final String? updatedBy;
  final int version;
  final String productId;
  final String code;
  final String symbology;
  const BarcodeRow(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt,
      this.createdBy,
      this.updatedBy,
      required this.version,
      required this.productId,
      required this.code,
      required this.symbology});
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
    map['product_id'] = Variable<String>(productId);
    map['code'] = Variable<String>(code);
    map['symbology'] = Variable<String>(symbology);
    return map;
  }

  BarcodesCompanion toCompanion(bool nullToAbsent) {
    return BarcodesCompanion(
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
      productId: Value(productId),
      code: Value(code),
      symbology: Value(symbology),
    );
  }

  factory BarcodeRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BarcodeRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
      updatedBy: serializer.fromJson<String?>(json['updatedBy']),
      version: serializer.fromJson<int>(json['version']),
      productId: serializer.fromJson<String>(json['productId']),
      code: serializer.fromJson<String>(json['code']),
      symbology: serializer.fromJson<String>(json['symbology']),
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
      'productId': serializer.toJson<String>(productId),
      'code': serializer.toJson<String>(code),
      'symbology': serializer.toJson<String>(symbology),
    };
  }

  BarcodeRow copyWith(
          {String? id,
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          Value<String?> createdBy = const Value.absent(),
          Value<String?> updatedBy = const Value.absent(),
          int? version,
          String? productId,
          String? code,
          String? symbology}) =>
      BarcodeRow(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        createdBy: createdBy.present ? createdBy.value : this.createdBy,
        updatedBy: updatedBy.present ? updatedBy.value : this.updatedBy,
        version: version ?? this.version,
        productId: productId ?? this.productId,
        code: code ?? this.code,
        symbology: symbology ?? this.symbology,
      );
  BarcodeRow copyWithCompanion(BarcodesCompanion data) {
    return BarcodeRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      version: data.version.present ? data.version.value : this.version,
      productId: data.productId.present ? data.productId.value : this.productId,
      code: data.code.present ? data.code.value : this.code,
      symbology: data.symbology.present ? data.symbology.value : this.symbology,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BarcodeRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('version: $version, ')
          ..write('productId: $productId, ')
          ..write('code: $code, ')
          ..write('symbology: $symbology')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, createdAt, updatedAt, deletedAt,
      createdBy, updatedBy, version, productId, code, symbology);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BarcodeRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.createdBy == this.createdBy &&
          other.updatedBy == this.updatedBy &&
          other.version == this.version &&
          other.productId == this.productId &&
          other.code == this.code &&
          other.symbology == this.symbology);
}

class BarcodesCompanion extends UpdateCompanion<BarcodeRow> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String?> createdBy;
  final Value<String?> updatedBy;
  final Value<int> version;
  final Value<String> productId;
  final Value<String> code;
  final Value<String> symbology;
  final Value<int> rowid;
  const BarcodesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.version = const Value.absent(),
    this.productId = const Value.absent(),
    this.code = const Value.absent(),
    this.symbology = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BarcodesCompanion.insert({
    required String id,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.version = const Value.absent(),
    required String productId,
    required String code,
    this.symbology = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        productId = Value(productId),
        code = Value(code);
  static Insertable<BarcodeRow> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? createdBy,
    Expression<String>? updatedBy,
    Expression<int>? version,
    Expression<String>? productId,
    Expression<String>? code,
    Expression<String>? symbology,
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
      if (productId != null) 'product_id': productId,
      if (code != null) 'code': code,
      if (symbology != null) 'symbology': symbology,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BarcodesCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<String?>? createdBy,
      Value<String?>? updatedBy,
      Value<int>? version,
      Value<String>? productId,
      Value<String>? code,
      Value<String>? symbology,
      Value<int>? rowid}) {
    return BarcodesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      version: version ?? this.version,
      productId: productId ?? this.productId,
      code: code ?? this.code,
      symbology: symbology ?? this.symbology,
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
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (symbology.present) {
      map['symbology'] = Variable<String>(symbology.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BarcodesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('version: $version, ')
          ..write('productId: $productId, ')
          ..write('code: $code, ')
          ..write('symbology: $symbology, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StockMovementsTable extends StockMovements
    with TableInfo<$StockMovementsTable, StockMovementRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StockMovementsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _productIdMeta =
      const VerificationMeta('productId');
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
      'product_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _branchIdMeta =
      const VerificationMeta('branchId');
  @override
  late final GeneratedColumn<String> branchId = GeneratedColumn<String>(
      'branch_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _qtyDeltaMeta =
      const VerificationMeta('qtyDelta');
  @override
  late final GeneratedColumn<int> qtyDelta = GeneratedColumn<int>(
      'qty_delta', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
      'reason', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _occurredAtMeta =
      const VerificationMeta('occurredAt');
  @override
  late final GeneratedColumn<DateTime> occurredAt = GeneratedColumn<DateTime>(
      'occurred_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        createdAt,
        updatedAt,
        deletedAt,
        createdBy,
        updatedBy,
        version,
        productId,
        branchId,
        qtyDelta,
        reason,
        occurredAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stock_movements';
  @override
  VerificationContext validateIntegrity(Insertable<StockMovementRow> instance,
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
    if (data.containsKey('product_id')) {
      context.handle(_productIdMeta,
          productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta));
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('branch_id')) {
      context.handle(_branchIdMeta,
          branchId.isAcceptableOrUnknown(data['branch_id']!, _branchIdMeta));
    } else if (isInserting) {
      context.missing(_branchIdMeta);
    }
    if (data.containsKey('qty_delta')) {
      context.handle(_qtyDeltaMeta,
          qtyDelta.isAcceptableOrUnknown(data['qty_delta']!, _qtyDeltaMeta));
    } else if (isInserting) {
      context.missing(_qtyDeltaMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(_reasonMeta,
          reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta));
    } else if (isInserting) {
      context.missing(_reasonMeta);
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
          _occurredAtMeta,
          occurredAt.isAcceptableOrUnknown(
              data['occurred_at']!, _occurredAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StockMovementRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StockMovementRow(
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
      productId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}product_id'])!,
      branchId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}branch_id'])!,
      qtyDelta: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}qty_delta'])!,
      reason: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reason'])!,
      occurredAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}occurred_at'])!,
    );
  }

  @override
  $StockMovementsTable createAlias(String alias) {
    return $StockMovementsTable(attachedDatabase, alias);
  }
}

class StockMovementRow extends DataClass
    implements Insertable<StockMovementRow> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String? createdBy;
  final String? updatedBy;
  final int version;
  final String productId;
  final String branchId;
  final int qtyDelta;
  final String reason;
  final DateTime occurredAt;
  const StockMovementRow(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt,
      this.createdBy,
      this.updatedBy,
      required this.version,
      required this.productId,
      required this.branchId,
      required this.qtyDelta,
      required this.reason,
      required this.occurredAt});
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
    map['product_id'] = Variable<String>(productId);
    map['branch_id'] = Variable<String>(branchId);
    map['qty_delta'] = Variable<int>(qtyDelta);
    map['reason'] = Variable<String>(reason);
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    return map;
  }

  StockMovementsCompanion toCompanion(bool nullToAbsent) {
    return StockMovementsCompanion(
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
      productId: Value(productId),
      branchId: Value(branchId),
      qtyDelta: Value(qtyDelta),
      reason: Value(reason),
      occurredAt: Value(occurredAt),
    );
  }

  factory StockMovementRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StockMovementRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
      updatedBy: serializer.fromJson<String?>(json['updatedBy']),
      version: serializer.fromJson<int>(json['version']),
      productId: serializer.fromJson<String>(json['productId']),
      branchId: serializer.fromJson<String>(json['branchId']),
      qtyDelta: serializer.fromJson<int>(json['qtyDelta']),
      reason: serializer.fromJson<String>(json['reason']),
      occurredAt: serializer.fromJson<DateTime>(json['occurredAt']),
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
      'productId': serializer.toJson<String>(productId),
      'branchId': serializer.toJson<String>(branchId),
      'qtyDelta': serializer.toJson<int>(qtyDelta),
      'reason': serializer.toJson<String>(reason),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
    };
  }

  StockMovementRow copyWith(
          {String? id,
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          Value<String?> createdBy = const Value.absent(),
          Value<String?> updatedBy = const Value.absent(),
          int? version,
          String? productId,
          String? branchId,
          int? qtyDelta,
          String? reason,
          DateTime? occurredAt}) =>
      StockMovementRow(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        createdBy: createdBy.present ? createdBy.value : this.createdBy,
        updatedBy: updatedBy.present ? updatedBy.value : this.updatedBy,
        version: version ?? this.version,
        productId: productId ?? this.productId,
        branchId: branchId ?? this.branchId,
        qtyDelta: qtyDelta ?? this.qtyDelta,
        reason: reason ?? this.reason,
        occurredAt: occurredAt ?? this.occurredAt,
      );
  StockMovementRow copyWithCompanion(StockMovementsCompanion data) {
    return StockMovementRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      version: data.version.present ? data.version.value : this.version,
      productId: data.productId.present ? data.productId.value : this.productId,
      branchId: data.branchId.present ? data.branchId.value : this.branchId,
      qtyDelta: data.qtyDelta.present ? data.qtyDelta.value : this.qtyDelta,
      reason: data.reason.present ? data.reason.value : this.reason,
      occurredAt:
          data.occurredAt.present ? data.occurredAt.value : this.occurredAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StockMovementRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('version: $version, ')
          ..write('productId: $productId, ')
          ..write('branchId: $branchId, ')
          ..write('qtyDelta: $qtyDelta, ')
          ..write('reason: $reason, ')
          ..write('occurredAt: $occurredAt')
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
      productId,
      branchId,
      qtyDelta,
      reason,
      occurredAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StockMovementRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.createdBy == this.createdBy &&
          other.updatedBy == this.updatedBy &&
          other.version == this.version &&
          other.productId == this.productId &&
          other.branchId == this.branchId &&
          other.qtyDelta == this.qtyDelta &&
          other.reason == this.reason &&
          other.occurredAt == this.occurredAt);
}

class StockMovementsCompanion extends UpdateCompanion<StockMovementRow> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String?> createdBy;
  final Value<String?> updatedBy;
  final Value<int> version;
  final Value<String> productId;
  final Value<String> branchId;
  final Value<int> qtyDelta;
  final Value<String> reason;
  final Value<DateTime> occurredAt;
  final Value<int> rowid;
  const StockMovementsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.version = const Value.absent(),
    this.productId = const Value.absent(),
    this.branchId = const Value.absent(),
    this.qtyDelta = const Value.absent(),
    this.reason = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StockMovementsCompanion.insert({
    required String id,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.version = const Value.absent(),
    required String productId,
    required String branchId,
    required int qtyDelta,
    required String reason,
    this.occurredAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        productId = Value(productId),
        branchId = Value(branchId),
        qtyDelta = Value(qtyDelta),
        reason = Value(reason);
  static Insertable<StockMovementRow> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? createdBy,
    Expression<String>? updatedBy,
    Expression<int>? version,
    Expression<String>? productId,
    Expression<String>? branchId,
    Expression<int>? qtyDelta,
    Expression<String>? reason,
    Expression<DateTime>? occurredAt,
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
      if (productId != null) 'product_id': productId,
      if (branchId != null) 'branch_id': branchId,
      if (qtyDelta != null) 'qty_delta': qtyDelta,
      if (reason != null) 'reason': reason,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StockMovementsCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<String?>? createdBy,
      Value<String?>? updatedBy,
      Value<int>? version,
      Value<String>? productId,
      Value<String>? branchId,
      Value<int>? qtyDelta,
      Value<String>? reason,
      Value<DateTime>? occurredAt,
      Value<int>? rowid}) {
    return StockMovementsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      version: version ?? this.version,
      productId: productId ?? this.productId,
      branchId: branchId ?? this.branchId,
      qtyDelta: qtyDelta ?? this.qtyDelta,
      reason: reason ?? this.reason,
      occurredAt: occurredAt ?? this.occurredAt,
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
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (branchId.present) {
      map['branch_id'] = Variable<String>(branchId.value);
    }
    if (qtyDelta.present) {
      map['qty_delta'] = Variable<int>(qtyDelta.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<DateTime>(occurredAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StockMovementsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('version: $version, ')
          ..write('productId: $productId, ')
          ..write('branchId: $branchId, ')
          ..write('qtyDelta: $qtyDelta, ')
          ..write('reason: $reason, ')
          ..write('occurredAt: $occurredAt, ')
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
  late final $UnitsTable units = $UnitsTable(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $ProductsTable products = $ProductsTable(this);
  late final $BarcodesTable barcodes = $BarcodesTable(this);
  late final $StockMovementsTable stockMovements = $StockMovementsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        outboxEntries,
        cachedProfiles,
        units,
        categories,
        products,
        barcodes,
        stockMovements
      ];
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
typedef $$UnitsTableCreateCompanionBuilder = UnitsCompanion Function({
  required String id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String?> createdBy,
  Value<String?> updatedBy,
  Value<int> version,
  required String name,
  Value<int> decimalPlaces,
  Value<int> rowid,
});
typedef $$UnitsTableUpdateCompanionBuilder = UnitsCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String?> createdBy,
  Value<String?> updatedBy,
  Value<int> version,
  Value<String> name,
  Value<int> decimalPlaces,
  Value<int> rowid,
});

class $$UnitsTableFilterComposer extends Composer<_$AppDatabase, $UnitsTable> {
  $$UnitsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get decimalPlaces => $composableBuilder(
      column: $table.decimalPlaces, builder: (column) => ColumnFilters(column));
}

class $$UnitsTableOrderingComposer
    extends Composer<_$AppDatabase, $UnitsTable> {
  $$UnitsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get decimalPlaces => $composableBuilder(
      column: $table.decimalPlaces,
      builder: (column) => ColumnOrderings(column));
}

class $$UnitsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UnitsTable> {
  $$UnitsTableAnnotationComposer({
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

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get decimalPlaces => $composableBuilder(
      column: $table.decimalPlaces, builder: (column) => column);
}

class $$UnitsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UnitsTable,
    UnitRow,
    $$UnitsTableFilterComposer,
    $$UnitsTableOrderingComposer,
    $$UnitsTableAnnotationComposer,
    $$UnitsTableCreateCompanionBuilder,
    $$UnitsTableUpdateCompanionBuilder,
    (UnitRow, BaseReferences<_$AppDatabase, $UnitsTable, UnitRow>),
    UnitRow,
    PrefetchHooks Function()> {
  $$UnitsTableTableManager(_$AppDatabase db, $UnitsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UnitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UnitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UnitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String?> createdBy = const Value.absent(),
            Value<String?> updatedBy = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> decimalPlaces = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UnitsCompanion(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            createdBy: createdBy,
            updatedBy: updatedBy,
            version: version,
            name: name,
            decimalPlaces: decimalPlaces,
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
            required String name,
            Value<int> decimalPlaces = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UnitsCompanion.insert(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            createdBy: createdBy,
            updatedBy: updatedBy,
            version: version,
            name: name,
            decimalPlaces: decimalPlaces,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$UnitsTable, UnitRow>(table),
                    BaseReferences<_$AppDatabase, $UnitsTable, UnitRow>(
                        db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$UnitsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UnitsTable,
    UnitRow,
    $$UnitsTableFilterComposer,
    $$UnitsTableOrderingComposer,
    $$UnitsTableAnnotationComposer,
    $$UnitsTableCreateCompanionBuilder,
    $$UnitsTableUpdateCompanionBuilder,
    (UnitRow, BaseReferences<_$AppDatabase, $UnitsTable, UnitRow>),
    UnitRow,
    PrefetchHooks Function()>;
typedef $$CategoriesTableCreateCompanionBuilder = CategoriesCompanion Function({
  required String id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String?> createdBy,
  Value<String?> updatedBy,
  Value<int> version,
  required String name,
  Value<String?> parentId,
  Value<int> rowid,
});
typedef $$CategoriesTableUpdateCompanionBuilder = CategoriesCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String?> createdBy,
  Value<String?> updatedBy,
  Value<int> version,
  Value<String> name,
  Value<String?> parentId,
  Value<int> rowid,
});

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get parentId => $composableBuilder(
      column: $table.parentId, builder: (column) => ColumnFilters(column));
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get parentId => $composableBuilder(
      column: $table.parentId, builder: (column) => ColumnOrderings(column));
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
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

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get parentId =>
      $composableBuilder(column: $table.parentId, builder: (column) => column);
}

class $$CategoriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CategoriesTable,
    CategoryRow,
    $$CategoriesTableFilterComposer,
    $$CategoriesTableOrderingComposer,
    $$CategoriesTableAnnotationComposer,
    $$CategoriesTableCreateCompanionBuilder,
    $$CategoriesTableUpdateCompanionBuilder,
    (CategoryRow, BaseReferences<_$AppDatabase, $CategoriesTable, CategoryRow>),
    CategoryRow,
    PrefetchHooks Function()> {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String?> createdBy = const Value.absent(),
            Value<String?> updatedBy = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> parentId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CategoriesCompanion(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            createdBy: createdBy,
            updatedBy: updatedBy,
            version: version,
            name: name,
            parentId: parentId,
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
            required String name,
            Value<String?> parentId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CategoriesCompanion.insert(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            createdBy: createdBy,
            updatedBy: updatedBy,
            version: version,
            name: name,
            parentId: parentId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$CategoriesTable, CategoryRow>(table),
                    BaseReferences<_$AppDatabase, $CategoriesTable,
                        CategoryRow>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CategoriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CategoriesTable,
    CategoryRow,
    $$CategoriesTableFilterComposer,
    $$CategoriesTableOrderingComposer,
    $$CategoriesTableAnnotationComposer,
    $$CategoriesTableCreateCompanionBuilder,
    $$CategoriesTableUpdateCompanionBuilder,
    (CategoryRow, BaseReferences<_$AppDatabase, $CategoriesTable, CategoryRow>),
    CategoryRow,
    PrefetchHooks Function()>;
typedef $$ProductsTableCreateCompanionBuilder = ProductsCompanion Function({
  required String id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String?> createdBy,
  Value<String?> updatedBy,
  Value<int> version,
  required String sku,
  required String name,
  required String unitId,
  Value<String?> categoryId,
  Value<int> sellPriceMinor,
  Value<String> sellCurrency,
  Value<int?> costMinor,
  Value<String?> costCurrency,
  Value<bool> trackStock,
  Value<bool> isActive,
  Value<int> rowid,
});
typedef $$ProductsTableUpdateCompanionBuilder = ProductsCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String?> createdBy,
  Value<String?> updatedBy,
  Value<int> version,
  Value<String> sku,
  Value<String> name,
  Value<String> unitId,
  Value<String?> categoryId,
  Value<int> sellPriceMinor,
  Value<String> sellCurrency,
  Value<int?> costMinor,
  Value<String?> costCurrency,
  Value<bool> trackStock,
  Value<bool> isActive,
  Value<int> rowid,
});

class $$ProductsTableFilterComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableFilterComposer({
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

  ColumnFilters<String> get sku => $composableBuilder(
      column: $table.sku, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get unitId => $composableBuilder(
      column: $table.unitId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sellPriceMinor => $composableBuilder(
      column: $table.sellPriceMinor,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sellCurrency => $composableBuilder(
      column: $table.sellCurrency, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get costMinor => $composableBuilder(
      column: $table.costMinor, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get costCurrency => $composableBuilder(
      column: $table.costCurrency, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get trackStock => $composableBuilder(
      column: $table.trackStock, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));
}

class $$ProductsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableOrderingComposer({
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

  ColumnOrderings<String> get sku => $composableBuilder(
      column: $table.sku, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get unitId => $composableBuilder(
      column: $table.unitId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sellPriceMinor => $composableBuilder(
      column: $table.sellPriceMinor,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sellCurrency => $composableBuilder(
      column: $table.sellCurrency,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get costMinor => $composableBuilder(
      column: $table.costMinor, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get costCurrency => $composableBuilder(
      column: $table.costCurrency,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get trackStock => $composableBuilder(
      column: $table.trackStock, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));
}

class $$ProductsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableAnnotationComposer({
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

  GeneratedColumn<String> get sku =>
      $composableBuilder(column: $table.sku, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get unitId =>
      $composableBuilder(column: $table.unitId, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => column);

  GeneratedColumn<int> get sellPriceMinor => $composableBuilder(
      column: $table.sellPriceMinor, builder: (column) => column);

  GeneratedColumn<String> get sellCurrency => $composableBuilder(
      column: $table.sellCurrency, builder: (column) => column);

  GeneratedColumn<int> get costMinor =>
      $composableBuilder(column: $table.costMinor, builder: (column) => column);

  GeneratedColumn<String> get costCurrency => $composableBuilder(
      column: $table.costCurrency, builder: (column) => column);

  GeneratedColumn<bool> get trackStock => $composableBuilder(
      column: $table.trackStock, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);
}

class $$ProductsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ProductsTable,
    ProductRow,
    $$ProductsTableFilterComposer,
    $$ProductsTableOrderingComposer,
    $$ProductsTableAnnotationComposer,
    $$ProductsTableCreateCompanionBuilder,
    $$ProductsTableUpdateCompanionBuilder,
    (ProductRow, BaseReferences<_$AppDatabase, $ProductsTable, ProductRow>),
    ProductRow,
    PrefetchHooks Function()> {
  $$ProductsTableTableManager(_$AppDatabase db, $ProductsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String?> createdBy = const Value.absent(),
            Value<String?> updatedBy = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<String> sku = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> unitId = const Value.absent(),
            Value<String?> categoryId = const Value.absent(),
            Value<int> sellPriceMinor = const Value.absent(),
            Value<String> sellCurrency = const Value.absent(),
            Value<int?> costMinor = const Value.absent(),
            Value<String?> costCurrency = const Value.absent(),
            Value<bool> trackStock = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ProductsCompanion(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            createdBy: createdBy,
            updatedBy: updatedBy,
            version: version,
            sku: sku,
            name: name,
            unitId: unitId,
            categoryId: categoryId,
            sellPriceMinor: sellPriceMinor,
            sellCurrency: sellCurrency,
            costMinor: costMinor,
            costCurrency: costCurrency,
            trackStock: trackStock,
            isActive: isActive,
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
            required String sku,
            required String name,
            required String unitId,
            Value<String?> categoryId = const Value.absent(),
            Value<int> sellPriceMinor = const Value.absent(),
            Value<String> sellCurrency = const Value.absent(),
            Value<int?> costMinor = const Value.absent(),
            Value<String?> costCurrency = const Value.absent(),
            Value<bool> trackStock = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ProductsCompanion.insert(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            createdBy: createdBy,
            updatedBy: updatedBy,
            version: version,
            sku: sku,
            name: name,
            unitId: unitId,
            categoryId: categoryId,
            sellPriceMinor: sellPriceMinor,
            sellCurrency: sellCurrency,
            costMinor: costMinor,
            costCurrency: costCurrency,
            trackStock: trackStock,
            isActive: isActive,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$ProductsTable, ProductRow>(table),
                    BaseReferences<_$AppDatabase, $ProductsTable, ProductRow>(
                        db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ProductsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ProductsTable,
    ProductRow,
    $$ProductsTableFilterComposer,
    $$ProductsTableOrderingComposer,
    $$ProductsTableAnnotationComposer,
    $$ProductsTableCreateCompanionBuilder,
    $$ProductsTableUpdateCompanionBuilder,
    (ProductRow, BaseReferences<_$AppDatabase, $ProductsTable, ProductRow>),
    ProductRow,
    PrefetchHooks Function()>;
typedef $$BarcodesTableCreateCompanionBuilder = BarcodesCompanion Function({
  required String id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String?> createdBy,
  Value<String?> updatedBy,
  Value<int> version,
  required String productId,
  required String code,
  Value<String> symbology,
  Value<int> rowid,
});
typedef $$BarcodesTableUpdateCompanionBuilder = BarcodesCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String?> createdBy,
  Value<String?> updatedBy,
  Value<int> version,
  Value<String> productId,
  Value<String> code,
  Value<String> symbology,
  Value<int> rowid,
});

class $$BarcodesTableFilterComposer
    extends Composer<_$AppDatabase, $BarcodesTable> {
  $$BarcodesTableFilterComposer({
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

  ColumnFilters<String> get productId => $composableBuilder(
      column: $table.productId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get symbology => $composableBuilder(
      column: $table.symbology, builder: (column) => ColumnFilters(column));
}

class $$BarcodesTableOrderingComposer
    extends Composer<_$AppDatabase, $BarcodesTable> {
  $$BarcodesTableOrderingComposer({
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

  ColumnOrderings<String> get productId => $composableBuilder(
      column: $table.productId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get symbology => $composableBuilder(
      column: $table.symbology, builder: (column) => ColumnOrderings(column));
}

class $$BarcodesTableAnnotationComposer
    extends Composer<_$AppDatabase, $BarcodesTable> {
  $$BarcodesTableAnnotationComposer({
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

  GeneratedColumn<String> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get symbology =>
      $composableBuilder(column: $table.symbology, builder: (column) => column);
}

class $$BarcodesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BarcodesTable,
    BarcodeRow,
    $$BarcodesTableFilterComposer,
    $$BarcodesTableOrderingComposer,
    $$BarcodesTableAnnotationComposer,
    $$BarcodesTableCreateCompanionBuilder,
    $$BarcodesTableUpdateCompanionBuilder,
    (BarcodeRow, BaseReferences<_$AppDatabase, $BarcodesTable, BarcodeRow>),
    BarcodeRow,
    PrefetchHooks Function()> {
  $$BarcodesTableTableManager(_$AppDatabase db, $BarcodesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BarcodesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BarcodesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BarcodesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String?> createdBy = const Value.absent(),
            Value<String?> updatedBy = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<String> productId = const Value.absent(),
            Value<String> code = const Value.absent(),
            Value<String> symbology = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BarcodesCompanion(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            createdBy: createdBy,
            updatedBy: updatedBy,
            version: version,
            productId: productId,
            code: code,
            symbology: symbology,
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
            required String productId,
            required String code,
            Value<String> symbology = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BarcodesCompanion.insert(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            createdBy: createdBy,
            updatedBy: updatedBy,
            version: version,
            productId: productId,
            code: code,
            symbology: symbology,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$BarcodesTable, BarcodeRow>(table),
                    BaseReferences<_$AppDatabase, $BarcodesTable, BarcodeRow>(
                        db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$BarcodesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BarcodesTable,
    BarcodeRow,
    $$BarcodesTableFilterComposer,
    $$BarcodesTableOrderingComposer,
    $$BarcodesTableAnnotationComposer,
    $$BarcodesTableCreateCompanionBuilder,
    $$BarcodesTableUpdateCompanionBuilder,
    (BarcodeRow, BaseReferences<_$AppDatabase, $BarcodesTable, BarcodeRow>),
    BarcodeRow,
    PrefetchHooks Function()>;
typedef $$StockMovementsTableCreateCompanionBuilder = StockMovementsCompanion
    Function({
  required String id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String?> createdBy,
  Value<String?> updatedBy,
  Value<int> version,
  required String productId,
  required String branchId,
  required int qtyDelta,
  required String reason,
  Value<DateTime> occurredAt,
  Value<int> rowid,
});
typedef $$StockMovementsTableUpdateCompanionBuilder = StockMovementsCompanion
    Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String?> createdBy,
  Value<String?> updatedBy,
  Value<int> version,
  Value<String> productId,
  Value<String> branchId,
  Value<int> qtyDelta,
  Value<String> reason,
  Value<DateTime> occurredAt,
  Value<int> rowid,
});

class $$StockMovementsTableFilterComposer
    extends Composer<_$AppDatabase, $StockMovementsTable> {
  $$StockMovementsTableFilterComposer({
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

  ColumnFilters<String> get productId => $composableBuilder(
      column: $table.productId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get branchId => $composableBuilder(
      column: $table.branchId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get qtyDelta => $composableBuilder(
      column: $table.qtyDelta, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reason => $composableBuilder(
      column: $table.reason, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get occurredAt => $composableBuilder(
      column: $table.occurredAt, builder: (column) => ColumnFilters(column));
}

class $$StockMovementsTableOrderingComposer
    extends Composer<_$AppDatabase, $StockMovementsTable> {
  $$StockMovementsTableOrderingComposer({
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

  ColumnOrderings<String> get productId => $composableBuilder(
      column: $table.productId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get branchId => $composableBuilder(
      column: $table.branchId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get qtyDelta => $composableBuilder(
      column: $table.qtyDelta, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reason => $composableBuilder(
      column: $table.reason, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get occurredAt => $composableBuilder(
      column: $table.occurredAt, builder: (column) => ColumnOrderings(column));
}

class $$StockMovementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StockMovementsTable> {
  $$StockMovementsTableAnnotationComposer({
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

  GeneratedColumn<String> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<String> get branchId =>
      $composableBuilder(column: $table.branchId, builder: (column) => column);

  GeneratedColumn<int> get qtyDelta =>
      $composableBuilder(column: $table.qtyDelta, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<DateTime> get occurredAt => $composableBuilder(
      column: $table.occurredAt, builder: (column) => column);
}

class $$StockMovementsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $StockMovementsTable,
    StockMovementRow,
    $$StockMovementsTableFilterComposer,
    $$StockMovementsTableOrderingComposer,
    $$StockMovementsTableAnnotationComposer,
    $$StockMovementsTableCreateCompanionBuilder,
    $$StockMovementsTableUpdateCompanionBuilder,
    (
      StockMovementRow,
      BaseReferences<_$AppDatabase, $StockMovementsTable, StockMovementRow>
    ),
    StockMovementRow,
    PrefetchHooks Function()> {
  $$StockMovementsTableTableManager(
      _$AppDatabase db, $StockMovementsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StockMovementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StockMovementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StockMovementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String?> createdBy = const Value.absent(),
            Value<String?> updatedBy = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<String> productId = const Value.absent(),
            Value<String> branchId = const Value.absent(),
            Value<int> qtyDelta = const Value.absent(),
            Value<String> reason = const Value.absent(),
            Value<DateTime> occurredAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              StockMovementsCompanion(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            createdBy: createdBy,
            updatedBy: updatedBy,
            version: version,
            productId: productId,
            branchId: branchId,
            qtyDelta: qtyDelta,
            reason: reason,
            occurredAt: occurredAt,
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
            required String productId,
            required String branchId,
            required int qtyDelta,
            required String reason,
            Value<DateTime> occurredAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              StockMovementsCompanion.insert(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            createdBy: createdBy,
            updatedBy: updatedBy,
            version: version,
            productId: productId,
            branchId: branchId,
            qtyDelta: qtyDelta,
            reason: reason,
            occurredAt: occurredAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$StockMovementsTable, StockMovementRow>(table),
                    BaseReferences<_$AppDatabase, $StockMovementsTable,
                        StockMovementRow>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$StockMovementsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $StockMovementsTable,
    StockMovementRow,
    $$StockMovementsTableFilterComposer,
    $$StockMovementsTableOrderingComposer,
    $$StockMovementsTableAnnotationComposer,
    $$StockMovementsTableCreateCompanionBuilder,
    $$StockMovementsTableUpdateCompanionBuilder,
    (
      StockMovementRow,
      BaseReferences<_$AppDatabase, $StockMovementsTable, StockMovementRow>
    ),
    StockMovementRow,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$OutboxEntriesTableTableManager get outboxEntries =>
      $$OutboxEntriesTableTableManager(_db, _db.outboxEntries);
  $$CachedProfilesTableTableManager get cachedProfiles =>
      $$CachedProfilesTableTableManager(_db, _db.cachedProfiles);
  $$UnitsTableTableManager get units =>
      $$UnitsTableTableManager(_db, _db.units);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$ProductsTableTableManager get products =>
      $$ProductsTableTableManager(_db, _db.products);
  $$BarcodesTableTableManager get barcodes =>
      $$BarcodesTableTableManager(_db, _db.barcodes);
  $$StockMovementsTableTableManager get stockMovements =>
      $$StockMovementsTableTableManager(_db, _db.stockMovements);
}
