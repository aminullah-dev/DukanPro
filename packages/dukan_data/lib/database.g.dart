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
  static const VerificationMeta _lastErrorMeta =
      const VerificationMeta('lastError');
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
      'last_error', aliasedName, true,
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
        aggregateType,
        aggregateId,
        opType,
        payload,
        localSeq,
        deviceId,
        actorId,
        status,
        baseVersion,
        lastError
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
    if (data.containsKey('last_error')) {
      context.handle(_lastErrorMeta,
          lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta));
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
      lastError: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_error']),
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

  /// The server's code for an op it conflicted or rejected (shown for review).
  final String? lastError;
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
      this.baseVersion,
      this.lastError});
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
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
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
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
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
      lastError: serializer.fromJson<String?>(json['lastError']),
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
      'lastError': serializer.toJson<String?>(lastError),
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
          Value<int?> baseVersion = const Value.absent(),
          Value<String?> lastError = const Value.absent()}) =>
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
        lastError: lastError.present ? lastError.value : this.lastError,
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
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
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
          ..write('baseVersion: $baseVersion, ')
          ..write('lastError: $lastError')
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
      baseVersion,
      lastError);
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
          other.baseVersion == this.baseVersion &&
          other.lastError == this.lastError);
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
  final Value<String?> lastError;
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
    this.lastError = const Value.absent(),
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
    this.lastError = const Value.absent(),
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
    Expression<String>? lastError,
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
      if (lastError != null) 'last_error': lastError,
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
      Value<String?>? lastError,
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
      lastError: lastError ?? this.lastError,
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
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
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
          ..write('lastError: $lastError, ')
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

class $SalesTable extends Sales with TableInfo<$SalesTable, SaleRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SalesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _numberMeta = const VerificationMeta('number');
  @override
  late final GeneratedColumn<String> number = GeneratedColumn<String>(
      'number', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _branchIdMeta =
      const VerificationMeta('branchId');
  @override
  late final GeneratedColumn<String> branchId = GeneratedColumn<String>(
      'branch_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _shiftIdMeta =
      const VerificationMeta('shiftId');
  @override
  late final GeneratedColumn<String> shiftId = GeneratedColumn<String>(
      'shift_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _customerIdMeta =
      const VerificationMeta('customerId');
  @override
  late final GeneratedColumn<String> customerId = GeneratedColumn<String>(
      'customer_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('settled'));
  static const VerificationMeta _currencyMeta =
      const VerificationMeta('currency');
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
      'currency', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('AFN'));
  static const VerificationMeta _discountMinorMeta =
      const VerificationMeta('discountMinor');
  @override
  late final GeneratedColumn<int> discountMinor = GeneratedColumn<int>(
      'discount_minor', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _subtotalMinorMeta =
      const VerificationMeta('subtotalMinor');
  @override
  late final GeneratedColumn<int> subtotalMinor = GeneratedColumn<int>(
      'subtotal_minor', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _taxMinorMeta =
      const VerificationMeta('taxMinor');
  @override
  late final GeneratedColumn<int> taxMinor = GeneratedColumn<int>(
      'tax_minor', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _totalMinorMeta =
      const VerificationMeta('totalMinor');
  @override
  late final GeneratedColumn<int> totalMinor = GeneratedColumn<int>(
      'total_minor', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _paidMinorMeta =
      const VerificationMeta('paidMinor');
  @override
  late final GeneratedColumn<int> paidMinor = GeneratedColumn<int>(
      'paid_minor', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _changeMinorMeta =
      const VerificationMeta('changeMinor');
  @override
  late final GeneratedColumn<int> changeMinor = GeneratedColumn<int>(
      'change_minor', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _occurredAtMeta =
      const VerificationMeta('occurredAt');
  @override
  late final GeneratedColumn<DateTime> occurredAt = GeneratedColumn<DateTime>(
      'occurred_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _refundOfMeta =
      const VerificationMeta('refundOf');
  @override
  late final GeneratedColumn<String> refundOf = GeneratedColumn<String>(
      'refund_of', aliasedName, true,
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
        number,
        branchId,
        shiftId,
        customerId,
        status,
        currency,
        discountMinor,
        subtotalMinor,
        taxMinor,
        totalMinor,
        paidMinor,
        changeMinor,
        occurredAt,
        refundOf
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sales';
  @override
  VerificationContext validateIntegrity(Insertable<SaleRow> instance,
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
    if (data.containsKey('number')) {
      context.handle(_numberMeta,
          number.isAcceptableOrUnknown(data['number']!, _numberMeta));
    } else if (isInserting) {
      context.missing(_numberMeta);
    }
    if (data.containsKey('branch_id')) {
      context.handle(_branchIdMeta,
          branchId.isAcceptableOrUnknown(data['branch_id']!, _branchIdMeta));
    } else if (isInserting) {
      context.missing(_branchIdMeta);
    }
    if (data.containsKey('shift_id')) {
      context.handle(_shiftIdMeta,
          shiftId.isAcceptableOrUnknown(data['shift_id']!, _shiftIdMeta));
    }
    if (data.containsKey('customer_id')) {
      context.handle(
          _customerIdMeta,
          customerId.isAcceptableOrUnknown(
              data['customer_id']!, _customerIdMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('currency')) {
      context.handle(_currencyMeta,
          currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta));
    }
    if (data.containsKey('discount_minor')) {
      context.handle(
          _discountMinorMeta,
          discountMinor.isAcceptableOrUnknown(
              data['discount_minor']!, _discountMinorMeta));
    }
    if (data.containsKey('subtotal_minor')) {
      context.handle(
          _subtotalMinorMeta,
          subtotalMinor.isAcceptableOrUnknown(
              data['subtotal_minor']!, _subtotalMinorMeta));
    }
    if (data.containsKey('tax_minor')) {
      context.handle(_taxMinorMeta,
          taxMinor.isAcceptableOrUnknown(data['tax_minor']!, _taxMinorMeta));
    }
    if (data.containsKey('total_minor')) {
      context.handle(
          _totalMinorMeta,
          totalMinor.isAcceptableOrUnknown(
              data['total_minor']!, _totalMinorMeta));
    }
    if (data.containsKey('paid_minor')) {
      context.handle(_paidMinorMeta,
          paidMinor.isAcceptableOrUnknown(data['paid_minor']!, _paidMinorMeta));
    }
    if (data.containsKey('change_minor')) {
      context.handle(
          _changeMinorMeta,
          changeMinor.isAcceptableOrUnknown(
              data['change_minor']!, _changeMinorMeta));
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
          _occurredAtMeta,
          occurredAt.isAcceptableOrUnknown(
              data['occurred_at']!, _occurredAtMeta));
    }
    if (data.containsKey('refund_of')) {
      context.handle(_refundOfMeta,
          refundOf.isAcceptableOrUnknown(data['refund_of']!, _refundOfMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SaleRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SaleRow(
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
      number: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}number'])!,
      branchId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}branch_id'])!,
      shiftId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}shift_id']),
      customerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}customer_id']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      currency: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}currency'])!,
      discountMinor: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}discount_minor'])!,
      subtotalMinor: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}subtotal_minor'])!,
      taxMinor: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}tax_minor'])!,
      totalMinor: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_minor'])!,
      paidMinor: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}paid_minor'])!,
      changeMinor: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}change_minor'])!,
      occurredAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}occurred_at'])!,
      refundOf: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}refund_of']),
    );
  }

  @override
  $SalesTable createAlias(String alias) {
    return $SalesTable(attachedDatabase, alias);
  }
}

class SaleRow extends DataClass implements Insertable<SaleRow> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String? createdBy;
  final String? updatedBy;
  final int version;
  final String number;
  final String branchId;
  final String? shiftId;
  final String? customerId;
  final String status;
  final String currency;
  final int discountMinor;
  final int subtotalMinor;
  final int taxMinor;
  final int totalMinor;
  final int paidMinor;
  final int changeMinor;
  final DateTime occurredAt;

  /// A return: the sale it takes goods back from. Only the server writes returns.
  final String? refundOf;
  const SaleRow(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt,
      this.createdBy,
      this.updatedBy,
      required this.version,
      required this.number,
      required this.branchId,
      this.shiftId,
      this.customerId,
      required this.status,
      required this.currency,
      required this.discountMinor,
      required this.subtotalMinor,
      required this.taxMinor,
      required this.totalMinor,
      required this.paidMinor,
      required this.changeMinor,
      required this.occurredAt,
      this.refundOf});
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
    map['number'] = Variable<String>(number);
    map['branch_id'] = Variable<String>(branchId);
    if (!nullToAbsent || shiftId != null) {
      map['shift_id'] = Variable<String>(shiftId);
    }
    if (!nullToAbsent || customerId != null) {
      map['customer_id'] = Variable<String>(customerId);
    }
    map['status'] = Variable<String>(status);
    map['currency'] = Variable<String>(currency);
    map['discount_minor'] = Variable<int>(discountMinor);
    map['subtotal_minor'] = Variable<int>(subtotalMinor);
    map['tax_minor'] = Variable<int>(taxMinor);
    map['total_minor'] = Variable<int>(totalMinor);
    map['paid_minor'] = Variable<int>(paidMinor);
    map['change_minor'] = Variable<int>(changeMinor);
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    if (!nullToAbsent || refundOf != null) {
      map['refund_of'] = Variable<String>(refundOf);
    }
    return map;
  }

  SalesCompanion toCompanion(bool nullToAbsent) {
    return SalesCompanion(
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
      number: Value(number),
      branchId: Value(branchId),
      shiftId: shiftId == null && nullToAbsent
          ? const Value.absent()
          : Value(shiftId),
      customerId: customerId == null && nullToAbsent
          ? const Value.absent()
          : Value(customerId),
      status: Value(status),
      currency: Value(currency),
      discountMinor: Value(discountMinor),
      subtotalMinor: Value(subtotalMinor),
      taxMinor: Value(taxMinor),
      totalMinor: Value(totalMinor),
      paidMinor: Value(paidMinor),
      changeMinor: Value(changeMinor),
      occurredAt: Value(occurredAt),
      refundOf: refundOf == null && nullToAbsent
          ? const Value.absent()
          : Value(refundOf),
    );
  }

  factory SaleRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SaleRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
      updatedBy: serializer.fromJson<String?>(json['updatedBy']),
      version: serializer.fromJson<int>(json['version']),
      number: serializer.fromJson<String>(json['number']),
      branchId: serializer.fromJson<String>(json['branchId']),
      shiftId: serializer.fromJson<String?>(json['shiftId']),
      customerId: serializer.fromJson<String?>(json['customerId']),
      status: serializer.fromJson<String>(json['status']),
      currency: serializer.fromJson<String>(json['currency']),
      discountMinor: serializer.fromJson<int>(json['discountMinor']),
      subtotalMinor: serializer.fromJson<int>(json['subtotalMinor']),
      taxMinor: serializer.fromJson<int>(json['taxMinor']),
      totalMinor: serializer.fromJson<int>(json['totalMinor']),
      paidMinor: serializer.fromJson<int>(json['paidMinor']),
      changeMinor: serializer.fromJson<int>(json['changeMinor']),
      occurredAt: serializer.fromJson<DateTime>(json['occurredAt']),
      refundOf: serializer.fromJson<String?>(json['refundOf']),
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
      'number': serializer.toJson<String>(number),
      'branchId': serializer.toJson<String>(branchId),
      'shiftId': serializer.toJson<String?>(shiftId),
      'customerId': serializer.toJson<String?>(customerId),
      'status': serializer.toJson<String>(status),
      'currency': serializer.toJson<String>(currency),
      'discountMinor': serializer.toJson<int>(discountMinor),
      'subtotalMinor': serializer.toJson<int>(subtotalMinor),
      'taxMinor': serializer.toJson<int>(taxMinor),
      'totalMinor': serializer.toJson<int>(totalMinor),
      'paidMinor': serializer.toJson<int>(paidMinor),
      'changeMinor': serializer.toJson<int>(changeMinor),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
      'refundOf': serializer.toJson<String?>(refundOf),
    };
  }

  SaleRow copyWith(
          {String? id,
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          Value<String?> createdBy = const Value.absent(),
          Value<String?> updatedBy = const Value.absent(),
          int? version,
          String? number,
          String? branchId,
          Value<String?> shiftId = const Value.absent(),
          Value<String?> customerId = const Value.absent(),
          String? status,
          String? currency,
          int? discountMinor,
          int? subtotalMinor,
          int? taxMinor,
          int? totalMinor,
          int? paidMinor,
          int? changeMinor,
          DateTime? occurredAt,
          Value<String?> refundOf = const Value.absent()}) =>
      SaleRow(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        createdBy: createdBy.present ? createdBy.value : this.createdBy,
        updatedBy: updatedBy.present ? updatedBy.value : this.updatedBy,
        version: version ?? this.version,
        number: number ?? this.number,
        branchId: branchId ?? this.branchId,
        shiftId: shiftId.present ? shiftId.value : this.shiftId,
        customerId: customerId.present ? customerId.value : this.customerId,
        status: status ?? this.status,
        currency: currency ?? this.currency,
        discountMinor: discountMinor ?? this.discountMinor,
        subtotalMinor: subtotalMinor ?? this.subtotalMinor,
        taxMinor: taxMinor ?? this.taxMinor,
        totalMinor: totalMinor ?? this.totalMinor,
        paidMinor: paidMinor ?? this.paidMinor,
        changeMinor: changeMinor ?? this.changeMinor,
        occurredAt: occurredAt ?? this.occurredAt,
        refundOf: refundOf.present ? refundOf.value : this.refundOf,
      );
  SaleRow copyWithCompanion(SalesCompanion data) {
    return SaleRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      version: data.version.present ? data.version.value : this.version,
      number: data.number.present ? data.number.value : this.number,
      branchId: data.branchId.present ? data.branchId.value : this.branchId,
      shiftId: data.shiftId.present ? data.shiftId.value : this.shiftId,
      customerId:
          data.customerId.present ? data.customerId.value : this.customerId,
      status: data.status.present ? data.status.value : this.status,
      currency: data.currency.present ? data.currency.value : this.currency,
      discountMinor: data.discountMinor.present
          ? data.discountMinor.value
          : this.discountMinor,
      subtotalMinor: data.subtotalMinor.present
          ? data.subtotalMinor.value
          : this.subtotalMinor,
      taxMinor: data.taxMinor.present ? data.taxMinor.value : this.taxMinor,
      totalMinor:
          data.totalMinor.present ? data.totalMinor.value : this.totalMinor,
      paidMinor: data.paidMinor.present ? data.paidMinor.value : this.paidMinor,
      changeMinor:
          data.changeMinor.present ? data.changeMinor.value : this.changeMinor,
      occurredAt:
          data.occurredAt.present ? data.occurredAt.value : this.occurredAt,
      refundOf: data.refundOf.present ? data.refundOf.value : this.refundOf,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SaleRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('version: $version, ')
          ..write('number: $number, ')
          ..write('branchId: $branchId, ')
          ..write('shiftId: $shiftId, ')
          ..write('customerId: $customerId, ')
          ..write('status: $status, ')
          ..write('currency: $currency, ')
          ..write('discountMinor: $discountMinor, ')
          ..write('subtotalMinor: $subtotalMinor, ')
          ..write('taxMinor: $taxMinor, ')
          ..write('totalMinor: $totalMinor, ')
          ..write('paidMinor: $paidMinor, ')
          ..write('changeMinor: $changeMinor, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('refundOf: $refundOf')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        createdAt,
        updatedAt,
        deletedAt,
        createdBy,
        updatedBy,
        version,
        number,
        branchId,
        shiftId,
        customerId,
        status,
        currency,
        discountMinor,
        subtotalMinor,
        taxMinor,
        totalMinor,
        paidMinor,
        changeMinor,
        occurredAt,
        refundOf
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SaleRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.createdBy == this.createdBy &&
          other.updatedBy == this.updatedBy &&
          other.version == this.version &&
          other.number == this.number &&
          other.branchId == this.branchId &&
          other.shiftId == this.shiftId &&
          other.customerId == this.customerId &&
          other.status == this.status &&
          other.currency == this.currency &&
          other.discountMinor == this.discountMinor &&
          other.subtotalMinor == this.subtotalMinor &&
          other.taxMinor == this.taxMinor &&
          other.totalMinor == this.totalMinor &&
          other.paidMinor == this.paidMinor &&
          other.changeMinor == this.changeMinor &&
          other.occurredAt == this.occurredAt &&
          other.refundOf == this.refundOf);
}

class SalesCompanion extends UpdateCompanion<SaleRow> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String?> createdBy;
  final Value<String?> updatedBy;
  final Value<int> version;
  final Value<String> number;
  final Value<String> branchId;
  final Value<String?> shiftId;
  final Value<String?> customerId;
  final Value<String> status;
  final Value<String> currency;
  final Value<int> discountMinor;
  final Value<int> subtotalMinor;
  final Value<int> taxMinor;
  final Value<int> totalMinor;
  final Value<int> paidMinor;
  final Value<int> changeMinor;
  final Value<DateTime> occurredAt;
  final Value<String?> refundOf;
  final Value<int> rowid;
  const SalesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.version = const Value.absent(),
    this.number = const Value.absent(),
    this.branchId = const Value.absent(),
    this.shiftId = const Value.absent(),
    this.customerId = const Value.absent(),
    this.status = const Value.absent(),
    this.currency = const Value.absent(),
    this.discountMinor = const Value.absent(),
    this.subtotalMinor = const Value.absent(),
    this.taxMinor = const Value.absent(),
    this.totalMinor = const Value.absent(),
    this.paidMinor = const Value.absent(),
    this.changeMinor = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.refundOf = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SalesCompanion.insert({
    required String id,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.version = const Value.absent(),
    required String number,
    required String branchId,
    this.shiftId = const Value.absent(),
    this.customerId = const Value.absent(),
    this.status = const Value.absent(),
    this.currency = const Value.absent(),
    this.discountMinor = const Value.absent(),
    this.subtotalMinor = const Value.absent(),
    this.taxMinor = const Value.absent(),
    this.totalMinor = const Value.absent(),
    this.paidMinor = const Value.absent(),
    this.changeMinor = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.refundOf = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        number = Value(number),
        branchId = Value(branchId);
  static Insertable<SaleRow> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? createdBy,
    Expression<String>? updatedBy,
    Expression<int>? version,
    Expression<String>? number,
    Expression<String>? branchId,
    Expression<String>? shiftId,
    Expression<String>? customerId,
    Expression<String>? status,
    Expression<String>? currency,
    Expression<int>? discountMinor,
    Expression<int>? subtotalMinor,
    Expression<int>? taxMinor,
    Expression<int>? totalMinor,
    Expression<int>? paidMinor,
    Expression<int>? changeMinor,
    Expression<DateTime>? occurredAt,
    Expression<String>? refundOf,
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
      if (number != null) 'number': number,
      if (branchId != null) 'branch_id': branchId,
      if (shiftId != null) 'shift_id': shiftId,
      if (customerId != null) 'customer_id': customerId,
      if (status != null) 'status': status,
      if (currency != null) 'currency': currency,
      if (discountMinor != null) 'discount_minor': discountMinor,
      if (subtotalMinor != null) 'subtotal_minor': subtotalMinor,
      if (taxMinor != null) 'tax_minor': taxMinor,
      if (totalMinor != null) 'total_minor': totalMinor,
      if (paidMinor != null) 'paid_minor': paidMinor,
      if (changeMinor != null) 'change_minor': changeMinor,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (refundOf != null) 'refund_of': refundOf,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SalesCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<String?>? createdBy,
      Value<String?>? updatedBy,
      Value<int>? version,
      Value<String>? number,
      Value<String>? branchId,
      Value<String?>? shiftId,
      Value<String?>? customerId,
      Value<String>? status,
      Value<String>? currency,
      Value<int>? discountMinor,
      Value<int>? subtotalMinor,
      Value<int>? taxMinor,
      Value<int>? totalMinor,
      Value<int>? paidMinor,
      Value<int>? changeMinor,
      Value<DateTime>? occurredAt,
      Value<String?>? refundOf,
      Value<int>? rowid}) {
    return SalesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      version: version ?? this.version,
      number: number ?? this.number,
      branchId: branchId ?? this.branchId,
      shiftId: shiftId ?? this.shiftId,
      customerId: customerId ?? this.customerId,
      status: status ?? this.status,
      currency: currency ?? this.currency,
      discountMinor: discountMinor ?? this.discountMinor,
      subtotalMinor: subtotalMinor ?? this.subtotalMinor,
      taxMinor: taxMinor ?? this.taxMinor,
      totalMinor: totalMinor ?? this.totalMinor,
      paidMinor: paidMinor ?? this.paidMinor,
      changeMinor: changeMinor ?? this.changeMinor,
      occurredAt: occurredAt ?? this.occurredAt,
      refundOf: refundOf ?? this.refundOf,
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
    if (number.present) {
      map['number'] = Variable<String>(number.value);
    }
    if (branchId.present) {
      map['branch_id'] = Variable<String>(branchId.value);
    }
    if (shiftId.present) {
      map['shift_id'] = Variable<String>(shiftId.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<String>(customerId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (discountMinor.present) {
      map['discount_minor'] = Variable<int>(discountMinor.value);
    }
    if (subtotalMinor.present) {
      map['subtotal_minor'] = Variable<int>(subtotalMinor.value);
    }
    if (taxMinor.present) {
      map['tax_minor'] = Variable<int>(taxMinor.value);
    }
    if (totalMinor.present) {
      map['total_minor'] = Variable<int>(totalMinor.value);
    }
    if (paidMinor.present) {
      map['paid_minor'] = Variable<int>(paidMinor.value);
    }
    if (changeMinor.present) {
      map['change_minor'] = Variable<int>(changeMinor.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<DateTime>(occurredAt.value);
    }
    if (refundOf.present) {
      map['refund_of'] = Variable<String>(refundOf.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SalesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('version: $version, ')
          ..write('number: $number, ')
          ..write('branchId: $branchId, ')
          ..write('shiftId: $shiftId, ')
          ..write('customerId: $customerId, ')
          ..write('status: $status, ')
          ..write('currency: $currency, ')
          ..write('discountMinor: $discountMinor, ')
          ..write('subtotalMinor: $subtotalMinor, ')
          ..write('taxMinor: $taxMinor, ')
          ..write('totalMinor: $totalMinor, ')
          ..write('paidMinor: $paidMinor, ')
          ..write('changeMinor: $changeMinor, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('refundOf: $refundOf, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SaleLinesTable extends SaleLines
    with TableInfo<$SaleLinesTable, SaleLineRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SaleLinesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _saleIdMeta = const VerificationMeta('saleId');
  @override
  late final GeneratedColumn<String> saleId = GeneratedColumn<String>(
      'sale_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _productIdMeta =
      const VerificationMeta('productId');
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
      'product_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _qtyMinorMeta =
      const VerificationMeta('qtyMinor');
  @override
  late final GeneratedColumn<int> qtyMinor = GeneratedColumn<int>(
      'qty_minor', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _decimalPlacesMeta =
      const VerificationMeta('decimalPlaces');
  @override
  late final GeneratedColumn<int> decimalPlaces = GeneratedColumn<int>(
      'decimal_places', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _unitPriceMinorMeta =
      const VerificationMeta('unitPriceMinor');
  @override
  late final GeneratedColumn<int> unitPriceMinor = GeneratedColumn<int>(
      'unit_price_minor', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _unitCostMinorMeta =
      const VerificationMeta('unitCostMinor');
  @override
  late final GeneratedColumn<int> unitCostMinor = GeneratedColumn<int>(
      'unit_cost_minor', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lineTotalMinorMeta =
      const VerificationMeta('lineTotalMinor');
  @override
  late final GeneratedColumn<int> lineTotalMinor = GeneratedColumn<int>(
      'line_total_minor', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _currencyMeta =
      const VerificationMeta('currency');
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
      'currency', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('AFN'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        createdAt,
        updatedAt,
        deletedAt,
        createdBy,
        updatedBy,
        version,
        saleId,
        productId,
        name,
        qtyMinor,
        decimalPlaces,
        unitPriceMinor,
        unitCostMinor,
        lineTotalMinor,
        currency
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sale_lines';
  @override
  VerificationContext validateIntegrity(Insertable<SaleLineRow> instance,
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
    if (data.containsKey('sale_id')) {
      context.handle(_saleIdMeta,
          saleId.isAcceptableOrUnknown(data['sale_id']!, _saleIdMeta));
    } else if (isInserting) {
      context.missing(_saleIdMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(_productIdMeta,
          productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta));
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('qty_minor')) {
      context.handle(_qtyMinorMeta,
          qtyMinor.isAcceptableOrUnknown(data['qty_minor']!, _qtyMinorMeta));
    } else if (isInserting) {
      context.missing(_qtyMinorMeta);
    }
    if (data.containsKey('decimal_places')) {
      context.handle(
          _decimalPlacesMeta,
          decimalPlaces.isAcceptableOrUnknown(
              data['decimal_places']!, _decimalPlacesMeta));
    }
    if (data.containsKey('unit_price_minor')) {
      context.handle(
          _unitPriceMinorMeta,
          unitPriceMinor.isAcceptableOrUnknown(
              data['unit_price_minor']!, _unitPriceMinorMeta));
    } else if (isInserting) {
      context.missing(_unitPriceMinorMeta);
    }
    if (data.containsKey('unit_cost_minor')) {
      context.handle(
          _unitCostMinorMeta,
          unitCostMinor.isAcceptableOrUnknown(
              data['unit_cost_minor']!, _unitCostMinorMeta));
    }
    if (data.containsKey('line_total_minor')) {
      context.handle(
          _lineTotalMinorMeta,
          lineTotalMinor.isAcceptableOrUnknown(
              data['line_total_minor']!, _lineTotalMinorMeta));
    } else if (isInserting) {
      context.missing(_lineTotalMinorMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(_currencyMeta,
          currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SaleLineRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SaleLineRow(
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
      saleId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sale_id'])!,
      productId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}product_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      qtyMinor: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}qty_minor'])!,
      decimalPlaces: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}decimal_places'])!,
      unitPriceMinor: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}unit_price_minor'])!,
      unitCostMinor: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}unit_cost_minor'])!,
      lineTotalMinor: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}line_total_minor'])!,
      currency: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}currency'])!,
    );
  }

  @override
  $SaleLinesTable createAlias(String alias) {
    return $SaleLinesTable(attachedDatabase, alias);
  }
}

class SaleLineRow extends DataClass implements Insertable<SaleLineRow> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String? createdBy;
  final String? updatedBy;
  final int version;
  final String saleId;
  final String productId;
  final String name;
  final int qtyMinor;
  final int decimalPlaces;
  final int unitPriceMinor;
  final int unitCostMinor;
  final int lineTotalMinor;
  final String currency;
  const SaleLineRow(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt,
      this.createdBy,
      this.updatedBy,
      required this.version,
      required this.saleId,
      required this.productId,
      required this.name,
      required this.qtyMinor,
      required this.decimalPlaces,
      required this.unitPriceMinor,
      required this.unitCostMinor,
      required this.lineTotalMinor,
      required this.currency});
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
    map['sale_id'] = Variable<String>(saleId);
    map['product_id'] = Variable<String>(productId);
    map['name'] = Variable<String>(name);
    map['qty_minor'] = Variable<int>(qtyMinor);
    map['decimal_places'] = Variable<int>(decimalPlaces);
    map['unit_price_minor'] = Variable<int>(unitPriceMinor);
    map['unit_cost_minor'] = Variable<int>(unitCostMinor);
    map['line_total_minor'] = Variable<int>(lineTotalMinor);
    map['currency'] = Variable<String>(currency);
    return map;
  }

  SaleLinesCompanion toCompanion(bool nullToAbsent) {
    return SaleLinesCompanion(
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
      saleId: Value(saleId),
      productId: Value(productId),
      name: Value(name),
      qtyMinor: Value(qtyMinor),
      decimalPlaces: Value(decimalPlaces),
      unitPriceMinor: Value(unitPriceMinor),
      unitCostMinor: Value(unitCostMinor),
      lineTotalMinor: Value(lineTotalMinor),
      currency: Value(currency),
    );
  }

  factory SaleLineRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SaleLineRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
      updatedBy: serializer.fromJson<String?>(json['updatedBy']),
      version: serializer.fromJson<int>(json['version']),
      saleId: serializer.fromJson<String>(json['saleId']),
      productId: serializer.fromJson<String>(json['productId']),
      name: serializer.fromJson<String>(json['name']),
      qtyMinor: serializer.fromJson<int>(json['qtyMinor']),
      decimalPlaces: serializer.fromJson<int>(json['decimalPlaces']),
      unitPriceMinor: serializer.fromJson<int>(json['unitPriceMinor']),
      unitCostMinor: serializer.fromJson<int>(json['unitCostMinor']),
      lineTotalMinor: serializer.fromJson<int>(json['lineTotalMinor']),
      currency: serializer.fromJson<String>(json['currency']),
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
      'saleId': serializer.toJson<String>(saleId),
      'productId': serializer.toJson<String>(productId),
      'name': serializer.toJson<String>(name),
      'qtyMinor': serializer.toJson<int>(qtyMinor),
      'decimalPlaces': serializer.toJson<int>(decimalPlaces),
      'unitPriceMinor': serializer.toJson<int>(unitPriceMinor),
      'unitCostMinor': serializer.toJson<int>(unitCostMinor),
      'lineTotalMinor': serializer.toJson<int>(lineTotalMinor),
      'currency': serializer.toJson<String>(currency),
    };
  }

  SaleLineRow copyWith(
          {String? id,
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          Value<String?> createdBy = const Value.absent(),
          Value<String?> updatedBy = const Value.absent(),
          int? version,
          String? saleId,
          String? productId,
          String? name,
          int? qtyMinor,
          int? decimalPlaces,
          int? unitPriceMinor,
          int? unitCostMinor,
          int? lineTotalMinor,
          String? currency}) =>
      SaleLineRow(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        createdBy: createdBy.present ? createdBy.value : this.createdBy,
        updatedBy: updatedBy.present ? updatedBy.value : this.updatedBy,
        version: version ?? this.version,
        saleId: saleId ?? this.saleId,
        productId: productId ?? this.productId,
        name: name ?? this.name,
        qtyMinor: qtyMinor ?? this.qtyMinor,
        decimalPlaces: decimalPlaces ?? this.decimalPlaces,
        unitPriceMinor: unitPriceMinor ?? this.unitPriceMinor,
        unitCostMinor: unitCostMinor ?? this.unitCostMinor,
        lineTotalMinor: lineTotalMinor ?? this.lineTotalMinor,
        currency: currency ?? this.currency,
      );
  SaleLineRow copyWithCompanion(SaleLinesCompanion data) {
    return SaleLineRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      version: data.version.present ? data.version.value : this.version,
      saleId: data.saleId.present ? data.saleId.value : this.saleId,
      productId: data.productId.present ? data.productId.value : this.productId,
      name: data.name.present ? data.name.value : this.name,
      qtyMinor: data.qtyMinor.present ? data.qtyMinor.value : this.qtyMinor,
      decimalPlaces: data.decimalPlaces.present
          ? data.decimalPlaces.value
          : this.decimalPlaces,
      unitPriceMinor: data.unitPriceMinor.present
          ? data.unitPriceMinor.value
          : this.unitPriceMinor,
      unitCostMinor: data.unitCostMinor.present
          ? data.unitCostMinor.value
          : this.unitCostMinor,
      lineTotalMinor: data.lineTotalMinor.present
          ? data.lineTotalMinor.value
          : this.lineTotalMinor,
      currency: data.currency.present ? data.currency.value : this.currency,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SaleLineRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('version: $version, ')
          ..write('saleId: $saleId, ')
          ..write('productId: $productId, ')
          ..write('name: $name, ')
          ..write('qtyMinor: $qtyMinor, ')
          ..write('decimalPlaces: $decimalPlaces, ')
          ..write('unitPriceMinor: $unitPriceMinor, ')
          ..write('unitCostMinor: $unitCostMinor, ')
          ..write('lineTotalMinor: $lineTotalMinor, ')
          ..write('currency: $currency')
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
      saleId,
      productId,
      name,
      qtyMinor,
      decimalPlaces,
      unitPriceMinor,
      unitCostMinor,
      lineTotalMinor,
      currency);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SaleLineRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.createdBy == this.createdBy &&
          other.updatedBy == this.updatedBy &&
          other.version == this.version &&
          other.saleId == this.saleId &&
          other.productId == this.productId &&
          other.name == this.name &&
          other.qtyMinor == this.qtyMinor &&
          other.decimalPlaces == this.decimalPlaces &&
          other.unitPriceMinor == this.unitPriceMinor &&
          other.unitCostMinor == this.unitCostMinor &&
          other.lineTotalMinor == this.lineTotalMinor &&
          other.currency == this.currency);
}

class SaleLinesCompanion extends UpdateCompanion<SaleLineRow> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String?> createdBy;
  final Value<String?> updatedBy;
  final Value<int> version;
  final Value<String> saleId;
  final Value<String> productId;
  final Value<String> name;
  final Value<int> qtyMinor;
  final Value<int> decimalPlaces;
  final Value<int> unitPriceMinor;
  final Value<int> unitCostMinor;
  final Value<int> lineTotalMinor;
  final Value<String> currency;
  final Value<int> rowid;
  const SaleLinesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.version = const Value.absent(),
    this.saleId = const Value.absent(),
    this.productId = const Value.absent(),
    this.name = const Value.absent(),
    this.qtyMinor = const Value.absent(),
    this.decimalPlaces = const Value.absent(),
    this.unitPriceMinor = const Value.absent(),
    this.unitCostMinor = const Value.absent(),
    this.lineTotalMinor = const Value.absent(),
    this.currency = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SaleLinesCompanion.insert({
    required String id,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.version = const Value.absent(),
    required String saleId,
    required String productId,
    required String name,
    required int qtyMinor,
    this.decimalPlaces = const Value.absent(),
    required int unitPriceMinor,
    this.unitCostMinor = const Value.absent(),
    required int lineTotalMinor,
    this.currency = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        saleId = Value(saleId),
        productId = Value(productId),
        name = Value(name),
        qtyMinor = Value(qtyMinor),
        unitPriceMinor = Value(unitPriceMinor),
        lineTotalMinor = Value(lineTotalMinor);
  static Insertable<SaleLineRow> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? createdBy,
    Expression<String>? updatedBy,
    Expression<int>? version,
    Expression<String>? saleId,
    Expression<String>? productId,
    Expression<String>? name,
    Expression<int>? qtyMinor,
    Expression<int>? decimalPlaces,
    Expression<int>? unitPriceMinor,
    Expression<int>? unitCostMinor,
    Expression<int>? lineTotalMinor,
    Expression<String>? currency,
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
      if (saleId != null) 'sale_id': saleId,
      if (productId != null) 'product_id': productId,
      if (name != null) 'name': name,
      if (qtyMinor != null) 'qty_minor': qtyMinor,
      if (decimalPlaces != null) 'decimal_places': decimalPlaces,
      if (unitPriceMinor != null) 'unit_price_minor': unitPriceMinor,
      if (unitCostMinor != null) 'unit_cost_minor': unitCostMinor,
      if (lineTotalMinor != null) 'line_total_minor': lineTotalMinor,
      if (currency != null) 'currency': currency,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SaleLinesCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<String?>? createdBy,
      Value<String?>? updatedBy,
      Value<int>? version,
      Value<String>? saleId,
      Value<String>? productId,
      Value<String>? name,
      Value<int>? qtyMinor,
      Value<int>? decimalPlaces,
      Value<int>? unitPriceMinor,
      Value<int>? unitCostMinor,
      Value<int>? lineTotalMinor,
      Value<String>? currency,
      Value<int>? rowid}) {
    return SaleLinesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      version: version ?? this.version,
      saleId: saleId ?? this.saleId,
      productId: productId ?? this.productId,
      name: name ?? this.name,
      qtyMinor: qtyMinor ?? this.qtyMinor,
      decimalPlaces: decimalPlaces ?? this.decimalPlaces,
      unitPriceMinor: unitPriceMinor ?? this.unitPriceMinor,
      unitCostMinor: unitCostMinor ?? this.unitCostMinor,
      lineTotalMinor: lineTotalMinor ?? this.lineTotalMinor,
      currency: currency ?? this.currency,
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
    if (saleId.present) {
      map['sale_id'] = Variable<String>(saleId.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (qtyMinor.present) {
      map['qty_minor'] = Variable<int>(qtyMinor.value);
    }
    if (decimalPlaces.present) {
      map['decimal_places'] = Variable<int>(decimalPlaces.value);
    }
    if (unitPriceMinor.present) {
      map['unit_price_minor'] = Variable<int>(unitPriceMinor.value);
    }
    if (unitCostMinor.present) {
      map['unit_cost_minor'] = Variable<int>(unitCostMinor.value);
    }
    if (lineTotalMinor.present) {
      map['line_total_minor'] = Variable<int>(lineTotalMinor.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SaleLinesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('version: $version, ')
          ..write('saleId: $saleId, ')
          ..write('productId: $productId, ')
          ..write('name: $name, ')
          ..write('qtyMinor: $qtyMinor, ')
          ..write('decimalPlaces: $decimalPlaces, ')
          ..write('unitPriceMinor: $unitPriceMinor, ')
          ..write('unitCostMinor: $unitCostMinor, ')
          ..write('lineTotalMinor: $lineTotalMinor, ')
          ..write('currency: $currency, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PaymentsTable extends Payments
    with TableInfo<$PaymentsTable, PaymentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PaymentsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _saleIdMeta = const VerificationMeta('saleId');
  @override
  late final GeneratedColumn<String> saleId = GeneratedColumn<String>(
      'sale_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _methodMeta = const VerificationMeta('method');
  @override
  late final GeneratedColumn<String> method = GeneratedColumn<String>(
      'method', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _amountMinorMeta =
      const VerificationMeta('amountMinor');
  @override
  late final GeneratedColumn<int> amountMinor = GeneratedColumn<int>(
      'amount_minor', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _currencyMeta =
      const VerificationMeta('currency');
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
      'currency', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('AFN'));
  static const VerificationMeta _tenderedMinorMeta =
      const VerificationMeta('tenderedMinor');
  @override
  late final GeneratedColumn<int> tenderedMinor = GeneratedColumn<int>(
      'tendered_minor', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _changeMinorMeta =
      const VerificationMeta('changeMinor');
  @override
  late final GeneratedColumn<int> changeMinor = GeneratedColumn<int>(
      'change_minor', aliasedName, true,
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
        saleId,
        method,
        amountMinor,
        currency,
        tenderedMinor,
        changeMinor
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'payments';
  @override
  VerificationContext validateIntegrity(Insertable<PaymentRow> instance,
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
    if (data.containsKey('sale_id')) {
      context.handle(_saleIdMeta,
          saleId.isAcceptableOrUnknown(data['sale_id']!, _saleIdMeta));
    } else if (isInserting) {
      context.missing(_saleIdMeta);
    }
    if (data.containsKey('method')) {
      context.handle(_methodMeta,
          method.isAcceptableOrUnknown(data['method']!, _methodMeta));
    } else if (isInserting) {
      context.missing(_methodMeta);
    }
    if (data.containsKey('amount_minor')) {
      context.handle(
          _amountMinorMeta,
          amountMinor.isAcceptableOrUnknown(
              data['amount_minor']!, _amountMinorMeta));
    } else if (isInserting) {
      context.missing(_amountMinorMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(_currencyMeta,
          currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta));
    }
    if (data.containsKey('tendered_minor')) {
      context.handle(
          _tenderedMinorMeta,
          tenderedMinor.isAcceptableOrUnknown(
              data['tendered_minor']!, _tenderedMinorMeta));
    }
    if (data.containsKey('change_minor')) {
      context.handle(
          _changeMinorMeta,
          changeMinor.isAcceptableOrUnknown(
              data['change_minor']!, _changeMinorMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PaymentRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PaymentRow(
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
      saleId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sale_id'])!,
      method: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}method'])!,
      amountMinor: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}amount_minor'])!,
      currency: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}currency'])!,
      tenderedMinor: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}tendered_minor']),
      changeMinor: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}change_minor']),
    );
  }

  @override
  $PaymentsTable createAlias(String alias) {
    return $PaymentsTable(attachedDatabase, alias);
  }
}

class PaymentRow extends DataClass implements Insertable<PaymentRow> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String? createdBy;
  final String? updatedBy;
  final int version;
  final String saleId;
  final String method;
  final int amountMinor;
  final String currency;
  final int? tenderedMinor;
  final int? changeMinor;
  const PaymentRow(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt,
      this.createdBy,
      this.updatedBy,
      required this.version,
      required this.saleId,
      required this.method,
      required this.amountMinor,
      required this.currency,
      this.tenderedMinor,
      this.changeMinor});
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
    map['sale_id'] = Variable<String>(saleId);
    map['method'] = Variable<String>(method);
    map['amount_minor'] = Variable<int>(amountMinor);
    map['currency'] = Variable<String>(currency);
    if (!nullToAbsent || tenderedMinor != null) {
      map['tendered_minor'] = Variable<int>(tenderedMinor);
    }
    if (!nullToAbsent || changeMinor != null) {
      map['change_minor'] = Variable<int>(changeMinor);
    }
    return map;
  }

  PaymentsCompanion toCompanion(bool nullToAbsent) {
    return PaymentsCompanion(
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
      saleId: Value(saleId),
      method: Value(method),
      amountMinor: Value(amountMinor),
      currency: Value(currency),
      tenderedMinor: tenderedMinor == null && nullToAbsent
          ? const Value.absent()
          : Value(tenderedMinor),
      changeMinor: changeMinor == null && nullToAbsent
          ? const Value.absent()
          : Value(changeMinor),
    );
  }

  factory PaymentRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PaymentRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
      updatedBy: serializer.fromJson<String?>(json['updatedBy']),
      version: serializer.fromJson<int>(json['version']),
      saleId: serializer.fromJson<String>(json['saleId']),
      method: serializer.fromJson<String>(json['method']),
      amountMinor: serializer.fromJson<int>(json['amountMinor']),
      currency: serializer.fromJson<String>(json['currency']),
      tenderedMinor: serializer.fromJson<int?>(json['tenderedMinor']),
      changeMinor: serializer.fromJson<int?>(json['changeMinor']),
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
      'saleId': serializer.toJson<String>(saleId),
      'method': serializer.toJson<String>(method),
      'amountMinor': serializer.toJson<int>(amountMinor),
      'currency': serializer.toJson<String>(currency),
      'tenderedMinor': serializer.toJson<int?>(tenderedMinor),
      'changeMinor': serializer.toJson<int?>(changeMinor),
    };
  }

  PaymentRow copyWith(
          {String? id,
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          Value<String?> createdBy = const Value.absent(),
          Value<String?> updatedBy = const Value.absent(),
          int? version,
          String? saleId,
          String? method,
          int? amountMinor,
          String? currency,
          Value<int?> tenderedMinor = const Value.absent(),
          Value<int?> changeMinor = const Value.absent()}) =>
      PaymentRow(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        createdBy: createdBy.present ? createdBy.value : this.createdBy,
        updatedBy: updatedBy.present ? updatedBy.value : this.updatedBy,
        version: version ?? this.version,
        saleId: saleId ?? this.saleId,
        method: method ?? this.method,
        amountMinor: amountMinor ?? this.amountMinor,
        currency: currency ?? this.currency,
        tenderedMinor:
            tenderedMinor.present ? tenderedMinor.value : this.tenderedMinor,
        changeMinor: changeMinor.present ? changeMinor.value : this.changeMinor,
      );
  PaymentRow copyWithCompanion(PaymentsCompanion data) {
    return PaymentRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      version: data.version.present ? data.version.value : this.version,
      saleId: data.saleId.present ? data.saleId.value : this.saleId,
      method: data.method.present ? data.method.value : this.method,
      amountMinor:
          data.amountMinor.present ? data.amountMinor.value : this.amountMinor,
      currency: data.currency.present ? data.currency.value : this.currency,
      tenderedMinor: data.tenderedMinor.present
          ? data.tenderedMinor.value
          : this.tenderedMinor,
      changeMinor:
          data.changeMinor.present ? data.changeMinor.value : this.changeMinor,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PaymentRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('version: $version, ')
          ..write('saleId: $saleId, ')
          ..write('method: $method, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currency: $currency, ')
          ..write('tenderedMinor: $tenderedMinor, ')
          ..write('changeMinor: $changeMinor')
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
      saleId,
      method,
      amountMinor,
      currency,
      tenderedMinor,
      changeMinor);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PaymentRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.createdBy == this.createdBy &&
          other.updatedBy == this.updatedBy &&
          other.version == this.version &&
          other.saleId == this.saleId &&
          other.method == this.method &&
          other.amountMinor == this.amountMinor &&
          other.currency == this.currency &&
          other.tenderedMinor == this.tenderedMinor &&
          other.changeMinor == this.changeMinor);
}

class PaymentsCompanion extends UpdateCompanion<PaymentRow> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String?> createdBy;
  final Value<String?> updatedBy;
  final Value<int> version;
  final Value<String> saleId;
  final Value<String> method;
  final Value<int> amountMinor;
  final Value<String> currency;
  final Value<int?> tenderedMinor;
  final Value<int?> changeMinor;
  final Value<int> rowid;
  const PaymentsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.version = const Value.absent(),
    this.saleId = const Value.absent(),
    this.method = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.currency = const Value.absent(),
    this.tenderedMinor = const Value.absent(),
    this.changeMinor = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PaymentsCompanion.insert({
    required String id,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.version = const Value.absent(),
    required String saleId,
    required String method,
    required int amountMinor,
    this.currency = const Value.absent(),
    this.tenderedMinor = const Value.absent(),
    this.changeMinor = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        saleId = Value(saleId),
        method = Value(method),
        amountMinor = Value(amountMinor);
  static Insertable<PaymentRow> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? createdBy,
    Expression<String>? updatedBy,
    Expression<int>? version,
    Expression<String>? saleId,
    Expression<String>? method,
    Expression<int>? amountMinor,
    Expression<String>? currency,
    Expression<int>? tenderedMinor,
    Expression<int>? changeMinor,
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
      if (saleId != null) 'sale_id': saleId,
      if (method != null) 'method': method,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (currency != null) 'currency': currency,
      if (tenderedMinor != null) 'tendered_minor': tenderedMinor,
      if (changeMinor != null) 'change_minor': changeMinor,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PaymentsCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<String?>? createdBy,
      Value<String?>? updatedBy,
      Value<int>? version,
      Value<String>? saleId,
      Value<String>? method,
      Value<int>? amountMinor,
      Value<String>? currency,
      Value<int?>? tenderedMinor,
      Value<int?>? changeMinor,
      Value<int>? rowid}) {
    return PaymentsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      version: version ?? this.version,
      saleId: saleId ?? this.saleId,
      method: method ?? this.method,
      amountMinor: amountMinor ?? this.amountMinor,
      currency: currency ?? this.currency,
      tenderedMinor: tenderedMinor ?? this.tenderedMinor,
      changeMinor: changeMinor ?? this.changeMinor,
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
    if (saleId.present) {
      map['sale_id'] = Variable<String>(saleId.value);
    }
    if (method.present) {
      map['method'] = Variable<String>(method.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (tenderedMinor.present) {
      map['tendered_minor'] = Variable<int>(tenderedMinor.value);
    }
    if (changeMinor.present) {
      map['change_minor'] = Variable<int>(changeMinor.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PaymentsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('version: $version, ')
          ..write('saleId: $saleId, ')
          ..write('method: $method, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currency: $currency, ')
          ..write('tenderedMinor: $tenderedMinor, ')
          ..write('changeMinor: $changeMinor, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ShiftsTable extends Shifts with TableInfo<$ShiftsTable, ShiftRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShiftsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _branchIdMeta =
      const VerificationMeta('branchId');
  @override
  late final GeneratedColumn<String> branchId = GeneratedColumn<String>(
      'branch_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _openedAtMeta =
      const VerificationMeta('openedAt');
  @override
  late final GeneratedColumn<DateTime> openedAt = GeneratedColumn<DateTime>(
      'opened_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _openingFloatMinorMeta =
      const VerificationMeta('openingFloatMinor');
  @override
  late final GeneratedColumn<int> openingFloatMinor = GeneratedColumn<int>(
      'opening_float_minor', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _closedAtMeta =
      const VerificationMeta('closedAt');
  @override
  late final GeneratedColumn<DateTime> closedAt = GeneratedColumn<DateTime>(
      'closed_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _countedCashMinorMeta =
      const VerificationMeta('countedCashMinor');
  @override
  late final GeneratedColumn<int> countedCashMinor = GeneratedColumn<int>(
      'counted_cash_minor', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _expectedCashMinorMeta =
      const VerificationMeta('expectedCashMinor');
  @override
  late final GeneratedColumn<int> expectedCashMinor = GeneratedColumn<int>(
      'expected_cash_minor', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _varianceMinorMeta =
      const VerificationMeta('varianceMinor');
  @override
  late final GeneratedColumn<int> varianceMinor = GeneratedColumn<int>(
      'variance_minor', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('open'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        createdAt,
        updatedAt,
        deletedAt,
        createdBy,
        updatedBy,
        version,
        branchId,
        userId,
        openedAt,
        openingFloatMinor,
        closedAt,
        countedCashMinor,
        expectedCashMinor,
        varianceMinor,
        status
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shifts';
  @override
  VerificationContext validateIntegrity(Insertable<ShiftRow> instance,
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
    if (data.containsKey('branch_id')) {
      context.handle(_branchIdMeta,
          branchId.isAcceptableOrUnknown(data['branch_id']!, _branchIdMeta));
    } else if (isInserting) {
      context.missing(_branchIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('opened_at')) {
      context.handle(_openedAtMeta,
          openedAt.isAcceptableOrUnknown(data['opened_at']!, _openedAtMeta));
    }
    if (data.containsKey('opening_float_minor')) {
      context.handle(
          _openingFloatMinorMeta,
          openingFloatMinor.isAcceptableOrUnknown(
              data['opening_float_minor']!, _openingFloatMinorMeta));
    }
    if (data.containsKey('closed_at')) {
      context.handle(_closedAtMeta,
          closedAt.isAcceptableOrUnknown(data['closed_at']!, _closedAtMeta));
    }
    if (data.containsKey('counted_cash_minor')) {
      context.handle(
          _countedCashMinorMeta,
          countedCashMinor.isAcceptableOrUnknown(
              data['counted_cash_minor']!, _countedCashMinorMeta));
    }
    if (data.containsKey('expected_cash_minor')) {
      context.handle(
          _expectedCashMinorMeta,
          expectedCashMinor.isAcceptableOrUnknown(
              data['expected_cash_minor']!, _expectedCashMinorMeta));
    }
    if (data.containsKey('variance_minor')) {
      context.handle(
          _varianceMinorMeta,
          varianceMinor.isAcceptableOrUnknown(
              data['variance_minor']!, _varianceMinorMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ShiftRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ShiftRow(
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
      branchId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}branch_id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      openedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}opened_at'])!,
      openingFloatMinor: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}opening_float_minor'])!,
      closedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}closed_at']),
      countedCashMinor: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}counted_cash_minor']),
      expectedCashMinor: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}expected_cash_minor']),
      varianceMinor: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}variance_minor']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
    );
  }

  @override
  $ShiftsTable createAlias(String alias) {
    return $ShiftsTable(attachedDatabase, alias);
  }
}

class ShiftRow extends DataClass implements Insertable<ShiftRow> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String? createdBy;
  final String? updatedBy;
  final int version;
  final String branchId;
  final String userId;
  final DateTime openedAt;
  final int openingFloatMinor;
  final DateTime? closedAt;
  final int? countedCashMinor;
  final int? expectedCashMinor;
  final int? varianceMinor;
  final String status;
  const ShiftRow(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt,
      this.createdBy,
      this.updatedBy,
      required this.version,
      required this.branchId,
      required this.userId,
      required this.openedAt,
      required this.openingFloatMinor,
      this.closedAt,
      this.countedCashMinor,
      this.expectedCashMinor,
      this.varianceMinor,
      required this.status});
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
    map['branch_id'] = Variable<String>(branchId);
    map['user_id'] = Variable<String>(userId);
    map['opened_at'] = Variable<DateTime>(openedAt);
    map['opening_float_minor'] = Variable<int>(openingFloatMinor);
    if (!nullToAbsent || closedAt != null) {
      map['closed_at'] = Variable<DateTime>(closedAt);
    }
    if (!nullToAbsent || countedCashMinor != null) {
      map['counted_cash_minor'] = Variable<int>(countedCashMinor);
    }
    if (!nullToAbsent || expectedCashMinor != null) {
      map['expected_cash_minor'] = Variable<int>(expectedCashMinor);
    }
    if (!nullToAbsent || varianceMinor != null) {
      map['variance_minor'] = Variable<int>(varianceMinor);
    }
    map['status'] = Variable<String>(status);
    return map;
  }

  ShiftsCompanion toCompanion(bool nullToAbsent) {
    return ShiftsCompanion(
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
      branchId: Value(branchId),
      userId: Value(userId),
      openedAt: Value(openedAt),
      openingFloatMinor: Value(openingFloatMinor),
      closedAt: closedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(closedAt),
      countedCashMinor: countedCashMinor == null && nullToAbsent
          ? const Value.absent()
          : Value(countedCashMinor),
      expectedCashMinor: expectedCashMinor == null && nullToAbsent
          ? const Value.absent()
          : Value(expectedCashMinor),
      varianceMinor: varianceMinor == null && nullToAbsent
          ? const Value.absent()
          : Value(varianceMinor),
      status: Value(status),
    );
  }

  factory ShiftRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ShiftRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
      updatedBy: serializer.fromJson<String?>(json['updatedBy']),
      version: serializer.fromJson<int>(json['version']),
      branchId: serializer.fromJson<String>(json['branchId']),
      userId: serializer.fromJson<String>(json['userId']),
      openedAt: serializer.fromJson<DateTime>(json['openedAt']),
      openingFloatMinor: serializer.fromJson<int>(json['openingFloatMinor']),
      closedAt: serializer.fromJson<DateTime?>(json['closedAt']),
      countedCashMinor: serializer.fromJson<int?>(json['countedCashMinor']),
      expectedCashMinor: serializer.fromJson<int?>(json['expectedCashMinor']),
      varianceMinor: serializer.fromJson<int?>(json['varianceMinor']),
      status: serializer.fromJson<String>(json['status']),
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
      'branchId': serializer.toJson<String>(branchId),
      'userId': serializer.toJson<String>(userId),
      'openedAt': serializer.toJson<DateTime>(openedAt),
      'openingFloatMinor': serializer.toJson<int>(openingFloatMinor),
      'closedAt': serializer.toJson<DateTime?>(closedAt),
      'countedCashMinor': serializer.toJson<int?>(countedCashMinor),
      'expectedCashMinor': serializer.toJson<int?>(expectedCashMinor),
      'varianceMinor': serializer.toJson<int?>(varianceMinor),
      'status': serializer.toJson<String>(status),
    };
  }

  ShiftRow copyWith(
          {String? id,
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          Value<String?> createdBy = const Value.absent(),
          Value<String?> updatedBy = const Value.absent(),
          int? version,
          String? branchId,
          String? userId,
          DateTime? openedAt,
          int? openingFloatMinor,
          Value<DateTime?> closedAt = const Value.absent(),
          Value<int?> countedCashMinor = const Value.absent(),
          Value<int?> expectedCashMinor = const Value.absent(),
          Value<int?> varianceMinor = const Value.absent(),
          String? status}) =>
      ShiftRow(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        createdBy: createdBy.present ? createdBy.value : this.createdBy,
        updatedBy: updatedBy.present ? updatedBy.value : this.updatedBy,
        version: version ?? this.version,
        branchId: branchId ?? this.branchId,
        userId: userId ?? this.userId,
        openedAt: openedAt ?? this.openedAt,
        openingFloatMinor: openingFloatMinor ?? this.openingFloatMinor,
        closedAt: closedAt.present ? closedAt.value : this.closedAt,
        countedCashMinor: countedCashMinor.present
            ? countedCashMinor.value
            : this.countedCashMinor,
        expectedCashMinor: expectedCashMinor.present
            ? expectedCashMinor.value
            : this.expectedCashMinor,
        varianceMinor:
            varianceMinor.present ? varianceMinor.value : this.varianceMinor,
        status: status ?? this.status,
      );
  ShiftRow copyWithCompanion(ShiftsCompanion data) {
    return ShiftRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      version: data.version.present ? data.version.value : this.version,
      branchId: data.branchId.present ? data.branchId.value : this.branchId,
      userId: data.userId.present ? data.userId.value : this.userId,
      openedAt: data.openedAt.present ? data.openedAt.value : this.openedAt,
      openingFloatMinor: data.openingFloatMinor.present
          ? data.openingFloatMinor.value
          : this.openingFloatMinor,
      closedAt: data.closedAt.present ? data.closedAt.value : this.closedAt,
      countedCashMinor: data.countedCashMinor.present
          ? data.countedCashMinor.value
          : this.countedCashMinor,
      expectedCashMinor: data.expectedCashMinor.present
          ? data.expectedCashMinor.value
          : this.expectedCashMinor,
      varianceMinor: data.varianceMinor.present
          ? data.varianceMinor.value
          : this.varianceMinor,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ShiftRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('version: $version, ')
          ..write('branchId: $branchId, ')
          ..write('userId: $userId, ')
          ..write('openedAt: $openedAt, ')
          ..write('openingFloatMinor: $openingFloatMinor, ')
          ..write('closedAt: $closedAt, ')
          ..write('countedCashMinor: $countedCashMinor, ')
          ..write('expectedCashMinor: $expectedCashMinor, ')
          ..write('varianceMinor: $varianceMinor, ')
          ..write('status: $status')
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
      branchId,
      userId,
      openedAt,
      openingFloatMinor,
      closedAt,
      countedCashMinor,
      expectedCashMinor,
      varianceMinor,
      status);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ShiftRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.createdBy == this.createdBy &&
          other.updatedBy == this.updatedBy &&
          other.version == this.version &&
          other.branchId == this.branchId &&
          other.userId == this.userId &&
          other.openedAt == this.openedAt &&
          other.openingFloatMinor == this.openingFloatMinor &&
          other.closedAt == this.closedAt &&
          other.countedCashMinor == this.countedCashMinor &&
          other.expectedCashMinor == this.expectedCashMinor &&
          other.varianceMinor == this.varianceMinor &&
          other.status == this.status);
}

class ShiftsCompanion extends UpdateCompanion<ShiftRow> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String?> createdBy;
  final Value<String?> updatedBy;
  final Value<int> version;
  final Value<String> branchId;
  final Value<String> userId;
  final Value<DateTime> openedAt;
  final Value<int> openingFloatMinor;
  final Value<DateTime?> closedAt;
  final Value<int?> countedCashMinor;
  final Value<int?> expectedCashMinor;
  final Value<int?> varianceMinor;
  final Value<String> status;
  final Value<int> rowid;
  const ShiftsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.version = const Value.absent(),
    this.branchId = const Value.absent(),
    this.userId = const Value.absent(),
    this.openedAt = const Value.absent(),
    this.openingFloatMinor = const Value.absent(),
    this.closedAt = const Value.absent(),
    this.countedCashMinor = const Value.absent(),
    this.expectedCashMinor = const Value.absent(),
    this.varianceMinor = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ShiftsCompanion.insert({
    required String id,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.version = const Value.absent(),
    required String branchId,
    required String userId,
    this.openedAt = const Value.absent(),
    this.openingFloatMinor = const Value.absent(),
    this.closedAt = const Value.absent(),
    this.countedCashMinor = const Value.absent(),
    this.expectedCashMinor = const Value.absent(),
    this.varianceMinor = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        branchId = Value(branchId),
        userId = Value(userId);
  static Insertable<ShiftRow> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? createdBy,
    Expression<String>? updatedBy,
    Expression<int>? version,
    Expression<String>? branchId,
    Expression<String>? userId,
    Expression<DateTime>? openedAt,
    Expression<int>? openingFloatMinor,
    Expression<DateTime>? closedAt,
    Expression<int>? countedCashMinor,
    Expression<int>? expectedCashMinor,
    Expression<int>? varianceMinor,
    Expression<String>? status,
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
      if (branchId != null) 'branch_id': branchId,
      if (userId != null) 'user_id': userId,
      if (openedAt != null) 'opened_at': openedAt,
      if (openingFloatMinor != null) 'opening_float_minor': openingFloatMinor,
      if (closedAt != null) 'closed_at': closedAt,
      if (countedCashMinor != null) 'counted_cash_minor': countedCashMinor,
      if (expectedCashMinor != null) 'expected_cash_minor': expectedCashMinor,
      if (varianceMinor != null) 'variance_minor': varianceMinor,
      if (status != null) 'status': status,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ShiftsCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<String?>? createdBy,
      Value<String?>? updatedBy,
      Value<int>? version,
      Value<String>? branchId,
      Value<String>? userId,
      Value<DateTime>? openedAt,
      Value<int>? openingFloatMinor,
      Value<DateTime?>? closedAt,
      Value<int?>? countedCashMinor,
      Value<int?>? expectedCashMinor,
      Value<int?>? varianceMinor,
      Value<String>? status,
      Value<int>? rowid}) {
    return ShiftsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      version: version ?? this.version,
      branchId: branchId ?? this.branchId,
      userId: userId ?? this.userId,
      openedAt: openedAt ?? this.openedAt,
      openingFloatMinor: openingFloatMinor ?? this.openingFloatMinor,
      closedAt: closedAt ?? this.closedAt,
      countedCashMinor: countedCashMinor ?? this.countedCashMinor,
      expectedCashMinor: expectedCashMinor ?? this.expectedCashMinor,
      varianceMinor: varianceMinor ?? this.varianceMinor,
      status: status ?? this.status,
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
    if (branchId.present) {
      map['branch_id'] = Variable<String>(branchId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (openedAt.present) {
      map['opened_at'] = Variable<DateTime>(openedAt.value);
    }
    if (openingFloatMinor.present) {
      map['opening_float_minor'] = Variable<int>(openingFloatMinor.value);
    }
    if (closedAt.present) {
      map['closed_at'] = Variable<DateTime>(closedAt.value);
    }
    if (countedCashMinor.present) {
      map['counted_cash_minor'] = Variable<int>(countedCashMinor.value);
    }
    if (expectedCashMinor.present) {
      map['expected_cash_minor'] = Variable<int>(expectedCashMinor.value);
    }
    if (varianceMinor.present) {
      map['variance_minor'] = Variable<int>(varianceMinor.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShiftsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('version: $version, ')
          ..write('branchId: $branchId, ')
          ..write('userId: $userId, ')
          ..write('openedAt: $openedAt, ')
          ..write('openingFloatMinor: $openingFloatMinor, ')
          ..write('closedAt: $closedAt, ')
          ..write('countedCashMinor: $countedCashMinor, ')
          ..write('expectedCashMinor: $expectedCashMinor, ')
          ..write('varianceMinor: $varianceMinor, ')
          ..write('status: $status, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CustomersTable extends Customers
    with TableInfo<$CustomersTable, CustomerRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomersTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
      'phone', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _creditLimitMinorMeta =
      const VerificationMeta('creditLimitMinor');
  @override
  late final GeneratedColumn<int> creditLimitMinor = GeneratedColumn<int>(
      'credit_limit_minor', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _currencyMeta =
      const VerificationMeta('currency');
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
      'currency', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('AFN'));
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
        name,
        phone,
        creditLimitMinor,
        currency,
        isActive
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'customers';
  @override
  VerificationContext validateIntegrity(Insertable<CustomerRow> instance,
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
    if (data.containsKey('phone')) {
      context.handle(
          _phoneMeta, phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta));
    }
    if (data.containsKey('credit_limit_minor')) {
      context.handle(
          _creditLimitMinorMeta,
          creditLimitMinor.isAcceptableOrUnknown(
              data['credit_limit_minor']!, _creditLimitMinorMeta));
    }
    if (data.containsKey('currency')) {
      context.handle(_currencyMeta,
          currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta));
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
  CustomerRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomerRow(
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
      phone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone']),
      creditLimitMinor: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}credit_limit_minor']),
      currency: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}currency'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
    );
  }

  @override
  $CustomersTable createAlias(String alias) {
    return $CustomersTable(attachedDatabase, alias);
  }
}

class CustomerRow extends DataClass implements Insertable<CustomerRow> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String? createdBy;
  final String? updatedBy;
  final int version;
  final String name;
  final String? phone;
  final int? creditLimitMinor;
  final String currency;
  final bool isActive;
  const CustomerRow(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt,
      this.createdBy,
      this.updatedBy,
      required this.version,
      required this.name,
      this.phone,
      this.creditLimitMinor,
      required this.currency,
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
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || creditLimitMinor != null) {
      map['credit_limit_minor'] = Variable<int>(creditLimitMinor);
    }
    map['currency'] = Variable<String>(currency);
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  CustomersCompanion toCompanion(bool nullToAbsent) {
    return CustomersCompanion(
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
      phone:
          phone == null && nullToAbsent ? const Value.absent() : Value(phone),
      creditLimitMinor: creditLimitMinor == null && nullToAbsent
          ? const Value.absent()
          : Value(creditLimitMinor),
      currency: Value(currency),
      isActive: Value(isActive),
    );
  }

  factory CustomerRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomerRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
      updatedBy: serializer.fromJson<String?>(json['updatedBy']),
      version: serializer.fromJson<int>(json['version']),
      name: serializer.fromJson<String>(json['name']),
      phone: serializer.fromJson<String?>(json['phone']),
      creditLimitMinor: serializer.fromJson<int?>(json['creditLimitMinor']),
      currency: serializer.fromJson<String>(json['currency']),
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
      'name': serializer.toJson<String>(name),
      'phone': serializer.toJson<String?>(phone),
      'creditLimitMinor': serializer.toJson<int?>(creditLimitMinor),
      'currency': serializer.toJson<String>(currency),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  CustomerRow copyWith(
          {String? id,
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          Value<String?> createdBy = const Value.absent(),
          Value<String?> updatedBy = const Value.absent(),
          int? version,
          String? name,
          Value<String?> phone = const Value.absent(),
          Value<int?> creditLimitMinor = const Value.absent(),
          String? currency,
          bool? isActive}) =>
      CustomerRow(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        createdBy: createdBy.present ? createdBy.value : this.createdBy,
        updatedBy: updatedBy.present ? updatedBy.value : this.updatedBy,
        version: version ?? this.version,
        name: name ?? this.name,
        phone: phone.present ? phone.value : this.phone,
        creditLimitMinor: creditLimitMinor.present
            ? creditLimitMinor.value
            : this.creditLimitMinor,
        currency: currency ?? this.currency,
        isActive: isActive ?? this.isActive,
      );
  CustomerRow copyWithCompanion(CustomersCompanion data) {
    return CustomerRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      version: data.version.present ? data.version.value : this.version,
      name: data.name.present ? data.name.value : this.name,
      phone: data.phone.present ? data.phone.value : this.phone,
      creditLimitMinor: data.creditLimitMinor.present
          ? data.creditLimitMinor.value
          : this.creditLimitMinor,
      currency: data.currency.present ? data.currency.value : this.currency,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomerRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('version: $version, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('creditLimitMinor: $creditLimitMinor, ')
          ..write('currency: $currency, ')
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
      name,
      phone,
      creditLimitMinor,
      currency,
      isActive);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomerRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.createdBy == this.createdBy &&
          other.updatedBy == this.updatedBy &&
          other.version == this.version &&
          other.name == this.name &&
          other.phone == this.phone &&
          other.creditLimitMinor == this.creditLimitMinor &&
          other.currency == this.currency &&
          other.isActive == this.isActive);
}

class CustomersCompanion extends UpdateCompanion<CustomerRow> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String?> createdBy;
  final Value<String?> updatedBy;
  final Value<int> version;
  final Value<String> name;
  final Value<String?> phone;
  final Value<int?> creditLimitMinor;
  final Value<String> currency;
  final Value<bool> isActive;
  final Value<int> rowid;
  const CustomersCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.version = const Value.absent(),
    this.name = const Value.absent(),
    this.phone = const Value.absent(),
    this.creditLimitMinor = const Value.absent(),
    this.currency = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CustomersCompanion.insert({
    required String id,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.version = const Value.absent(),
    required String name,
    this.phone = const Value.absent(),
    this.creditLimitMinor = const Value.absent(),
    this.currency = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name);
  static Insertable<CustomerRow> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? createdBy,
    Expression<String>? updatedBy,
    Expression<int>? version,
    Expression<String>? name,
    Expression<String>? phone,
    Expression<int>? creditLimitMinor,
    Expression<String>? currency,
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
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (creditLimitMinor != null) 'credit_limit_minor': creditLimitMinor,
      if (currency != null) 'currency': currency,
      if (isActive != null) 'is_active': isActive,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CustomersCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<String?>? createdBy,
      Value<String?>? updatedBy,
      Value<int>? version,
      Value<String>? name,
      Value<String?>? phone,
      Value<int?>? creditLimitMinor,
      Value<String>? currency,
      Value<bool>? isActive,
      Value<int>? rowid}) {
    return CustomersCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      version: version ?? this.version,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      creditLimitMinor: creditLimitMinor ?? this.creditLimitMinor,
      currency: currency ?? this.currency,
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
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (creditLimitMinor.present) {
      map['credit_limit_minor'] = Variable<int>(creditLimitMinor.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
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
    return (StringBuffer('CustomersCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('version: $version, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('creditLimitMinor: $creditLimitMinor, ')
          ..write('currency: $currency, ')
          ..write('isActive: $isActive, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CustomerLedgerTable extends CustomerLedger
    with TableInfo<$CustomerLedgerTable, CustomerLedgerRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomerLedgerTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _customerIdMeta =
      const VerificationMeta('customerId');
  @override
  late final GeneratedColumn<String> customerId = GeneratedColumn<String>(
      'customer_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _methodMeta = const VerificationMeta('method');
  @override
  late final GeneratedColumn<String> method = GeneratedColumn<String>(
      'method', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _shiftIdMeta =
      const VerificationMeta('shiftId');
  @override
  late final GeneratedColumn<String> shiftId = GeneratedColumn<String>(
      'shift_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _amountMinorMeta =
      const VerificationMeta('amountMinor');
  @override
  late final GeneratedColumn<int> amountMinor = GeneratedColumn<int>(
      'amount_minor', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _currencyMeta =
      const VerificationMeta('currency');
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
      'currency', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('AFN'));
  static const VerificationMeta _refTypeMeta =
      const VerificationMeta('refType');
  @override
  late final GeneratedColumn<String> refType = GeneratedColumn<String>(
      'ref_type', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _refIdMeta = const VerificationMeta('refId');
  @override
  late final GeneratedColumn<String> refId = GeneratedColumn<String>(
      'ref_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
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
        customerId,
        method,
        shiftId,
        type,
        amountMinor,
        currency,
        refType,
        refId,
        occurredAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'customer_ledger';
  @override
  VerificationContext validateIntegrity(Insertable<CustomerLedgerRow> instance,
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
    if (data.containsKey('customer_id')) {
      context.handle(
          _customerIdMeta,
          customerId.isAcceptableOrUnknown(
              data['customer_id']!, _customerIdMeta));
    } else if (isInserting) {
      context.missing(_customerIdMeta);
    }
    if (data.containsKey('method')) {
      context.handle(_methodMeta,
          method.isAcceptableOrUnknown(data['method']!, _methodMeta));
    }
    if (data.containsKey('shift_id')) {
      context.handle(_shiftIdMeta,
          shiftId.isAcceptableOrUnknown(data['shift_id']!, _shiftIdMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('amount_minor')) {
      context.handle(
          _amountMinorMeta,
          amountMinor.isAcceptableOrUnknown(
              data['amount_minor']!, _amountMinorMeta));
    } else if (isInserting) {
      context.missing(_amountMinorMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(_currencyMeta,
          currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta));
    }
    if (data.containsKey('ref_type')) {
      context.handle(_refTypeMeta,
          refType.isAcceptableOrUnknown(data['ref_type']!, _refTypeMeta));
    }
    if (data.containsKey('ref_id')) {
      context.handle(
          _refIdMeta, refId.isAcceptableOrUnknown(data['ref_id']!, _refIdMeta));
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
  CustomerLedgerRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomerLedgerRow(
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
      customerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}customer_id'])!,
      method: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}method']),
      shiftId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}shift_id']),
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      amountMinor: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}amount_minor'])!,
      currency: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}currency'])!,
      refType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ref_type']),
      refId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ref_id']),
      occurredAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}occurred_at'])!,
    );
  }

  @override
  $CustomerLedgerTable createAlias(String alias) {
    return $CustomerLedgerTable(attachedDatabase, alias);
  }
}

class CustomerLedgerRow extends DataClass
    implements Insertable<CustomerLedgerRow> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String? createdBy;
  final String? updatedBy;
  final int version;
  final String customerId;

  /// A debt payment: how it was paid, and the shift whose drawer it went into.
  final String? method;
  final String? shiftId;
  final String type;
  final int amountMinor;
  final String currency;
  final String? refType;
  final String? refId;
  final DateTime occurredAt;
  const CustomerLedgerRow(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt,
      this.createdBy,
      this.updatedBy,
      required this.version,
      required this.customerId,
      this.method,
      this.shiftId,
      required this.type,
      required this.amountMinor,
      required this.currency,
      this.refType,
      this.refId,
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
    map['customer_id'] = Variable<String>(customerId);
    if (!nullToAbsent || method != null) {
      map['method'] = Variable<String>(method);
    }
    if (!nullToAbsent || shiftId != null) {
      map['shift_id'] = Variable<String>(shiftId);
    }
    map['type'] = Variable<String>(type);
    map['amount_minor'] = Variable<int>(amountMinor);
    map['currency'] = Variable<String>(currency);
    if (!nullToAbsent || refType != null) {
      map['ref_type'] = Variable<String>(refType);
    }
    if (!nullToAbsent || refId != null) {
      map['ref_id'] = Variable<String>(refId);
    }
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    return map;
  }

  CustomerLedgerCompanion toCompanion(bool nullToAbsent) {
    return CustomerLedgerCompanion(
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
      customerId: Value(customerId),
      method:
          method == null && nullToAbsent ? const Value.absent() : Value(method),
      shiftId: shiftId == null && nullToAbsent
          ? const Value.absent()
          : Value(shiftId),
      type: Value(type),
      amountMinor: Value(amountMinor),
      currency: Value(currency),
      refType: refType == null && nullToAbsent
          ? const Value.absent()
          : Value(refType),
      refId:
          refId == null && nullToAbsent ? const Value.absent() : Value(refId),
      occurredAt: Value(occurredAt),
    );
  }

  factory CustomerLedgerRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomerLedgerRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
      updatedBy: serializer.fromJson<String?>(json['updatedBy']),
      version: serializer.fromJson<int>(json['version']),
      customerId: serializer.fromJson<String>(json['customerId']),
      method: serializer.fromJson<String?>(json['method']),
      shiftId: serializer.fromJson<String?>(json['shiftId']),
      type: serializer.fromJson<String>(json['type']),
      amountMinor: serializer.fromJson<int>(json['amountMinor']),
      currency: serializer.fromJson<String>(json['currency']),
      refType: serializer.fromJson<String?>(json['refType']),
      refId: serializer.fromJson<String?>(json['refId']),
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
      'customerId': serializer.toJson<String>(customerId),
      'method': serializer.toJson<String?>(method),
      'shiftId': serializer.toJson<String?>(shiftId),
      'type': serializer.toJson<String>(type),
      'amountMinor': serializer.toJson<int>(amountMinor),
      'currency': serializer.toJson<String>(currency),
      'refType': serializer.toJson<String?>(refType),
      'refId': serializer.toJson<String?>(refId),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
    };
  }

  CustomerLedgerRow copyWith(
          {String? id,
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          Value<String?> createdBy = const Value.absent(),
          Value<String?> updatedBy = const Value.absent(),
          int? version,
          String? customerId,
          Value<String?> method = const Value.absent(),
          Value<String?> shiftId = const Value.absent(),
          String? type,
          int? amountMinor,
          String? currency,
          Value<String?> refType = const Value.absent(),
          Value<String?> refId = const Value.absent(),
          DateTime? occurredAt}) =>
      CustomerLedgerRow(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        createdBy: createdBy.present ? createdBy.value : this.createdBy,
        updatedBy: updatedBy.present ? updatedBy.value : this.updatedBy,
        version: version ?? this.version,
        customerId: customerId ?? this.customerId,
        method: method.present ? method.value : this.method,
        shiftId: shiftId.present ? shiftId.value : this.shiftId,
        type: type ?? this.type,
        amountMinor: amountMinor ?? this.amountMinor,
        currency: currency ?? this.currency,
        refType: refType.present ? refType.value : this.refType,
        refId: refId.present ? refId.value : this.refId,
        occurredAt: occurredAt ?? this.occurredAt,
      );
  CustomerLedgerRow copyWithCompanion(CustomerLedgerCompanion data) {
    return CustomerLedgerRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      version: data.version.present ? data.version.value : this.version,
      customerId:
          data.customerId.present ? data.customerId.value : this.customerId,
      method: data.method.present ? data.method.value : this.method,
      shiftId: data.shiftId.present ? data.shiftId.value : this.shiftId,
      type: data.type.present ? data.type.value : this.type,
      amountMinor:
          data.amountMinor.present ? data.amountMinor.value : this.amountMinor,
      currency: data.currency.present ? data.currency.value : this.currency,
      refType: data.refType.present ? data.refType.value : this.refType,
      refId: data.refId.present ? data.refId.value : this.refId,
      occurredAt:
          data.occurredAt.present ? data.occurredAt.value : this.occurredAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomerLedgerRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('version: $version, ')
          ..write('customerId: $customerId, ')
          ..write('method: $method, ')
          ..write('shiftId: $shiftId, ')
          ..write('type: $type, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currency: $currency, ')
          ..write('refType: $refType, ')
          ..write('refId: $refId, ')
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
      customerId,
      method,
      shiftId,
      type,
      amountMinor,
      currency,
      refType,
      refId,
      occurredAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomerLedgerRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.createdBy == this.createdBy &&
          other.updatedBy == this.updatedBy &&
          other.version == this.version &&
          other.customerId == this.customerId &&
          other.method == this.method &&
          other.shiftId == this.shiftId &&
          other.type == this.type &&
          other.amountMinor == this.amountMinor &&
          other.currency == this.currency &&
          other.refType == this.refType &&
          other.refId == this.refId &&
          other.occurredAt == this.occurredAt);
}

class CustomerLedgerCompanion extends UpdateCompanion<CustomerLedgerRow> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String?> createdBy;
  final Value<String?> updatedBy;
  final Value<int> version;
  final Value<String> customerId;
  final Value<String?> method;
  final Value<String?> shiftId;
  final Value<String> type;
  final Value<int> amountMinor;
  final Value<String> currency;
  final Value<String?> refType;
  final Value<String?> refId;
  final Value<DateTime> occurredAt;
  final Value<int> rowid;
  const CustomerLedgerCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.version = const Value.absent(),
    this.customerId = const Value.absent(),
    this.method = const Value.absent(),
    this.shiftId = const Value.absent(),
    this.type = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.currency = const Value.absent(),
    this.refType = const Value.absent(),
    this.refId = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CustomerLedgerCompanion.insert({
    required String id,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.version = const Value.absent(),
    required String customerId,
    this.method = const Value.absent(),
    this.shiftId = const Value.absent(),
    required String type,
    required int amountMinor,
    this.currency = const Value.absent(),
    this.refType = const Value.absent(),
    this.refId = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        customerId = Value(customerId),
        type = Value(type),
        amountMinor = Value(amountMinor);
  static Insertable<CustomerLedgerRow> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? createdBy,
    Expression<String>? updatedBy,
    Expression<int>? version,
    Expression<String>? customerId,
    Expression<String>? method,
    Expression<String>? shiftId,
    Expression<String>? type,
    Expression<int>? amountMinor,
    Expression<String>? currency,
    Expression<String>? refType,
    Expression<String>? refId,
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
      if (customerId != null) 'customer_id': customerId,
      if (method != null) 'method': method,
      if (shiftId != null) 'shift_id': shiftId,
      if (type != null) 'type': type,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (currency != null) 'currency': currency,
      if (refType != null) 'ref_type': refType,
      if (refId != null) 'ref_id': refId,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CustomerLedgerCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<String?>? createdBy,
      Value<String?>? updatedBy,
      Value<int>? version,
      Value<String>? customerId,
      Value<String?>? method,
      Value<String?>? shiftId,
      Value<String>? type,
      Value<int>? amountMinor,
      Value<String>? currency,
      Value<String?>? refType,
      Value<String?>? refId,
      Value<DateTime>? occurredAt,
      Value<int>? rowid}) {
    return CustomerLedgerCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      version: version ?? this.version,
      customerId: customerId ?? this.customerId,
      method: method ?? this.method,
      shiftId: shiftId ?? this.shiftId,
      type: type ?? this.type,
      amountMinor: amountMinor ?? this.amountMinor,
      currency: currency ?? this.currency,
      refType: refType ?? this.refType,
      refId: refId ?? this.refId,
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
    if (customerId.present) {
      map['customer_id'] = Variable<String>(customerId.value);
    }
    if (method.present) {
      map['method'] = Variable<String>(method.value);
    }
    if (shiftId.present) {
      map['shift_id'] = Variable<String>(shiftId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (refType.present) {
      map['ref_type'] = Variable<String>(refType.value);
    }
    if (refId.present) {
      map['ref_id'] = Variable<String>(refId.value);
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
    return (StringBuffer('CustomerLedgerCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('version: $version, ')
          ..write('customerId: $customerId, ')
          ..write('method: $method, ')
          ..write('shiftId: $shiftId, ')
          ..write('type: $type, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currency: $currency, ')
          ..write('refType: $refType, ')
          ..write('refId: $refId, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SuppliersTable extends Suppliers
    with TableInfo<$SuppliersTable, SupplierRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SuppliersTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
      'phone', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _currencyMeta =
      const VerificationMeta('currency');
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
      'currency', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('AFN'));
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
        name,
        phone,
        currency,
        isActive
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'suppliers';
  @override
  VerificationContext validateIntegrity(Insertable<SupplierRow> instance,
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
    if (data.containsKey('phone')) {
      context.handle(
          _phoneMeta, phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta));
    }
    if (data.containsKey('currency')) {
      context.handle(_currencyMeta,
          currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta));
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
  SupplierRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SupplierRow(
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
      phone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone']),
      currency: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}currency'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
    );
  }

  @override
  $SuppliersTable createAlias(String alias) {
    return $SuppliersTable(attachedDatabase, alias);
  }
}

class SupplierRow extends DataClass implements Insertable<SupplierRow> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String? createdBy;
  final String? updatedBy;
  final int version;
  final String name;
  final String? phone;
  final String currency;
  final bool isActive;
  const SupplierRow(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt,
      this.createdBy,
      this.updatedBy,
      required this.version,
      required this.name,
      this.phone,
      required this.currency,
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
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    map['currency'] = Variable<String>(currency);
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  SuppliersCompanion toCompanion(bool nullToAbsent) {
    return SuppliersCompanion(
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
      phone:
          phone == null && nullToAbsent ? const Value.absent() : Value(phone),
      currency: Value(currency),
      isActive: Value(isActive),
    );
  }

  factory SupplierRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SupplierRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
      updatedBy: serializer.fromJson<String?>(json['updatedBy']),
      version: serializer.fromJson<int>(json['version']),
      name: serializer.fromJson<String>(json['name']),
      phone: serializer.fromJson<String?>(json['phone']),
      currency: serializer.fromJson<String>(json['currency']),
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
      'name': serializer.toJson<String>(name),
      'phone': serializer.toJson<String?>(phone),
      'currency': serializer.toJson<String>(currency),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  SupplierRow copyWith(
          {String? id,
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          Value<String?> createdBy = const Value.absent(),
          Value<String?> updatedBy = const Value.absent(),
          int? version,
          String? name,
          Value<String?> phone = const Value.absent(),
          String? currency,
          bool? isActive}) =>
      SupplierRow(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        createdBy: createdBy.present ? createdBy.value : this.createdBy,
        updatedBy: updatedBy.present ? updatedBy.value : this.updatedBy,
        version: version ?? this.version,
        name: name ?? this.name,
        phone: phone.present ? phone.value : this.phone,
        currency: currency ?? this.currency,
        isActive: isActive ?? this.isActive,
      );
  SupplierRow copyWithCompanion(SuppliersCompanion data) {
    return SupplierRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      version: data.version.present ? data.version.value : this.version,
      name: data.name.present ? data.name.value : this.name,
      phone: data.phone.present ? data.phone.value : this.phone,
      currency: data.currency.present ? data.currency.value : this.currency,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SupplierRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('version: $version, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('currency: $currency, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, createdAt, updatedAt, deletedAt,
      createdBy, updatedBy, version, name, phone, currency, isActive);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SupplierRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.createdBy == this.createdBy &&
          other.updatedBy == this.updatedBy &&
          other.version == this.version &&
          other.name == this.name &&
          other.phone == this.phone &&
          other.currency == this.currency &&
          other.isActive == this.isActive);
}

class SuppliersCompanion extends UpdateCompanion<SupplierRow> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String?> createdBy;
  final Value<String?> updatedBy;
  final Value<int> version;
  final Value<String> name;
  final Value<String?> phone;
  final Value<String> currency;
  final Value<bool> isActive;
  final Value<int> rowid;
  const SuppliersCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.version = const Value.absent(),
    this.name = const Value.absent(),
    this.phone = const Value.absent(),
    this.currency = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SuppliersCompanion.insert({
    required String id,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.version = const Value.absent(),
    required String name,
    this.phone = const Value.absent(),
    this.currency = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name);
  static Insertable<SupplierRow> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? createdBy,
    Expression<String>? updatedBy,
    Expression<int>? version,
    Expression<String>? name,
    Expression<String>? phone,
    Expression<String>? currency,
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
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (currency != null) 'currency': currency,
      if (isActive != null) 'is_active': isActive,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SuppliersCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<String?>? createdBy,
      Value<String?>? updatedBy,
      Value<int>? version,
      Value<String>? name,
      Value<String?>? phone,
      Value<String>? currency,
      Value<bool>? isActive,
      Value<int>? rowid}) {
    return SuppliersCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      version: version ?? this.version,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      currency: currency ?? this.currency,
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
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
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
    return (StringBuffer('SuppliersCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('version: $version, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('currency: $currency, ')
          ..write('isActive: $isActive, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SupplierLedgerTable extends SupplierLedger
    with TableInfo<$SupplierLedgerTable, SupplierLedgerRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SupplierLedgerTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _supplierIdMeta =
      const VerificationMeta('supplierId');
  @override
  late final GeneratedColumn<String> supplierId = GeneratedColumn<String>(
      'supplier_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _methodMeta = const VerificationMeta('method');
  @override
  late final GeneratedColumn<String> method = GeneratedColumn<String>(
      'method', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _shiftIdMeta =
      const VerificationMeta('shiftId');
  @override
  late final GeneratedColumn<String> shiftId = GeneratedColumn<String>(
      'shift_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _amountMinorMeta =
      const VerificationMeta('amountMinor');
  @override
  late final GeneratedColumn<int> amountMinor = GeneratedColumn<int>(
      'amount_minor', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _currencyMeta =
      const VerificationMeta('currency');
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
      'currency', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('AFN'));
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
        supplierId,
        method,
        shiftId,
        type,
        amountMinor,
        currency,
        occurredAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'supplier_ledger';
  @override
  VerificationContext validateIntegrity(Insertable<SupplierLedgerRow> instance,
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
    if (data.containsKey('supplier_id')) {
      context.handle(
          _supplierIdMeta,
          supplierId.isAcceptableOrUnknown(
              data['supplier_id']!, _supplierIdMeta));
    } else if (isInserting) {
      context.missing(_supplierIdMeta);
    }
    if (data.containsKey('method')) {
      context.handle(_methodMeta,
          method.isAcceptableOrUnknown(data['method']!, _methodMeta));
    }
    if (data.containsKey('shift_id')) {
      context.handle(_shiftIdMeta,
          shiftId.isAcceptableOrUnknown(data['shift_id']!, _shiftIdMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('amount_minor')) {
      context.handle(
          _amountMinorMeta,
          amountMinor.isAcceptableOrUnknown(
              data['amount_minor']!, _amountMinorMeta));
    } else if (isInserting) {
      context.missing(_amountMinorMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(_currencyMeta,
          currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta));
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
  SupplierLedgerRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SupplierLedgerRow(
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
      supplierId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}supplier_id'])!,
      method: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}method']),
      shiftId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}shift_id']),
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      amountMinor: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}amount_minor'])!,
      currency: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}currency'])!,
      occurredAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}occurred_at'])!,
    );
  }

  @override
  $SupplierLedgerTable createAlias(String alias) {
    return $SupplierLedgerTable(attachedDatabase, alias);
  }
}

class SupplierLedgerRow extends DataClass
    implements Insertable<SupplierLedgerRow> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String? createdBy;
  final String? updatedBy;
  final int version;
  final String supplierId;

  /// A payment: how it was paid, and the shift whose drawer it came out of.
  final String? method;
  final String? shiftId;
  final String type;
  final int amountMinor;
  final String currency;
  final DateTime occurredAt;
  const SupplierLedgerRow(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt,
      this.createdBy,
      this.updatedBy,
      required this.version,
      required this.supplierId,
      this.method,
      this.shiftId,
      required this.type,
      required this.amountMinor,
      required this.currency,
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
    map['supplier_id'] = Variable<String>(supplierId);
    if (!nullToAbsent || method != null) {
      map['method'] = Variable<String>(method);
    }
    if (!nullToAbsent || shiftId != null) {
      map['shift_id'] = Variable<String>(shiftId);
    }
    map['type'] = Variable<String>(type);
    map['amount_minor'] = Variable<int>(amountMinor);
    map['currency'] = Variable<String>(currency);
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    return map;
  }

  SupplierLedgerCompanion toCompanion(bool nullToAbsent) {
    return SupplierLedgerCompanion(
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
      supplierId: Value(supplierId),
      method:
          method == null && nullToAbsent ? const Value.absent() : Value(method),
      shiftId: shiftId == null && nullToAbsent
          ? const Value.absent()
          : Value(shiftId),
      type: Value(type),
      amountMinor: Value(amountMinor),
      currency: Value(currency),
      occurredAt: Value(occurredAt),
    );
  }

  factory SupplierLedgerRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SupplierLedgerRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
      updatedBy: serializer.fromJson<String?>(json['updatedBy']),
      version: serializer.fromJson<int>(json['version']),
      supplierId: serializer.fromJson<String>(json['supplierId']),
      method: serializer.fromJson<String?>(json['method']),
      shiftId: serializer.fromJson<String?>(json['shiftId']),
      type: serializer.fromJson<String>(json['type']),
      amountMinor: serializer.fromJson<int>(json['amountMinor']),
      currency: serializer.fromJson<String>(json['currency']),
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
      'supplierId': serializer.toJson<String>(supplierId),
      'method': serializer.toJson<String?>(method),
      'shiftId': serializer.toJson<String?>(shiftId),
      'type': serializer.toJson<String>(type),
      'amountMinor': serializer.toJson<int>(amountMinor),
      'currency': serializer.toJson<String>(currency),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
    };
  }

  SupplierLedgerRow copyWith(
          {String? id,
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          Value<String?> createdBy = const Value.absent(),
          Value<String?> updatedBy = const Value.absent(),
          int? version,
          String? supplierId,
          Value<String?> method = const Value.absent(),
          Value<String?> shiftId = const Value.absent(),
          String? type,
          int? amountMinor,
          String? currency,
          DateTime? occurredAt}) =>
      SupplierLedgerRow(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        createdBy: createdBy.present ? createdBy.value : this.createdBy,
        updatedBy: updatedBy.present ? updatedBy.value : this.updatedBy,
        version: version ?? this.version,
        supplierId: supplierId ?? this.supplierId,
        method: method.present ? method.value : this.method,
        shiftId: shiftId.present ? shiftId.value : this.shiftId,
        type: type ?? this.type,
        amountMinor: amountMinor ?? this.amountMinor,
        currency: currency ?? this.currency,
        occurredAt: occurredAt ?? this.occurredAt,
      );
  SupplierLedgerRow copyWithCompanion(SupplierLedgerCompanion data) {
    return SupplierLedgerRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      version: data.version.present ? data.version.value : this.version,
      supplierId:
          data.supplierId.present ? data.supplierId.value : this.supplierId,
      method: data.method.present ? data.method.value : this.method,
      shiftId: data.shiftId.present ? data.shiftId.value : this.shiftId,
      type: data.type.present ? data.type.value : this.type,
      amountMinor:
          data.amountMinor.present ? data.amountMinor.value : this.amountMinor,
      currency: data.currency.present ? data.currency.value : this.currency,
      occurredAt:
          data.occurredAt.present ? data.occurredAt.value : this.occurredAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SupplierLedgerRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('version: $version, ')
          ..write('supplierId: $supplierId, ')
          ..write('method: $method, ')
          ..write('shiftId: $shiftId, ')
          ..write('type: $type, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currency: $currency, ')
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
      supplierId,
      method,
      shiftId,
      type,
      amountMinor,
      currency,
      occurredAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SupplierLedgerRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.createdBy == this.createdBy &&
          other.updatedBy == this.updatedBy &&
          other.version == this.version &&
          other.supplierId == this.supplierId &&
          other.method == this.method &&
          other.shiftId == this.shiftId &&
          other.type == this.type &&
          other.amountMinor == this.amountMinor &&
          other.currency == this.currency &&
          other.occurredAt == this.occurredAt);
}

class SupplierLedgerCompanion extends UpdateCompanion<SupplierLedgerRow> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String?> createdBy;
  final Value<String?> updatedBy;
  final Value<int> version;
  final Value<String> supplierId;
  final Value<String?> method;
  final Value<String?> shiftId;
  final Value<String> type;
  final Value<int> amountMinor;
  final Value<String> currency;
  final Value<DateTime> occurredAt;
  final Value<int> rowid;
  const SupplierLedgerCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.version = const Value.absent(),
    this.supplierId = const Value.absent(),
    this.method = const Value.absent(),
    this.shiftId = const Value.absent(),
    this.type = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.currency = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SupplierLedgerCompanion.insert({
    required String id,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.version = const Value.absent(),
    required String supplierId,
    this.method = const Value.absent(),
    this.shiftId = const Value.absent(),
    required String type,
    required int amountMinor,
    this.currency = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        supplierId = Value(supplierId),
        type = Value(type),
        amountMinor = Value(amountMinor);
  static Insertable<SupplierLedgerRow> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? createdBy,
    Expression<String>? updatedBy,
    Expression<int>? version,
    Expression<String>? supplierId,
    Expression<String>? method,
    Expression<String>? shiftId,
    Expression<String>? type,
    Expression<int>? amountMinor,
    Expression<String>? currency,
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
      if (supplierId != null) 'supplier_id': supplierId,
      if (method != null) 'method': method,
      if (shiftId != null) 'shift_id': shiftId,
      if (type != null) 'type': type,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (currency != null) 'currency': currency,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SupplierLedgerCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<String?>? createdBy,
      Value<String?>? updatedBy,
      Value<int>? version,
      Value<String>? supplierId,
      Value<String?>? method,
      Value<String?>? shiftId,
      Value<String>? type,
      Value<int>? amountMinor,
      Value<String>? currency,
      Value<DateTime>? occurredAt,
      Value<int>? rowid}) {
    return SupplierLedgerCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      version: version ?? this.version,
      supplierId: supplierId ?? this.supplierId,
      method: method ?? this.method,
      shiftId: shiftId ?? this.shiftId,
      type: type ?? this.type,
      amountMinor: amountMinor ?? this.amountMinor,
      currency: currency ?? this.currency,
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
    if (supplierId.present) {
      map['supplier_id'] = Variable<String>(supplierId.value);
    }
    if (method.present) {
      map['method'] = Variable<String>(method.value);
    }
    if (shiftId.present) {
      map['shift_id'] = Variable<String>(shiftId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
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
    return (StringBuffer('SupplierLedgerCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('version: $version, ')
          ..write('supplierId: $supplierId, ')
          ..write('method: $method, ')
          ..write('shiftId: $shiftId, ')
          ..write('type: $type, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currency: $currency, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncStatesTable extends SyncStates
    with TableInfo<$SyncStatesTable, SyncStateRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncStatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
      'device_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _lastPulledSeqMeta =
      const VerificationMeta('lastPulledSeq');
  @override
  late final GeneratedColumn<int> lastPulledSeq = GeneratedColumn<int>(
      'last_pulled_seq', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _watermarkTokenMeta =
      const VerificationMeta('watermarkToken');
  @override
  late final GeneratedColumn<String> watermarkToken = GeneratedColumn<String>(
      'watermark_token', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _scopeMeta = const VerificationMeta('scope');
  @override
  late final GeneratedColumn<String> scope = GeneratedColumn<String>(
      'scope', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [deviceId, lastPulledSeq, watermarkToken, scope];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_states';
  @override
  VerificationContext validateIntegrity(Insertable<SyncStateRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('last_pulled_seq')) {
      context.handle(
          _lastPulledSeqMeta,
          lastPulledSeq.isAcceptableOrUnknown(
              data['last_pulled_seq']!, _lastPulledSeqMeta));
    }
    if (data.containsKey('watermark_token')) {
      context.handle(
          _watermarkTokenMeta,
          watermarkToken.isAcceptableOrUnknown(
              data['watermark_token']!, _watermarkTokenMeta));
    }
    if (data.containsKey('scope')) {
      context.handle(
          _scopeMeta, scope.isAcceptableOrUnknown(data['scope']!, _scopeMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {deviceId};
  @override
  SyncStateRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncStateRow(
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id'])!,
      lastPulledSeq: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}last_pulled_seq'])!,
      watermarkToken: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}watermark_token']),
      scope: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}scope']),
    );
  }

  @override
  $SyncStatesTable createAlias(String alias) {
    return $SyncStatesTable(attachedDatabase, alias);
  }
}

class SyncStateRow extends DataClass implements Insertable<SyncStateRow> {
  final String deviceId;
  final int lastPulledSeq;

  /// The server's name for the change at the cursor: another change there means
  /// the server was restored from a backup (docs/sync-protocol.md, "Pull").
  final String? watermarkToken;

  /// The read scope the cursor was pulled in: a new one (a role or a branch
  /// granted) reads the feed again, for the rows the old scope hid.
  final String? scope;
  const SyncStateRow(
      {required this.deviceId,
      required this.lastPulledSeq,
      this.watermarkToken,
      this.scope});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['device_id'] = Variable<String>(deviceId);
    map['last_pulled_seq'] = Variable<int>(lastPulledSeq);
    if (!nullToAbsent || watermarkToken != null) {
      map['watermark_token'] = Variable<String>(watermarkToken);
    }
    if (!nullToAbsent || scope != null) {
      map['scope'] = Variable<String>(scope);
    }
    return map;
  }

  SyncStatesCompanion toCompanion(bool nullToAbsent) {
    return SyncStatesCompanion(
      deviceId: Value(deviceId),
      lastPulledSeq: Value(lastPulledSeq),
      watermarkToken: watermarkToken == null && nullToAbsent
          ? const Value.absent()
          : Value(watermarkToken),
      scope:
          scope == null && nullToAbsent ? const Value.absent() : Value(scope),
    );
  }

  factory SyncStateRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncStateRow(
      deviceId: serializer.fromJson<String>(json['deviceId']),
      lastPulledSeq: serializer.fromJson<int>(json['lastPulledSeq']),
      watermarkToken: serializer.fromJson<String?>(json['watermarkToken']),
      scope: serializer.fromJson<String?>(json['scope']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'deviceId': serializer.toJson<String>(deviceId),
      'lastPulledSeq': serializer.toJson<int>(lastPulledSeq),
      'watermarkToken': serializer.toJson<String?>(watermarkToken),
      'scope': serializer.toJson<String?>(scope),
    };
  }

  SyncStateRow copyWith(
          {String? deviceId,
          int? lastPulledSeq,
          Value<String?> watermarkToken = const Value.absent(),
          Value<String?> scope = const Value.absent()}) =>
      SyncStateRow(
        deviceId: deviceId ?? this.deviceId,
        lastPulledSeq: lastPulledSeq ?? this.lastPulledSeq,
        watermarkToken:
            watermarkToken.present ? watermarkToken.value : this.watermarkToken,
        scope: scope.present ? scope.value : this.scope,
      );
  SyncStateRow copyWithCompanion(SyncStatesCompanion data) {
    return SyncStateRow(
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      lastPulledSeq: data.lastPulledSeq.present
          ? data.lastPulledSeq.value
          : this.lastPulledSeq,
      watermarkToken: data.watermarkToken.present
          ? data.watermarkToken.value
          : this.watermarkToken,
      scope: data.scope.present ? data.scope.value : this.scope,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncStateRow(')
          ..write('deviceId: $deviceId, ')
          ..write('lastPulledSeq: $lastPulledSeq, ')
          ..write('watermarkToken: $watermarkToken, ')
          ..write('scope: $scope')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(deviceId, lastPulledSeq, watermarkToken, scope);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncStateRow &&
          other.deviceId == this.deviceId &&
          other.lastPulledSeq == this.lastPulledSeq &&
          other.watermarkToken == this.watermarkToken &&
          other.scope == this.scope);
}

class SyncStatesCompanion extends UpdateCompanion<SyncStateRow> {
  final Value<String> deviceId;
  final Value<int> lastPulledSeq;
  final Value<String?> watermarkToken;
  final Value<String?> scope;
  final Value<int> rowid;
  const SyncStatesCompanion({
    this.deviceId = const Value.absent(),
    this.lastPulledSeq = const Value.absent(),
    this.watermarkToken = const Value.absent(),
    this.scope = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncStatesCompanion.insert({
    required String deviceId,
    this.lastPulledSeq = const Value.absent(),
    this.watermarkToken = const Value.absent(),
    this.scope = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : deviceId = Value(deviceId);
  static Insertable<SyncStateRow> custom({
    Expression<String>? deviceId,
    Expression<int>? lastPulledSeq,
    Expression<String>? watermarkToken,
    Expression<String>? scope,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (deviceId != null) 'device_id': deviceId,
      if (lastPulledSeq != null) 'last_pulled_seq': lastPulledSeq,
      if (watermarkToken != null) 'watermark_token': watermarkToken,
      if (scope != null) 'scope': scope,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncStatesCompanion copyWith(
      {Value<String>? deviceId,
      Value<int>? lastPulledSeq,
      Value<String?>? watermarkToken,
      Value<String?>? scope,
      Value<int>? rowid}) {
    return SyncStatesCompanion(
      deviceId: deviceId ?? this.deviceId,
      lastPulledSeq: lastPulledSeq ?? this.lastPulledSeq,
      watermarkToken: watermarkToken ?? this.watermarkToken,
      scope: scope ?? this.scope,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (lastPulledSeq.present) {
      map['last_pulled_seq'] = Variable<int>(lastPulledSeq.value);
    }
    if (watermarkToken.present) {
      map['watermark_token'] = Variable<String>(watermarkToken.value);
    }
    if (scope.present) {
      map['scope'] = Variable<String>(scope.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncStatesCompanion(')
          ..write('deviceId: $deviceId, ')
          ..write('lastPulledSeq: $lastPulledSeq, ')
          ..write('watermarkToken: $watermarkToken, ')
          ..write('scope: $scope, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSettingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(Insertable<AppSettingRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSettingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSettingRow(
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value'])!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSettingRow extends DataClass implements Insertable<AppSettingRow> {
  final String key;
  final String value;
  const AppSettingRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      key: Value(key),
      value: Value(value),
    );
  }

  factory AppSettingRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSettingRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppSettingRow copyWith({String? key, String? value}) => AppSettingRow(
        key: key ?? this.key,
        value: value ?? this.value,
      );
  AppSettingRow copyWithCompanion(AppSettingsCompanion data) {
    return AppSettingRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSettingRow &&
          other.key == this.key &&
          other.value == this.value);
}

class AppSettingsCompanion extends UpdateCompanion<AppSettingRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  })  : key = Value(key),
        value = Value(value);
  static Insertable<AppSettingRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith(
      {Value<String>? key, Value<String>? value, Value<int>? rowid}) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
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
  late final $SalesTable sales = $SalesTable(this);
  late final $SaleLinesTable saleLines = $SaleLinesTable(this);
  late final $PaymentsTable payments = $PaymentsTable(this);
  late final $ShiftsTable shifts = $ShiftsTable(this);
  late final $CustomersTable customers = $CustomersTable(this);
  late final $CustomerLedgerTable customerLedger = $CustomerLedgerTable(this);
  late final $SuppliersTable suppliers = $SuppliersTable(this);
  late final $SupplierLedgerTable supplierLedger = $SupplierLedgerTable(this);
  late final $SyncStatesTable syncStates = $SyncStatesTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
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
        stockMovements,
        sales,
        saleLines,
        payments,
        shifts,
        customers,
        customerLedger,
        suppliers,
        supplierLedger,
        syncStates,
        appSettings
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
  Value<String?> lastError,
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
  Value<String?> lastError,
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

  ColumnFilters<String> get lastError => $composableBuilder(
      column: $table.lastError, builder: (column) => ColumnFilters(column));
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

  ColumnOrderings<String> get lastError => $composableBuilder(
      column: $table.lastError, builder: (column) => ColumnOrderings(column));
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

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);
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
            Value<String?> lastError = const Value.absent(),
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
            lastError: lastError,
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
            Value<String?> lastError = const Value.absent(),
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
            lastError: lastError,
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
typedef $$SalesTableCreateCompanionBuilder = SalesCompanion Function({
  required String id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String?> createdBy,
  Value<String?> updatedBy,
  Value<int> version,
  required String number,
  required String branchId,
  Value<String?> shiftId,
  Value<String?> customerId,
  Value<String> status,
  Value<String> currency,
  Value<int> discountMinor,
  Value<int> subtotalMinor,
  Value<int> taxMinor,
  Value<int> totalMinor,
  Value<int> paidMinor,
  Value<int> changeMinor,
  Value<DateTime> occurredAt,
  Value<String?> refundOf,
  Value<int> rowid,
});
typedef $$SalesTableUpdateCompanionBuilder = SalesCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String?> createdBy,
  Value<String?> updatedBy,
  Value<int> version,
  Value<String> number,
  Value<String> branchId,
  Value<String?> shiftId,
  Value<String?> customerId,
  Value<String> status,
  Value<String> currency,
  Value<int> discountMinor,
  Value<int> subtotalMinor,
  Value<int> taxMinor,
  Value<int> totalMinor,
  Value<int> paidMinor,
  Value<int> changeMinor,
  Value<DateTime> occurredAt,
  Value<String?> refundOf,
  Value<int> rowid,
});

class $$SalesTableFilterComposer extends Composer<_$AppDatabase, $SalesTable> {
  $$SalesTableFilterComposer({
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

  ColumnFilters<String> get number => $composableBuilder(
      column: $table.number, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get branchId => $composableBuilder(
      column: $table.branchId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get shiftId => $composableBuilder(
      column: $table.shiftId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get customerId => $composableBuilder(
      column: $table.customerId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get currency => $composableBuilder(
      column: $table.currency, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get discountMinor => $composableBuilder(
      column: $table.discountMinor, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get subtotalMinor => $composableBuilder(
      column: $table.subtotalMinor, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get taxMinor => $composableBuilder(
      column: $table.taxMinor, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalMinor => $composableBuilder(
      column: $table.totalMinor, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get paidMinor => $composableBuilder(
      column: $table.paidMinor, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get changeMinor => $composableBuilder(
      column: $table.changeMinor, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get occurredAt => $composableBuilder(
      column: $table.occurredAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get refundOf => $composableBuilder(
      column: $table.refundOf, builder: (column) => ColumnFilters(column));
}

class $$SalesTableOrderingComposer
    extends Composer<_$AppDatabase, $SalesTable> {
  $$SalesTableOrderingComposer({
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

  ColumnOrderings<String> get number => $composableBuilder(
      column: $table.number, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get branchId => $composableBuilder(
      column: $table.branchId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get shiftId => $composableBuilder(
      column: $table.shiftId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get customerId => $composableBuilder(
      column: $table.customerId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get currency => $composableBuilder(
      column: $table.currency, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get discountMinor => $composableBuilder(
      column: $table.discountMinor,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get subtotalMinor => $composableBuilder(
      column: $table.subtotalMinor,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get taxMinor => $composableBuilder(
      column: $table.taxMinor, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalMinor => $composableBuilder(
      column: $table.totalMinor, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get paidMinor => $composableBuilder(
      column: $table.paidMinor, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get changeMinor => $composableBuilder(
      column: $table.changeMinor, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get occurredAt => $composableBuilder(
      column: $table.occurredAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get refundOf => $composableBuilder(
      column: $table.refundOf, builder: (column) => ColumnOrderings(column));
}

class $$SalesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SalesTable> {
  $$SalesTableAnnotationComposer({
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

  GeneratedColumn<String> get number =>
      $composableBuilder(column: $table.number, builder: (column) => column);

  GeneratedColumn<String> get branchId =>
      $composableBuilder(column: $table.branchId, builder: (column) => column);

  GeneratedColumn<String> get shiftId =>
      $composableBuilder(column: $table.shiftId, builder: (column) => column);

  GeneratedColumn<String> get customerId => $composableBuilder(
      column: $table.customerId, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<int> get discountMinor => $composableBuilder(
      column: $table.discountMinor, builder: (column) => column);

  GeneratedColumn<int> get subtotalMinor => $composableBuilder(
      column: $table.subtotalMinor, builder: (column) => column);

  GeneratedColumn<int> get taxMinor =>
      $composableBuilder(column: $table.taxMinor, builder: (column) => column);

  GeneratedColumn<int> get totalMinor => $composableBuilder(
      column: $table.totalMinor, builder: (column) => column);

  GeneratedColumn<int> get paidMinor =>
      $composableBuilder(column: $table.paidMinor, builder: (column) => column);

  GeneratedColumn<int> get changeMinor => $composableBuilder(
      column: $table.changeMinor, builder: (column) => column);

  GeneratedColumn<DateTime> get occurredAt => $composableBuilder(
      column: $table.occurredAt, builder: (column) => column);

  GeneratedColumn<String> get refundOf =>
      $composableBuilder(column: $table.refundOf, builder: (column) => column);
}

class $$SalesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SalesTable,
    SaleRow,
    $$SalesTableFilterComposer,
    $$SalesTableOrderingComposer,
    $$SalesTableAnnotationComposer,
    $$SalesTableCreateCompanionBuilder,
    $$SalesTableUpdateCompanionBuilder,
    (SaleRow, BaseReferences<_$AppDatabase, $SalesTable, SaleRow>),
    SaleRow,
    PrefetchHooks Function()> {
  $$SalesTableTableManager(_$AppDatabase db, $SalesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SalesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SalesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SalesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String?> createdBy = const Value.absent(),
            Value<String?> updatedBy = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<String> number = const Value.absent(),
            Value<String> branchId = const Value.absent(),
            Value<String?> shiftId = const Value.absent(),
            Value<String?> customerId = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String> currency = const Value.absent(),
            Value<int> discountMinor = const Value.absent(),
            Value<int> subtotalMinor = const Value.absent(),
            Value<int> taxMinor = const Value.absent(),
            Value<int> totalMinor = const Value.absent(),
            Value<int> paidMinor = const Value.absent(),
            Value<int> changeMinor = const Value.absent(),
            Value<DateTime> occurredAt = const Value.absent(),
            Value<String?> refundOf = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SalesCompanion(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            createdBy: createdBy,
            updatedBy: updatedBy,
            version: version,
            number: number,
            branchId: branchId,
            shiftId: shiftId,
            customerId: customerId,
            status: status,
            currency: currency,
            discountMinor: discountMinor,
            subtotalMinor: subtotalMinor,
            taxMinor: taxMinor,
            totalMinor: totalMinor,
            paidMinor: paidMinor,
            changeMinor: changeMinor,
            occurredAt: occurredAt,
            refundOf: refundOf,
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
            required String number,
            required String branchId,
            Value<String?> shiftId = const Value.absent(),
            Value<String?> customerId = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String> currency = const Value.absent(),
            Value<int> discountMinor = const Value.absent(),
            Value<int> subtotalMinor = const Value.absent(),
            Value<int> taxMinor = const Value.absent(),
            Value<int> totalMinor = const Value.absent(),
            Value<int> paidMinor = const Value.absent(),
            Value<int> changeMinor = const Value.absent(),
            Value<DateTime> occurredAt = const Value.absent(),
            Value<String?> refundOf = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SalesCompanion.insert(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            createdBy: createdBy,
            updatedBy: updatedBy,
            version: version,
            number: number,
            branchId: branchId,
            shiftId: shiftId,
            customerId: customerId,
            status: status,
            currency: currency,
            discountMinor: discountMinor,
            subtotalMinor: subtotalMinor,
            taxMinor: taxMinor,
            totalMinor: totalMinor,
            paidMinor: paidMinor,
            changeMinor: changeMinor,
            occurredAt: occurredAt,
            refundOf: refundOf,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$SalesTable, SaleRow>(table),
                    BaseReferences<_$AppDatabase, $SalesTable, SaleRow>(
                        db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SalesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SalesTable,
    SaleRow,
    $$SalesTableFilterComposer,
    $$SalesTableOrderingComposer,
    $$SalesTableAnnotationComposer,
    $$SalesTableCreateCompanionBuilder,
    $$SalesTableUpdateCompanionBuilder,
    (SaleRow, BaseReferences<_$AppDatabase, $SalesTable, SaleRow>),
    SaleRow,
    PrefetchHooks Function()>;
typedef $$SaleLinesTableCreateCompanionBuilder = SaleLinesCompanion Function({
  required String id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String?> createdBy,
  Value<String?> updatedBy,
  Value<int> version,
  required String saleId,
  required String productId,
  required String name,
  required int qtyMinor,
  Value<int> decimalPlaces,
  required int unitPriceMinor,
  Value<int> unitCostMinor,
  required int lineTotalMinor,
  Value<String> currency,
  Value<int> rowid,
});
typedef $$SaleLinesTableUpdateCompanionBuilder = SaleLinesCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String?> createdBy,
  Value<String?> updatedBy,
  Value<int> version,
  Value<String> saleId,
  Value<String> productId,
  Value<String> name,
  Value<int> qtyMinor,
  Value<int> decimalPlaces,
  Value<int> unitPriceMinor,
  Value<int> unitCostMinor,
  Value<int> lineTotalMinor,
  Value<String> currency,
  Value<int> rowid,
});

class $$SaleLinesTableFilterComposer
    extends Composer<_$AppDatabase, $SaleLinesTable> {
  $$SaleLinesTableFilterComposer({
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

  ColumnFilters<String> get saleId => $composableBuilder(
      column: $table.saleId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get productId => $composableBuilder(
      column: $table.productId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get qtyMinor => $composableBuilder(
      column: $table.qtyMinor, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get decimalPlaces => $composableBuilder(
      column: $table.decimalPlaces, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get unitPriceMinor => $composableBuilder(
      column: $table.unitPriceMinor,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get unitCostMinor => $composableBuilder(
      column: $table.unitCostMinor, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lineTotalMinor => $composableBuilder(
      column: $table.lineTotalMinor,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get currency => $composableBuilder(
      column: $table.currency, builder: (column) => ColumnFilters(column));
}

class $$SaleLinesTableOrderingComposer
    extends Composer<_$AppDatabase, $SaleLinesTable> {
  $$SaleLinesTableOrderingComposer({
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

  ColumnOrderings<String> get saleId => $composableBuilder(
      column: $table.saleId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get productId => $composableBuilder(
      column: $table.productId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get qtyMinor => $composableBuilder(
      column: $table.qtyMinor, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get decimalPlaces => $composableBuilder(
      column: $table.decimalPlaces,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get unitPriceMinor => $composableBuilder(
      column: $table.unitPriceMinor,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get unitCostMinor => $composableBuilder(
      column: $table.unitCostMinor,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lineTotalMinor => $composableBuilder(
      column: $table.lineTotalMinor,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get currency => $composableBuilder(
      column: $table.currency, builder: (column) => ColumnOrderings(column));
}

class $$SaleLinesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SaleLinesTable> {
  $$SaleLinesTableAnnotationComposer({
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

  GeneratedColumn<String> get saleId =>
      $composableBuilder(column: $table.saleId, builder: (column) => column);

  GeneratedColumn<String> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get qtyMinor =>
      $composableBuilder(column: $table.qtyMinor, builder: (column) => column);

  GeneratedColumn<int> get decimalPlaces => $composableBuilder(
      column: $table.decimalPlaces, builder: (column) => column);

  GeneratedColumn<int> get unitPriceMinor => $composableBuilder(
      column: $table.unitPriceMinor, builder: (column) => column);

  GeneratedColumn<int> get unitCostMinor => $composableBuilder(
      column: $table.unitCostMinor, builder: (column) => column);

  GeneratedColumn<int> get lineTotalMinor => $composableBuilder(
      column: $table.lineTotalMinor, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);
}

class $$SaleLinesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SaleLinesTable,
    SaleLineRow,
    $$SaleLinesTableFilterComposer,
    $$SaleLinesTableOrderingComposer,
    $$SaleLinesTableAnnotationComposer,
    $$SaleLinesTableCreateCompanionBuilder,
    $$SaleLinesTableUpdateCompanionBuilder,
    (SaleLineRow, BaseReferences<_$AppDatabase, $SaleLinesTable, SaleLineRow>),
    SaleLineRow,
    PrefetchHooks Function()> {
  $$SaleLinesTableTableManager(_$AppDatabase db, $SaleLinesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SaleLinesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SaleLinesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SaleLinesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String?> createdBy = const Value.absent(),
            Value<String?> updatedBy = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<String> saleId = const Value.absent(),
            Value<String> productId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> qtyMinor = const Value.absent(),
            Value<int> decimalPlaces = const Value.absent(),
            Value<int> unitPriceMinor = const Value.absent(),
            Value<int> unitCostMinor = const Value.absent(),
            Value<int> lineTotalMinor = const Value.absent(),
            Value<String> currency = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SaleLinesCompanion(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            createdBy: createdBy,
            updatedBy: updatedBy,
            version: version,
            saleId: saleId,
            productId: productId,
            name: name,
            qtyMinor: qtyMinor,
            decimalPlaces: decimalPlaces,
            unitPriceMinor: unitPriceMinor,
            unitCostMinor: unitCostMinor,
            lineTotalMinor: lineTotalMinor,
            currency: currency,
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
            required String saleId,
            required String productId,
            required String name,
            required int qtyMinor,
            Value<int> decimalPlaces = const Value.absent(),
            required int unitPriceMinor,
            Value<int> unitCostMinor = const Value.absent(),
            required int lineTotalMinor,
            Value<String> currency = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SaleLinesCompanion.insert(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            createdBy: createdBy,
            updatedBy: updatedBy,
            version: version,
            saleId: saleId,
            productId: productId,
            name: name,
            qtyMinor: qtyMinor,
            decimalPlaces: decimalPlaces,
            unitPriceMinor: unitPriceMinor,
            unitCostMinor: unitCostMinor,
            lineTotalMinor: lineTotalMinor,
            currency: currency,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$SaleLinesTable, SaleLineRow>(table),
                    BaseReferences<_$AppDatabase, $SaleLinesTable, SaleLineRow>(
                        db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SaleLinesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SaleLinesTable,
    SaleLineRow,
    $$SaleLinesTableFilterComposer,
    $$SaleLinesTableOrderingComposer,
    $$SaleLinesTableAnnotationComposer,
    $$SaleLinesTableCreateCompanionBuilder,
    $$SaleLinesTableUpdateCompanionBuilder,
    (SaleLineRow, BaseReferences<_$AppDatabase, $SaleLinesTable, SaleLineRow>),
    SaleLineRow,
    PrefetchHooks Function()>;
typedef $$PaymentsTableCreateCompanionBuilder = PaymentsCompanion Function({
  required String id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String?> createdBy,
  Value<String?> updatedBy,
  Value<int> version,
  required String saleId,
  required String method,
  required int amountMinor,
  Value<String> currency,
  Value<int?> tenderedMinor,
  Value<int?> changeMinor,
  Value<int> rowid,
});
typedef $$PaymentsTableUpdateCompanionBuilder = PaymentsCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String?> createdBy,
  Value<String?> updatedBy,
  Value<int> version,
  Value<String> saleId,
  Value<String> method,
  Value<int> amountMinor,
  Value<String> currency,
  Value<int?> tenderedMinor,
  Value<int?> changeMinor,
  Value<int> rowid,
});

class $$PaymentsTableFilterComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableFilterComposer({
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

  ColumnFilters<String> get saleId => $composableBuilder(
      column: $table.saleId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get method => $composableBuilder(
      column: $table.method, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get amountMinor => $composableBuilder(
      column: $table.amountMinor, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get currency => $composableBuilder(
      column: $table.currency, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get tenderedMinor => $composableBuilder(
      column: $table.tenderedMinor, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get changeMinor => $composableBuilder(
      column: $table.changeMinor, builder: (column) => ColumnFilters(column));
}

class $$PaymentsTableOrderingComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableOrderingComposer({
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

  ColumnOrderings<String> get saleId => $composableBuilder(
      column: $table.saleId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get method => $composableBuilder(
      column: $table.method, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get amountMinor => $composableBuilder(
      column: $table.amountMinor, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get currency => $composableBuilder(
      column: $table.currency, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get tenderedMinor => $composableBuilder(
      column: $table.tenderedMinor,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get changeMinor => $composableBuilder(
      column: $table.changeMinor, builder: (column) => ColumnOrderings(column));
}

class $$PaymentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableAnnotationComposer({
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

  GeneratedColumn<String> get saleId =>
      $composableBuilder(column: $table.saleId, builder: (column) => column);

  GeneratedColumn<String> get method =>
      $composableBuilder(column: $table.method, builder: (column) => column);

  GeneratedColumn<int> get amountMinor => $composableBuilder(
      column: $table.amountMinor, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<int> get tenderedMinor => $composableBuilder(
      column: $table.tenderedMinor, builder: (column) => column);

  GeneratedColumn<int> get changeMinor => $composableBuilder(
      column: $table.changeMinor, builder: (column) => column);
}

class $$PaymentsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PaymentsTable,
    PaymentRow,
    $$PaymentsTableFilterComposer,
    $$PaymentsTableOrderingComposer,
    $$PaymentsTableAnnotationComposer,
    $$PaymentsTableCreateCompanionBuilder,
    $$PaymentsTableUpdateCompanionBuilder,
    (PaymentRow, BaseReferences<_$AppDatabase, $PaymentsTable, PaymentRow>),
    PaymentRow,
    PrefetchHooks Function()> {
  $$PaymentsTableTableManager(_$AppDatabase db, $PaymentsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PaymentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PaymentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PaymentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String?> createdBy = const Value.absent(),
            Value<String?> updatedBy = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<String> saleId = const Value.absent(),
            Value<String> method = const Value.absent(),
            Value<int> amountMinor = const Value.absent(),
            Value<String> currency = const Value.absent(),
            Value<int?> tenderedMinor = const Value.absent(),
            Value<int?> changeMinor = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PaymentsCompanion(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            createdBy: createdBy,
            updatedBy: updatedBy,
            version: version,
            saleId: saleId,
            method: method,
            amountMinor: amountMinor,
            currency: currency,
            tenderedMinor: tenderedMinor,
            changeMinor: changeMinor,
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
            required String saleId,
            required String method,
            required int amountMinor,
            Value<String> currency = const Value.absent(),
            Value<int?> tenderedMinor = const Value.absent(),
            Value<int?> changeMinor = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PaymentsCompanion.insert(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            createdBy: createdBy,
            updatedBy: updatedBy,
            version: version,
            saleId: saleId,
            method: method,
            amountMinor: amountMinor,
            currency: currency,
            tenderedMinor: tenderedMinor,
            changeMinor: changeMinor,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$PaymentsTable, PaymentRow>(table),
                    BaseReferences<_$AppDatabase, $PaymentsTable, PaymentRow>(
                        db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PaymentsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PaymentsTable,
    PaymentRow,
    $$PaymentsTableFilterComposer,
    $$PaymentsTableOrderingComposer,
    $$PaymentsTableAnnotationComposer,
    $$PaymentsTableCreateCompanionBuilder,
    $$PaymentsTableUpdateCompanionBuilder,
    (PaymentRow, BaseReferences<_$AppDatabase, $PaymentsTable, PaymentRow>),
    PaymentRow,
    PrefetchHooks Function()>;
typedef $$ShiftsTableCreateCompanionBuilder = ShiftsCompanion Function({
  required String id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String?> createdBy,
  Value<String?> updatedBy,
  Value<int> version,
  required String branchId,
  required String userId,
  Value<DateTime> openedAt,
  Value<int> openingFloatMinor,
  Value<DateTime?> closedAt,
  Value<int?> countedCashMinor,
  Value<int?> expectedCashMinor,
  Value<int?> varianceMinor,
  Value<String> status,
  Value<int> rowid,
});
typedef $$ShiftsTableUpdateCompanionBuilder = ShiftsCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String?> createdBy,
  Value<String?> updatedBy,
  Value<int> version,
  Value<String> branchId,
  Value<String> userId,
  Value<DateTime> openedAt,
  Value<int> openingFloatMinor,
  Value<DateTime?> closedAt,
  Value<int?> countedCashMinor,
  Value<int?> expectedCashMinor,
  Value<int?> varianceMinor,
  Value<String> status,
  Value<int> rowid,
});

class $$ShiftsTableFilterComposer
    extends Composer<_$AppDatabase, $ShiftsTable> {
  $$ShiftsTableFilterComposer({
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

  ColumnFilters<String> get branchId => $composableBuilder(
      column: $table.branchId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get openedAt => $composableBuilder(
      column: $table.openedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get openingFloatMinor => $composableBuilder(
      column: $table.openingFloatMinor,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get closedAt => $composableBuilder(
      column: $table.closedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get countedCashMinor => $composableBuilder(
      column: $table.countedCashMinor,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get expectedCashMinor => $composableBuilder(
      column: $table.expectedCashMinor,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get varianceMinor => $composableBuilder(
      column: $table.varianceMinor, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));
}

class $$ShiftsTableOrderingComposer
    extends Composer<_$AppDatabase, $ShiftsTable> {
  $$ShiftsTableOrderingComposer({
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

  ColumnOrderings<String> get branchId => $composableBuilder(
      column: $table.branchId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get openedAt => $composableBuilder(
      column: $table.openedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get openingFloatMinor => $composableBuilder(
      column: $table.openingFloatMinor,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get closedAt => $composableBuilder(
      column: $table.closedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get countedCashMinor => $composableBuilder(
      column: $table.countedCashMinor,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get expectedCashMinor => $composableBuilder(
      column: $table.expectedCashMinor,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get varianceMinor => $composableBuilder(
      column: $table.varianceMinor,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));
}

class $$ShiftsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ShiftsTable> {
  $$ShiftsTableAnnotationComposer({
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

  GeneratedColumn<String> get branchId =>
      $composableBuilder(column: $table.branchId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<DateTime> get openedAt =>
      $composableBuilder(column: $table.openedAt, builder: (column) => column);

  GeneratedColumn<int> get openingFloatMinor => $composableBuilder(
      column: $table.openingFloatMinor, builder: (column) => column);

  GeneratedColumn<DateTime> get closedAt =>
      $composableBuilder(column: $table.closedAt, builder: (column) => column);

  GeneratedColumn<int> get countedCashMinor => $composableBuilder(
      column: $table.countedCashMinor, builder: (column) => column);

  GeneratedColumn<int> get expectedCashMinor => $composableBuilder(
      column: $table.expectedCashMinor, builder: (column) => column);

  GeneratedColumn<int> get varianceMinor => $composableBuilder(
      column: $table.varianceMinor, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);
}

class $$ShiftsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ShiftsTable,
    ShiftRow,
    $$ShiftsTableFilterComposer,
    $$ShiftsTableOrderingComposer,
    $$ShiftsTableAnnotationComposer,
    $$ShiftsTableCreateCompanionBuilder,
    $$ShiftsTableUpdateCompanionBuilder,
    (ShiftRow, BaseReferences<_$AppDatabase, $ShiftsTable, ShiftRow>),
    ShiftRow,
    PrefetchHooks Function()> {
  $$ShiftsTableTableManager(_$AppDatabase db, $ShiftsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ShiftsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ShiftsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ShiftsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String?> createdBy = const Value.absent(),
            Value<String?> updatedBy = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<String> branchId = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<DateTime> openedAt = const Value.absent(),
            Value<int> openingFloatMinor = const Value.absent(),
            Value<DateTime?> closedAt = const Value.absent(),
            Value<int?> countedCashMinor = const Value.absent(),
            Value<int?> expectedCashMinor = const Value.absent(),
            Value<int?> varianceMinor = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ShiftsCompanion(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            createdBy: createdBy,
            updatedBy: updatedBy,
            version: version,
            branchId: branchId,
            userId: userId,
            openedAt: openedAt,
            openingFloatMinor: openingFloatMinor,
            closedAt: closedAt,
            countedCashMinor: countedCashMinor,
            expectedCashMinor: expectedCashMinor,
            varianceMinor: varianceMinor,
            status: status,
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
            required String branchId,
            required String userId,
            Value<DateTime> openedAt = const Value.absent(),
            Value<int> openingFloatMinor = const Value.absent(),
            Value<DateTime?> closedAt = const Value.absent(),
            Value<int?> countedCashMinor = const Value.absent(),
            Value<int?> expectedCashMinor = const Value.absent(),
            Value<int?> varianceMinor = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ShiftsCompanion.insert(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            createdBy: createdBy,
            updatedBy: updatedBy,
            version: version,
            branchId: branchId,
            userId: userId,
            openedAt: openedAt,
            openingFloatMinor: openingFloatMinor,
            closedAt: closedAt,
            countedCashMinor: countedCashMinor,
            expectedCashMinor: expectedCashMinor,
            varianceMinor: varianceMinor,
            status: status,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$ShiftsTable, ShiftRow>(table),
                    BaseReferences<_$AppDatabase, $ShiftsTable, ShiftRow>(
                        db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ShiftsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ShiftsTable,
    ShiftRow,
    $$ShiftsTableFilterComposer,
    $$ShiftsTableOrderingComposer,
    $$ShiftsTableAnnotationComposer,
    $$ShiftsTableCreateCompanionBuilder,
    $$ShiftsTableUpdateCompanionBuilder,
    (ShiftRow, BaseReferences<_$AppDatabase, $ShiftsTable, ShiftRow>),
    ShiftRow,
    PrefetchHooks Function()>;
typedef $$CustomersTableCreateCompanionBuilder = CustomersCompanion Function({
  required String id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String?> createdBy,
  Value<String?> updatedBy,
  Value<int> version,
  required String name,
  Value<String?> phone,
  Value<int?> creditLimitMinor,
  Value<String> currency,
  Value<bool> isActive,
  Value<int> rowid,
});
typedef $$CustomersTableUpdateCompanionBuilder = CustomersCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String?> createdBy,
  Value<String?> updatedBy,
  Value<int> version,
  Value<String> name,
  Value<String?> phone,
  Value<int?> creditLimitMinor,
  Value<String> currency,
  Value<bool> isActive,
  Value<int> rowid,
});

class $$CustomersTableFilterComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableFilterComposer({
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

  ColumnFilters<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get creditLimitMinor => $composableBuilder(
      column: $table.creditLimitMinor,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get currency => $composableBuilder(
      column: $table.currency, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));
}

class $$CustomersTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableOrderingComposer({
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

  ColumnOrderings<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get creditLimitMinor => $composableBuilder(
      column: $table.creditLimitMinor,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get currency => $composableBuilder(
      column: $table.currency, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));
}

class $$CustomersTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableAnnotationComposer({
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

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<int> get creditLimitMinor => $composableBuilder(
      column: $table.creditLimitMinor, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);
}

class $$CustomersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CustomersTable,
    CustomerRow,
    $$CustomersTableFilterComposer,
    $$CustomersTableOrderingComposer,
    $$CustomersTableAnnotationComposer,
    $$CustomersTableCreateCompanionBuilder,
    $$CustomersTableUpdateCompanionBuilder,
    (CustomerRow, BaseReferences<_$AppDatabase, $CustomersTable, CustomerRow>),
    CustomerRow,
    PrefetchHooks Function()> {
  $$CustomersTableTableManager(_$AppDatabase db, $CustomersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String?> createdBy = const Value.absent(),
            Value<String?> updatedBy = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> phone = const Value.absent(),
            Value<int?> creditLimitMinor = const Value.absent(),
            Value<String> currency = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CustomersCompanion(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            createdBy: createdBy,
            updatedBy: updatedBy,
            version: version,
            name: name,
            phone: phone,
            creditLimitMinor: creditLimitMinor,
            currency: currency,
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
            required String name,
            Value<String?> phone = const Value.absent(),
            Value<int?> creditLimitMinor = const Value.absent(),
            Value<String> currency = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CustomersCompanion.insert(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            createdBy: createdBy,
            updatedBy: updatedBy,
            version: version,
            name: name,
            phone: phone,
            creditLimitMinor: creditLimitMinor,
            currency: currency,
            isActive: isActive,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$CustomersTable, CustomerRow>(table),
                    BaseReferences<_$AppDatabase, $CustomersTable, CustomerRow>(
                        db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CustomersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CustomersTable,
    CustomerRow,
    $$CustomersTableFilterComposer,
    $$CustomersTableOrderingComposer,
    $$CustomersTableAnnotationComposer,
    $$CustomersTableCreateCompanionBuilder,
    $$CustomersTableUpdateCompanionBuilder,
    (CustomerRow, BaseReferences<_$AppDatabase, $CustomersTable, CustomerRow>),
    CustomerRow,
    PrefetchHooks Function()>;
typedef $$CustomerLedgerTableCreateCompanionBuilder = CustomerLedgerCompanion
    Function({
  required String id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String?> createdBy,
  Value<String?> updatedBy,
  Value<int> version,
  required String customerId,
  Value<String?> method,
  Value<String?> shiftId,
  required String type,
  required int amountMinor,
  Value<String> currency,
  Value<String?> refType,
  Value<String?> refId,
  Value<DateTime> occurredAt,
  Value<int> rowid,
});
typedef $$CustomerLedgerTableUpdateCompanionBuilder = CustomerLedgerCompanion
    Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String?> createdBy,
  Value<String?> updatedBy,
  Value<int> version,
  Value<String> customerId,
  Value<String?> method,
  Value<String?> shiftId,
  Value<String> type,
  Value<int> amountMinor,
  Value<String> currency,
  Value<String?> refType,
  Value<String?> refId,
  Value<DateTime> occurredAt,
  Value<int> rowid,
});

class $$CustomerLedgerTableFilterComposer
    extends Composer<_$AppDatabase, $CustomerLedgerTable> {
  $$CustomerLedgerTableFilterComposer({
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

  ColumnFilters<String> get customerId => $composableBuilder(
      column: $table.customerId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get method => $composableBuilder(
      column: $table.method, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get shiftId => $composableBuilder(
      column: $table.shiftId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get amountMinor => $composableBuilder(
      column: $table.amountMinor, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get currency => $composableBuilder(
      column: $table.currency, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get refType => $composableBuilder(
      column: $table.refType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get refId => $composableBuilder(
      column: $table.refId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get occurredAt => $composableBuilder(
      column: $table.occurredAt, builder: (column) => ColumnFilters(column));
}

class $$CustomerLedgerTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomerLedgerTable> {
  $$CustomerLedgerTableOrderingComposer({
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

  ColumnOrderings<String> get customerId => $composableBuilder(
      column: $table.customerId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get method => $composableBuilder(
      column: $table.method, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get shiftId => $composableBuilder(
      column: $table.shiftId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get amountMinor => $composableBuilder(
      column: $table.amountMinor, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get currency => $composableBuilder(
      column: $table.currency, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get refType => $composableBuilder(
      column: $table.refType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get refId => $composableBuilder(
      column: $table.refId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get occurredAt => $composableBuilder(
      column: $table.occurredAt, builder: (column) => ColumnOrderings(column));
}

class $$CustomerLedgerTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomerLedgerTable> {
  $$CustomerLedgerTableAnnotationComposer({
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

  GeneratedColumn<String> get customerId => $composableBuilder(
      column: $table.customerId, builder: (column) => column);

  GeneratedColumn<String> get method =>
      $composableBuilder(column: $table.method, builder: (column) => column);

  GeneratedColumn<String> get shiftId =>
      $composableBuilder(column: $table.shiftId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get amountMinor => $composableBuilder(
      column: $table.amountMinor, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<String> get refType =>
      $composableBuilder(column: $table.refType, builder: (column) => column);

  GeneratedColumn<String> get refId =>
      $composableBuilder(column: $table.refId, builder: (column) => column);

  GeneratedColumn<DateTime> get occurredAt => $composableBuilder(
      column: $table.occurredAt, builder: (column) => column);
}

class $$CustomerLedgerTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CustomerLedgerTable,
    CustomerLedgerRow,
    $$CustomerLedgerTableFilterComposer,
    $$CustomerLedgerTableOrderingComposer,
    $$CustomerLedgerTableAnnotationComposer,
    $$CustomerLedgerTableCreateCompanionBuilder,
    $$CustomerLedgerTableUpdateCompanionBuilder,
    (
      CustomerLedgerRow,
      BaseReferences<_$AppDatabase, $CustomerLedgerTable, CustomerLedgerRow>
    ),
    CustomerLedgerRow,
    PrefetchHooks Function()> {
  $$CustomerLedgerTableTableManager(
      _$AppDatabase db, $CustomerLedgerTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomerLedgerTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomerLedgerTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomerLedgerTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String?> createdBy = const Value.absent(),
            Value<String?> updatedBy = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<String> customerId = const Value.absent(),
            Value<String?> method = const Value.absent(),
            Value<String?> shiftId = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<int> amountMinor = const Value.absent(),
            Value<String> currency = const Value.absent(),
            Value<String?> refType = const Value.absent(),
            Value<String?> refId = const Value.absent(),
            Value<DateTime> occurredAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CustomerLedgerCompanion(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            createdBy: createdBy,
            updatedBy: updatedBy,
            version: version,
            customerId: customerId,
            method: method,
            shiftId: shiftId,
            type: type,
            amountMinor: amountMinor,
            currency: currency,
            refType: refType,
            refId: refId,
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
            required String customerId,
            Value<String?> method = const Value.absent(),
            Value<String?> shiftId = const Value.absent(),
            required String type,
            required int amountMinor,
            Value<String> currency = const Value.absent(),
            Value<String?> refType = const Value.absent(),
            Value<String?> refId = const Value.absent(),
            Value<DateTime> occurredAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CustomerLedgerCompanion.insert(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            createdBy: createdBy,
            updatedBy: updatedBy,
            version: version,
            customerId: customerId,
            method: method,
            shiftId: shiftId,
            type: type,
            amountMinor: amountMinor,
            currency: currency,
            refType: refType,
            refId: refId,
            occurredAt: occurredAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$CustomerLedgerTable, CustomerLedgerRow>(table),
                    BaseReferences<_$AppDatabase, $CustomerLedgerTable,
                        CustomerLedgerRow>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CustomerLedgerTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CustomerLedgerTable,
    CustomerLedgerRow,
    $$CustomerLedgerTableFilterComposer,
    $$CustomerLedgerTableOrderingComposer,
    $$CustomerLedgerTableAnnotationComposer,
    $$CustomerLedgerTableCreateCompanionBuilder,
    $$CustomerLedgerTableUpdateCompanionBuilder,
    (
      CustomerLedgerRow,
      BaseReferences<_$AppDatabase, $CustomerLedgerTable, CustomerLedgerRow>
    ),
    CustomerLedgerRow,
    PrefetchHooks Function()>;
typedef $$SuppliersTableCreateCompanionBuilder = SuppliersCompanion Function({
  required String id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String?> createdBy,
  Value<String?> updatedBy,
  Value<int> version,
  required String name,
  Value<String?> phone,
  Value<String> currency,
  Value<bool> isActive,
  Value<int> rowid,
});
typedef $$SuppliersTableUpdateCompanionBuilder = SuppliersCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String?> createdBy,
  Value<String?> updatedBy,
  Value<int> version,
  Value<String> name,
  Value<String?> phone,
  Value<String> currency,
  Value<bool> isActive,
  Value<int> rowid,
});

class $$SuppliersTableFilterComposer
    extends Composer<_$AppDatabase, $SuppliersTable> {
  $$SuppliersTableFilterComposer({
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

  ColumnFilters<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get currency => $composableBuilder(
      column: $table.currency, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));
}

class $$SuppliersTableOrderingComposer
    extends Composer<_$AppDatabase, $SuppliersTable> {
  $$SuppliersTableOrderingComposer({
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

  ColumnOrderings<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get currency => $composableBuilder(
      column: $table.currency, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));
}

class $$SuppliersTableAnnotationComposer
    extends Composer<_$AppDatabase, $SuppliersTable> {
  $$SuppliersTableAnnotationComposer({
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

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);
}

class $$SuppliersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SuppliersTable,
    SupplierRow,
    $$SuppliersTableFilterComposer,
    $$SuppliersTableOrderingComposer,
    $$SuppliersTableAnnotationComposer,
    $$SuppliersTableCreateCompanionBuilder,
    $$SuppliersTableUpdateCompanionBuilder,
    (SupplierRow, BaseReferences<_$AppDatabase, $SuppliersTable, SupplierRow>),
    SupplierRow,
    PrefetchHooks Function()> {
  $$SuppliersTableTableManager(_$AppDatabase db, $SuppliersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SuppliersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SuppliersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SuppliersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String?> createdBy = const Value.absent(),
            Value<String?> updatedBy = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> phone = const Value.absent(),
            Value<String> currency = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SuppliersCompanion(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            createdBy: createdBy,
            updatedBy: updatedBy,
            version: version,
            name: name,
            phone: phone,
            currency: currency,
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
            required String name,
            Value<String?> phone = const Value.absent(),
            Value<String> currency = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SuppliersCompanion.insert(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            createdBy: createdBy,
            updatedBy: updatedBy,
            version: version,
            name: name,
            phone: phone,
            currency: currency,
            isActive: isActive,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$SuppliersTable, SupplierRow>(table),
                    BaseReferences<_$AppDatabase, $SuppliersTable, SupplierRow>(
                        db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SuppliersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SuppliersTable,
    SupplierRow,
    $$SuppliersTableFilterComposer,
    $$SuppliersTableOrderingComposer,
    $$SuppliersTableAnnotationComposer,
    $$SuppliersTableCreateCompanionBuilder,
    $$SuppliersTableUpdateCompanionBuilder,
    (SupplierRow, BaseReferences<_$AppDatabase, $SuppliersTable, SupplierRow>),
    SupplierRow,
    PrefetchHooks Function()>;
typedef $$SupplierLedgerTableCreateCompanionBuilder = SupplierLedgerCompanion
    Function({
  required String id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String?> createdBy,
  Value<String?> updatedBy,
  Value<int> version,
  required String supplierId,
  Value<String?> method,
  Value<String?> shiftId,
  required String type,
  required int amountMinor,
  Value<String> currency,
  Value<DateTime> occurredAt,
  Value<int> rowid,
});
typedef $$SupplierLedgerTableUpdateCompanionBuilder = SupplierLedgerCompanion
    Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String?> createdBy,
  Value<String?> updatedBy,
  Value<int> version,
  Value<String> supplierId,
  Value<String?> method,
  Value<String?> shiftId,
  Value<String> type,
  Value<int> amountMinor,
  Value<String> currency,
  Value<DateTime> occurredAt,
  Value<int> rowid,
});

class $$SupplierLedgerTableFilterComposer
    extends Composer<_$AppDatabase, $SupplierLedgerTable> {
  $$SupplierLedgerTableFilterComposer({
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

  ColumnFilters<String> get supplierId => $composableBuilder(
      column: $table.supplierId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get method => $composableBuilder(
      column: $table.method, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get shiftId => $composableBuilder(
      column: $table.shiftId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get amountMinor => $composableBuilder(
      column: $table.amountMinor, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get currency => $composableBuilder(
      column: $table.currency, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get occurredAt => $composableBuilder(
      column: $table.occurredAt, builder: (column) => ColumnFilters(column));
}

class $$SupplierLedgerTableOrderingComposer
    extends Composer<_$AppDatabase, $SupplierLedgerTable> {
  $$SupplierLedgerTableOrderingComposer({
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

  ColumnOrderings<String> get supplierId => $composableBuilder(
      column: $table.supplierId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get method => $composableBuilder(
      column: $table.method, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get shiftId => $composableBuilder(
      column: $table.shiftId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get amountMinor => $composableBuilder(
      column: $table.amountMinor, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get currency => $composableBuilder(
      column: $table.currency, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get occurredAt => $composableBuilder(
      column: $table.occurredAt, builder: (column) => ColumnOrderings(column));
}

class $$SupplierLedgerTableAnnotationComposer
    extends Composer<_$AppDatabase, $SupplierLedgerTable> {
  $$SupplierLedgerTableAnnotationComposer({
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

  GeneratedColumn<String> get supplierId => $composableBuilder(
      column: $table.supplierId, builder: (column) => column);

  GeneratedColumn<String> get method =>
      $composableBuilder(column: $table.method, builder: (column) => column);

  GeneratedColumn<String> get shiftId =>
      $composableBuilder(column: $table.shiftId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get amountMinor => $composableBuilder(
      column: $table.amountMinor, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<DateTime> get occurredAt => $composableBuilder(
      column: $table.occurredAt, builder: (column) => column);
}

class $$SupplierLedgerTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SupplierLedgerTable,
    SupplierLedgerRow,
    $$SupplierLedgerTableFilterComposer,
    $$SupplierLedgerTableOrderingComposer,
    $$SupplierLedgerTableAnnotationComposer,
    $$SupplierLedgerTableCreateCompanionBuilder,
    $$SupplierLedgerTableUpdateCompanionBuilder,
    (
      SupplierLedgerRow,
      BaseReferences<_$AppDatabase, $SupplierLedgerTable, SupplierLedgerRow>
    ),
    SupplierLedgerRow,
    PrefetchHooks Function()> {
  $$SupplierLedgerTableTableManager(
      _$AppDatabase db, $SupplierLedgerTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SupplierLedgerTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SupplierLedgerTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SupplierLedgerTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String?> createdBy = const Value.absent(),
            Value<String?> updatedBy = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<String> supplierId = const Value.absent(),
            Value<String?> method = const Value.absent(),
            Value<String?> shiftId = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<int> amountMinor = const Value.absent(),
            Value<String> currency = const Value.absent(),
            Value<DateTime> occurredAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SupplierLedgerCompanion(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            createdBy: createdBy,
            updatedBy: updatedBy,
            version: version,
            supplierId: supplierId,
            method: method,
            shiftId: shiftId,
            type: type,
            amountMinor: amountMinor,
            currency: currency,
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
            required String supplierId,
            Value<String?> method = const Value.absent(),
            Value<String?> shiftId = const Value.absent(),
            required String type,
            required int amountMinor,
            Value<String> currency = const Value.absent(),
            Value<DateTime> occurredAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SupplierLedgerCompanion.insert(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            createdBy: createdBy,
            updatedBy: updatedBy,
            version: version,
            supplierId: supplierId,
            method: method,
            shiftId: shiftId,
            type: type,
            amountMinor: amountMinor,
            currency: currency,
            occurredAt: occurredAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$SupplierLedgerTable, SupplierLedgerRow>(table),
                    BaseReferences<_$AppDatabase, $SupplierLedgerTable,
                        SupplierLedgerRow>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SupplierLedgerTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SupplierLedgerTable,
    SupplierLedgerRow,
    $$SupplierLedgerTableFilterComposer,
    $$SupplierLedgerTableOrderingComposer,
    $$SupplierLedgerTableAnnotationComposer,
    $$SupplierLedgerTableCreateCompanionBuilder,
    $$SupplierLedgerTableUpdateCompanionBuilder,
    (
      SupplierLedgerRow,
      BaseReferences<_$AppDatabase, $SupplierLedgerTable, SupplierLedgerRow>
    ),
    SupplierLedgerRow,
    PrefetchHooks Function()>;
typedef $$SyncStatesTableCreateCompanionBuilder = SyncStatesCompanion Function({
  required String deviceId,
  Value<int> lastPulledSeq,
  Value<String?> watermarkToken,
  Value<String?> scope,
  Value<int> rowid,
});
typedef $$SyncStatesTableUpdateCompanionBuilder = SyncStatesCompanion Function({
  Value<String> deviceId,
  Value<int> lastPulledSeq,
  Value<String?> watermarkToken,
  Value<String?> scope,
  Value<int> rowid,
});

class $$SyncStatesTableFilterComposer
    extends Composer<_$AppDatabase, $SyncStatesTable> {
  $$SyncStatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lastPulledSeq => $composableBuilder(
      column: $table.lastPulledSeq, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get watermarkToken => $composableBuilder(
      column: $table.watermarkToken,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get scope => $composableBuilder(
      column: $table.scope, builder: (column) => ColumnFilters(column));
}

class $$SyncStatesTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncStatesTable> {
  $$SyncStatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lastPulledSeq => $composableBuilder(
      column: $table.lastPulledSeq,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get watermarkToken => $composableBuilder(
      column: $table.watermarkToken,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get scope => $composableBuilder(
      column: $table.scope, builder: (column) => ColumnOrderings(column));
}

class $$SyncStatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncStatesTable> {
  $$SyncStatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<int> get lastPulledSeq => $composableBuilder(
      column: $table.lastPulledSeq, builder: (column) => column);

  GeneratedColumn<String> get watermarkToken => $composableBuilder(
      column: $table.watermarkToken, builder: (column) => column);

  GeneratedColumn<String> get scope =>
      $composableBuilder(column: $table.scope, builder: (column) => column);
}

class $$SyncStatesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SyncStatesTable,
    SyncStateRow,
    $$SyncStatesTableFilterComposer,
    $$SyncStatesTableOrderingComposer,
    $$SyncStatesTableAnnotationComposer,
    $$SyncStatesTableCreateCompanionBuilder,
    $$SyncStatesTableUpdateCompanionBuilder,
    (
      SyncStateRow,
      BaseReferences<_$AppDatabase, $SyncStatesTable, SyncStateRow>
    ),
    SyncStateRow,
    PrefetchHooks Function()> {
  $$SyncStatesTableTableManager(_$AppDatabase db, $SyncStatesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncStatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncStatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncStatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> deviceId = const Value.absent(),
            Value<int> lastPulledSeq = const Value.absent(),
            Value<String?> watermarkToken = const Value.absent(),
            Value<String?> scope = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncStatesCompanion(
            deviceId: deviceId,
            lastPulledSeq: lastPulledSeq,
            watermarkToken: watermarkToken,
            scope: scope,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String deviceId,
            Value<int> lastPulledSeq = const Value.absent(),
            Value<String?> watermarkToken = const Value.absent(),
            Value<String?> scope = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncStatesCompanion.insert(
            deviceId: deviceId,
            lastPulledSeq: lastPulledSeq,
            watermarkToken: watermarkToken,
            scope: scope,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$SyncStatesTable, SyncStateRow>(table),
                    BaseReferences<_$AppDatabase, $SyncStatesTable,
                        SyncStateRow>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SyncStatesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SyncStatesTable,
    SyncStateRow,
    $$SyncStatesTableFilterComposer,
    $$SyncStatesTableOrderingComposer,
    $$SyncStatesTableAnnotationComposer,
    $$SyncStatesTableCreateCompanionBuilder,
    $$SyncStatesTableUpdateCompanionBuilder,
    (
      SyncStateRow,
      BaseReferences<_$AppDatabase, $SyncStatesTable, SyncStateRow>
    ),
    SyncStateRow,
    PrefetchHooks Function()>;
typedef $$AppSettingsTableCreateCompanionBuilder = AppSettingsCompanion
    Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$AppSettingsTableUpdateCompanionBuilder = AppSettingsCompanion
    Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppSettingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AppSettingsTable,
    AppSettingRow,
    $$AppSettingsTableFilterComposer,
    $$AppSettingsTableOrderingComposer,
    $$AppSettingsTableAnnotationComposer,
    $$AppSettingsTableCreateCompanionBuilder,
    $$AppSettingsTableUpdateCompanionBuilder,
    (
      AppSettingRow,
      BaseReferences<_$AppDatabase, $AppSettingsTable, AppSettingRow>
    ),
    AppSettingRow,
    PrefetchHooks Function()> {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AppSettingsCompanion(
            key: key,
            value: value,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) =>
              AppSettingsCompanion.insert(
            key: key,
            value: value,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$AppSettingsTable, AppSettingRow>(table),
                    BaseReferences<_$AppDatabase, $AppSettingsTable,
                        AppSettingRow>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AppSettingsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AppSettingsTable,
    AppSettingRow,
    $$AppSettingsTableFilterComposer,
    $$AppSettingsTableOrderingComposer,
    $$AppSettingsTableAnnotationComposer,
    $$AppSettingsTableCreateCompanionBuilder,
    $$AppSettingsTableUpdateCompanionBuilder,
    (
      AppSettingRow,
      BaseReferences<_$AppDatabase, $AppSettingsTable, AppSettingRow>
    ),
    AppSettingRow,
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
  $$SalesTableTableManager get sales =>
      $$SalesTableTableManager(_db, _db.sales);
  $$SaleLinesTableTableManager get saleLines =>
      $$SaleLinesTableTableManager(_db, _db.saleLines);
  $$PaymentsTableTableManager get payments =>
      $$PaymentsTableTableManager(_db, _db.payments);
  $$ShiftsTableTableManager get shifts =>
      $$ShiftsTableTableManager(_db, _db.shifts);
  $$CustomersTableTableManager get customers =>
      $$CustomersTableTableManager(_db, _db.customers);
  $$CustomerLedgerTableTableManager get customerLedger =>
      $$CustomerLedgerTableTableManager(_db, _db.customerLedger);
  $$SuppliersTableTableManager get suppliers =>
      $$SuppliersTableTableManager(_db, _db.suppliers);
  $$SupplierLedgerTableTableManager get supplierLedger =>
      $$SupplierLedgerTableTableManager(_db, _db.supplierLedger);
  $$SyncStatesTableTableManager get syncStates =>
      $$SyncStatesTableTableManager(_db, _db.syncStates);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
}
