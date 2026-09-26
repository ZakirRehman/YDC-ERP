// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $SocietiesTable extends Societies
    with TableInfo<$SocietiesTable, Society> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SocietiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _acronymMeta =
      const VerificationMeta('acronym');
  @override
  late final GeneratedColumn<String> acronym = GeneratedColumn<String>(
      'acronym', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _pillarMeta = const VerificationMeta('pillar');
  @override
  late final GeneratedColumn<String> pillar = GeneratedColumn<String>(
      'pillar', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _facultyAdvisorMeta =
      const VerificationMeta('facultyAdvisor');
  @override
  late final GeneratedColumn<String> facultyAdvisor = GeneratedColumn<String>(
      'faculty_advisor', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _logoPathMeta =
      const VerificationMeta('logoPath');
  @override
  late final GeneratedColumn<String> logoPath = GeneratedColumn<String>(
      'logo_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
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
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        acronym,
        pillar,
        facultyAdvisor,
        logoPath,
        isActive,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'societies';
  @override
  VerificationContext validateIntegrity(Insertable<Society> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('acronym')) {
      context.handle(_acronymMeta,
          acronym.isAcceptableOrUnknown(data['acronym']!, _acronymMeta));
    }
    if (data.containsKey('pillar')) {
      context.handle(_pillarMeta,
          pillar.isAcceptableOrUnknown(data['pillar']!, _pillarMeta));
    } else if (isInserting) {
      context.missing(_pillarMeta);
    }
    if (data.containsKey('faculty_advisor')) {
      context.handle(
          _facultyAdvisorMeta,
          facultyAdvisor.isAcceptableOrUnknown(
              data['faculty_advisor']!, _facultyAdvisorMeta));
    } else if (isInserting) {
      context.missing(_facultyAdvisorMeta);
    }
    if (data.containsKey('logo_path')) {
      context.handle(_logoPathMeta,
          logoPath.isAcceptableOrUnknown(data['logo_path']!, _logoPathMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Society map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Society(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      acronym: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}acronym']),
      pillar: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}pillar'])!,
      facultyAdvisor: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}faculty_advisor'])!,
      logoPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}logo_path']),
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $SocietiesTable createAlias(String alias) {
    return $SocietiesTable(attachedDatabase, alias);
  }
}

class Society extends DataClass implements Insertable<Society> {
  final String id;
  final String name;
  final String? acronym;
  final String pillar;
  final String facultyAdvisor;
  final String? logoPath;
  final bool isActive;
  final DateTime createdAt;
  const Society(
      {required this.id,
      required this.name,
      this.acronym,
      required this.pillar,
      required this.facultyAdvisor,
      this.logoPath,
      required this.isActive,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || acronym != null) {
      map['acronym'] = Variable<String>(acronym);
    }
    map['pillar'] = Variable<String>(pillar);
    map['faculty_advisor'] = Variable<String>(facultyAdvisor);
    if (!nullToAbsent || logoPath != null) {
      map['logo_path'] = Variable<String>(logoPath);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SocietiesCompanion toCompanion(bool nullToAbsent) {
    return SocietiesCompanion(
      id: Value(id),
      name: Value(name),
      acronym: acronym == null && nullToAbsent
          ? const Value.absent()
          : Value(acronym),
      pillar: Value(pillar),
      facultyAdvisor: Value(facultyAdvisor),
      logoPath: logoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(logoPath),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
    );
  }

  factory Society.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Society(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      acronym: serializer.fromJson<String?>(json['acronym']),
      pillar: serializer.fromJson<String>(json['pillar']),
      facultyAdvisor: serializer.fromJson<String>(json['facultyAdvisor']),
      logoPath: serializer.fromJson<String?>(json['logoPath']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'acronym': serializer.toJson<String?>(acronym),
      'pillar': serializer.toJson<String>(pillar),
      'facultyAdvisor': serializer.toJson<String>(facultyAdvisor),
      'logoPath': serializer.toJson<String?>(logoPath),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Society copyWith(
          {String? id,
          String? name,
          Value<String?> acronym = const Value.absent(),
          String? pillar,
          String? facultyAdvisor,
          Value<String?> logoPath = const Value.absent(),
          bool? isActive,
          DateTime? createdAt}) =>
      Society(
        id: id ?? this.id,
        name: name ?? this.name,
        acronym: acronym.present ? acronym.value : this.acronym,
        pillar: pillar ?? this.pillar,
        facultyAdvisor: facultyAdvisor ?? this.facultyAdvisor,
        logoPath: logoPath.present ? logoPath.value : this.logoPath,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
      );
  Society copyWithCompanion(SocietiesCompanion data) {
    return Society(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      acronym: data.acronym.present ? data.acronym.value : this.acronym,
      pillar: data.pillar.present ? data.pillar.value : this.pillar,
      facultyAdvisor: data.facultyAdvisor.present
          ? data.facultyAdvisor.value
          : this.facultyAdvisor,
      logoPath: data.logoPath.present ? data.logoPath.value : this.logoPath,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Society(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('acronym: $acronym, ')
          ..write('pillar: $pillar, ')
          ..write('facultyAdvisor: $facultyAdvisor, ')
          ..write('logoPath: $logoPath, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, name, acronym, pillar, facultyAdvisor, logoPath, isActive, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Society &&
          other.id == this.id &&
          other.name == this.name &&
          other.acronym == this.acronym &&
          other.pillar == this.pillar &&
          other.facultyAdvisor == this.facultyAdvisor &&
          other.logoPath == this.logoPath &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt);
}

class SocietiesCompanion extends UpdateCompanion<Society> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> acronym;
  final Value<String> pillar;
  final Value<String> facultyAdvisor;
  final Value<String?> logoPath;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const SocietiesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.acronym = const Value.absent(),
    this.pillar = const Value.absent(),
    this.facultyAdvisor = const Value.absent(),
    this.logoPath = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SocietiesCompanion.insert({
    required String id,
    required String name,
    this.acronym = const Value.absent(),
    required String pillar,
    required String facultyAdvisor,
    this.logoPath = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        pillar = Value(pillar),
        facultyAdvisor = Value(facultyAdvisor);
  static Insertable<Society> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? acronym,
    Expression<String>? pillar,
    Expression<String>? facultyAdvisor,
    Expression<String>? logoPath,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (acronym != null) 'acronym': acronym,
      if (pillar != null) 'pillar': pillar,
      if (facultyAdvisor != null) 'faculty_advisor': facultyAdvisor,
      if (logoPath != null) 'logo_path': logoPath,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SocietiesCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String?>? acronym,
      Value<String>? pillar,
      Value<String>? facultyAdvisor,
      Value<String?>? logoPath,
      Value<bool>? isActive,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return SocietiesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      acronym: acronym ?? this.acronym,
      pillar: pillar ?? this.pillar,
      facultyAdvisor: facultyAdvisor ?? this.facultyAdvisor,
      logoPath: logoPath ?? this.logoPath,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
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
    if (acronym.present) {
      map['acronym'] = Variable<String>(acronym.value);
    }
    if (pillar.present) {
      map['pillar'] = Variable<String>(pillar.value);
    }
    if (facultyAdvisor.present) {
      map['faculty_advisor'] = Variable<String>(facultyAdvisor.value);
    }
    if (logoPath.present) {
      map['logo_path'] = Variable<String>(logoPath.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SocietiesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('acronym: $acronym, ')
          ..write('pillar: $pillar, ')
          ..write('facultyAdvisor: $facultyAdvisor, ')
          ..write('logoPath: $logoPath, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CabinetMembersTable extends CabinetMembers
    with TableInfo<$CabinetMembersTable, CabinetMember> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CabinetMembersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _societyIdMeta =
      const VerificationMeta('societyId');
  @override
  late final GeneratedColumn<String> societyId = GeneratedColumn<String>(
      'society_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES societies (id) ON DELETE CASCADE'));
  static const VerificationMeta _tenureSessionMeta =
      const VerificationMeta('tenureSession');
  @override
  late final GeneratedColumn<String> tenureSession = GeneratedColumn<String>(
      'tenure_session', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
      'role', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fullNameMeta =
      const VerificationMeta('fullName');
  @override
  late final GeneratedColumn<String> fullName = GeneratedColumn<String>(
      'full_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _cnicMeta = const VerificationMeta('cnic');
  @override
  late final GeneratedColumn<String> cnic = GeneratedColumn<String>(
      'cnic', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
      'phone', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _departmentMeta =
      const VerificationMeta('department');
  @override
  late final GeneratedColumn<String> department = GeneratedColumn<String>(
      'department', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _semesterMeta =
      const VerificationMeta('semester');
  @override
  late final GeneratedColumn<int> semester = GeneratedColumn<int>(
      'semester', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
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
        societyId,
        tenureSession,
        role,
        fullName,
        cnic,
        email,
        phone,
        department,
        semester,
        isActive
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cabinet_members';
  @override
  VerificationContext validateIntegrity(Insertable<CabinetMember> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('society_id')) {
      context.handle(_societyIdMeta,
          societyId.isAcceptableOrUnknown(data['society_id']!, _societyIdMeta));
    } else if (isInserting) {
      context.missing(_societyIdMeta);
    }
    if (data.containsKey('tenure_session')) {
      context.handle(
          _tenureSessionMeta,
          tenureSession.isAcceptableOrUnknown(
              data['tenure_session']!, _tenureSessionMeta));
    } else if (isInserting) {
      context.missing(_tenureSessionMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
          _roleMeta, role.isAcceptableOrUnknown(data['role']!, _roleMeta));
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('full_name')) {
      context.handle(_fullNameMeta,
          fullName.isAcceptableOrUnknown(data['full_name']!, _fullNameMeta));
    } else if (isInserting) {
      context.missing(_fullNameMeta);
    }
    if (data.containsKey('cnic')) {
      context.handle(
          _cnicMeta, cnic.isAcceptableOrUnknown(data['cnic']!, _cnicMeta));
    } else if (isInserting) {
      context.missing(_cnicMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
          _phoneMeta, phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta));
    } else if (isInserting) {
      context.missing(_phoneMeta);
    }
    if (data.containsKey('department')) {
      context.handle(
          _departmentMeta,
          department.isAcceptableOrUnknown(
              data['department']!, _departmentMeta));
    } else if (isInserting) {
      context.missing(_departmentMeta);
    }
    if (data.containsKey('semester')) {
      context.handle(_semesterMeta,
          semester.isAcceptableOrUnknown(data['semester']!, _semesterMeta));
    } else if (isInserting) {
      context.missing(_semesterMeta);
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
  CabinetMember map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CabinetMember(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      societyId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}society_id'])!,
      tenureSession: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tenure_session'])!,
      role: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}role'])!,
      fullName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}full_name'])!,
      cnic: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cnic'])!,
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email'])!,
      phone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone'])!,
      department: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}department'])!,
      semester: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}semester'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
    );
  }

  @override
  $CabinetMembersTable createAlias(String alias) {
    return $CabinetMembersTable(attachedDatabase, alias);
  }
}

class CabinetMember extends DataClass implements Insertable<CabinetMember> {
  final String id;
  final String societyId;
  final String tenureSession;
  final String role;
  final String fullName;
  final String cnic;
  final String email;
  final String phone;
  final String department;
  final int semester;
  final bool isActive;
  const CabinetMember(
      {required this.id,
      required this.societyId,
      required this.tenureSession,
      required this.role,
      required this.fullName,
      required this.cnic,
      required this.email,
      required this.phone,
      required this.department,
      required this.semester,
      required this.isActive});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['society_id'] = Variable<String>(societyId);
    map['tenure_session'] = Variable<String>(tenureSession);
    map['role'] = Variable<String>(role);
    map['full_name'] = Variable<String>(fullName);
    map['cnic'] = Variable<String>(cnic);
    map['email'] = Variable<String>(email);
    map['phone'] = Variable<String>(phone);
    map['department'] = Variable<String>(department);
    map['semester'] = Variable<int>(semester);
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  CabinetMembersCompanion toCompanion(bool nullToAbsent) {
    return CabinetMembersCompanion(
      id: Value(id),
      societyId: Value(societyId),
      tenureSession: Value(tenureSession),
      role: Value(role),
      fullName: Value(fullName),
      cnic: Value(cnic),
      email: Value(email),
      phone: Value(phone),
      department: Value(department),
      semester: Value(semester),
      isActive: Value(isActive),
    );
  }

  factory CabinetMember.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CabinetMember(
      id: serializer.fromJson<String>(json['id']),
      societyId: serializer.fromJson<String>(json['societyId']),
      tenureSession: serializer.fromJson<String>(json['tenureSession']),
      role: serializer.fromJson<String>(json['role']),
      fullName: serializer.fromJson<String>(json['fullName']),
      cnic: serializer.fromJson<String>(json['cnic']),
      email: serializer.fromJson<String>(json['email']),
      phone: serializer.fromJson<String>(json['phone']),
      department: serializer.fromJson<String>(json['department']),
      semester: serializer.fromJson<int>(json['semester']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'societyId': serializer.toJson<String>(societyId),
      'tenureSession': serializer.toJson<String>(tenureSession),
      'role': serializer.toJson<String>(role),
      'fullName': serializer.toJson<String>(fullName),
      'cnic': serializer.toJson<String>(cnic),
      'email': serializer.toJson<String>(email),
      'phone': serializer.toJson<String>(phone),
      'department': serializer.toJson<String>(department),
      'semester': serializer.toJson<int>(semester),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  CabinetMember copyWith(
          {String? id,
          String? societyId,
          String? tenureSession,
          String? role,
          String? fullName,
          String? cnic,
          String? email,
          String? phone,
          String? department,
          int? semester,
          bool? isActive}) =>
      CabinetMember(
        id: id ?? this.id,
        societyId: societyId ?? this.societyId,
        tenureSession: tenureSession ?? this.tenureSession,
        role: role ?? this.role,
        fullName: fullName ?? this.fullName,
        cnic: cnic ?? this.cnic,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        department: department ?? this.department,
        semester: semester ?? this.semester,
        isActive: isActive ?? this.isActive,
      );
  CabinetMember copyWithCompanion(CabinetMembersCompanion data) {
    return CabinetMember(
      id: data.id.present ? data.id.value : this.id,
      societyId: data.societyId.present ? data.societyId.value : this.societyId,
      tenureSession: data.tenureSession.present
          ? data.tenureSession.value
          : this.tenureSession,
      role: data.role.present ? data.role.value : this.role,
      fullName: data.fullName.present ? data.fullName.value : this.fullName,
      cnic: data.cnic.present ? data.cnic.value : this.cnic,
      email: data.email.present ? data.email.value : this.email,
      phone: data.phone.present ? data.phone.value : this.phone,
      department:
          data.department.present ? data.department.value : this.department,
      semester: data.semester.present ? data.semester.value : this.semester,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CabinetMember(')
          ..write('id: $id, ')
          ..write('societyId: $societyId, ')
          ..write('tenureSession: $tenureSession, ')
          ..write('role: $role, ')
          ..write('fullName: $fullName, ')
          ..write('cnic: $cnic, ')
          ..write('email: $email, ')
          ..write('phone: $phone, ')
          ..write('department: $department, ')
          ..write('semester: $semester, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, societyId, tenureSession, role, fullName,
      cnic, email, phone, department, semester, isActive);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CabinetMember &&
          other.id == this.id &&
          other.societyId == this.societyId &&
          other.tenureSession == this.tenureSession &&
          other.role == this.role &&
          other.fullName == this.fullName &&
          other.cnic == this.cnic &&
          other.email == this.email &&
          other.phone == this.phone &&
          other.department == this.department &&
          other.semester == this.semester &&
          other.isActive == this.isActive);
}

class CabinetMembersCompanion extends UpdateCompanion<CabinetMember> {
  final Value<String> id;
  final Value<String> societyId;
  final Value<String> tenureSession;
  final Value<String> role;
  final Value<String> fullName;
  final Value<String> cnic;
  final Value<String> email;
  final Value<String> phone;
  final Value<String> department;
  final Value<int> semester;
  final Value<bool> isActive;
  final Value<int> rowid;
  const CabinetMembersCompanion({
    this.id = const Value.absent(),
    this.societyId = const Value.absent(),
    this.tenureSession = const Value.absent(),
    this.role = const Value.absent(),
    this.fullName = const Value.absent(),
    this.cnic = const Value.absent(),
    this.email = const Value.absent(),
    this.phone = const Value.absent(),
    this.department = const Value.absent(),
    this.semester = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CabinetMembersCompanion.insert({
    required String id,
    required String societyId,
    required String tenureSession,
    required String role,
    required String fullName,
    required String cnic,
    required String email,
    required String phone,
    required String department,
    required int semester,
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        societyId = Value(societyId),
        tenureSession = Value(tenureSession),
        role = Value(role),
        fullName = Value(fullName),
        cnic = Value(cnic),
        email = Value(email),
        phone = Value(phone),
        department = Value(department),
        semester = Value(semester);
  static Insertable<CabinetMember> custom({
    Expression<String>? id,
    Expression<String>? societyId,
    Expression<String>? tenureSession,
    Expression<String>? role,
    Expression<String>? fullName,
    Expression<String>? cnic,
    Expression<String>? email,
    Expression<String>? phone,
    Expression<String>? department,
    Expression<int>? semester,
    Expression<bool>? isActive,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (societyId != null) 'society_id': societyId,
      if (tenureSession != null) 'tenure_session': tenureSession,
      if (role != null) 'role': role,
      if (fullName != null) 'full_name': fullName,
      if (cnic != null) 'cnic': cnic,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (department != null) 'department': department,
      if (semester != null) 'semester': semester,
      if (isActive != null) 'is_active': isActive,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CabinetMembersCompanion copyWith(
      {Value<String>? id,
      Value<String>? societyId,
      Value<String>? tenureSession,
      Value<String>? role,
      Value<String>? fullName,
      Value<String>? cnic,
      Value<String>? email,
      Value<String>? phone,
      Value<String>? department,
      Value<int>? semester,
      Value<bool>? isActive,
      Value<int>? rowid}) {
    return CabinetMembersCompanion(
      id: id ?? this.id,
      societyId: societyId ?? this.societyId,
      tenureSession: tenureSession ?? this.tenureSession,
      role: role ?? this.role,
      fullName: fullName ?? this.fullName,
      cnic: cnic ?? this.cnic,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      department: department ?? this.department,
      semester: semester ?? this.semester,
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
    if (societyId.present) {
      map['society_id'] = Variable<String>(societyId.value);
    }
    if (tenureSession.present) {
      map['tenure_session'] = Variable<String>(tenureSession.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (fullName.present) {
      map['full_name'] = Variable<String>(fullName.value);
    }
    if (cnic.present) {
      map['cnic'] = Variable<String>(cnic.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (department.present) {
      map['department'] = Variable<String>(department.value);
    }
    if (semester.present) {
      map['semester'] = Variable<int>(semester.value);
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
    return (StringBuffer('CabinetMembersCompanion(')
          ..write('id: $id, ')
          ..write('societyId: $societyId, ')
          ..write('tenureSession: $tenureSession, ')
          ..write('role: $role, ')
          ..write('fullName: $fullName, ')
          ..write('cnic: $cnic, ')
          ..write('email: $email, ')
          ..write('phone: $phone, ')
          ..write('department: $department, ')
          ..write('semester: $semester, ')
          ..write('isActive: $isActive, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SocietyMembersTable extends SocietyMembers
    with TableInfo<$SocietyMembersTable, SocietyMember> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SocietyMembersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _societyIdMeta =
      const VerificationMeta('societyId');
  @override
  late final GeneratedColumn<String> societyId = GeneratedColumn<String>(
      'society_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES societies (id) ON DELETE CASCADE'));
  static const VerificationMeta _fullNameMeta =
      const VerificationMeta('fullName');
  @override
  late final GeneratedColumn<String> fullName = GeneratedColumn<String>(
      'full_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _rollNoMeta = const VerificationMeta('rollNo');
  @override
  late final GeneratedColumn<String> rollNo = GeneratedColumn<String>(
      'roll_no', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _cnicMeta = const VerificationMeta('cnic');
  @override
  late final GeneratedColumn<String> cnic = GeneratedColumn<String>(
      'cnic', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
      'phone', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _departmentMeta =
      const VerificationMeta('department');
  @override
  late final GeneratedColumn<String> department = GeneratedColumn<String>(
      'department', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _semesterMeta =
      const VerificationMeta('semester');
  @override
  late final GeneratedColumn<int> semester = GeneratedColumn<int>(
      'semester', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _joinedDateMeta =
      const VerificationMeta('joinedDate');
  @override
  late final GeneratedColumn<DateTime> joinedDate = GeneratedColumn<DateTime>(
      'joined_date', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
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
        societyId,
        fullName,
        rollNo,
        cnic,
        email,
        phone,
        department,
        semester,
        joinedDate,
        isActive
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'society_members';
  @override
  VerificationContext validateIntegrity(Insertable<SocietyMember> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('society_id')) {
      context.handle(_societyIdMeta,
          societyId.isAcceptableOrUnknown(data['society_id']!, _societyIdMeta));
    } else if (isInserting) {
      context.missing(_societyIdMeta);
    }
    if (data.containsKey('full_name')) {
      context.handle(_fullNameMeta,
          fullName.isAcceptableOrUnknown(data['full_name']!, _fullNameMeta));
    } else if (isInserting) {
      context.missing(_fullNameMeta);
    }
    if (data.containsKey('roll_no')) {
      context.handle(_rollNoMeta,
          rollNo.isAcceptableOrUnknown(data['roll_no']!, _rollNoMeta));
    } else if (isInserting) {
      context.missing(_rollNoMeta);
    }
    if (data.containsKey('cnic')) {
      context.handle(
          _cnicMeta, cnic.isAcceptableOrUnknown(data['cnic']!, _cnicMeta));
    } else if (isInserting) {
      context.missing(_cnicMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    }
    if (data.containsKey('phone')) {
      context.handle(
          _phoneMeta, phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta));
    }
    if (data.containsKey('department')) {
      context.handle(
          _departmentMeta,
          department.isAcceptableOrUnknown(
              data['department']!, _departmentMeta));
    } else if (isInserting) {
      context.missing(_departmentMeta);
    }
    if (data.containsKey('semester')) {
      context.handle(_semesterMeta,
          semester.isAcceptableOrUnknown(data['semester']!, _semesterMeta));
    } else if (isInserting) {
      context.missing(_semesterMeta);
    }
    if (data.containsKey('joined_date')) {
      context.handle(
          _joinedDateMeta,
          joinedDate.isAcceptableOrUnknown(
              data['joined_date']!, _joinedDateMeta));
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
  SocietyMember map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SocietyMember(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      societyId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}society_id'])!,
      fullName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}full_name'])!,
      rollNo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}roll_no'])!,
      cnic: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cnic'])!,
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email']),
      phone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone']),
      department: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}department'])!,
      semester: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}semester'])!,
      joinedDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}joined_date'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
    );
  }

  @override
  $SocietyMembersTable createAlias(String alias) {
    return $SocietyMembersTable(attachedDatabase, alias);
  }
}

class SocietyMember extends DataClass implements Insertable<SocietyMember> {
  final String id;
  final String societyId;
  final String fullName;
  final String rollNo;
  final String cnic;
  final String? email;
  final String? phone;
  final String department;
  final int semester;
  final DateTime joinedDate;
  final bool isActive;
  const SocietyMember(
      {required this.id,
      required this.societyId,
      required this.fullName,
      required this.rollNo,
      required this.cnic,
      this.email,
      this.phone,
      required this.department,
      required this.semester,
      required this.joinedDate,
      required this.isActive});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['society_id'] = Variable<String>(societyId);
    map['full_name'] = Variable<String>(fullName);
    map['roll_no'] = Variable<String>(rollNo);
    map['cnic'] = Variable<String>(cnic);
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    map['department'] = Variable<String>(department);
    map['semester'] = Variable<int>(semester);
    map['joined_date'] = Variable<DateTime>(joinedDate);
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  SocietyMembersCompanion toCompanion(bool nullToAbsent) {
    return SocietyMembersCompanion(
      id: Value(id),
      societyId: Value(societyId),
      fullName: Value(fullName),
      rollNo: Value(rollNo),
      cnic: Value(cnic),
      email:
          email == null && nullToAbsent ? const Value.absent() : Value(email),
      phone:
          phone == null && nullToAbsent ? const Value.absent() : Value(phone),
      department: Value(department),
      semester: Value(semester),
      joinedDate: Value(joinedDate),
      isActive: Value(isActive),
    );
  }

  factory SocietyMember.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SocietyMember(
      id: serializer.fromJson<String>(json['id']),
      societyId: serializer.fromJson<String>(json['societyId']),
      fullName: serializer.fromJson<String>(json['fullName']),
      rollNo: serializer.fromJson<String>(json['rollNo']),
      cnic: serializer.fromJson<String>(json['cnic']),
      email: serializer.fromJson<String?>(json['email']),
      phone: serializer.fromJson<String?>(json['phone']),
      department: serializer.fromJson<String>(json['department']),
      semester: serializer.fromJson<int>(json['semester']),
      joinedDate: serializer.fromJson<DateTime>(json['joinedDate']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'societyId': serializer.toJson<String>(societyId),
      'fullName': serializer.toJson<String>(fullName),
      'rollNo': serializer.toJson<String>(rollNo),
      'cnic': serializer.toJson<String>(cnic),
      'email': serializer.toJson<String?>(email),
      'phone': serializer.toJson<String?>(phone),
      'department': serializer.toJson<String>(department),
      'semester': serializer.toJson<int>(semester),
      'joinedDate': serializer.toJson<DateTime>(joinedDate),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  SocietyMember copyWith(
          {String? id,
          String? societyId,
          String? fullName,
          String? rollNo,
          String? cnic,
          Value<String?> email = const Value.absent(),
          Value<String?> phone = const Value.absent(),
          String? department,
          int? semester,
          DateTime? joinedDate,
          bool? isActive}) =>
      SocietyMember(
        id: id ?? this.id,
        societyId: societyId ?? this.societyId,
        fullName: fullName ?? this.fullName,
        rollNo: rollNo ?? this.rollNo,
        cnic: cnic ?? this.cnic,
        email: email.present ? email.value : this.email,
        phone: phone.present ? phone.value : this.phone,
        department: department ?? this.department,
        semester: semester ?? this.semester,
        joinedDate: joinedDate ?? this.joinedDate,
        isActive: isActive ?? this.isActive,
      );
  SocietyMember copyWithCompanion(SocietyMembersCompanion data) {
    return SocietyMember(
      id: data.id.present ? data.id.value : this.id,
      societyId: data.societyId.present ? data.societyId.value : this.societyId,
      fullName: data.fullName.present ? data.fullName.value : this.fullName,
      rollNo: data.rollNo.present ? data.rollNo.value : this.rollNo,
      cnic: data.cnic.present ? data.cnic.value : this.cnic,
      email: data.email.present ? data.email.value : this.email,
      phone: data.phone.present ? data.phone.value : this.phone,
      department:
          data.department.present ? data.department.value : this.department,
      semester: data.semester.present ? data.semester.value : this.semester,
      joinedDate:
          data.joinedDate.present ? data.joinedDate.value : this.joinedDate,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SocietyMember(')
          ..write('id: $id, ')
          ..write('societyId: $societyId, ')
          ..write('fullName: $fullName, ')
          ..write('rollNo: $rollNo, ')
          ..write('cnic: $cnic, ')
          ..write('email: $email, ')
          ..write('phone: $phone, ')
          ..write('department: $department, ')
          ..write('semester: $semester, ')
          ..write('joinedDate: $joinedDate, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, societyId, fullName, rollNo, cnic, email,
      phone, department, semester, joinedDate, isActive);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SocietyMember &&
          other.id == this.id &&
          other.societyId == this.societyId &&
          other.fullName == this.fullName &&
          other.rollNo == this.rollNo &&
          other.cnic == this.cnic &&
          other.email == this.email &&
          other.phone == this.phone &&
          other.department == this.department &&
          other.semester == this.semester &&
          other.joinedDate == this.joinedDate &&
          other.isActive == this.isActive);
}

class SocietyMembersCompanion extends UpdateCompanion<SocietyMember> {
  final Value<String> id;
  final Value<String> societyId;
  final Value<String> fullName;
  final Value<String> rollNo;
  final Value<String> cnic;
  final Value<String?> email;
  final Value<String?> phone;
  final Value<String> department;
  final Value<int> semester;
  final Value<DateTime> joinedDate;
  final Value<bool> isActive;
  final Value<int> rowid;
  const SocietyMembersCompanion({
    this.id = const Value.absent(),
    this.societyId = const Value.absent(),
    this.fullName = const Value.absent(),
    this.rollNo = const Value.absent(),
    this.cnic = const Value.absent(),
    this.email = const Value.absent(),
    this.phone = const Value.absent(),
    this.department = const Value.absent(),
    this.semester = const Value.absent(),
    this.joinedDate = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SocietyMembersCompanion.insert({
    required String id,
    required String societyId,
    required String fullName,
    required String rollNo,
    required String cnic,
    this.email = const Value.absent(),
    this.phone = const Value.absent(),
    required String department,
    required int semester,
    this.joinedDate = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        societyId = Value(societyId),
        fullName = Value(fullName),
        rollNo = Value(rollNo),
        cnic = Value(cnic),
        department = Value(department),
        semester = Value(semester);
  static Insertable<SocietyMember> custom({
    Expression<String>? id,
    Expression<String>? societyId,
    Expression<String>? fullName,
    Expression<String>? rollNo,
    Expression<String>? cnic,
    Expression<String>? email,
    Expression<String>? phone,
    Expression<String>? department,
    Expression<int>? semester,
    Expression<DateTime>? joinedDate,
    Expression<bool>? isActive,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (societyId != null) 'society_id': societyId,
      if (fullName != null) 'full_name': fullName,
      if (rollNo != null) 'roll_no': rollNo,
      if (cnic != null) 'cnic': cnic,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (department != null) 'department': department,
      if (semester != null) 'semester': semester,
      if (joinedDate != null) 'joined_date': joinedDate,
      if (isActive != null) 'is_active': isActive,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SocietyMembersCompanion copyWith(
      {Value<String>? id,
      Value<String>? societyId,
      Value<String>? fullName,
      Value<String>? rollNo,
      Value<String>? cnic,
      Value<String?>? email,
      Value<String?>? phone,
      Value<String>? department,
      Value<int>? semester,
      Value<DateTime>? joinedDate,
      Value<bool>? isActive,
      Value<int>? rowid}) {
    return SocietyMembersCompanion(
      id: id ?? this.id,
      societyId: societyId ?? this.societyId,
      fullName: fullName ?? this.fullName,
      rollNo: rollNo ?? this.rollNo,
      cnic: cnic ?? this.cnic,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      department: department ?? this.department,
      semester: semester ?? this.semester,
      joinedDate: joinedDate ?? this.joinedDate,
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
    if (societyId.present) {
      map['society_id'] = Variable<String>(societyId.value);
    }
    if (fullName.present) {
      map['full_name'] = Variable<String>(fullName.value);
    }
    if (rollNo.present) {
      map['roll_no'] = Variable<String>(rollNo.value);
    }
    if (cnic.present) {
      map['cnic'] = Variable<String>(cnic.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (department.present) {
      map['department'] = Variable<String>(department.value);
    }
    if (semester.present) {
      map['semester'] = Variable<int>(semester.value);
    }
    if (joinedDate.present) {
      map['joined_date'] = Variable<DateTime>(joinedDate.value);
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
    return (StringBuffer('SocietyMembersCompanion(')
          ..write('id: $id, ')
          ..write('societyId: $societyId, ')
          ..write('fullName: $fullName, ')
          ..write('rollNo: $rollNo, ')
          ..write('cnic: $cnic, ')
          ..write('email: $email, ')
          ..write('phone: $phone, ')
          ..write('department: $department, ')
          ..write('semester: $semester, ')
          ..write('joinedDate: $joinedDate, ')
          ..write('isActive: $isActive, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EventsTable extends Events with TableInfo<$EventsTable, Event> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _eventDateMeta =
      const VerificationMeta('eventDate');
  @override
  late final GeneratedColumn<DateTime> eventDate = GeneratedColumn<DateTime>(
      'event_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _societyIdMeta =
      const VerificationMeta('societyId');
  @override
  late final GeneratedColumn<String> societyId = GeneratedColumn<String>(
      'society_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES societies (id) ON DELETE SET NULL'));
  static const VerificationMeta _isCollaborationMeta =
      const VerificationMeta('isCollaboration');
  @override
  late final GeneratedColumn<bool> isCollaboration = GeneratedColumn<bool>(
      'is_collaboration', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_collaboration" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _collaboratorNamesMeta =
      const VerificationMeta('collaboratorNames');
  @override
  late final GeneratedColumn<String> collaboratorNames =
      GeneratedColumn<String>('collaborator_names', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _venueMeta = const VerificationMeta('venue');
  @override
  late final GeneratedColumn<String> venue = GeneratedColumn<String>(
      'venue', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _allocatedBudgetMeta =
      const VerificationMeta('allocatedBudget');
  @override
  late final GeneratedColumn<double> allocatedBudget = GeneratedColumn<double>(
      'allocated_budget', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _actualExpenseMeta =
      const VerificationMeta('actualExpense');
  @override
  late final GeneratedColumn<double> actualExpense = GeneratedColumn<double>(
      'actual_expense', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _positiveImpactSummaryMeta =
      const VerificationMeta('positiveImpactSummary');
  @override
  late final GeneratedColumn<String> positiveImpactSummary =
      GeneratedColumn<String>('positive_impact_summary', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _attendeesCountMeta =
      const VerificationMeta('attendeesCount');
  @override
  late final GeneratedColumn<int> attendeesCount = GeneratedColumn<int>(
      'attendees_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _bannerImagePathMeta =
      const VerificationMeta('bannerImagePath');
  @override
  late final GeneratedColumn<String> bannerImagePath = GeneratedColumn<String>(
      'banner_image_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _imagePathsMeta =
      const VerificationMeta('imagePaths');
  @override
  late final GeneratedColumn<String> imagePaths = GeneratedColumn<String>(
      'image_paths', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        title,
        description,
        eventDate,
        societyId,
        isCollaboration,
        collaboratorNames,
        venue,
        allocatedBudget,
        actualExpense,
        positiveImpactSummary,
        attendeesCount,
        bannerImagePath,
        imagePaths,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'events';
  @override
  VerificationContext validateIntegrity(Insertable<Event> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('event_date')) {
      context.handle(_eventDateMeta,
          eventDate.isAcceptableOrUnknown(data['event_date']!, _eventDateMeta));
    } else if (isInserting) {
      context.missing(_eventDateMeta);
    }
    if (data.containsKey('society_id')) {
      context.handle(_societyIdMeta,
          societyId.isAcceptableOrUnknown(data['society_id']!, _societyIdMeta));
    }
    if (data.containsKey('is_collaboration')) {
      context.handle(
          _isCollaborationMeta,
          isCollaboration.isAcceptableOrUnknown(
              data['is_collaboration']!, _isCollaborationMeta));
    }
    if (data.containsKey('collaborator_names')) {
      context.handle(
          _collaboratorNamesMeta,
          collaboratorNames.isAcceptableOrUnknown(
              data['collaborator_names']!, _collaboratorNamesMeta));
    }
    if (data.containsKey('venue')) {
      context.handle(
          _venueMeta, venue.isAcceptableOrUnknown(data['venue']!, _venueMeta));
    }
    if (data.containsKey('allocated_budget')) {
      context.handle(
          _allocatedBudgetMeta,
          allocatedBudget.isAcceptableOrUnknown(
              data['allocated_budget']!, _allocatedBudgetMeta));
    }
    if (data.containsKey('actual_expense')) {
      context.handle(
          _actualExpenseMeta,
          actualExpense.isAcceptableOrUnknown(
              data['actual_expense']!, _actualExpenseMeta));
    }
    if (data.containsKey('positive_impact_summary')) {
      context.handle(
          _positiveImpactSummaryMeta,
          positiveImpactSummary.isAcceptableOrUnknown(
              data['positive_impact_summary']!, _positiveImpactSummaryMeta));
    }
    if (data.containsKey('attendees_count')) {
      context.handle(
          _attendeesCountMeta,
          attendeesCount.isAcceptableOrUnknown(
              data['attendees_count']!, _attendeesCountMeta));
    }
    if (data.containsKey('banner_image_path')) {
      context.handle(
          _bannerImagePathMeta,
          bannerImagePath.isAcceptableOrUnknown(
              data['banner_image_path']!, _bannerImagePathMeta));
    }
    if (data.containsKey('image_paths')) {
      context.handle(
          _imagePathsMeta,
          imagePaths.isAcceptableOrUnknown(
              data['image_paths']!, _imagePathsMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Event map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Event(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      eventDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}event_date'])!,
      societyId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}society_id']),
      isCollaboration: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_collaboration'])!,
      collaboratorNames: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}collaborator_names']),
      venue: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}venue']),
      allocatedBudget: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}allocated_budget'])!,
      actualExpense: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}actual_expense'])!,
      positiveImpactSummary: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}positive_impact_summary']),
      attendeesCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}attendees_count'])!,
      bannerImagePath: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}banner_image_path']),
      imagePaths: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_paths']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $EventsTable createAlias(String alias) {
    return $EventsTable(attachedDatabase, alias);
  }
}

class Event extends DataClass implements Insertable<Event> {
  final String id;
  final String title;
  final String description;
  final DateTime eventDate;
  final String? societyId;
  final bool isCollaboration;
  final String? collaboratorNames;
  final String? venue;
  final double allocatedBudget;
  final double actualExpense;
  final String? positiveImpactSummary;
  final int attendeesCount;
  final String? bannerImagePath;
  final String? imagePaths;
  final DateTime createdAt;
  const Event(
      {required this.id,
      required this.title,
      required this.description,
      required this.eventDate,
      this.societyId,
      required this.isCollaboration,
      this.collaboratorNames,
      this.venue,
      required this.allocatedBudget,
      required this.actualExpense,
      this.positiveImpactSummary,
      required this.attendeesCount,
      this.bannerImagePath,
      this.imagePaths,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    map['event_date'] = Variable<DateTime>(eventDate);
    if (!nullToAbsent || societyId != null) {
      map['society_id'] = Variable<String>(societyId);
    }
    map['is_collaboration'] = Variable<bool>(isCollaboration);
    if (!nullToAbsent || collaboratorNames != null) {
      map['collaborator_names'] = Variable<String>(collaboratorNames);
    }
    if (!nullToAbsent || venue != null) {
      map['venue'] = Variable<String>(venue);
    }
    map['allocated_budget'] = Variable<double>(allocatedBudget);
    map['actual_expense'] = Variable<double>(actualExpense);
    if (!nullToAbsent || positiveImpactSummary != null) {
      map['positive_impact_summary'] = Variable<String>(positiveImpactSummary);
    }
    map['attendees_count'] = Variable<int>(attendeesCount);
    if (!nullToAbsent || bannerImagePath != null) {
      map['banner_image_path'] = Variable<String>(bannerImagePath);
    }
    if (!nullToAbsent || imagePaths != null) {
      map['image_paths'] = Variable<String>(imagePaths);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  EventsCompanion toCompanion(bool nullToAbsent) {
    return EventsCompanion(
      id: Value(id),
      title: Value(title),
      description: Value(description),
      eventDate: Value(eventDate),
      societyId: societyId == null && nullToAbsent
          ? const Value.absent()
          : Value(societyId),
      isCollaboration: Value(isCollaboration),
      collaboratorNames: collaboratorNames == null && nullToAbsent
          ? const Value.absent()
          : Value(collaboratorNames),
      venue:
          venue == null && nullToAbsent ? const Value.absent() : Value(venue),
      allocatedBudget: Value(allocatedBudget),
      actualExpense: Value(actualExpense),
      positiveImpactSummary: positiveImpactSummary == null && nullToAbsent
          ? const Value.absent()
          : Value(positiveImpactSummary),
      attendeesCount: Value(attendeesCount),
      bannerImagePath: bannerImagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(bannerImagePath),
      imagePaths: imagePaths == null && nullToAbsent
          ? const Value.absent()
          : Value(imagePaths),
      createdAt: Value(createdAt),
    );
  }

  factory Event.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Event(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      eventDate: serializer.fromJson<DateTime>(json['eventDate']),
      societyId: serializer.fromJson<String?>(json['societyId']),
      isCollaboration: serializer.fromJson<bool>(json['isCollaboration']),
      collaboratorNames:
          serializer.fromJson<String?>(json['collaboratorNames']),
      venue: serializer.fromJson<String?>(json['venue']),
      allocatedBudget: serializer.fromJson<double>(json['allocatedBudget']),
      actualExpense: serializer.fromJson<double>(json['actualExpense']),
      positiveImpactSummary:
          serializer.fromJson<String?>(json['positiveImpactSummary']),
      attendeesCount: serializer.fromJson<int>(json['attendeesCount']),
      bannerImagePath: serializer.fromJson<String?>(json['bannerImagePath']),
      imagePaths: serializer.fromJson<String?>(json['imagePaths']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'eventDate': serializer.toJson<DateTime>(eventDate),
      'societyId': serializer.toJson<String?>(societyId),
      'isCollaboration': serializer.toJson<bool>(isCollaboration),
      'collaboratorNames': serializer.toJson<String?>(collaboratorNames),
      'venue': serializer.toJson<String?>(venue),
      'allocatedBudget': serializer.toJson<double>(allocatedBudget),
      'actualExpense': serializer.toJson<double>(actualExpense),
      'positiveImpactSummary':
          serializer.toJson<String?>(positiveImpactSummary),
      'attendeesCount': serializer.toJson<int>(attendeesCount),
      'bannerImagePath': serializer.toJson<String?>(bannerImagePath),
      'imagePaths': serializer.toJson<String?>(imagePaths),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Event copyWith(
          {String? id,
          String? title,
          String? description,
          DateTime? eventDate,
          Value<String?> societyId = const Value.absent(),
          bool? isCollaboration,
          Value<String?> collaboratorNames = const Value.absent(),
          Value<String?> venue = const Value.absent(),
          double? allocatedBudget,
          double? actualExpense,
          Value<String?> positiveImpactSummary = const Value.absent(),
          int? attendeesCount,
          Value<String?> bannerImagePath = const Value.absent(),
          Value<String?> imagePaths = const Value.absent(),
          DateTime? createdAt}) =>
      Event(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        eventDate: eventDate ?? this.eventDate,
        societyId: societyId.present ? societyId.value : this.societyId,
        isCollaboration: isCollaboration ?? this.isCollaboration,
        collaboratorNames: collaboratorNames.present
            ? collaboratorNames.value
            : this.collaboratorNames,
        venue: venue.present ? venue.value : this.venue,
        allocatedBudget: allocatedBudget ?? this.allocatedBudget,
        actualExpense: actualExpense ?? this.actualExpense,
        positiveImpactSummary: positiveImpactSummary.present
            ? positiveImpactSummary.value
            : this.positiveImpactSummary,
        attendeesCount: attendeesCount ?? this.attendeesCount,
        bannerImagePath: bannerImagePath.present
            ? bannerImagePath.value
            : this.bannerImagePath,
        imagePaths: imagePaths.present ? imagePaths.value : this.imagePaths,
        createdAt: createdAt ?? this.createdAt,
      );
  Event copyWithCompanion(EventsCompanion data) {
    return Event(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description:
          data.description.present ? data.description.value : this.description,
      eventDate: data.eventDate.present ? data.eventDate.value : this.eventDate,
      societyId: data.societyId.present ? data.societyId.value : this.societyId,
      isCollaboration: data.isCollaboration.present
          ? data.isCollaboration.value
          : this.isCollaboration,
      collaboratorNames: data.collaboratorNames.present
          ? data.collaboratorNames.value
          : this.collaboratorNames,
      venue: data.venue.present ? data.venue.value : this.venue,
      allocatedBudget: data.allocatedBudget.present
          ? data.allocatedBudget.value
          : this.allocatedBudget,
      actualExpense: data.actualExpense.present
          ? data.actualExpense.value
          : this.actualExpense,
      positiveImpactSummary: data.positiveImpactSummary.present
          ? data.positiveImpactSummary.value
          : this.positiveImpactSummary,
      attendeesCount: data.attendeesCount.present
          ? data.attendeesCount.value
          : this.attendeesCount,
      bannerImagePath: data.bannerImagePath.present
          ? data.bannerImagePath.value
          : this.bannerImagePath,
      imagePaths:
          data.imagePaths.present ? data.imagePaths.value : this.imagePaths,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Event(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('eventDate: $eventDate, ')
          ..write('societyId: $societyId, ')
          ..write('isCollaboration: $isCollaboration, ')
          ..write('collaboratorNames: $collaboratorNames, ')
          ..write('venue: $venue, ')
          ..write('allocatedBudget: $allocatedBudget, ')
          ..write('actualExpense: $actualExpense, ')
          ..write('positiveImpactSummary: $positiveImpactSummary, ')
          ..write('attendeesCount: $attendeesCount, ')
          ..write('bannerImagePath: $bannerImagePath, ')
          ..write('imagePaths: $imagePaths, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      title,
      description,
      eventDate,
      societyId,
      isCollaboration,
      collaboratorNames,
      venue,
      allocatedBudget,
      actualExpense,
      positiveImpactSummary,
      attendeesCount,
      bannerImagePath,
      imagePaths,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Event &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.eventDate == this.eventDate &&
          other.societyId == this.societyId &&
          other.isCollaboration == this.isCollaboration &&
          other.collaboratorNames == this.collaboratorNames &&
          other.venue == this.venue &&
          other.allocatedBudget == this.allocatedBudget &&
          other.actualExpense == this.actualExpense &&
          other.positiveImpactSummary == this.positiveImpactSummary &&
          other.attendeesCount == this.attendeesCount &&
          other.bannerImagePath == this.bannerImagePath &&
          other.imagePaths == this.imagePaths &&
          other.createdAt == this.createdAt);
}

class EventsCompanion extends UpdateCompanion<Event> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> description;
  final Value<DateTime> eventDate;
  final Value<String?> societyId;
  final Value<bool> isCollaboration;
  final Value<String?> collaboratorNames;
  final Value<String?> venue;
  final Value<double> allocatedBudget;
  final Value<double> actualExpense;
  final Value<String?> positiveImpactSummary;
  final Value<int> attendeesCount;
  final Value<String?> bannerImagePath;
  final Value<String?> imagePaths;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const EventsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.eventDate = const Value.absent(),
    this.societyId = const Value.absent(),
    this.isCollaboration = const Value.absent(),
    this.collaboratorNames = const Value.absent(),
    this.venue = const Value.absent(),
    this.allocatedBudget = const Value.absent(),
    this.actualExpense = const Value.absent(),
    this.positiveImpactSummary = const Value.absent(),
    this.attendeesCount = const Value.absent(),
    this.bannerImagePath = const Value.absent(),
    this.imagePaths = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EventsCompanion.insert({
    required String id,
    required String title,
    required String description,
    required DateTime eventDate,
    this.societyId = const Value.absent(),
    this.isCollaboration = const Value.absent(),
    this.collaboratorNames = const Value.absent(),
    this.venue = const Value.absent(),
    this.allocatedBudget = const Value.absent(),
    this.actualExpense = const Value.absent(),
    this.positiveImpactSummary = const Value.absent(),
    this.attendeesCount = const Value.absent(),
    this.bannerImagePath = const Value.absent(),
    this.imagePaths = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        title = Value(title),
        description = Value(description),
        eventDate = Value(eventDate);
  static Insertable<Event> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<DateTime>? eventDate,
    Expression<String>? societyId,
    Expression<bool>? isCollaboration,
    Expression<String>? collaboratorNames,
    Expression<String>? venue,
    Expression<double>? allocatedBudget,
    Expression<double>? actualExpense,
    Expression<String>? positiveImpactSummary,
    Expression<int>? attendeesCount,
    Expression<String>? bannerImagePath,
    Expression<String>? imagePaths,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (eventDate != null) 'event_date': eventDate,
      if (societyId != null) 'society_id': societyId,
      if (isCollaboration != null) 'is_collaboration': isCollaboration,
      if (collaboratorNames != null) 'collaborator_names': collaboratorNames,
      if (venue != null) 'venue': venue,
      if (allocatedBudget != null) 'allocated_budget': allocatedBudget,
      if (actualExpense != null) 'actual_expense': actualExpense,
      if (positiveImpactSummary != null)
        'positive_impact_summary': positiveImpactSummary,
      if (attendeesCount != null) 'attendees_count': attendeesCount,
      if (bannerImagePath != null) 'banner_image_path': bannerImagePath,
      if (imagePaths != null) 'image_paths': imagePaths,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EventsCompanion copyWith(
      {Value<String>? id,
      Value<String>? title,
      Value<String>? description,
      Value<DateTime>? eventDate,
      Value<String?>? societyId,
      Value<bool>? isCollaboration,
      Value<String?>? collaboratorNames,
      Value<String?>? venue,
      Value<double>? allocatedBudget,
      Value<double>? actualExpense,
      Value<String?>? positiveImpactSummary,
      Value<int>? attendeesCount,
      Value<String?>? bannerImagePath,
      Value<String?>? imagePaths,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return EventsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      eventDate: eventDate ?? this.eventDate,
      societyId: societyId ?? this.societyId,
      isCollaboration: isCollaboration ?? this.isCollaboration,
      collaboratorNames: collaboratorNames ?? this.collaboratorNames,
      venue: venue ?? this.venue,
      allocatedBudget: allocatedBudget ?? this.allocatedBudget,
      actualExpense: actualExpense ?? this.actualExpense,
      positiveImpactSummary:
          positiveImpactSummary ?? this.positiveImpactSummary,
      attendeesCount: attendeesCount ?? this.attendeesCount,
      bannerImagePath: bannerImagePath ?? this.bannerImagePath,
      imagePaths: imagePaths ?? this.imagePaths,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (eventDate.present) {
      map['event_date'] = Variable<DateTime>(eventDate.value);
    }
    if (societyId.present) {
      map['society_id'] = Variable<String>(societyId.value);
    }
    if (isCollaboration.present) {
      map['is_collaboration'] = Variable<bool>(isCollaboration.value);
    }
    if (collaboratorNames.present) {
      map['collaborator_names'] = Variable<String>(collaboratorNames.value);
    }
    if (venue.present) {
      map['venue'] = Variable<String>(venue.value);
    }
    if (allocatedBudget.present) {
      map['allocated_budget'] = Variable<double>(allocatedBudget.value);
    }
    if (actualExpense.present) {
      map['actual_expense'] = Variable<double>(actualExpense.value);
    }
    if (positiveImpactSummary.present) {
      map['positive_impact_summary'] =
          Variable<String>(positiveImpactSummary.value);
    }
    if (attendeesCount.present) {
      map['attendees_count'] = Variable<int>(attendeesCount.value);
    }
    if (bannerImagePath.present) {
      map['banner_image_path'] = Variable<String>(bannerImagePath.value);
    }
    if (imagePaths.present) {
      map['image_paths'] = Variable<String>(imagePaths.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EventsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('eventDate: $eventDate, ')
          ..write('societyId: $societyId, ')
          ..write('isCollaboration: $isCollaboration, ')
          ..write('collaboratorNames: $collaboratorNames, ')
          ..write('venue: $venue, ')
          ..write('allocatedBudget: $allocatedBudget, ')
          ..write('actualExpense: $actualExpense, ')
          ..write('positiveImpactSummary: $positiveImpactSummary, ')
          ..write('attendeesCount: $attendeesCount, ')
          ..write('bannerImagePath: $bannerImagePath, ')
          ..write('imagePaths: $imagePaths, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EventSpeakersTable extends EventSpeakers
    with TableInfo<$EventSpeakersTable, EventSpeaker> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EventSpeakersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _eventIdMeta =
      const VerificationMeta('eventId');
  @override
  late final GeneratedColumn<String> eventId = GeneratedColumn<String>(
      'event_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES events (id) ON DELETE CASCADE'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _designationMeta =
      const VerificationMeta('designation');
  @override
  late final GeneratedColumn<String> designation = GeneratedColumn<String>(
      'designation', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _organizationMeta =
      const VerificationMeta('organization');
  @override
  late final GeneratedColumn<String> organization = GeneratedColumn<String>(
      'organization', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _contactPhoneMeta =
      const VerificationMeta('contactPhone');
  @override
  late final GeneratedColumn<String> contactPhone = GeneratedColumn<String>(
      'contact_phone', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _contactEmailMeta =
      const VerificationMeta('contactEmail');
  @override
  late final GeneratedColumn<String> contactEmail = GeneratedColumn<String>(
      'contact_email', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        eventId,
        name,
        designation,
        organization,
        contactPhone,
        contactEmail
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'event_speakers';
  @override
  VerificationContext validateIntegrity(Insertable<EventSpeaker> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('event_id')) {
      context.handle(_eventIdMeta,
          eventId.isAcceptableOrUnknown(data['event_id']!, _eventIdMeta));
    } else if (isInserting) {
      context.missing(_eventIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('designation')) {
      context.handle(
          _designationMeta,
          designation.isAcceptableOrUnknown(
              data['designation']!, _designationMeta));
    }
    if (data.containsKey('organization')) {
      context.handle(
          _organizationMeta,
          organization.isAcceptableOrUnknown(
              data['organization']!, _organizationMeta));
    } else if (isInserting) {
      context.missing(_organizationMeta);
    }
    if (data.containsKey('contact_phone')) {
      context.handle(
          _contactPhoneMeta,
          contactPhone.isAcceptableOrUnknown(
              data['contact_phone']!, _contactPhoneMeta));
    }
    if (data.containsKey('contact_email')) {
      context.handle(
          _contactEmailMeta,
          contactEmail.isAcceptableOrUnknown(
              data['contact_email']!, _contactEmailMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EventSpeaker map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EventSpeaker(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      eventId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}event_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      designation: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}designation']),
      organization: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}organization'])!,
      contactPhone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}contact_phone']),
      contactEmail: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}contact_email']),
    );
  }

  @override
  $EventSpeakersTable createAlias(String alias) {
    return $EventSpeakersTable(attachedDatabase, alias);
  }
}

class EventSpeaker extends DataClass implements Insertable<EventSpeaker> {
  final String id;
  final String eventId;
  final String name;
  final String? designation;
  final String organization;
  final String? contactPhone;
  final String? contactEmail;
  const EventSpeaker(
      {required this.id,
      required this.eventId,
      required this.name,
      this.designation,
      required this.organization,
      this.contactPhone,
      this.contactEmail});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['event_id'] = Variable<String>(eventId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || designation != null) {
      map['designation'] = Variable<String>(designation);
    }
    map['organization'] = Variable<String>(organization);
    if (!nullToAbsent || contactPhone != null) {
      map['contact_phone'] = Variable<String>(contactPhone);
    }
    if (!nullToAbsent || contactEmail != null) {
      map['contact_email'] = Variable<String>(contactEmail);
    }
    return map;
  }

  EventSpeakersCompanion toCompanion(bool nullToAbsent) {
    return EventSpeakersCompanion(
      id: Value(id),
      eventId: Value(eventId),
      name: Value(name),
      designation: designation == null && nullToAbsent
          ? const Value.absent()
          : Value(designation),
      organization: Value(organization),
      contactPhone: contactPhone == null && nullToAbsent
          ? const Value.absent()
          : Value(contactPhone),
      contactEmail: contactEmail == null && nullToAbsent
          ? const Value.absent()
          : Value(contactEmail),
    );
  }

  factory EventSpeaker.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EventSpeaker(
      id: serializer.fromJson<String>(json['id']),
      eventId: serializer.fromJson<String>(json['eventId']),
      name: serializer.fromJson<String>(json['name']),
      designation: serializer.fromJson<String?>(json['designation']),
      organization: serializer.fromJson<String>(json['organization']),
      contactPhone: serializer.fromJson<String?>(json['contactPhone']),
      contactEmail: serializer.fromJson<String?>(json['contactEmail']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'eventId': serializer.toJson<String>(eventId),
      'name': serializer.toJson<String>(name),
      'designation': serializer.toJson<String?>(designation),
      'organization': serializer.toJson<String>(organization),
      'contactPhone': serializer.toJson<String?>(contactPhone),
      'contactEmail': serializer.toJson<String?>(contactEmail),
    };
  }

  EventSpeaker copyWith(
          {String? id,
          String? eventId,
          String? name,
          Value<String?> designation = const Value.absent(),
          String? organization,
          Value<String?> contactPhone = const Value.absent(),
          Value<String?> contactEmail = const Value.absent()}) =>
      EventSpeaker(
        id: id ?? this.id,
        eventId: eventId ?? this.eventId,
        name: name ?? this.name,
        designation: designation.present ? designation.value : this.designation,
        organization: organization ?? this.organization,
        contactPhone:
            contactPhone.present ? contactPhone.value : this.contactPhone,
        contactEmail:
            contactEmail.present ? contactEmail.value : this.contactEmail,
      );
  EventSpeaker copyWithCompanion(EventSpeakersCompanion data) {
    return EventSpeaker(
      id: data.id.present ? data.id.value : this.id,
      eventId: data.eventId.present ? data.eventId.value : this.eventId,
      name: data.name.present ? data.name.value : this.name,
      designation:
          data.designation.present ? data.designation.value : this.designation,
      organization: data.organization.present
          ? data.organization.value
          : this.organization,
      contactPhone: data.contactPhone.present
          ? data.contactPhone.value
          : this.contactPhone,
      contactEmail: data.contactEmail.present
          ? data.contactEmail.value
          : this.contactEmail,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EventSpeaker(')
          ..write('id: $id, ')
          ..write('eventId: $eventId, ')
          ..write('name: $name, ')
          ..write('designation: $designation, ')
          ..write('organization: $organization, ')
          ..write('contactPhone: $contactPhone, ')
          ..write('contactEmail: $contactEmail')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, eventId, name, designation, organization, contactPhone, contactEmail);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EventSpeaker &&
          other.id == this.id &&
          other.eventId == this.eventId &&
          other.name == this.name &&
          other.designation == this.designation &&
          other.organization == this.organization &&
          other.contactPhone == this.contactPhone &&
          other.contactEmail == this.contactEmail);
}

class EventSpeakersCompanion extends UpdateCompanion<EventSpeaker> {
  final Value<String> id;
  final Value<String> eventId;
  final Value<String> name;
  final Value<String?> designation;
  final Value<String> organization;
  final Value<String?> contactPhone;
  final Value<String?> contactEmail;
  final Value<int> rowid;
  const EventSpeakersCompanion({
    this.id = const Value.absent(),
    this.eventId = const Value.absent(),
    this.name = const Value.absent(),
    this.designation = const Value.absent(),
    this.organization = const Value.absent(),
    this.contactPhone = const Value.absent(),
    this.contactEmail = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EventSpeakersCompanion.insert({
    required String id,
    required String eventId,
    required String name,
    this.designation = const Value.absent(),
    required String organization,
    this.contactPhone = const Value.absent(),
    this.contactEmail = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        eventId = Value(eventId),
        name = Value(name),
        organization = Value(organization);
  static Insertable<EventSpeaker> custom({
    Expression<String>? id,
    Expression<String>? eventId,
    Expression<String>? name,
    Expression<String>? designation,
    Expression<String>? organization,
    Expression<String>? contactPhone,
    Expression<String>? contactEmail,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (eventId != null) 'event_id': eventId,
      if (name != null) 'name': name,
      if (designation != null) 'designation': designation,
      if (organization != null) 'organization': organization,
      if (contactPhone != null) 'contact_phone': contactPhone,
      if (contactEmail != null) 'contact_email': contactEmail,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EventSpeakersCompanion copyWith(
      {Value<String>? id,
      Value<String>? eventId,
      Value<String>? name,
      Value<String?>? designation,
      Value<String>? organization,
      Value<String?>? contactPhone,
      Value<String?>? contactEmail,
      Value<int>? rowid}) {
    return EventSpeakersCompanion(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      name: name ?? this.name,
      designation: designation ?? this.designation,
      organization: organization ?? this.organization,
      contactPhone: contactPhone ?? this.contactPhone,
      contactEmail: contactEmail ?? this.contactEmail,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (eventId.present) {
      map['event_id'] = Variable<String>(eventId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (designation.present) {
      map['designation'] = Variable<String>(designation.value);
    }
    if (organization.present) {
      map['organization'] = Variable<String>(organization.value);
    }
    if (contactPhone.present) {
      map['contact_phone'] = Variable<String>(contactPhone.value);
    }
    if (contactEmail.present) {
      map['contact_email'] = Variable<String>(contactEmail.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EventSpeakersCompanion(')
          ..write('id: $id, ')
          ..write('eventId: $eventId, ')
          ..write('name: $name, ')
          ..write('designation: $designation, ')
          ..write('organization: $organization, ')
          ..write('contactPhone: $contactPhone, ')
          ..write('contactEmail: $contactEmail, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AchievementsTable extends Achievements
    with TableInfo<$AchievementsTable, Achievement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AchievementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _monthYearMeta =
      const VerificationMeta('monthYear');
  @override
  late final GeneratedColumn<String> monthYear = GeneratedColumn<String>(
      'month_year', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _societyIdMeta =
      const VerificationMeta('societyId');
  @override
  late final GeneratedColumn<String> societyId = GeneratedColumn<String>(
      'society_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES societies (id) ON DELETE SET NULL'));
  static const VerificationMeta _proofImagePathMeta =
      const VerificationMeta('proofImagePath');
  @override
  late final GeneratedColumn<String> proofImagePath = GeneratedColumn<String>(
      'proof_image_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, monthYear, title, description, societyId, proofImagePath, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'achievements';
  @override
  VerificationContext validateIntegrity(Insertable<Achievement> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('month_year')) {
      context.handle(_monthYearMeta,
          monthYear.isAcceptableOrUnknown(data['month_year']!, _monthYearMeta));
    } else if (isInserting) {
      context.missing(_monthYearMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('society_id')) {
      context.handle(_societyIdMeta,
          societyId.isAcceptableOrUnknown(data['society_id']!, _societyIdMeta));
    }
    if (data.containsKey('proof_image_path')) {
      context.handle(
          _proofImagePathMeta,
          proofImagePath.isAcceptableOrUnknown(
              data['proof_image_path']!, _proofImagePathMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Achievement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Achievement(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      monthYear: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}month_year'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      societyId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}society_id']),
      proofImagePath: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}proof_image_path']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $AchievementsTable createAlias(String alias) {
    return $AchievementsTable(attachedDatabase, alias);
  }
}

class Achievement extends DataClass implements Insertable<Achievement> {
  final String id;
  final String monthYear;
  final String title;
  final String? description;
  final String? societyId;
  final String? proofImagePath;
  final DateTime createdAt;
  const Achievement(
      {required this.id,
      required this.monthYear,
      required this.title,
      this.description,
      this.societyId,
      this.proofImagePath,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['month_year'] = Variable<String>(monthYear);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || societyId != null) {
      map['society_id'] = Variable<String>(societyId);
    }
    if (!nullToAbsent || proofImagePath != null) {
      map['proof_image_path'] = Variable<String>(proofImagePath);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  AchievementsCompanion toCompanion(bool nullToAbsent) {
    return AchievementsCompanion(
      id: Value(id),
      monthYear: Value(monthYear),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      societyId: societyId == null && nullToAbsent
          ? const Value.absent()
          : Value(societyId),
      proofImagePath: proofImagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(proofImagePath),
      createdAt: Value(createdAt),
    );
  }

  factory Achievement.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Achievement(
      id: serializer.fromJson<String>(json['id']),
      monthYear: serializer.fromJson<String>(json['monthYear']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      societyId: serializer.fromJson<String?>(json['societyId']),
      proofImagePath: serializer.fromJson<String?>(json['proofImagePath']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'monthYear': serializer.toJson<String>(monthYear),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'societyId': serializer.toJson<String?>(societyId),
      'proofImagePath': serializer.toJson<String?>(proofImagePath),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Achievement copyWith(
          {String? id,
          String? monthYear,
          String? title,
          Value<String?> description = const Value.absent(),
          Value<String?> societyId = const Value.absent(),
          Value<String?> proofImagePath = const Value.absent(),
          DateTime? createdAt}) =>
      Achievement(
        id: id ?? this.id,
        monthYear: monthYear ?? this.monthYear,
        title: title ?? this.title,
        description: description.present ? description.value : this.description,
        societyId: societyId.present ? societyId.value : this.societyId,
        proofImagePath:
            proofImagePath.present ? proofImagePath.value : this.proofImagePath,
        createdAt: createdAt ?? this.createdAt,
      );
  Achievement copyWithCompanion(AchievementsCompanion data) {
    return Achievement(
      id: data.id.present ? data.id.value : this.id,
      monthYear: data.monthYear.present ? data.monthYear.value : this.monthYear,
      title: data.title.present ? data.title.value : this.title,
      description:
          data.description.present ? data.description.value : this.description,
      societyId: data.societyId.present ? data.societyId.value : this.societyId,
      proofImagePath: data.proofImagePath.present
          ? data.proofImagePath.value
          : this.proofImagePath,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Achievement(')
          ..write('id: $id, ')
          ..write('monthYear: $monthYear, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('societyId: $societyId, ')
          ..write('proofImagePath: $proofImagePath, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, monthYear, title, description, societyId, proofImagePath, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Achievement &&
          other.id == this.id &&
          other.monthYear == this.monthYear &&
          other.title == this.title &&
          other.description == this.description &&
          other.societyId == this.societyId &&
          other.proofImagePath == this.proofImagePath &&
          other.createdAt == this.createdAt);
}

class AchievementsCompanion extends UpdateCompanion<Achievement> {
  final Value<String> id;
  final Value<String> monthYear;
  final Value<String> title;
  final Value<String?> description;
  final Value<String?> societyId;
  final Value<String?> proofImagePath;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const AchievementsCompanion({
    this.id = const Value.absent(),
    this.monthYear = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.societyId = const Value.absent(),
    this.proofImagePath = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AchievementsCompanion.insert({
    required String id,
    required String monthYear,
    required String title,
    this.description = const Value.absent(),
    this.societyId = const Value.absent(),
    this.proofImagePath = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        monthYear = Value(monthYear),
        title = Value(title);
  static Insertable<Achievement> custom({
    Expression<String>? id,
    Expression<String>? monthYear,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? societyId,
    Expression<String>? proofImagePath,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (monthYear != null) 'month_year': monthYear,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (societyId != null) 'society_id': societyId,
      if (proofImagePath != null) 'proof_image_path': proofImagePath,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AchievementsCompanion copyWith(
      {Value<String>? id,
      Value<String>? monthYear,
      Value<String>? title,
      Value<String?>? description,
      Value<String?>? societyId,
      Value<String?>? proofImagePath,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return AchievementsCompanion(
      id: id ?? this.id,
      monthYear: monthYear ?? this.monthYear,
      title: title ?? this.title,
      description: description ?? this.description,
      societyId: societyId ?? this.societyId,
      proofImagePath: proofImagePath ?? this.proofImagePath,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (monthYear.present) {
      map['month_year'] = Variable<String>(monthYear.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (societyId.present) {
      map['society_id'] = Variable<String>(societyId.value);
    }
    if (proofImagePath.present) {
      map['proof_image_path'] = Variable<String>(proofImagePath.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AchievementsCompanion(')
          ..write('id: $id, ')
          ..write('monthYear: $monthYear, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('societyId: $societyId, ')
          ..write('proofImagePath: $proofImagePath, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FinancialRecordsTable extends FinancialRecords
    with TableInfo<$FinancialRecordsTable, FinancialRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FinancialRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _monthYearMeta =
      const VerificationMeta('monthYear');
  @override
  late final GeneratedColumn<String> monthYear = GeneratedColumn<String>(
      'month_year', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _sponsorNameMeta =
      const VerificationMeta('sponsorName');
  @override
  late final GeneratedColumn<String> sponsorName = GeneratedColumn<String>(
      'sponsor_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _voucherPathMeta =
      const VerificationMeta('voucherPath');
  @override
  late final GeneratedColumn<String> voucherPath = GeneratedColumn<String>(
      'voucher_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _recordedAtMeta =
      const VerificationMeta('recordedAt');
  @override
  late final GeneratedColumn<DateTime> recordedAt = GeneratedColumn<DateTime>(
      'recorded_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        monthYear,
        type,
        title,
        amount,
        sponsorName,
        voucherPath,
        notes,
        recordedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'financial_records';
  @override
  VerificationContext validateIntegrity(Insertable<FinancialRecord> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('month_year')) {
      context.handle(_monthYearMeta,
          monthYear.isAcceptableOrUnknown(data['month_year']!, _monthYearMeta));
    } else if (isInserting) {
      context.missing(_monthYearMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('sponsor_name')) {
      context.handle(
          _sponsorNameMeta,
          sponsorName.isAcceptableOrUnknown(
              data['sponsor_name']!, _sponsorNameMeta));
    }
    if (data.containsKey('voucher_path')) {
      context.handle(
          _voucherPathMeta,
          voucherPath.isAcceptableOrUnknown(
              data['voucher_path']!, _voucherPathMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('recorded_at')) {
      context.handle(
          _recordedAtMeta,
          recordedAt.isAcceptableOrUnknown(
              data['recorded_at']!, _recordedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FinancialRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FinancialRecord(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      monthYear: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}month_year'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      sponsorName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sponsor_name']),
      voucherPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}voucher_path']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      recordedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}recorded_at'])!,
    );
  }

  @override
  $FinancialRecordsTable createAlias(String alias) {
    return $FinancialRecordsTable(attachedDatabase, alias);
  }
}

class FinancialRecord extends DataClass implements Insertable<FinancialRecord> {
  final String id;
  final String monthYear;
  final String type;
  final String title;
  final double amount;
  final String? sponsorName;
  final String? voucherPath;
  final String? notes;
  final DateTime recordedAt;
  const FinancialRecord(
      {required this.id,
      required this.monthYear,
      required this.type,
      required this.title,
      required this.amount,
      this.sponsorName,
      this.voucherPath,
      this.notes,
      required this.recordedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['month_year'] = Variable<String>(monthYear);
    map['type'] = Variable<String>(type);
    map['title'] = Variable<String>(title);
    map['amount'] = Variable<double>(amount);
    if (!nullToAbsent || sponsorName != null) {
      map['sponsor_name'] = Variable<String>(sponsorName);
    }
    if (!nullToAbsent || voucherPath != null) {
      map['voucher_path'] = Variable<String>(voucherPath);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['recorded_at'] = Variable<DateTime>(recordedAt);
    return map;
  }

  FinancialRecordsCompanion toCompanion(bool nullToAbsent) {
    return FinancialRecordsCompanion(
      id: Value(id),
      monthYear: Value(monthYear),
      type: Value(type),
      title: Value(title),
      amount: Value(amount),
      sponsorName: sponsorName == null && nullToAbsent
          ? const Value.absent()
          : Value(sponsorName),
      voucherPath: voucherPath == null && nullToAbsent
          ? const Value.absent()
          : Value(voucherPath),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      recordedAt: Value(recordedAt),
    );
  }

  factory FinancialRecord.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FinancialRecord(
      id: serializer.fromJson<String>(json['id']),
      monthYear: serializer.fromJson<String>(json['monthYear']),
      type: serializer.fromJson<String>(json['type']),
      title: serializer.fromJson<String>(json['title']),
      amount: serializer.fromJson<double>(json['amount']),
      sponsorName: serializer.fromJson<String?>(json['sponsorName']),
      voucherPath: serializer.fromJson<String?>(json['voucherPath']),
      notes: serializer.fromJson<String?>(json['notes']),
      recordedAt: serializer.fromJson<DateTime>(json['recordedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'monthYear': serializer.toJson<String>(monthYear),
      'type': serializer.toJson<String>(type),
      'title': serializer.toJson<String>(title),
      'amount': serializer.toJson<double>(amount),
      'sponsorName': serializer.toJson<String?>(sponsorName),
      'voucherPath': serializer.toJson<String?>(voucherPath),
      'notes': serializer.toJson<String?>(notes),
      'recordedAt': serializer.toJson<DateTime>(recordedAt),
    };
  }

  FinancialRecord copyWith(
          {String? id,
          String? monthYear,
          String? type,
          String? title,
          double? amount,
          Value<String?> sponsorName = const Value.absent(),
          Value<String?> voucherPath = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          DateTime? recordedAt}) =>
      FinancialRecord(
        id: id ?? this.id,
        monthYear: monthYear ?? this.monthYear,
        type: type ?? this.type,
        title: title ?? this.title,
        amount: amount ?? this.amount,
        sponsorName: sponsorName.present ? sponsorName.value : this.sponsorName,
        voucherPath: voucherPath.present ? voucherPath.value : this.voucherPath,
        notes: notes.present ? notes.value : this.notes,
        recordedAt: recordedAt ?? this.recordedAt,
      );
  FinancialRecord copyWithCompanion(FinancialRecordsCompanion data) {
    return FinancialRecord(
      id: data.id.present ? data.id.value : this.id,
      monthYear: data.monthYear.present ? data.monthYear.value : this.monthYear,
      type: data.type.present ? data.type.value : this.type,
      title: data.title.present ? data.title.value : this.title,
      amount: data.amount.present ? data.amount.value : this.amount,
      sponsorName:
          data.sponsorName.present ? data.sponsorName.value : this.sponsorName,
      voucherPath:
          data.voucherPath.present ? data.voucherPath.value : this.voucherPath,
      notes: data.notes.present ? data.notes.value : this.notes,
      recordedAt:
          data.recordedAt.present ? data.recordedAt.value : this.recordedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FinancialRecord(')
          ..write('id: $id, ')
          ..write('monthYear: $monthYear, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('amount: $amount, ')
          ..write('sponsorName: $sponsorName, ')
          ..write('voucherPath: $voucherPath, ')
          ..write('notes: $notes, ')
          ..write('recordedAt: $recordedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, monthYear, type, title, amount,
      sponsorName, voucherPath, notes, recordedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FinancialRecord &&
          other.id == this.id &&
          other.monthYear == this.monthYear &&
          other.type == this.type &&
          other.title == this.title &&
          other.amount == this.amount &&
          other.sponsorName == this.sponsorName &&
          other.voucherPath == this.voucherPath &&
          other.notes == this.notes &&
          other.recordedAt == this.recordedAt);
}

class FinancialRecordsCompanion extends UpdateCompanion<FinancialRecord> {
  final Value<String> id;
  final Value<String> monthYear;
  final Value<String> type;
  final Value<String> title;
  final Value<double> amount;
  final Value<String?> sponsorName;
  final Value<String?> voucherPath;
  final Value<String?> notes;
  final Value<DateTime> recordedAt;
  final Value<int> rowid;
  const FinancialRecordsCompanion({
    this.id = const Value.absent(),
    this.monthYear = const Value.absent(),
    this.type = const Value.absent(),
    this.title = const Value.absent(),
    this.amount = const Value.absent(),
    this.sponsorName = const Value.absent(),
    this.voucherPath = const Value.absent(),
    this.notes = const Value.absent(),
    this.recordedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FinancialRecordsCompanion.insert({
    required String id,
    required String monthYear,
    required String type,
    required String title,
    required double amount,
    this.sponsorName = const Value.absent(),
    this.voucherPath = const Value.absent(),
    this.notes = const Value.absent(),
    this.recordedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        monthYear = Value(monthYear),
        type = Value(type),
        title = Value(title),
        amount = Value(amount);
  static Insertable<FinancialRecord> custom({
    Expression<String>? id,
    Expression<String>? monthYear,
    Expression<String>? type,
    Expression<String>? title,
    Expression<double>? amount,
    Expression<String>? sponsorName,
    Expression<String>? voucherPath,
    Expression<String>? notes,
    Expression<DateTime>? recordedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (monthYear != null) 'month_year': monthYear,
      if (type != null) 'type': type,
      if (title != null) 'title': title,
      if (amount != null) 'amount': amount,
      if (sponsorName != null) 'sponsor_name': sponsorName,
      if (voucherPath != null) 'voucher_path': voucherPath,
      if (notes != null) 'notes': notes,
      if (recordedAt != null) 'recorded_at': recordedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FinancialRecordsCompanion copyWith(
      {Value<String>? id,
      Value<String>? monthYear,
      Value<String>? type,
      Value<String>? title,
      Value<double>? amount,
      Value<String?>? sponsorName,
      Value<String?>? voucherPath,
      Value<String?>? notes,
      Value<DateTime>? recordedAt,
      Value<int>? rowid}) {
    return FinancialRecordsCompanion(
      id: id ?? this.id,
      monthYear: monthYear ?? this.monthYear,
      type: type ?? this.type,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      sponsorName: sponsorName ?? this.sponsorName,
      voucherPath: voucherPath ?? this.voucherPath,
      notes: notes ?? this.notes,
      recordedAt: recordedAt ?? this.recordedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (monthYear.present) {
      map['month_year'] = Variable<String>(monthYear.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (sponsorName.present) {
      map['sponsor_name'] = Variable<String>(sponsorName.value);
    }
    if (voucherPath.present) {
      map['voucher_path'] = Variable<String>(voucherPath.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (recordedAt.present) {
      map['recorded_at'] = Variable<DateTime>(recordedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FinancialRecordsCompanion(')
          ..write('id: $id, ')
          ..write('monthYear: $monthYear, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('amount: $amount, ')
          ..write('sponsorName: $sponsorName, ')
          ..write('voucherPath: $voucherPath, ')
          ..write('notes: $notes, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ConfidentialVaultTable extends ConfidentialVault
    with TableInfo<$ConfidentialVaultTable, ConfidentialVaultData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConfidentialVaultTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _societyIdMeta =
      const VerificationMeta('societyId');
  @override
  late final GeneratedColumn<String> societyId = GeneratedColumn<String>(
      'society_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES societies (id) ON DELETE SET NULL'));
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _referenceNumberMeta =
      const VerificationMeta('referenceNumber');
  @override
  late final GeneratedColumn<String> referenceNumber = GeneratedColumn<String>(
      'reference_number', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _effectiveDateMeta =
      const VerificationMeta('effectiveDate');
  @override
  late final GeneratedColumn<DateTime> effectiveDate =
      GeneratedColumn<DateTime>('effective_date', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _expiryDateMeta =
      const VerificationMeta('expiryDate');
  @override
  late final GeneratedColumn<DateTime> expiryDate = GeneratedColumn<DateTime>(
      'expiry_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _encryptedFilePathMeta =
      const VerificationMeta('encryptedFilePath');
  @override
  late final GeneratedColumn<String> encryptedFilePath =
      GeneratedColumn<String>('encrypted_file_path', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fileChecksumMeta =
      const VerificationMeta('fileChecksum');
  @override
  late final GeneratedColumn<String> fileChecksum = GeneratedColumn<String>(
      'file_checksum', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fileSizeBytesMeta =
      const VerificationMeta('fileSizeBytes');
  @override
  late final GeneratedColumn<int> fileSizeBytes = GeneratedColumn<int>(
      'file_size_bytes', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _originalFileNameMeta =
      const VerificationMeta('originalFileName');
  @override
  late final GeneratedColumn<String> originalFileName = GeneratedColumn<String>(
      'original_file_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _metadataNotesMeta =
      const VerificationMeta('metadataNotes');
  @override
  late final GeneratedColumn<String> metadataNotes = GeneratedColumn<String>(
      'metadata_notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _uploadedAtMeta =
      const VerificationMeta('uploadedAt');
  @override
  late final GeneratedColumn<DateTime> uploadedAt = GeneratedColumn<DateTime>(
      'uploaded_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        societyId,
        category,
        title,
        referenceNumber,
        effectiveDate,
        expiryDate,
        encryptedFilePath,
        fileChecksum,
        fileSizeBytes,
        originalFileName,
        metadataNotes,
        uploadedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'confidential_vault';
  @override
  VerificationContext validateIntegrity(
      Insertable<ConfidentialVaultData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('society_id')) {
      context.handle(_societyIdMeta,
          societyId.isAcceptableOrUnknown(data['society_id']!, _societyIdMeta));
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('reference_number')) {
      context.handle(
          _referenceNumberMeta,
          referenceNumber.isAcceptableOrUnknown(
              data['reference_number']!, _referenceNumberMeta));
    }
    if (data.containsKey('effective_date')) {
      context.handle(
          _effectiveDateMeta,
          effectiveDate.isAcceptableOrUnknown(
              data['effective_date']!, _effectiveDateMeta));
    }
    if (data.containsKey('expiry_date')) {
      context.handle(
          _expiryDateMeta,
          expiryDate.isAcceptableOrUnknown(
              data['expiry_date']!, _expiryDateMeta));
    }
    if (data.containsKey('encrypted_file_path')) {
      context.handle(
          _encryptedFilePathMeta,
          encryptedFilePath.isAcceptableOrUnknown(
              data['encrypted_file_path']!, _encryptedFilePathMeta));
    } else if (isInserting) {
      context.missing(_encryptedFilePathMeta);
    }
    if (data.containsKey('file_checksum')) {
      context.handle(
          _fileChecksumMeta,
          fileChecksum.isAcceptableOrUnknown(
              data['file_checksum']!, _fileChecksumMeta));
    } else if (isInserting) {
      context.missing(_fileChecksumMeta);
    }
    if (data.containsKey('file_size_bytes')) {
      context.handle(
          _fileSizeBytesMeta,
          fileSizeBytes.isAcceptableOrUnknown(
              data['file_size_bytes']!, _fileSizeBytesMeta));
    }
    if (data.containsKey('original_file_name')) {
      context.handle(
          _originalFileNameMeta,
          originalFileName.isAcceptableOrUnknown(
              data['original_file_name']!, _originalFileNameMeta));
    }
    if (data.containsKey('metadata_notes')) {
      context.handle(
          _metadataNotesMeta,
          metadataNotes.isAcceptableOrUnknown(
              data['metadata_notes']!, _metadataNotesMeta));
    }
    if (data.containsKey('uploaded_at')) {
      context.handle(
          _uploadedAtMeta,
          uploadedAt.isAcceptableOrUnknown(
              data['uploaded_at']!, _uploadedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ConfidentialVaultData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ConfidentialVaultData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      societyId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}society_id']),
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      referenceNumber: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}reference_number']),
      effectiveDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}effective_date']),
      expiryDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}expiry_date']),
      encryptedFilePath: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}encrypted_file_path'])!,
      fileChecksum: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}file_checksum'])!,
      fileSizeBytes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}file_size_bytes']),
      originalFileName: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}original_file_name']),
      metadataNotes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}metadata_notes']),
      uploadedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}uploaded_at'])!,
    );
  }

  @override
  $ConfidentialVaultTable createAlias(String alias) {
    return $ConfidentialVaultTable(attachedDatabase, alias);
  }
}

class ConfidentialVaultData extends DataClass
    implements Insertable<ConfidentialVaultData> {
  final String id;
  final String? societyId;
  final String category;
  final String title;
  final String? referenceNumber;
  final DateTime? effectiveDate;
  final DateTime? expiryDate;
  final String encryptedFilePath;
  final String fileChecksum;
  final int? fileSizeBytes;
  final String? originalFileName;
  final String? metadataNotes;
  final DateTime uploadedAt;
  const ConfidentialVaultData(
      {required this.id,
      this.societyId,
      required this.category,
      required this.title,
      this.referenceNumber,
      this.effectiveDate,
      this.expiryDate,
      required this.encryptedFilePath,
      required this.fileChecksum,
      this.fileSizeBytes,
      this.originalFileName,
      this.metadataNotes,
      required this.uploadedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || societyId != null) {
      map['society_id'] = Variable<String>(societyId);
    }
    map['category'] = Variable<String>(category);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || referenceNumber != null) {
      map['reference_number'] = Variable<String>(referenceNumber);
    }
    if (!nullToAbsent || effectiveDate != null) {
      map['effective_date'] = Variable<DateTime>(effectiveDate);
    }
    if (!nullToAbsent || expiryDate != null) {
      map['expiry_date'] = Variable<DateTime>(expiryDate);
    }
    map['encrypted_file_path'] = Variable<String>(encryptedFilePath);
    map['file_checksum'] = Variable<String>(fileChecksum);
    if (!nullToAbsent || fileSizeBytes != null) {
      map['file_size_bytes'] = Variable<int>(fileSizeBytes);
    }
    if (!nullToAbsent || originalFileName != null) {
      map['original_file_name'] = Variable<String>(originalFileName);
    }
    if (!nullToAbsent || metadataNotes != null) {
      map['metadata_notes'] = Variable<String>(metadataNotes);
    }
    map['uploaded_at'] = Variable<DateTime>(uploadedAt);
    return map;
  }

  ConfidentialVaultCompanion toCompanion(bool nullToAbsent) {
    return ConfidentialVaultCompanion(
      id: Value(id),
      societyId: societyId == null && nullToAbsent
          ? const Value.absent()
          : Value(societyId),
      category: Value(category),
      title: Value(title),
      referenceNumber: referenceNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(referenceNumber),
      effectiveDate: effectiveDate == null && nullToAbsent
          ? const Value.absent()
          : Value(effectiveDate),
      expiryDate: expiryDate == null && nullToAbsent
          ? const Value.absent()
          : Value(expiryDate),
      encryptedFilePath: Value(encryptedFilePath),
      fileChecksum: Value(fileChecksum),
      fileSizeBytes: fileSizeBytes == null && nullToAbsent
          ? const Value.absent()
          : Value(fileSizeBytes),
      originalFileName: originalFileName == null && nullToAbsent
          ? const Value.absent()
          : Value(originalFileName),
      metadataNotes: metadataNotes == null && nullToAbsent
          ? const Value.absent()
          : Value(metadataNotes),
      uploadedAt: Value(uploadedAt),
    );
  }

  factory ConfidentialVaultData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ConfidentialVaultData(
      id: serializer.fromJson<String>(json['id']),
      societyId: serializer.fromJson<String?>(json['societyId']),
      category: serializer.fromJson<String>(json['category']),
      title: serializer.fromJson<String>(json['title']),
      referenceNumber: serializer.fromJson<String?>(json['referenceNumber']),
      effectiveDate: serializer.fromJson<DateTime?>(json['effectiveDate']),
      expiryDate: serializer.fromJson<DateTime?>(json['expiryDate']),
      encryptedFilePath: serializer.fromJson<String>(json['encryptedFilePath']),
      fileChecksum: serializer.fromJson<String>(json['fileChecksum']),
      fileSizeBytes: serializer.fromJson<int?>(json['fileSizeBytes']),
      originalFileName: serializer.fromJson<String?>(json['originalFileName']),
      metadataNotes: serializer.fromJson<String?>(json['metadataNotes']),
      uploadedAt: serializer.fromJson<DateTime>(json['uploadedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'societyId': serializer.toJson<String?>(societyId),
      'category': serializer.toJson<String>(category),
      'title': serializer.toJson<String>(title),
      'referenceNumber': serializer.toJson<String?>(referenceNumber),
      'effectiveDate': serializer.toJson<DateTime?>(effectiveDate),
      'expiryDate': serializer.toJson<DateTime?>(expiryDate),
      'encryptedFilePath': serializer.toJson<String>(encryptedFilePath),
      'fileChecksum': serializer.toJson<String>(fileChecksum),
      'fileSizeBytes': serializer.toJson<int?>(fileSizeBytes),
      'originalFileName': serializer.toJson<String?>(originalFileName),
      'metadataNotes': serializer.toJson<String?>(metadataNotes),
      'uploadedAt': serializer.toJson<DateTime>(uploadedAt),
    };
  }

  ConfidentialVaultData copyWith(
          {String? id,
          Value<String?> societyId = const Value.absent(),
          String? category,
          String? title,
          Value<String?> referenceNumber = const Value.absent(),
          Value<DateTime?> effectiveDate = const Value.absent(),
          Value<DateTime?> expiryDate = const Value.absent(),
          String? encryptedFilePath,
          String? fileChecksum,
          Value<int?> fileSizeBytes = const Value.absent(),
          Value<String?> originalFileName = const Value.absent(),
          Value<String?> metadataNotes = const Value.absent(),
          DateTime? uploadedAt}) =>
      ConfidentialVaultData(
        id: id ?? this.id,
        societyId: societyId.present ? societyId.value : this.societyId,
        category: category ?? this.category,
        title: title ?? this.title,
        referenceNumber: referenceNumber.present
            ? referenceNumber.value
            : this.referenceNumber,
        effectiveDate:
            effectiveDate.present ? effectiveDate.value : this.effectiveDate,
        expiryDate: expiryDate.present ? expiryDate.value : this.expiryDate,
        encryptedFilePath: encryptedFilePath ?? this.encryptedFilePath,
        fileChecksum: fileChecksum ?? this.fileChecksum,
        fileSizeBytes:
            fileSizeBytes.present ? fileSizeBytes.value : this.fileSizeBytes,
        originalFileName: originalFileName.present
            ? originalFileName.value
            : this.originalFileName,
        metadataNotes:
            metadataNotes.present ? metadataNotes.value : this.metadataNotes,
        uploadedAt: uploadedAt ?? this.uploadedAt,
      );
  ConfidentialVaultData copyWithCompanion(ConfidentialVaultCompanion data) {
    return ConfidentialVaultData(
      id: data.id.present ? data.id.value : this.id,
      societyId: data.societyId.present ? data.societyId.value : this.societyId,
      category: data.category.present ? data.category.value : this.category,
      title: data.title.present ? data.title.value : this.title,
      referenceNumber: data.referenceNumber.present
          ? data.referenceNumber.value
          : this.referenceNumber,
      effectiveDate: data.effectiveDate.present
          ? data.effectiveDate.value
          : this.effectiveDate,
      expiryDate:
          data.expiryDate.present ? data.expiryDate.value : this.expiryDate,
      encryptedFilePath: data.encryptedFilePath.present
          ? data.encryptedFilePath.value
          : this.encryptedFilePath,
      fileChecksum: data.fileChecksum.present
          ? data.fileChecksum.value
          : this.fileChecksum,
      fileSizeBytes: data.fileSizeBytes.present
          ? data.fileSizeBytes.value
          : this.fileSizeBytes,
      originalFileName: data.originalFileName.present
          ? data.originalFileName.value
          : this.originalFileName,
      metadataNotes: data.metadataNotes.present
          ? data.metadataNotes.value
          : this.metadataNotes,
      uploadedAt:
          data.uploadedAt.present ? data.uploadedAt.value : this.uploadedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ConfidentialVaultData(')
          ..write('id: $id, ')
          ..write('societyId: $societyId, ')
          ..write('category: $category, ')
          ..write('title: $title, ')
          ..write('referenceNumber: $referenceNumber, ')
          ..write('effectiveDate: $effectiveDate, ')
          ..write('expiryDate: $expiryDate, ')
          ..write('encryptedFilePath: $encryptedFilePath, ')
          ..write('fileChecksum: $fileChecksum, ')
          ..write('fileSizeBytes: $fileSizeBytes, ')
          ..write('originalFileName: $originalFileName, ')
          ..write('metadataNotes: $metadataNotes, ')
          ..write('uploadedAt: $uploadedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      societyId,
      category,
      title,
      referenceNumber,
      effectiveDate,
      expiryDate,
      encryptedFilePath,
      fileChecksum,
      fileSizeBytes,
      originalFileName,
      metadataNotes,
      uploadedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ConfidentialVaultData &&
          other.id == this.id &&
          other.societyId == this.societyId &&
          other.category == this.category &&
          other.title == this.title &&
          other.referenceNumber == this.referenceNumber &&
          other.effectiveDate == this.effectiveDate &&
          other.expiryDate == this.expiryDate &&
          other.encryptedFilePath == this.encryptedFilePath &&
          other.fileChecksum == this.fileChecksum &&
          other.fileSizeBytes == this.fileSizeBytes &&
          other.originalFileName == this.originalFileName &&
          other.metadataNotes == this.metadataNotes &&
          other.uploadedAt == this.uploadedAt);
}

class ConfidentialVaultCompanion
    extends UpdateCompanion<ConfidentialVaultData> {
  final Value<String> id;
  final Value<String?> societyId;
  final Value<String> category;
  final Value<String> title;
  final Value<String?> referenceNumber;
  final Value<DateTime?> effectiveDate;
  final Value<DateTime?> expiryDate;
  final Value<String> encryptedFilePath;
  final Value<String> fileChecksum;
  final Value<int?> fileSizeBytes;
  final Value<String?> originalFileName;
  final Value<String?> metadataNotes;
  final Value<DateTime> uploadedAt;
  final Value<int> rowid;
  const ConfidentialVaultCompanion({
    this.id = const Value.absent(),
    this.societyId = const Value.absent(),
    this.category = const Value.absent(),
    this.title = const Value.absent(),
    this.referenceNumber = const Value.absent(),
    this.effectiveDate = const Value.absent(),
    this.expiryDate = const Value.absent(),
    this.encryptedFilePath = const Value.absent(),
    this.fileChecksum = const Value.absent(),
    this.fileSizeBytes = const Value.absent(),
    this.originalFileName = const Value.absent(),
    this.metadataNotes = const Value.absent(),
    this.uploadedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ConfidentialVaultCompanion.insert({
    required String id,
    this.societyId = const Value.absent(),
    required String category,
    required String title,
    this.referenceNumber = const Value.absent(),
    this.effectiveDate = const Value.absent(),
    this.expiryDate = const Value.absent(),
    required String encryptedFilePath,
    required String fileChecksum,
    this.fileSizeBytes = const Value.absent(),
    this.originalFileName = const Value.absent(),
    this.metadataNotes = const Value.absent(),
    this.uploadedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        category = Value(category),
        title = Value(title),
        encryptedFilePath = Value(encryptedFilePath),
        fileChecksum = Value(fileChecksum);
  static Insertable<ConfidentialVaultData> custom({
    Expression<String>? id,
    Expression<String>? societyId,
    Expression<String>? category,
    Expression<String>? title,
    Expression<String>? referenceNumber,
    Expression<DateTime>? effectiveDate,
    Expression<DateTime>? expiryDate,
    Expression<String>? encryptedFilePath,
    Expression<String>? fileChecksum,
    Expression<int>? fileSizeBytes,
    Expression<String>? originalFileName,
    Expression<String>? metadataNotes,
    Expression<DateTime>? uploadedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (societyId != null) 'society_id': societyId,
      if (category != null) 'category': category,
      if (title != null) 'title': title,
      if (referenceNumber != null) 'reference_number': referenceNumber,
      if (effectiveDate != null) 'effective_date': effectiveDate,
      if (expiryDate != null) 'expiry_date': expiryDate,
      if (encryptedFilePath != null) 'encrypted_file_path': encryptedFilePath,
      if (fileChecksum != null) 'file_checksum': fileChecksum,
      if (fileSizeBytes != null) 'file_size_bytes': fileSizeBytes,
      if (originalFileName != null) 'original_file_name': originalFileName,
      if (metadataNotes != null) 'metadata_notes': metadataNotes,
      if (uploadedAt != null) 'uploaded_at': uploadedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ConfidentialVaultCompanion copyWith(
      {Value<String>? id,
      Value<String?>? societyId,
      Value<String>? category,
      Value<String>? title,
      Value<String?>? referenceNumber,
      Value<DateTime?>? effectiveDate,
      Value<DateTime?>? expiryDate,
      Value<String>? encryptedFilePath,
      Value<String>? fileChecksum,
      Value<int?>? fileSizeBytes,
      Value<String?>? originalFileName,
      Value<String?>? metadataNotes,
      Value<DateTime>? uploadedAt,
      Value<int>? rowid}) {
    return ConfidentialVaultCompanion(
      id: id ?? this.id,
      societyId: societyId ?? this.societyId,
      category: category ?? this.category,
      title: title ?? this.title,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      effectiveDate: effectiveDate ?? this.effectiveDate,
      expiryDate: expiryDate ?? this.expiryDate,
      encryptedFilePath: encryptedFilePath ?? this.encryptedFilePath,
      fileChecksum: fileChecksum ?? this.fileChecksum,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      originalFileName: originalFileName ?? this.originalFileName,
      metadataNotes: metadataNotes ?? this.metadataNotes,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (societyId.present) {
      map['society_id'] = Variable<String>(societyId.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (referenceNumber.present) {
      map['reference_number'] = Variable<String>(referenceNumber.value);
    }
    if (effectiveDate.present) {
      map['effective_date'] = Variable<DateTime>(effectiveDate.value);
    }
    if (expiryDate.present) {
      map['expiry_date'] = Variable<DateTime>(expiryDate.value);
    }
    if (encryptedFilePath.present) {
      map['encrypted_file_path'] = Variable<String>(encryptedFilePath.value);
    }
    if (fileChecksum.present) {
      map['file_checksum'] = Variable<String>(fileChecksum.value);
    }
    if (fileSizeBytes.present) {
      map['file_size_bytes'] = Variable<int>(fileSizeBytes.value);
    }
    if (originalFileName.present) {
      map['original_file_name'] = Variable<String>(originalFileName.value);
    }
    if (metadataNotes.present) {
      map['metadata_notes'] = Variable<String>(metadataNotes.value);
    }
    if (uploadedAt.present) {
      map['uploaded_at'] = Variable<DateTime>(uploadedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConfidentialVaultCompanion(')
          ..write('id: $id, ')
          ..write('societyId: $societyId, ')
          ..write('category: $category, ')
          ..write('title: $title, ')
          ..write('referenceNumber: $referenceNumber, ')
          ..write('effectiveDate: $effectiveDate, ')
          ..write('expiryDate: $expiryDate, ')
          ..write('encryptedFilePath: $encryptedFilePath, ')
          ..write('fileChecksum: $fileChecksum, ')
          ..write('fileSizeBytes: $fileSizeBytes, ')
          ..write('originalFileName: $originalFileName, ')
          ..write('metadataNotes: $metadataNotes, ')
          ..write('uploadedAt: $uploadedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SocietiesTable societies = $SocietiesTable(this);
  late final $CabinetMembersTable cabinetMembers = $CabinetMembersTable(this);
  late final $SocietyMembersTable societyMembers = $SocietyMembersTable(this);
  late final $EventsTable events = $EventsTable(this);
  late final $EventSpeakersTable eventSpeakers = $EventSpeakersTable(this);
  late final $AchievementsTable achievements = $AchievementsTable(this);
  late final $FinancialRecordsTable financialRecords =
      $FinancialRecordsTable(this);
  late final $ConfidentialVaultTable confidentialVault =
      $ConfidentialVaultTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        societies,
        cabinetMembers,
        societyMembers,
        events,
        eventSpeakers,
        achievements,
        financialRecords,
        confidentialVault
      ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('societies',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('cabinet_members', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('societies',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('society_members', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('societies',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('events', kind: UpdateKind.update),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('events',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('event_speakers', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('societies',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('achievements', kind: UpdateKind.update),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('societies',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('confidential_vault', kind: UpdateKind.update),
            ],
          ),
        ],
      );
}

typedef $$SocietiesTableCreateCompanionBuilder = SocietiesCompanion Function({
  required String id,
  required String name,
  Value<String?> acronym,
  required String pillar,
  required String facultyAdvisor,
  Value<String?> logoPath,
  Value<bool> isActive,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$SocietiesTableUpdateCompanionBuilder = SocietiesCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String?> acronym,
  Value<String> pillar,
  Value<String> facultyAdvisor,
  Value<String?> logoPath,
  Value<bool> isActive,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$SocietiesTableReferences
    extends BaseReferences<_$AppDatabase, $SocietiesTable, Society> {
  $$SocietiesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CabinetMembersTable, List<CabinetMember>>
      _cabinetMembersRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.cabinetMembers,
              aliasName: $_aliasNameGenerator(
                  db.societies.id, db.cabinetMembers.societyId));

  $$CabinetMembersTableProcessedTableManager get cabinetMembersRefs {
    final manager = $$CabinetMembersTableTableManager($_db, $_db.cabinetMembers)
        .filter((f) => f.societyId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_cabinetMembersRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$SocietyMembersTable, List<SocietyMember>>
      _societyMembersRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.societyMembers,
              aliasName: $_aliasNameGenerator(
                  db.societies.id, db.societyMembers.societyId));

  $$SocietyMembersTableProcessedTableManager get societyMembersRefs {
    final manager = $$SocietyMembersTableTableManager($_db, $_db.societyMembers)
        .filter((f) => f.societyId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_societyMembersRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$EventsTable, List<Event>> _eventsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.events,
          aliasName:
              $_aliasNameGenerator(db.societies.id, db.events.societyId));

  $$EventsTableProcessedTableManager get eventsRefs {
    final manager = $$EventsTableTableManager($_db, $_db.events)
        .filter((f) => f.societyId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_eventsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$AchievementsTable, List<Achievement>>
      _achievementsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.achievements,
          aliasName:
              $_aliasNameGenerator(db.societies.id, db.achievements.societyId));

  $$AchievementsTableProcessedTableManager get achievementsRefs {
    final manager = $$AchievementsTableTableManager($_db, $_db.achievements)
        .filter((f) => f.societyId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_achievementsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ConfidentialVaultTable,
      List<ConfidentialVaultData>> _confidentialVaultRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.confidentialVault,
          aliasName: $_aliasNameGenerator(
              db.societies.id, db.confidentialVault.societyId));

  $$ConfidentialVaultTableProcessedTableManager get confidentialVaultRefs {
    final manager = $$ConfidentialVaultTableTableManager(
            $_db, $_db.confidentialVault)
        .filter((f) => f.societyId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_confidentialVaultRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$SocietiesTableFilterComposer
    extends Composer<_$AppDatabase, $SocietiesTable> {
  $$SocietiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get acronym => $composableBuilder(
      column: $table.acronym, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get pillar => $composableBuilder(
      column: $table.pillar, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get facultyAdvisor => $composableBuilder(
      column: $table.facultyAdvisor,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get logoPath => $composableBuilder(
      column: $table.logoPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  Expression<bool> cabinetMembersRefs(
      Expression<bool> Function($$CabinetMembersTableFilterComposer f) f) {
    final $$CabinetMembersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.cabinetMembers,
        getReferencedColumn: (t) => t.societyId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CabinetMembersTableFilterComposer(
              $db: $db,
              $table: $db.cabinetMembers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> societyMembersRefs(
      Expression<bool> Function($$SocietyMembersTableFilterComposer f) f) {
    final $$SocietyMembersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.societyMembers,
        getReferencedColumn: (t) => t.societyId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SocietyMembersTableFilterComposer(
              $db: $db,
              $table: $db.societyMembers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> eventsRefs(
      Expression<bool> Function($$EventsTableFilterComposer f) f) {
    final $$EventsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.events,
        getReferencedColumn: (t) => t.societyId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EventsTableFilterComposer(
              $db: $db,
              $table: $db.events,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> achievementsRefs(
      Expression<bool> Function($$AchievementsTableFilterComposer f) f) {
    final $$AchievementsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.achievements,
        getReferencedColumn: (t) => t.societyId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AchievementsTableFilterComposer(
              $db: $db,
              $table: $db.achievements,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> confidentialVaultRefs(
      Expression<bool> Function($$ConfidentialVaultTableFilterComposer f) f) {
    final $$ConfidentialVaultTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.confidentialVault,
        getReferencedColumn: (t) => t.societyId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ConfidentialVaultTableFilterComposer(
              $db: $db,
              $table: $db.confidentialVault,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SocietiesTableOrderingComposer
    extends Composer<_$AppDatabase, $SocietiesTable> {
  $$SocietiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get acronym => $composableBuilder(
      column: $table.acronym, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get pillar => $composableBuilder(
      column: $table.pillar, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get facultyAdvisor => $composableBuilder(
      column: $table.facultyAdvisor,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get logoPath => $composableBuilder(
      column: $table.logoPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$SocietiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SocietiesTable> {
  $$SocietiesTableAnnotationComposer({
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

  GeneratedColumn<String> get acronym =>
      $composableBuilder(column: $table.acronym, builder: (column) => column);

  GeneratedColumn<String> get pillar =>
      $composableBuilder(column: $table.pillar, builder: (column) => column);

  GeneratedColumn<String> get facultyAdvisor => $composableBuilder(
      column: $table.facultyAdvisor, builder: (column) => column);

  GeneratedColumn<String> get logoPath =>
      $composableBuilder(column: $table.logoPath, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> cabinetMembersRefs<T extends Object>(
      Expression<T> Function($$CabinetMembersTableAnnotationComposer a) f) {
    final $$CabinetMembersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.cabinetMembers,
        getReferencedColumn: (t) => t.societyId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CabinetMembersTableAnnotationComposer(
              $db: $db,
              $table: $db.cabinetMembers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> societyMembersRefs<T extends Object>(
      Expression<T> Function($$SocietyMembersTableAnnotationComposer a) f) {
    final $$SocietyMembersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.societyMembers,
        getReferencedColumn: (t) => t.societyId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SocietyMembersTableAnnotationComposer(
              $db: $db,
              $table: $db.societyMembers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> eventsRefs<T extends Object>(
      Expression<T> Function($$EventsTableAnnotationComposer a) f) {
    final $$EventsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.events,
        getReferencedColumn: (t) => t.societyId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EventsTableAnnotationComposer(
              $db: $db,
              $table: $db.events,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> achievementsRefs<T extends Object>(
      Expression<T> Function($$AchievementsTableAnnotationComposer a) f) {
    final $$AchievementsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.achievements,
        getReferencedColumn: (t) => t.societyId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AchievementsTableAnnotationComposer(
              $db: $db,
              $table: $db.achievements,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> confidentialVaultRefs<T extends Object>(
      Expression<T> Function($$ConfidentialVaultTableAnnotationComposer a) f) {
    final $$ConfidentialVaultTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.confidentialVault,
            getReferencedColumn: (t) => t.societyId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$ConfidentialVaultTableAnnotationComposer(
                  $db: $db,
                  $table: $db.confidentialVault,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$SocietiesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SocietiesTable,
    Society,
    $$SocietiesTableFilterComposer,
    $$SocietiesTableOrderingComposer,
    $$SocietiesTableAnnotationComposer,
    $$SocietiesTableCreateCompanionBuilder,
    $$SocietiesTableUpdateCompanionBuilder,
    (Society, $$SocietiesTableReferences),
    Society,
    PrefetchHooks Function(
        {bool cabinetMembersRefs,
        bool societyMembersRefs,
        bool eventsRefs,
        bool achievementsRefs,
        bool confidentialVaultRefs})> {
  $$SocietiesTableTableManager(_$AppDatabase db, $SocietiesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SocietiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SocietiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SocietiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> acronym = const Value.absent(),
            Value<String> pillar = const Value.absent(),
            Value<String> facultyAdvisor = const Value.absent(),
            Value<String?> logoPath = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SocietiesCompanion(
            id: id,
            name: name,
            acronym: acronym,
            pillar: pillar,
            facultyAdvisor: facultyAdvisor,
            logoPath: logoPath,
            isActive: isActive,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String?> acronym = const Value.absent(),
            required String pillar,
            required String facultyAdvisor,
            Value<String?> logoPath = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SocietiesCompanion.insert(
            id: id,
            name: name,
            acronym: acronym,
            pillar: pillar,
            facultyAdvisor: facultyAdvisor,
            logoPath: logoPath,
            isActive: isActive,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$SocietiesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {cabinetMembersRefs = false,
              societyMembersRefs = false,
              eventsRefs = false,
              achievementsRefs = false,
              confidentialVaultRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (cabinetMembersRefs) db.cabinetMembers,
                if (societyMembersRefs) db.societyMembers,
                if (eventsRefs) db.events,
                if (achievementsRefs) db.achievements,
                if (confidentialVaultRefs) db.confidentialVault
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (cabinetMembersRefs)
                    await $_getPrefetchedData<Society, $SocietiesTable,
                            CabinetMember>(
                        currentTable: table,
                        referencedTable: $$SocietiesTableReferences
                            ._cabinetMembersRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SocietiesTableReferences(db, table, p0)
                                .cabinetMembersRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.societyId == item.id),
                        typedResults: items),
                  if (societyMembersRefs)
                    await $_getPrefetchedData<Society, $SocietiesTable,
                            SocietyMember>(
                        currentTable: table,
                        referencedTable: $$SocietiesTableReferences
                            ._societyMembersRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SocietiesTableReferences(db, table, p0)
                                .societyMembersRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.societyId == item.id),
                        typedResults: items),
                  if (eventsRefs)
                    await $_getPrefetchedData<Society, $SocietiesTable, Event>(
                        currentTable: table,
                        referencedTable:
                            $$SocietiesTableReferences._eventsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SocietiesTableReferences(db, table, p0)
                                .eventsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.societyId == item.id),
                        typedResults: items),
                  if (achievementsRefs)
                    await $_getPrefetchedData<Society, $SocietiesTable,
                            Achievement>(
                        currentTable: table,
                        referencedTable: $$SocietiesTableReferences
                            ._achievementsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SocietiesTableReferences(db, table, p0)
                                .achievementsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.societyId == item.id),
                        typedResults: items),
                  if (confidentialVaultRefs)
                    await $_getPrefetchedData<Society, $SocietiesTable,
                            ConfidentialVaultData>(
                        currentTable: table,
                        referencedTable: $$SocietiesTableReferences
                            ._confidentialVaultRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SocietiesTableReferences(db, table, p0)
                                .confidentialVaultRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.societyId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$SocietiesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SocietiesTable,
    Society,
    $$SocietiesTableFilterComposer,
    $$SocietiesTableOrderingComposer,
    $$SocietiesTableAnnotationComposer,
    $$SocietiesTableCreateCompanionBuilder,
    $$SocietiesTableUpdateCompanionBuilder,
    (Society, $$SocietiesTableReferences),
    Society,
    PrefetchHooks Function(
        {bool cabinetMembersRefs,
        bool societyMembersRefs,
        bool eventsRefs,
        bool achievementsRefs,
        bool confidentialVaultRefs})>;
typedef $$CabinetMembersTableCreateCompanionBuilder = CabinetMembersCompanion
    Function({
  required String id,
  required String societyId,
  required String tenureSession,
  required String role,
  required String fullName,
  required String cnic,
  required String email,
  required String phone,
  required String department,
  required int semester,
  Value<bool> isActive,
  Value<int> rowid,
});
typedef $$CabinetMembersTableUpdateCompanionBuilder = CabinetMembersCompanion
    Function({
  Value<String> id,
  Value<String> societyId,
  Value<String> tenureSession,
  Value<String> role,
  Value<String> fullName,
  Value<String> cnic,
  Value<String> email,
  Value<String> phone,
  Value<String> department,
  Value<int> semester,
  Value<bool> isActive,
  Value<int> rowid,
});

final class $$CabinetMembersTableReferences
    extends BaseReferences<_$AppDatabase, $CabinetMembersTable, CabinetMember> {
  $$CabinetMembersTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $SocietiesTable _societyIdTable(_$AppDatabase db) =>
      db.societies.createAlias(
          $_aliasNameGenerator(db.cabinetMembers.societyId, db.societies.id));

  $$SocietiesTableProcessedTableManager get societyId {
    final $_column = $_itemColumn<String>('society_id')!;

    final manager = $$SocietiesTableTableManager($_db, $_db.societies)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_societyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$CabinetMembersTableFilterComposer
    extends Composer<_$AppDatabase, $CabinetMembersTable> {
  $$CabinetMembersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tenureSession => $composableBuilder(
      column: $table.tenureSession, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fullName => $composableBuilder(
      column: $table.fullName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cnic => $composableBuilder(
      column: $table.cnic, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get department => $composableBuilder(
      column: $table.department, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get semester => $composableBuilder(
      column: $table.semester, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  $$SocietiesTableFilterComposer get societyId {
    final $$SocietiesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.societyId,
        referencedTable: $db.societies,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SocietiesTableFilterComposer(
              $db: $db,
              $table: $db.societies,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$CabinetMembersTableOrderingComposer
    extends Composer<_$AppDatabase, $CabinetMembersTable> {
  $$CabinetMembersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tenureSession => $composableBuilder(
      column: $table.tenureSession,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fullName => $composableBuilder(
      column: $table.fullName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cnic => $composableBuilder(
      column: $table.cnic, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get department => $composableBuilder(
      column: $table.department, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get semester => $composableBuilder(
      column: $table.semester, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  $$SocietiesTableOrderingComposer get societyId {
    final $$SocietiesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.societyId,
        referencedTable: $db.societies,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SocietiesTableOrderingComposer(
              $db: $db,
              $table: $db.societies,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$CabinetMembersTableAnnotationComposer
    extends Composer<_$AppDatabase, $CabinetMembersTable> {
  $$CabinetMembersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tenureSession => $composableBuilder(
      column: $table.tenureSession, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get fullName =>
      $composableBuilder(column: $table.fullName, builder: (column) => column);

  GeneratedColumn<String> get cnic =>
      $composableBuilder(column: $table.cnic, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get department => $composableBuilder(
      column: $table.department, builder: (column) => column);

  GeneratedColumn<int> get semester =>
      $composableBuilder(column: $table.semester, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  $$SocietiesTableAnnotationComposer get societyId {
    final $$SocietiesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.societyId,
        referencedTable: $db.societies,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SocietiesTableAnnotationComposer(
              $db: $db,
              $table: $db.societies,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$CabinetMembersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CabinetMembersTable,
    CabinetMember,
    $$CabinetMembersTableFilterComposer,
    $$CabinetMembersTableOrderingComposer,
    $$CabinetMembersTableAnnotationComposer,
    $$CabinetMembersTableCreateCompanionBuilder,
    $$CabinetMembersTableUpdateCompanionBuilder,
    (CabinetMember, $$CabinetMembersTableReferences),
    CabinetMember,
    PrefetchHooks Function({bool societyId})> {
  $$CabinetMembersTableTableManager(
      _$AppDatabase db, $CabinetMembersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CabinetMembersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CabinetMembersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CabinetMembersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> societyId = const Value.absent(),
            Value<String> tenureSession = const Value.absent(),
            Value<String> role = const Value.absent(),
            Value<String> fullName = const Value.absent(),
            Value<String> cnic = const Value.absent(),
            Value<String> email = const Value.absent(),
            Value<String> phone = const Value.absent(),
            Value<String> department = const Value.absent(),
            Value<int> semester = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CabinetMembersCompanion(
            id: id,
            societyId: societyId,
            tenureSession: tenureSession,
            role: role,
            fullName: fullName,
            cnic: cnic,
            email: email,
            phone: phone,
            department: department,
            semester: semester,
            isActive: isActive,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String societyId,
            required String tenureSession,
            required String role,
            required String fullName,
            required String cnic,
            required String email,
            required String phone,
            required String department,
            required int semester,
            Value<bool> isActive = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CabinetMembersCompanion.insert(
            id: id,
            societyId: societyId,
            tenureSession: tenureSession,
            role: role,
            fullName: fullName,
            cnic: cnic,
            email: email,
            phone: phone,
            department: department,
            semester: semester,
            isActive: isActive,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$CabinetMembersTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({societyId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (societyId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.societyId,
                    referencedTable:
                        $$CabinetMembersTableReferences._societyIdTable(db),
                    referencedColumn:
                        $$CabinetMembersTableReferences._societyIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$CabinetMembersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CabinetMembersTable,
    CabinetMember,
    $$CabinetMembersTableFilterComposer,
    $$CabinetMembersTableOrderingComposer,
    $$CabinetMembersTableAnnotationComposer,
    $$CabinetMembersTableCreateCompanionBuilder,
    $$CabinetMembersTableUpdateCompanionBuilder,
    (CabinetMember, $$CabinetMembersTableReferences),
    CabinetMember,
    PrefetchHooks Function({bool societyId})>;
typedef $$SocietyMembersTableCreateCompanionBuilder = SocietyMembersCompanion
    Function({
  required String id,
  required String societyId,
  required String fullName,
  required String rollNo,
  required String cnic,
  Value<String?> email,
  Value<String?> phone,
  required String department,
  required int semester,
  Value<DateTime> joinedDate,
  Value<bool> isActive,
  Value<int> rowid,
});
typedef $$SocietyMembersTableUpdateCompanionBuilder = SocietyMembersCompanion
    Function({
  Value<String> id,
  Value<String> societyId,
  Value<String> fullName,
  Value<String> rollNo,
  Value<String> cnic,
  Value<String?> email,
  Value<String?> phone,
  Value<String> department,
  Value<int> semester,
  Value<DateTime> joinedDate,
  Value<bool> isActive,
  Value<int> rowid,
});

final class $$SocietyMembersTableReferences
    extends BaseReferences<_$AppDatabase, $SocietyMembersTable, SocietyMember> {
  $$SocietyMembersTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $SocietiesTable _societyIdTable(_$AppDatabase db) =>
      db.societies.createAlias(
          $_aliasNameGenerator(db.societyMembers.societyId, db.societies.id));

  $$SocietiesTableProcessedTableManager get societyId {
    final $_column = $_itemColumn<String>('society_id')!;

    final manager = $$SocietiesTableTableManager($_db, $_db.societies)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_societyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$SocietyMembersTableFilterComposer
    extends Composer<_$AppDatabase, $SocietyMembersTable> {
  $$SocietyMembersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fullName => $composableBuilder(
      column: $table.fullName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rollNo => $composableBuilder(
      column: $table.rollNo, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cnic => $composableBuilder(
      column: $table.cnic, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get department => $composableBuilder(
      column: $table.department, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get semester => $composableBuilder(
      column: $table.semester, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get joinedDate => $composableBuilder(
      column: $table.joinedDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  $$SocietiesTableFilterComposer get societyId {
    final $$SocietiesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.societyId,
        referencedTable: $db.societies,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SocietiesTableFilterComposer(
              $db: $db,
              $table: $db.societies,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SocietyMembersTableOrderingComposer
    extends Composer<_$AppDatabase, $SocietyMembersTable> {
  $$SocietyMembersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fullName => $composableBuilder(
      column: $table.fullName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rollNo => $composableBuilder(
      column: $table.rollNo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cnic => $composableBuilder(
      column: $table.cnic, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get department => $composableBuilder(
      column: $table.department, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get semester => $composableBuilder(
      column: $table.semester, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get joinedDate => $composableBuilder(
      column: $table.joinedDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  $$SocietiesTableOrderingComposer get societyId {
    final $$SocietiesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.societyId,
        referencedTable: $db.societies,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SocietiesTableOrderingComposer(
              $db: $db,
              $table: $db.societies,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SocietyMembersTableAnnotationComposer
    extends Composer<_$AppDatabase, $SocietyMembersTable> {
  $$SocietyMembersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get fullName =>
      $composableBuilder(column: $table.fullName, builder: (column) => column);

  GeneratedColumn<String> get rollNo =>
      $composableBuilder(column: $table.rollNo, builder: (column) => column);

  GeneratedColumn<String> get cnic =>
      $composableBuilder(column: $table.cnic, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get department => $composableBuilder(
      column: $table.department, builder: (column) => column);

  GeneratedColumn<int> get semester =>
      $composableBuilder(column: $table.semester, builder: (column) => column);

  GeneratedColumn<DateTime> get joinedDate => $composableBuilder(
      column: $table.joinedDate, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  $$SocietiesTableAnnotationComposer get societyId {
    final $$SocietiesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.societyId,
        referencedTable: $db.societies,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SocietiesTableAnnotationComposer(
              $db: $db,
              $table: $db.societies,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SocietyMembersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SocietyMembersTable,
    SocietyMember,
    $$SocietyMembersTableFilterComposer,
    $$SocietyMembersTableOrderingComposer,
    $$SocietyMembersTableAnnotationComposer,
    $$SocietyMembersTableCreateCompanionBuilder,
    $$SocietyMembersTableUpdateCompanionBuilder,
    (SocietyMember, $$SocietyMembersTableReferences),
    SocietyMember,
    PrefetchHooks Function({bool societyId})> {
  $$SocietyMembersTableTableManager(
      _$AppDatabase db, $SocietyMembersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SocietyMembersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SocietyMembersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SocietyMembersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> societyId = const Value.absent(),
            Value<String> fullName = const Value.absent(),
            Value<String> rollNo = const Value.absent(),
            Value<String> cnic = const Value.absent(),
            Value<String?> email = const Value.absent(),
            Value<String?> phone = const Value.absent(),
            Value<String> department = const Value.absent(),
            Value<int> semester = const Value.absent(),
            Value<DateTime> joinedDate = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SocietyMembersCompanion(
            id: id,
            societyId: societyId,
            fullName: fullName,
            rollNo: rollNo,
            cnic: cnic,
            email: email,
            phone: phone,
            department: department,
            semester: semester,
            joinedDate: joinedDate,
            isActive: isActive,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String societyId,
            required String fullName,
            required String rollNo,
            required String cnic,
            Value<String?> email = const Value.absent(),
            Value<String?> phone = const Value.absent(),
            required String department,
            required int semester,
            Value<DateTime> joinedDate = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SocietyMembersCompanion.insert(
            id: id,
            societyId: societyId,
            fullName: fullName,
            rollNo: rollNo,
            cnic: cnic,
            email: email,
            phone: phone,
            department: department,
            semester: semester,
            joinedDate: joinedDate,
            isActive: isActive,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$SocietyMembersTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({societyId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (societyId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.societyId,
                    referencedTable:
                        $$SocietyMembersTableReferences._societyIdTable(db),
                    referencedColumn:
                        $$SocietyMembersTableReferences._societyIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$SocietyMembersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SocietyMembersTable,
    SocietyMember,
    $$SocietyMembersTableFilterComposer,
    $$SocietyMembersTableOrderingComposer,
    $$SocietyMembersTableAnnotationComposer,
    $$SocietyMembersTableCreateCompanionBuilder,
    $$SocietyMembersTableUpdateCompanionBuilder,
    (SocietyMember, $$SocietyMembersTableReferences),
    SocietyMember,
    PrefetchHooks Function({bool societyId})>;
typedef $$EventsTableCreateCompanionBuilder = EventsCompanion Function({
  required String id,
  required String title,
  required String description,
  required DateTime eventDate,
  Value<String?> societyId,
  Value<bool> isCollaboration,
  Value<String?> collaboratorNames,
  Value<String?> venue,
  Value<double> allocatedBudget,
  Value<double> actualExpense,
  Value<String?> positiveImpactSummary,
  Value<int> attendeesCount,
  Value<String?> bannerImagePath,
  Value<String?> imagePaths,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$EventsTableUpdateCompanionBuilder = EventsCompanion Function({
  Value<String> id,
  Value<String> title,
  Value<String> description,
  Value<DateTime> eventDate,
  Value<String?> societyId,
  Value<bool> isCollaboration,
  Value<String?> collaboratorNames,
  Value<String?> venue,
  Value<double> allocatedBudget,
  Value<double> actualExpense,
  Value<String?> positiveImpactSummary,
  Value<int> attendeesCount,
  Value<String?> bannerImagePath,
  Value<String?> imagePaths,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$EventsTableReferences
    extends BaseReferences<_$AppDatabase, $EventsTable, Event> {
  $$EventsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SocietiesTable _societyIdTable(_$AppDatabase db) => db.societies
      .createAlias($_aliasNameGenerator(db.events.societyId, db.societies.id));

  $$SocietiesTableProcessedTableManager? get societyId {
    final $_column = $_itemColumn<String>('society_id');
    if ($_column == null) return null;
    final manager = $$SocietiesTableTableManager($_db, $_db.societies)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_societyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$EventSpeakersTable, List<EventSpeaker>>
      _eventSpeakersRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.eventSpeakers,
              aliasName:
                  $_aliasNameGenerator(db.events.id, db.eventSpeakers.eventId));

  $$EventSpeakersTableProcessedTableManager get eventSpeakersRefs {
    final manager = $$EventSpeakersTableTableManager($_db, $_db.eventSpeakers)
        .filter((f) => f.eventId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_eventSpeakersRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$EventsTableFilterComposer
    extends Composer<_$AppDatabase, $EventsTable> {
  $$EventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get eventDate => $composableBuilder(
      column: $table.eventDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isCollaboration => $composableBuilder(
      column: $table.isCollaboration,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get collaboratorNames => $composableBuilder(
      column: $table.collaboratorNames,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get venue => $composableBuilder(
      column: $table.venue, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get allocatedBudget => $composableBuilder(
      column: $table.allocatedBudget,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get actualExpense => $composableBuilder(
      column: $table.actualExpense, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get positiveImpactSummary => $composableBuilder(
      column: $table.positiveImpactSummary,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get attendeesCount => $composableBuilder(
      column: $table.attendeesCount,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bannerImagePath => $composableBuilder(
      column: $table.bannerImagePath,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imagePaths => $composableBuilder(
      column: $table.imagePaths, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$SocietiesTableFilterComposer get societyId {
    final $$SocietiesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.societyId,
        referencedTable: $db.societies,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SocietiesTableFilterComposer(
              $db: $db,
              $table: $db.societies,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> eventSpeakersRefs(
      Expression<bool> Function($$EventSpeakersTableFilterComposer f) f) {
    final $$EventSpeakersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.eventSpeakers,
        getReferencedColumn: (t) => t.eventId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EventSpeakersTableFilterComposer(
              $db: $db,
              $table: $db.eventSpeakers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$EventsTableOrderingComposer
    extends Composer<_$AppDatabase, $EventsTable> {
  $$EventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get eventDate => $composableBuilder(
      column: $table.eventDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isCollaboration => $composableBuilder(
      column: $table.isCollaboration,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get collaboratorNames => $composableBuilder(
      column: $table.collaboratorNames,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get venue => $composableBuilder(
      column: $table.venue, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get allocatedBudget => $composableBuilder(
      column: $table.allocatedBudget,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get actualExpense => $composableBuilder(
      column: $table.actualExpense,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get positiveImpactSummary => $composableBuilder(
      column: $table.positiveImpactSummary,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get attendeesCount => $composableBuilder(
      column: $table.attendeesCount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bannerImagePath => $composableBuilder(
      column: $table.bannerImagePath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imagePaths => $composableBuilder(
      column: $table.imagePaths, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$SocietiesTableOrderingComposer get societyId {
    final $$SocietiesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.societyId,
        referencedTable: $db.societies,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SocietiesTableOrderingComposer(
              $db: $db,
              $table: $db.societies,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$EventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EventsTable> {
  $$EventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<DateTime> get eventDate =>
      $composableBuilder(column: $table.eventDate, builder: (column) => column);

  GeneratedColumn<bool> get isCollaboration => $composableBuilder(
      column: $table.isCollaboration, builder: (column) => column);

  GeneratedColumn<String> get collaboratorNames => $composableBuilder(
      column: $table.collaboratorNames, builder: (column) => column);

  GeneratedColumn<String> get venue =>
      $composableBuilder(column: $table.venue, builder: (column) => column);

  GeneratedColumn<double> get allocatedBudget => $composableBuilder(
      column: $table.allocatedBudget, builder: (column) => column);

  GeneratedColumn<double> get actualExpense => $composableBuilder(
      column: $table.actualExpense, builder: (column) => column);

  GeneratedColumn<String> get positiveImpactSummary => $composableBuilder(
      column: $table.positiveImpactSummary, builder: (column) => column);

  GeneratedColumn<int> get attendeesCount => $composableBuilder(
      column: $table.attendeesCount, builder: (column) => column);

  GeneratedColumn<String> get bannerImagePath => $composableBuilder(
      column: $table.bannerImagePath, builder: (column) => column);

  GeneratedColumn<String> get imagePaths => $composableBuilder(
      column: $table.imagePaths, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$SocietiesTableAnnotationComposer get societyId {
    final $$SocietiesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.societyId,
        referencedTable: $db.societies,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SocietiesTableAnnotationComposer(
              $db: $db,
              $table: $db.societies,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> eventSpeakersRefs<T extends Object>(
      Expression<T> Function($$EventSpeakersTableAnnotationComposer a) f) {
    final $$EventSpeakersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.eventSpeakers,
        getReferencedColumn: (t) => t.eventId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EventSpeakersTableAnnotationComposer(
              $db: $db,
              $table: $db.eventSpeakers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$EventsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $EventsTable,
    Event,
    $$EventsTableFilterComposer,
    $$EventsTableOrderingComposer,
    $$EventsTableAnnotationComposer,
    $$EventsTableCreateCompanionBuilder,
    $$EventsTableUpdateCompanionBuilder,
    (Event, $$EventsTableReferences),
    Event,
    PrefetchHooks Function({bool societyId, bool eventSpeakersRefs})> {
  $$EventsTableTableManager(_$AppDatabase db, $EventsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<DateTime> eventDate = const Value.absent(),
            Value<String?> societyId = const Value.absent(),
            Value<bool> isCollaboration = const Value.absent(),
            Value<String?> collaboratorNames = const Value.absent(),
            Value<String?> venue = const Value.absent(),
            Value<double> allocatedBudget = const Value.absent(),
            Value<double> actualExpense = const Value.absent(),
            Value<String?> positiveImpactSummary = const Value.absent(),
            Value<int> attendeesCount = const Value.absent(),
            Value<String?> bannerImagePath = const Value.absent(),
            Value<String?> imagePaths = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              EventsCompanion(
            id: id,
            title: title,
            description: description,
            eventDate: eventDate,
            societyId: societyId,
            isCollaboration: isCollaboration,
            collaboratorNames: collaboratorNames,
            venue: venue,
            allocatedBudget: allocatedBudget,
            actualExpense: actualExpense,
            positiveImpactSummary: positiveImpactSummary,
            attendeesCount: attendeesCount,
            bannerImagePath: bannerImagePath,
            imagePaths: imagePaths,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String title,
            required String description,
            required DateTime eventDate,
            Value<String?> societyId = const Value.absent(),
            Value<bool> isCollaboration = const Value.absent(),
            Value<String?> collaboratorNames = const Value.absent(),
            Value<String?> venue = const Value.absent(),
            Value<double> allocatedBudget = const Value.absent(),
            Value<double> actualExpense = const Value.absent(),
            Value<String?> positiveImpactSummary = const Value.absent(),
            Value<int> attendeesCount = const Value.absent(),
            Value<String?> bannerImagePath = const Value.absent(),
            Value<String?> imagePaths = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              EventsCompanion.insert(
            id: id,
            title: title,
            description: description,
            eventDate: eventDate,
            societyId: societyId,
            isCollaboration: isCollaboration,
            collaboratorNames: collaboratorNames,
            venue: venue,
            allocatedBudget: allocatedBudget,
            actualExpense: actualExpense,
            positiveImpactSummary: positiveImpactSummary,
            attendeesCount: attendeesCount,
            bannerImagePath: bannerImagePath,
            imagePaths: imagePaths,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$EventsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {societyId = false, eventSpeakersRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (eventSpeakersRefs) db.eventSpeakers
              ],
              addJoins: <
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
                      dynamic>>(state) {
                if (societyId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.societyId,
                    referencedTable:
                        $$EventsTableReferences._societyIdTable(db),
                    referencedColumn:
                        $$EventsTableReferences._societyIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (eventSpeakersRefs)
                    await $_getPrefetchedData<Event, $EventsTable,
                            EventSpeaker>(
                        currentTable: table,
                        referencedTable:
                            $$EventsTableReferences._eventSpeakersRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$EventsTableReferences(db, table, p0)
                                .eventSpeakersRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.eventId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$EventsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $EventsTable,
    Event,
    $$EventsTableFilterComposer,
    $$EventsTableOrderingComposer,
    $$EventsTableAnnotationComposer,
    $$EventsTableCreateCompanionBuilder,
    $$EventsTableUpdateCompanionBuilder,
    (Event, $$EventsTableReferences),
    Event,
    PrefetchHooks Function({bool societyId, bool eventSpeakersRefs})>;
typedef $$EventSpeakersTableCreateCompanionBuilder = EventSpeakersCompanion
    Function({
  required String id,
  required String eventId,
  required String name,
  Value<String?> designation,
  required String organization,
  Value<String?> contactPhone,
  Value<String?> contactEmail,
  Value<int> rowid,
});
typedef $$EventSpeakersTableUpdateCompanionBuilder = EventSpeakersCompanion
    Function({
  Value<String> id,
  Value<String> eventId,
  Value<String> name,
  Value<String?> designation,
  Value<String> organization,
  Value<String?> contactPhone,
  Value<String?> contactEmail,
  Value<int> rowid,
});

final class $$EventSpeakersTableReferences
    extends BaseReferences<_$AppDatabase, $EventSpeakersTable, EventSpeaker> {
  $$EventSpeakersTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $EventsTable _eventIdTable(_$AppDatabase db) => db.events.createAlias(
      $_aliasNameGenerator(db.eventSpeakers.eventId, db.events.id));

  $$EventsTableProcessedTableManager get eventId {
    final $_column = $_itemColumn<String>('event_id')!;

    final manager = $$EventsTableTableManager($_db, $_db.events)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_eventIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$EventSpeakersTableFilterComposer
    extends Composer<_$AppDatabase, $EventSpeakersTable> {
  $$EventSpeakersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get designation => $composableBuilder(
      column: $table.designation, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get organization => $composableBuilder(
      column: $table.organization, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get contactPhone => $composableBuilder(
      column: $table.contactPhone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get contactEmail => $composableBuilder(
      column: $table.contactEmail, builder: (column) => ColumnFilters(column));

  $$EventsTableFilterComposer get eventId {
    final $$EventsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.eventId,
        referencedTable: $db.events,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EventsTableFilterComposer(
              $db: $db,
              $table: $db.events,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$EventSpeakersTableOrderingComposer
    extends Composer<_$AppDatabase, $EventSpeakersTable> {
  $$EventSpeakersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get designation => $composableBuilder(
      column: $table.designation, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get organization => $composableBuilder(
      column: $table.organization,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get contactPhone => $composableBuilder(
      column: $table.contactPhone,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get contactEmail => $composableBuilder(
      column: $table.contactEmail,
      builder: (column) => ColumnOrderings(column));

  $$EventsTableOrderingComposer get eventId {
    final $$EventsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.eventId,
        referencedTable: $db.events,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EventsTableOrderingComposer(
              $db: $db,
              $table: $db.events,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$EventSpeakersTableAnnotationComposer
    extends Composer<_$AppDatabase, $EventSpeakersTable> {
  $$EventSpeakersTableAnnotationComposer({
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

  GeneratedColumn<String> get designation => $composableBuilder(
      column: $table.designation, builder: (column) => column);

  GeneratedColumn<String> get organization => $composableBuilder(
      column: $table.organization, builder: (column) => column);

  GeneratedColumn<String> get contactPhone => $composableBuilder(
      column: $table.contactPhone, builder: (column) => column);

  GeneratedColumn<String> get contactEmail => $composableBuilder(
      column: $table.contactEmail, builder: (column) => column);

  $$EventsTableAnnotationComposer get eventId {
    final $$EventsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.eventId,
        referencedTable: $db.events,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$EventsTableAnnotationComposer(
              $db: $db,
              $table: $db.events,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$EventSpeakersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $EventSpeakersTable,
    EventSpeaker,
    $$EventSpeakersTableFilterComposer,
    $$EventSpeakersTableOrderingComposer,
    $$EventSpeakersTableAnnotationComposer,
    $$EventSpeakersTableCreateCompanionBuilder,
    $$EventSpeakersTableUpdateCompanionBuilder,
    (EventSpeaker, $$EventSpeakersTableReferences),
    EventSpeaker,
    PrefetchHooks Function({bool eventId})> {
  $$EventSpeakersTableTableManager(_$AppDatabase db, $EventSpeakersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EventSpeakersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EventSpeakersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EventSpeakersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> eventId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> designation = const Value.absent(),
            Value<String> organization = const Value.absent(),
            Value<String?> contactPhone = const Value.absent(),
            Value<String?> contactEmail = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              EventSpeakersCompanion(
            id: id,
            eventId: eventId,
            name: name,
            designation: designation,
            organization: organization,
            contactPhone: contactPhone,
            contactEmail: contactEmail,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String eventId,
            required String name,
            Value<String?> designation = const Value.absent(),
            required String organization,
            Value<String?> contactPhone = const Value.absent(),
            Value<String?> contactEmail = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              EventSpeakersCompanion.insert(
            id: id,
            eventId: eventId,
            name: name,
            designation: designation,
            organization: organization,
            contactPhone: contactPhone,
            contactEmail: contactEmail,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$EventSpeakersTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({eventId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (eventId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.eventId,
                    referencedTable:
                        $$EventSpeakersTableReferences._eventIdTable(db),
                    referencedColumn:
                        $$EventSpeakersTableReferences._eventIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$EventSpeakersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $EventSpeakersTable,
    EventSpeaker,
    $$EventSpeakersTableFilterComposer,
    $$EventSpeakersTableOrderingComposer,
    $$EventSpeakersTableAnnotationComposer,
    $$EventSpeakersTableCreateCompanionBuilder,
    $$EventSpeakersTableUpdateCompanionBuilder,
    (EventSpeaker, $$EventSpeakersTableReferences),
    EventSpeaker,
    PrefetchHooks Function({bool eventId})>;
typedef $$AchievementsTableCreateCompanionBuilder = AchievementsCompanion
    Function({
  required String id,
  required String monthYear,
  required String title,
  Value<String?> description,
  Value<String?> societyId,
  Value<String?> proofImagePath,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$AchievementsTableUpdateCompanionBuilder = AchievementsCompanion
    Function({
  Value<String> id,
  Value<String> monthYear,
  Value<String> title,
  Value<String?> description,
  Value<String?> societyId,
  Value<String?> proofImagePath,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$AchievementsTableReferences
    extends BaseReferences<_$AppDatabase, $AchievementsTable, Achievement> {
  $$AchievementsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SocietiesTable _societyIdTable(_$AppDatabase db) =>
      db.societies.createAlias(
          $_aliasNameGenerator(db.achievements.societyId, db.societies.id));

  $$SocietiesTableProcessedTableManager? get societyId {
    final $_column = $_itemColumn<String>('society_id');
    if ($_column == null) return null;
    final manager = $$SocietiesTableTableManager($_db, $_db.societies)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_societyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$AchievementsTableFilterComposer
    extends Composer<_$AppDatabase, $AchievementsTable> {
  $$AchievementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get monthYear => $composableBuilder(
      column: $table.monthYear, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get proofImagePath => $composableBuilder(
      column: $table.proofImagePath,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$SocietiesTableFilterComposer get societyId {
    final $$SocietiesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.societyId,
        referencedTable: $db.societies,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SocietiesTableFilterComposer(
              $db: $db,
              $table: $db.societies,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AchievementsTableOrderingComposer
    extends Composer<_$AppDatabase, $AchievementsTable> {
  $$AchievementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get monthYear => $composableBuilder(
      column: $table.monthYear, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get proofImagePath => $composableBuilder(
      column: $table.proofImagePath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$SocietiesTableOrderingComposer get societyId {
    final $$SocietiesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.societyId,
        referencedTable: $db.societies,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SocietiesTableOrderingComposer(
              $db: $db,
              $table: $db.societies,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AchievementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AchievementsTable> {
  $$AchievementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get monthYear =>
      $composableBuilder(column: $table.monthYear, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get proofImagePath => $composableBuilder(
      column: $table.proofImagePath, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$SocietiesTableAnnotationComposer get societyId {
    final $$SocietiesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.societyId,
        referencedTable: $db.societies,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SocietiesTableAnnotationComposer(
              $db: $db,
              $table: $db.societies,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AchievementsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AchievementsTable,
    Achievement,
    $$AchievementsTableFilterComposer,
    $$AchievementsTableOrderingComposer,
    $$AchievementsTableAnnotationComposer,
    $$AchievementsTableCreateCompanionBuilder,
    $$AchievementsTableUpdateCompanionBuilder,
    (Achievement, $$AchievementsTableReferences),
    Achievement,
    PrefetchHooks Function({bool societyId})> {
  $$AchievementsTableTableManager(_$AppDatabase db, $AchievementsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AchievementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AchievementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AchievementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> monthYear = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String?> societyId = const Value.absent(),
            Value<String?> proofImagePath = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AchievementsCompanion(
            id: id,
            monthYear: monthYear,
            title: title,
            description: description,
            societyId: societyId,
            proofImagePath: proofImagePath,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String monthYear,
            required String title,
            Value<String?> description = const Value.absent(),
            Value<String?> societyId = const Value.absent(),
            Value<String?> proofImagePath = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AchievementsCompanion.insert(
            id: id,
            monthYear: monthYear,
            title: title,
            description: description,
            societyId: societyId,
            proofImagePath: proofImagePath,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$AchievementsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({societyId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (societyId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.societyId,
                    referencedTable:
                        $$AchievementsTableReferences._societyIdTable(db),
                    referencedColumn:
                        $$AchievementsTableReferences._societyIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$AchievementsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AchievementsTable,
    Achievement,
    $$AchievementsTableFilterComposer,
    $$AchievementsTableOrderingComposer,
    $$AchievementsTableAnnotationComposer,
    $$AchievementsTableCreateCompanionBuilder,
    $$AchievementsTableUpdateCompanionBuilder,
    (Achievement, $$AchievementsTableReferences),
    Achievement,
    PrefetchHooks Function({bool societyId})>;
typedef $$FinancialRecordsTableCreateCompanionBuilder
    = FinancialRecordsCompanion Function({
  required String id,
  required String monthYear,
  required String type,
  required String title,
  required double amount,
  Value<String?> sponsorName,
  Value<String?> voucherPath,
  Value<String?> notes,
  Value<DateTime> recordedAt,
  Value<int> rowid,
});
typedef $$FinancialRecordsTableUpdateCompanionBuilder
    = FinancialRecordsCompanion Function({
  Value<String> id,
  Value<String> monthYear,
  Value<String> type,
  Value<String> title,
  Value<double> amount,
  Value<String?> sponsorName,
  Value<String?> voucherPath,
  Value<String?> notes,
  Value<DateTime> recordedAt,
  Value<int> rowid,
});

class $$FinancialRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $FinancialRecordsTable> {
  $$FinancialRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get monthYear => $composableBuilder(
      column: $table.monthYear, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sponsorName => $composableBuilder(
      column: $table.sponsorName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get voucherPath => $composableBuilder(
      column: $table.voucherPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get recordedAt => $composableBuilder(
      column: $table.recordedAt, builder: (column) => ColumnFilters(column));
}

class $$FinancialRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $FinancialRecordsTable> {
  $$FinancialRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get monthYear => $composableBuilder(
      column: $table.monthYear, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sponsorName => $composableBuilder(
      column: $table.sponsorName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get voucherPath => $composableBuilder(
      column: $table.voucherPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get recordedAt => $composableBuilder(
      column: $table.recordedAt, builder: (column) => ColumnOrderings(column));
}

class $$FinancialRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FinancialRecordsTable> {
  $$FinancialRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get monthYear =>
      $composableBuilder(column: $table.monthYear, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get sponsorName => $composableBuilder(
      column: $table.sponsorName, builder: (column) => column);

  GeneratedColumn<String> get voucherPath => $composableBuilder(
      column: $table.voucherPath, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get recordedAt => $composableBuilder(
      column: $table.recordedAt, builder: (column) => column);
}

class $$FinancialRecordsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FinancialRecordsTable,
    FinancialRecord,
    $$FinancialRecordsTableFilterComposer,
    $$FinancialRecordsTableOrderingComposer,
    $$FinancialRecordsTableAnnotationComposer,
    $$FinancialRecordsTableCreateCompanionBuilder,
    $$FinancialRecordsTableUpdateCompanionBuilder,
    (
      FinancialRecord,
      BaseReferences<_$AppDatabase, $FinancialRecordsTable, FinancialRecord>
    ),
    FinancialRecord,
    PrefetchHooks Function()> {
  $$FinancialRecordsTableTableManager(
      _$AppDatabase db, $FinancialRecordsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FinancialRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FinancialRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FinancialRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> monthYear = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<double> amount = const Value.absent(),
            Value<String?> sponsorName = const Value.absent(),
            Value<String?> voucherPath = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> recordedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FinancialRecordsCompanion(
            id: id,
            monthYear: monthYear,
            type: type,
            title: title,
            amount: amount,
            sponsorName: sponsorName,
            voucherPath: voucherPath,
            notes: notes,
            recordedAt: recordedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String monthYear,
            required String type,
            required String title,
            required double amount,
            Value<String?> sponsorName = const Value.absent(),
            Value<String?> voucherPath = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> recordedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FinancialRecordsCompanion.insert(
            id: id,
            monthYear: monthYear,
            type: type,
            title: title,
            amount: amount,
            sponsorName: sponsorName,
            voucherPath: voucherPath,
            notes: notes,
            recordedAt: recordedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$FinancialRecordsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $FinancialRecordsTable,
    FinancialRecord,
    $$FinancialRecordsTableFilterComposer,
    $$FinancialRecordsTableOrderingComposer,
    $$FinancialRecordsTableAnnotationComposer,
    $$FinancialRecordsTableCreateCompanionBuilder,
    $$FinancialRecordsTableUpdateCompanionBuilder,
    (
      FinancialRecord,
      BaseReferences<_$AppDatabase, $FinancialRecordsTable, FinancialRecord>
    ),
    FinancialRecord,
    PrefetchHooks Function()>;
typedef $$ConfidentialVaultTableCreateCompanionBuilder
    = ConfidentialVaultCompanion Function({
  required String id,
  Value<String?> societyId,
  required String category,
  required String title,
  Value<String?> referenceNumber,
  Value<DateTime?> effectiveDate,
  Value<DateTime?> expiryDate,
  required String encryptedFilePath,
  required String fileChecksum,
  Value<int?> fileSizeBytes,
  Value<String?> originalFileName,
  Value<String?> metadataNotes,
  Value<DateTime> uploadedAt,
  Value<int> rowid,
});
typedef $$ConfidentialVaultTableUpdateCompanionBuilder
    = ConfidentialVaultCompanion Function({
  Value<String> id,
  Value<String?> societyId,
  Value<String> category,
  Value<String> title,
  Value<String?> referenceNumber,
  Value<DateTime?> effectiveDate,
  Value<DateTime?> expiryDate,
  Value<String> encryptedFilePath,
  Value<String> fileChecksum,
  Value<int?> fileSizeBytes,
  Value<String?> originalFileName,
  Value<String?> metadataNotes,
  Value<DateTime> uploadedAt,
  Value<int> rowid,
});

final class $$ConfidentialVaultTableReferences extends BaseReferences<
    _$AppDatabase, $ConfidentialVaultTable, ConfidentialVaultData> {
  $$ConfidentialVaultTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $SocietiesTable _societyIdTable(_$AppDatabase db) =>
      db.societies.createAlias($_aliasNameGenerator(
          db.confidentialVault.societyId, db.societies.id));

  $$SocietiesTableProcessedTableManager? get societyId {
    final $_column = $_itemColumn<String>('society_id');
    if ($_column == null) return null;
    final manager = $$SocietiesTableTableManager($_db, $_db.societies)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_societyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ConfidentialVaultTableFilterComposer
    extends Composer<_$AppDatabase, $ConfidentialVaultTable> {
  $$ConfidentialVaultTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get referenceNumber => $composableBuilder(
      column: $table.referenceNumber,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get effectiveDate => $composableBuilder(
      column: $table.effectiveDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get expiryDate => $composableBuilder(
      column: $table.expiryDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get encryptedFilePath => $composableBuilder(
      column: $table.encryptedFilePath,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fileChecksum => $composableBuilder(
      column: $table.fileChecksum, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get fileSizeBytes => $composableBuilder(
      column: $table.fileSizeBytes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get originalFileName => $composableBuilder(
      column: $table.originalFileName,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get metadataNotes => $composableBuilder(
      column: $table.metadataNotes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get uploadedAt => $composableBuilder(
      column: $table.uploadedAt, builder: (column) => ColumnFilters(column));

  $$SocietiesTableFilterComposer get societyId {
    final $$SocietiesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.societyId,
        referencedTable: $db.societies,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SocietiesTableFilterComposer(
              $db: $db,
              $table: $db.societies,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ConfidentialVaultTableOrderingComposer
    extends Composer<_$AppDatabase, $ConfidentialVaultTable> {
  $$ConfidentialVaultTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get referenceNumber => $composableBuilder(
      column: $table.referenceNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get effectiveDate => $composableBuilder(
      column: $table.effectiveDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get expiryDate => $composableBuilder(
      column: $table.expiryDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get encryptedFilePath => $composableBuilder(
      column: $table.encryptedFilePath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fileChecksum => $composableBuilder(
      column: $table.fileChecksum,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get fileSizeBytes => $composableBuilder(
      column: $table.fileSizeBytes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get originalFileName => $composableBuilder(
      column: $table.originalFileName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get metadataNotes => $composableBuilder(
      column: $table.metadataNotes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get uploadedAt => $composableBuilder(
      column: $table.uploadedAt, builder: (column) => ColumnOrderings(column));

  $$SocietiesTableOrderingComposer get societyId {
    final $$SocietiesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.societyId,
        referencedTable: $db.societies,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SocietiesTableOrderingComposer(
              $db: $db,
              $table: $db.societies,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ConfidentialVaultTableAnnotationComposer
    extends Composer<_$AppDatabase, $ConfidentialVaultTable> {
  $$ConfidentialVaultTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get referenceNumber => $composableBuilder(
      column: $table.referenceNumber, builder: (column) => column);

  GeneratedColumn<DateTime> get effectiveDate => $composableBuilder(
      column: $table.effectiveDate, builder: (column) => column);

  GeneratedColumn<DateTime> get expiryDate => $composableBuilder(
      column: $table.expiryDate, builder: (column) => column);

  GeneratedColumn<String> get encryptedFilePath => $composableBuilder(
      column: $table.encryptedFilePath, builder: (column) => column);

  GeneratedColumn<String> get fileChecksum => $composableBuilder(
      column: $table.fileChecksum, builder: (column) => column);

  GeneratedColumn<int> get fileSizeBytes => $composableBuilder(
      column: $table.fileSizeBytes, builder: (column) => column);

  GeneratedColumn<String> get originalFileName => $composableBuilder(
      column: $table.originalFileName, builder: (column) => column);

  GeneratedColumn<String> get metadataNotes => $composableBuilder(
      column: $table.metadataNotes, builder: (column) => column);

  GeneratedColumn<DateTime> get uploadedAt => $composableBuilder(
      column: $table.uploadedAt, builder: (column) => column);

  $$SocietiesTableAnnotationComposer get societyId {
    final $$SocietiesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.societyId,
        referencedTable: $db.societies,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SocietiesTableAnnotationComposer(
              $db: $db,
              $table: $db.societies,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ConfidentialVaultTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ConfidentialVaultTable,
    ConfidentialVaultData,
    $$ConfidentialVaultTableFilterComposer,
    $$ConfidentialVaultTableOrderingComposer,
    $$ConfidentialVaultTableAnnotationComposer,
    $$ConfidentialVaultTableCreateCompanionBuilder,
    $$ConfidentialVaultTableUpdateCompanionBuilder,
    (ConfidentialVaultData, $$ConfidentialVaultTableReferences),
    ConfidentialVaultData,
    PrefetchHooks Function({bool societyId})> {
  $$ConfidentialVaultTableTableManager(
      _$AppDatabase db, $ConfidentialVaultTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConfidentialVaultTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConfidentialVaultTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConfidentialVaultTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> societyId = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String?> referenceNumber = const Value.absent(),
            Value<DateTime?> effectiveDate = const Value.absent(),
            Value<DateTime?> expiryDate = const Value.absent(),
            Value<String> encryptedFilePath = const Value.absent(),
            Value<String> fileChecksum = const Value.absent(),
            Value<int?> fileSizeBytes = const Value.absent(),
            Value<String?> originalFileName = const Value.absent(),
            Value<String?> metadataNotes = const Value.absent(),
            Value<DateTime> uploadedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ConfidentialVaultCompanion(
            id: id,
            societyId: societyId,
            category: category,
            title: title,
            referenceNumber: referenceNumber,
            effectiveDate: effectiveDate,
            expiryDate: expiryDate,
            encryptedFilePath: encryptedFilePath,
            fileChecksum: fileChecksum,
            fileSizeBytes: fileSizeBytes,
            originalFileName: originalFileName,
            metadataNotes: metadataNotes,
            uploadedAt: uploadedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> societyId = const Value.absent(),
            required String category,
            required String title,
            Value<String?> referenceNumber = const Value.absent(),
            Value<DateTime?> effectiveDate = const Value.absent(),
            Value<DateTime?> expiryDate = const Value.absent(),
            required String encryptedFilePath,
            required String fileChecksum,
            Value<int?> fileSizeBytes = const Value.absent(),
            Value<String?> originalFileName = const Value.absent(),
            Value<String?> metadataNotes = const Value.absent(),
            Value<DateTime> uploadedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ConfidentialVaultCompanion.insert(
            id: id,
            societyId: societyId,
            category: category,
            title: title,
            referenceNumber: referenceNumber,
            effectiveDate: effectiveDate,
            expiryDate: expiryDate,
            encryptedFilePath: encryptedFilePath,
            fileChecksum: fileChecksum,
            fileSizeBytes: fileSizeBytes,
            originalFileName: originalFileName,
            metadataNotes: metadataNotes,
            uploadedAt: uploadedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ConfidentialVaultTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({societyId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (societyId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.societyId,
                    referencedTable:
                        $$ConfidentialVaultTableReferences._societyIdTable(db),
                    referencedColumn: $$ConfidentialVaultTableReferences
                        ._societyIdTable(db)
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
        ));
}

typedef $$ConfidentialVaultTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ConfidentialVaultTable,
    ConfidentialVaultData,
    $$ConfidentialVaultTableFilterComposer,
    $$ConfidentialVaultTableOrderingComposer,
    $$ConfidentialVaultTableAnnotationComposer,
    $$ConfidentialVaultTableCreateCompanionBuilder,
    $$ConfidentialVaultTableUpdateCompanionBuilder,
    (ConfidentialVaultData, $$ConfidentialVaultTableReferences),
    ConfidentialVaultData,
    PrefetchHooks Function({bool societyId})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SocietiesTableTableManager get societies =>
      $$SocietiesTableTableManager(_db, _db.societies);
  $$CabinetMembersTableTableManager get cabinetMembers =>
      $$CabinetMembersTableTableManager(_db, _db.cabinetMembers);
  $$SocietyMembersTableTableManager get societyMembers =>
      $$SocietyMembersTableTableManager(_db, _db.societyMembers);
  $$EventsTableTableManager get events =>
      $$EventsTableTableManager(_db, _db.events);
  $$EventSpeakersTableTableManager get eventSpeakers =>
      $$EventSpeakersTableTableManager(_db, _db.eventSpeakers);
  $$AchievementsTableTableManager get achievements =>
      $$AchievementsTableTableManager(_db, _db.achievements);
  $$FinancialRecordsTableTableManager get financialRecords =>
      $$FinancialRecordsTableTableManager(_db, _db.financialRecords);
  $$ConfidentialVaultTableTableManager get confidentialVault =>
      $$ConfidentialVaultTableTableManager(_db, _db.confidentialVault);
}
