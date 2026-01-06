// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $TermsTable extends Terms with TableInfo<$TermsTable, Term> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TermsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, isActive];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'terms';
  @override
  VerificationContext validateIntegrity(
    Insertable<Term> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Term map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Term(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
    );
  }

  @override
  $TermsTable createAlias(String alias) {
    return $TermsTable(attachedDatabase, alias);
  }
}

class Term extends DataClass implements Insertable<Term> {
  final int id;
  final String name;
  final bool isActive;
  const Term({required this.id, required this.name, required this.isActive});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  TermsCompanion toCompanion(bool nullToAbsent) {
    return TermsCompanion(
      id: Value(id),
      name: Value(name),
      isActive: Value(isActive),
    );
  }

  factory Term.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Term(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  Term copyWith({int? id, String? name, bool? isActive}) => Term(
    id: id ?? this.id,
    name: name ?? this.name,
    isActive: isActive ?? this.isActive,
  );
  Term copyWithCompanion(TermsCompanion data) {
    return Term(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Term(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, isActive);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Term &&
          other.id == this.id &&
          other.name == this.name &&
          other.isActive == this.isActive);
}

class TermsCompanion extends UpdateCompanion<Term> {
  final Value<int> id;
  final Value<String> name;
  final Value<bool> isActive;
  const TermsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.isActive = const Value.absent(),
  });
  TermsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.isActive = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Term> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<bool>? isActive,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (isActive != null) 'is_active': isActive,
    });
  }

  TermsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<bool>? isActive,
  }) {
    return TermsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TermsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }
}

class $CoursesTable extends Courses with TableInfo<$CoursesTable, Course> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CoursesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
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
  static const VerificationMeta _unitsMeta = const VerificationMeta('units');
  @override
  late final GeneratedColumn<double> units = GeneratedColumn<double>(
    'units',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetGwaMeta = const VerificationMeta(
    'targetGwa',
  );
  @override
  late final GeneratedColumn<double> targetGwa = GeneratedColumn<double>(
    'target_gwa',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorHexMeta = const VerificationMeta(
    'colorHex',
  );
  @override
  late final GeneratedColumn<String> colorHex = GeneratedColumn<String>(
    'color_hex',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _termIdMeta = const VerificationMeta('termId');
  @override
  late final GeneratedColumn<int> termId = GeneratedColumn<int>(
    'term_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES terms (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    code,
    name,
    units,
    targetGwa,
    colorHex,
    termId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'courses';
  @override
  VerificationContext validateIntegrity(
    Insertable<Course> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('units')) {
      context.handle(
        _unitsMeta,
        units.isAcceptableOrUnknown(data['units']!, _unitsMeta),
      );
    } else if (isInserting) {
      context.missing(_unitsMeta);
    }
    if (data.containsKey('target_gwa')) {
      context.handle(
        _targetGwaMeta,
        targetGwa.isAcceptableOrUnknown(data['target_gwa']!, _targetGwaMeta),
      );
    } else if (isInserting) {
      context.missing(_targetGwaMeta);
    }
    if (data.containsKey('color_hex')) {
      context.handle(
        _colorHexMeta,
        colorHex.isAcceptableOrUnknown(data['color_hex']!, _colorHexMeta),
      );
    } else if (isInserting) {
      context.missing(_colorHexMeta);
    }
    if (data.containsKey('term_id')) {
      context.handle(
        _termIdMeta,
        termId.isAcceptableOrUnknown(data['term_id']!, _termIdMeta),
      );
    } else if (isInserting) {
      context.missing(_termIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Course map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Course(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      units: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}units'],
      )!,
      targetGwa: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}target_gwa'],
      )!,
      colorHex: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color_hex'],
      )!,
      termId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}term_id'],
      )!,
    );
  }

  @override
  $CoursesTable createAlias(String alias) {
    return $CoursesTable(attachedDatabase, alias);
  }
}

class Course extends DataClass implements Insertable<Course> {
  final int id;
  final String code;
  final String name;
  final double units;
  final double targetGwa;
  final String colorHex;
  final int termId;
  const Course({
    required this.id,
    required this.code,
    required this.name,
    required this.units,
    required this.targetGwa,
    required this.colorHex,
    required this.termId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['code'] = Variable<String>(code);
    map['name'] = Variable<String>(name);
    map['units'] = Variable<double>(units);
    map['target_gwa'] = Variable<double>(targetGwa);
    map['color_hex'] = Variable<String>(colorHex);
    map['term_id'] = Variable<int>(termId);
    return map;
  }

  CoursesCompanion toCompanion(bool nullToAbsent) {
    return CoursesCompanion(
      id: Value(id),
      code: Value(code),
      name: Value(name),
      units: Value(units),
      targetGwa: Value(targetGwa),
      colorHex: Value(colorHex),
      termId: Value(termId),
    );
  }

  factory Course.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Course(
      id: serializer.fromJson<int>(json['id']),
      code: serializer.fromJson<String>(json['code']),
      name: serializer.fromJson<String>(json['name']),
      units: serializer.fromJson<double>(json['units']),
      targetGwa: serializer.fromJson<double>(json['targetGwa']),
      colorHex: serializer.fromJson<String>(json['colorHex']),
      termId: serializer.fromJson<int>(json['termId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'code': serializer.toJson<String>(code),
      'name': serializer.toJson<String>(name),
      'units': serializer.toJson<double>(units),
      'targetGwa': serializer.toJson<double>(targetGwa),
      'colorHex': serializer.toJson<String>(colorHex),
      'termId': serializer.toJson<int>(termId),
    };
  }

  Course copyWith({
    int? id,
    String? code,
    String? name,
    double? units,
    double? targetGwa,
    String? colorHex,
    int? termId,
  }) => Course(
    id: id ?? this.id,
    code: code ?? this.code,
    name: name ?? this.name,
    units: units ?? this.units,
    targetGwa: targetGwa ?? this.targetGwa,
    colorHex: colorHex ?? this.colorHex,
    termId: termId ?? this.termId,
  );
  Course copyWithCompanion(CoursesCompanion data) {
    return Course(
      id: data.id.present ? data.id.value : this.id,
      code: data.code.present ? data.code.value : this.code,
      name: data.name.present ? data.name.value : this.name,
      units: data.units.present ? data.units.value : this.units,
      targetGwa: data.targetGwa.present ? data.targetGwa.value : this.targetGwa,
      colorHex: data.colorHex.present ? data.colorHex.value : this.colorHex,
      termId: data.termId.present ? data.termId.value : this.termId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Course(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('units: $units, ')
          ..write('targetGwa: $targetGwa, ')
          ..write('colorHex: $colorHex, ')
          ..write('termId: $termId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, code, name, units, targetGwa, colorHex, termId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Course &&
          other.id == this.id &&
          other.code == this.code &&
          other.name == this.name &&
          other.units == this.units &&
          other.targetGwa == this.targetGwa &&
          other.colorHex == this.colorHex &&
          other.termId == this.termId);
}

class CoursesCompanion extends UpdateCompanion<Course> {
  final Value<int> id;
  final Value<String> code;
  final Value<String> name;
  final Value<double> units;
  final Value<double> targetGwa;
  final Value<String> colorHex;
  final Value<int> termId;
  const CoursesCompanion({
    this.id = const Value.absent(),
    this.code = const Value.absent(),
    this.name = const Value.absent(),
    this.units = const Value.absent(),
    this.targetGwa = const Value.absent(),
    this.colorHex = const Value.absent(),
    this.termId = const Value.absent(),
  });
  CoursesCompanion.insert({
    this.id = const Value.absent(),
    required String code,
    required String name,
    required double units,
    required double targetGwa,
    required String colorHex,
    required int termId,
  }) : code = Value(code),
       name = Value(name),
       units = Value(units),
       targetGwa = Value(targetGwa),
       colorHex = Value(colorHex),
       termId = Value(termId);
  static Insertable<Course> custom({
    Expression<int>? id,
    Expression<String>? code,
    Expression<String>? name,
    Expression<double>? units,
    Expression<double>? targetGwa,
    Expression<String>? colorHex,
    Expression<int>? termId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (code != null) 'code': code,
      if (name != null) 'name': name,
      if (units != null) 'units': units,
      if (targetGwa != null) 'target_gwa': targetGwa,
      if (colorHex != null) 'color_hex': colorHex,
      if (termId != null) 'term_id': termId,
    });
  }

  CoursesCompanion copyWith({
    Value<int>? id,
    Value<String>? code,
    Value<String>? name,
    Value<double>? units,
    Value<double>? targetGwa,
    Value<String>? colorHex,
    Value<int>? termId,
  }) {
    return CoursesCompanion(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      units: units ?? this.units,
      targetGwa: targetGwa ?? this.targetGwa,
      colorHex: colorHex ?? this.colorHex,
      termId: termId ?? this.termId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (units.present) {
      map['units'] = Variable<double>(units.value);
    }
    if (targetGwa.present) {
      map['target_gwa'] = Variable<double>(targetGwa.value);
    }
    if (colorHex.present) {
      map['color_hex'] = Variable<String>(colorHex.value);
    }
    if (termId.present) {
      map['term_id'] = Variable<int>(termId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CoursesCompanion(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('units: $units, ')
          ..write('targetGwa: $targetGwa, ')
          ..write('colorHex: $colorHex, ')
          ..write('termId: $termId')
          ..write(')'))
        .toString();
  }
}

class $GradingComponentsTable extends GradingComponents
    with TableInfo<$GradingComponentsTable, GradingComponent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GradingComponentsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weightPercentMeta = const VerificationMeta(
    'weightPercent',
  );
  @override
  late final GeneratedColumn<double> weightPercent = GeneratedColumn<double>(
    'weight_percent',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _courseIdMeta = const VerificationMeta(
    'courseId',
  );
  @override
  late final GeneratedColumn<int> courseId = GeneratedColumn<int>(
    'course_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES courses (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, weightPercent, courseId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'grading_components';
  @override
  VerificationContext validateIntegrity(
    Insertable<GradingComponent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('weight_percent')) {
      context.handle(
        _weightPercentMeta,
        weightPercent.isAcceptableOrUnknown(
          data['weight_percent']!,
          _weightPercentMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_weightPercentMeta);
    }
    if (data.containsKey('course_id')) {
      context.handle(
        _courseIdMeta,
        courseId.isAcceptableOrUnknown(data['course_id']!, _courseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_courseIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GradingComponent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GradingComponent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      weightPercent: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_percent'],
      )!,
      courseId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}course_id'],
      )!,
    );
  }

  @override
  $GradingComponentsTable createAlias(String alias) {
    return $GradingComponentsTable(attachedDatabase, alias);
  }
}

class GradingComponent extends DataClass
    implements Insertable<GradingComponent> {
  final int id;
  final String name;
  final double weightPercent;
  final int courseId;
  const GradingComponent({
    required this.id,
    required this.name,
    required this.weightPercent,
    required this.courseId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['weight_percent'] = Variable<double>(weightPercent);
    map['course_id'] = Variable<int>(courseId);
    return map;
  }

  GradingComponentsCompanion toCompanion(bool nullToAbsent) {
    return GradingComponentsCompanion(
      id: Value(id),
      name: Value(name),
      weightPercent: Value(weightPercent),
      courseId: Value(courseId),
    );
  }

  factory GradingComponent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GradingComponent(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      weightPercent: serializer.fromJson<double>(json['weightPercent']),
      courseId: serializer.fromJson<int>(json['courseId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'weightPercent': serializer.toJson<double>(weightPercent),
      'courseId': serializer.toJson<int>(courseId),
    };
  }

  GradingComponent copyWith({
    int? id,
    String? name,
    double? weightPercent,
    int? courseId,
  }) => GradingComponent(
    id: id ?? this.id,
    name: name ?? this.name,
    weightPercent: weightPercent ?? this.weightPercent,
    courseId: courseId ?? this.courseId,
  );
  GradingComponent copyWithCompanion(GradingComponentsCompanion data) {
    return GradingComponent(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      weightPercent: data.weightPercent.present
          ? data.weightPercent.value
          : this.weightPercent,
      courseId: data.courseId.present ? data.courseId.value : this.courseId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GradingComponent(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('weightPercent: $weightPercent, ')
          ..write('courseId: $courseId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, weightPercent, courseId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GradingComponent &&
          other.id == this.id &&
          other.name == this.name &&
          other.weightPercent == this.weightPercent &&
          other.courseId == this.courseId);
}

class GradingComponentsCompanion extends UpdateCompanion<GradingComponent> {
  final Value<int> id;
  final Value<String> name;
  final Value<double> weightPercent;
  final Value<int> courseId;
  const GradingComponentsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.weightPercent = const Value.absent(),
    this.courseId = const Value.absent(),
  });
  GradingComponentsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required double weightPercent,
    required int courseId,
  }) : name = Value(name),
       weightPercent = Value(weightPercent),
       courseId = Value(courseId);
  static Insertable<GradingComponent> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<double>? weightPercent,
    Expression<int>? courseId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (weightPercent != null) 'weight_percent': weightPercent,
      if (courseId != null) 'course_id': courseId,
    });
  }

  GradingComponentsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<double>? weightPercent,
    Value<int>? courseId,
  }) {
    return GradingComponentsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      weightPercent: weightPercent ?? this.weightPercent,
      courseId: courseId ?? this.courseId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (weightPercent.present) {
      map['weight_percent'] = Variable<double>(weightPercent.value);
    }
    if (courseId.present) {
      map['course_id'] = Variable<int>(courseId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GradingComponentsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('weightPercent: $weightPercent, ')
          ..write('courseId: $courseId')
          ..write(')'))
        .toString();
  }
}

class $AssessmentsTable extends Assessments
    with TableInfo<$AssessmentsTable, Assessment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AssessmentsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scoreObtainedMeta = const VerificationMeta(
    'scoreObtained',
  );
  @override
  late final GeneratedColumn<double> scoreObtained = GeneratedColumn<double>(
    'score_obtained',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalItemsMeta = const VerificationMeta(
    'totalItems',
  );
  @override
  late final GeneratedColumn<double> totalItems = GeneratedColumn<double>(
    'total_items',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isExcusedMeta = const VerificationMeta(
    'isExcused',
  );
  @override
  late final GeneratedColumn<bool> isExcused = GeneratedColumn<bool>(
    'is_excused',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_excused" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isGoalMeta = const VerificationMeta('isGoal');
  @override
  late final GeneratedColumn<bool> isGoal = GeneratedColumn<bool>(
    'is_goal',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_goal" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _componentIdMeta = const VerificationMeta(
    'componentId',
  );
  @override
  late final GeneratedColumn<int> componentId = GeneratedColumn<int>(
    'component_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES grading_components (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    scoreObtained,
    totalItems,
    isExcused,
    isGoal,
    componentId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'assessments';
  @override
  VerificationContext validateIntegrity(
    Insertable<Assessment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('score_obtained')) {
      context.handle(
        _scoreObtainedMeta,
        scoreObtained.isAcceptableOrUnknown(
          data['score_obtained']!,
          _scoreObtainedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scoreObtainedMeta);
    }
    if (data.containsKey('total_items')) {
      context.handle(
        _totalItemsMeta,
        totalItems.isAcceptableOrUnknown(data['total_items']!, _totalItemsMeta),
      );
    } else if (isInserting) {
      context.missing(_totalItemsMeta);
    }
    if (data.containsKey('is_excused')) {
      context.handle(
        _isExcusedMeta,
        isExcused.isAcceptableOrUnknown(data['is_excused']!, _isExcusedMeta),
      );
    }
    if (data.containsKey('is_goal')) {
      context.handle(
        _isGoalMeta,
        isGoal.isAcceptableOrUnknown(data['is_goal']!, _isGoalMeta),
      );
    }
    if (data.containsKey('component_id')) {
      context.handle(
        _componentIdMeta,
        componentId.isAcceptableOrUnknown(
          data['component_id']!,
          _componentIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_componentIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Assessment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Assessment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      scoreObtained: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}score_obtained'],
      )!,
      totalItems: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_items'],
      )!,
      isExcused: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_excused'],
      )!,
      isGoal: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_goal'],
      )!,
      componentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}component_id'],
      )!,
    );
  }

  @override
  $AssessmentsTable createAlias(String alias) {
    return $AssessmentsTable(attachedDatabase, alias);
  }
}

class Assessment extends DataClass implements Insertable<Assessment> {
  final int id;
  final String name;
  final double scoreObtained;
  final double totalItems;
  final bool isExcused;
  final bool isGoal;
  final int componentId;
  const Assessment({
    required this.id,
    required this.name,
    required this.scoreObtained,
    required this.totalItems,
    required this.isExcused,
    required this.isGoal,
    required this.componentId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['score_obtained'] = Variable<double>(scoreObtained);
    map['total_items'] = Variable<double>(totalItems);
    map['is_excused'] = Variable<bool>(isExcused);
    map['is_goal'] = Variable<bool>(isGoal);
    map['component_id'] = Variable<int>(componentId);
    return map;
  }

  AssessmentsCompanion toCompanion(bool nullToAbsent) {
    return AssessmentsCompanion(
      id: Value(id),
      name: Value(name),
      scoreObtained: Value(scoreObtained),
      totalItems: Value(totalItems),
      isExcused: Value(isExcused),
      isGoal: Value(isGoal),
      componentId: Value(componentId),
    );
  }

  factory Assessment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Assessment(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      scoreObtained: serializer.fromJson<double>(json['scoreObtained']),
      totalItems: serializer.fromJson<double>(json['totalItems']),
      isExcused: serializer.fromJson<bool>(json['isExcused']),
      isGoal: serializer.fromJson<bool>(json['isGoal']),
      componentId: serializer.fromJson<int>(json['componentId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'scoreObtained': serializer.toJson<double>(scoreObtained),
      'totalItems': serializer.toJson<double>(totalItems),
      'isExcused': serializer.toJson<bool>(isExcused),
      'isGoal': serializer.toJson<bool>(isGoal),
      'componentId': serializer.toJson<int>(componentId),
    };
  }

  Assessment copyWith({
    int? id,
    String? name,
    double? scoreObtained,
    double? totalItems,
    bool? isExcused,
    bool? isGoal,
    int? componentId,
  }) => Assessment(
    id: id ?? this.id,
    name: name ?? this.name,
    scoreObtained: scoreObtained ?? this.scoreObtained,
    totalItems: totalItems ?? this.totalItems,
    isExcused: isExcused ?? this.isExcused,
    isGoal: isGoal ?? this.isGoal,
    componentId: componentId ?? this.componentId,
  );
  Assessment copyWithCompanion(AssessmentsCompanion data) {
    return Assessment(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      scoreObtained: data.scoreObtained.present
          ? data.scoreObtained.value
          : this.scoreObtained,
      totalItems: data.totalItems.present
          ? data.totalItems.value
          : this.totalItems,
      isExcused: data.isExcused.present ? data.isExcused.value : this.isExcused,
      isGoal: data.isGoal.present ? data.isGoal.value : this.isGoal,
      componentId: data.componentId.present
          ? data.componentId.value
          : this.componentId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Assessment(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('scoreObtained: $scoreObtained, ')
          ..write('totalItems: $totalItems, ')
          ..write('isExcused: $isExcused, ')
          ..write('isGoal: $isGoal, ')
          ..write('componentId: $componentId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    scoreObtained,
    totalItems,
    isExcused,
    isGoal,
    componentId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Assessment &&
          other.id == this.id &&
          other.name == this.name &&
          other.scoreObtained == this.scoreObtained &&
          other.totalItems == this.totalItems &&
          other.isExcused == this.isExcused &&
          other.isGoal == this.isGoal &&
          other.componentId == this.componentId);
}

class AssessmentsCompanion extends UpdateCompanion<Assessment> {
  final Value<int> id;
  final Value<String> name;
  final Value<double> scoreObtained;
  final Value<double> totalItems;
  final Value<bool> isExcused;
  final Value<bool> isGoal;
  final Value<int> componentId;
  const AssessmentsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.scoreObtained = const Value.absent(),
    this.totalItems = const Value.absent(),
    this.isExcused = const Value.absent(),
    this.isGoal = const Value.absent(),
    this.componentId = const Value.absent(),
  });
  AssessmentsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required double scoreObtained,
    required double totalItems,
    this.isExcused = const Value.absent(),
    this.isGoal = const Value.absent(),
    required int componentId,
  }) : name = Value(name),
       scoreObtained = Value(scoreObtained),
       totalItems = Value(totalItems),
       componentId = Value(componentId);
  static Insertable<Assessment> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<double>? scoreObtained,
    Expression<double>? totalItems,
    Expression<bool>? isExcused,
    Expression<bool>? isGoal,
    Expression<int>? componentId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (scoreObtained != null) 'score_obtained': scoreObtained,
      if (totalItems != null) 'total_items': totalItems,
      if (isExcused != null) 'is_excused': isExcused,
      if (isGoal != null) 'is_goal': isGoal,
      if (componentId != null) 'component_id': componentId,
    });
  }

  AssessmentsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<double>? scoreObtained,
    Value<double>? totalItems,
    Value<bool>? isExcused,
    Value<bool>? isGoal,
    Value<int>? componentId,
  }) {
    return AssessmentsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      scoreObtained: scoreObtained ?? this.scoreObtained,
      totalItems: totalItems ?? this.totalItems,
      isExcused: isExcused ?? this.isExcused,
      isGoal: isGoal ?? this.isGoal,
      componentId: componentId ?? this.componentId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (scoreObtained.present) {
      map['score_obtained'] = Variable<double>(scoreObtained.value);
    }
    if (totalItems.present) {
      map['total_items'] = Variable<double>(totalItems.value);
    }
    if (isExcused.present) {
      map['is_excused'] = Variable<bool>(isExcused.value);
    }
    if (isGoal.present) {
      map['is_goal'] = Variable<bool>(isGoal.value);
    }
    if (componentId.present) {
      map['component_id'] = Variable<int>(componentId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AssessmentsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('scoreObtained: $scoreObtained, ')
          ..write('totalItems: $totalItems, ')
          ..write('isExcused: $isExcused, ')
          ..write('isGoal: $isGoal, ')
          ..write('componentId: $componentId')
          ..write(')'))
        .toString();
  }
}

class $CustomGradingSystemsTable extends CustomGradingSystems
    with TableInfo<$CustomGradingSystemsTable, CustomGradingSystem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomGradingSystemsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _isHigherBetterMeta = const VerificationMeta(
    'isHigherBetter',
  );
  @override
  late final GeneratedColumn<bool> isHigherBetter = GeneratedColumn<bool>(
    'is_higher_better',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_higher_better" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, isHigherBetter];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'custom_grading_systems';
  @override
  VerificationContext validateIntegrity(
    Insertable<CustomGradingSystem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('is_higher_better')) {
      context.handle(
        _isHigherBetterMeta,
        isHigherBetter.isAcceptableOrUnknown(
          data['is_higher_better']!,
          _isHigherBetterMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CustomGradingSystem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomGradingSystem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      isHigherBetter: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_higher_better'],
      )!,
    );
  }

  @override
  $CustomGradingSystemsTable createAlias(String alias) {
    return $CustomGradingSystemsTable(attachedDatabase, alias);
  }
}

class CustomGradingSystem extends DataClass
    implements Insertable<CustomGradingSystem> {
  final int id;
  final String name;
  final bool isHigherBetter;
  const CustomGradingSystem({
    required this.id,
    required this.name,
    required this.isHigherBetter,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['is_higher_better'] = Variable<bool>(isHigherBetter);
    return map;
  }

  CustomGradingSystemsCompanion toCompanion(bool nullToAbsent) {
    return CustomGradingSystemsCompanion(
      id: Value(id),
      name: Value(name),
      isHigherBetter: Value(isHigherBetter),
    );
  }

  factory CustomGradingSystem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomGradingSystem(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      isHigherBetter: serializer.fromJson<bool>(json['isHigherBetter']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'isHigherBetter': serializer.toJson<bool>(isHigherBetter),
    };
  }

  CustomGradingSystem copyWith({int? id, String? name, bool? isHigherBetter}) =>
      CustomGradingSystem(
        id: id ?? this.id,
        name: name ?? this.name,
        isHigherBetter: isHigherBetter ?? this.isHigherBetter,
      );
  CustomGradingSystem copyWithCompanion(CustomGradingSystemsCompanion data) {
    return CustomGradingSystem(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      isHigherBetter: data.isHigherBetter.present
          ? data.isHigherBetter.value
          : this.isHigherBetter,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomGradingSystem(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('isHigherBetter: $isHigherBetter')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, isHigherBetter);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomGradingSystem &&
          other.id == this.id &&
          other.name == this.name &&
          other.isHigherBetter == this.isHigherBetter);
}

class CustomGradingSystemsCompanion
    extends UpdateCompanion<CustomGradingSystem> {
  final Value<int> id;
  final Value<String> name;
  final Value<bool> isHigherBetter;
  const CustomGradingSystemsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.isHigherBetter = const Value.absent(),
  });
  CustomGradingSystemsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.isHigherBetter = const Value.absent(),
  }) : name = Value(name);
  static Insertable<CustomGradingSystem> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<bool>? isHigherBetter,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (isHigherBetter != null) 'is_higher_better': isHigherBetter,
    });
  }

  CustomGradingSystemsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<bool>? isHigherBetter,
  }) {
    return CustomGradingSystemsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      isHigherBetter: isHigherBetter ?? this.isHigherBetter,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (isHigherBetter.present) {
      map['is_higher_better'] = Variable<bool>(isHigherBetter.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomGradingSystemsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('isHigherBetter: $isHigherBetter')
          ..write(')'))
        .toString();
  }
}

class $CustomGradingScalesTable extends CustomGradingScales
    with TableInfo<$CustomGradingScalesTable, CustomGradingScale> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomGradingScalesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _systemIdMeta = const VerificationMeta(
    'systemId',
  );
  @override
  late final GeneratedColumn<int> systemId = GeneratedColumn<int>(
    'system_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES custom_grading_systems (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _minPercentageMeta = const VerificationMeta(
    'minPercentage',
  );
  @override
  late final GeneratedColumn<double> minPercentage = GeneratedColumn<double>(
    'min_percentage',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gradeValueMeta = const VerificationMeta(
    'gradeValue',
  );
  @override
  late final GeneratedColumn<double> gradeValue = GeneratedColumn<double>(
    'grade_value',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gradeLabelMeta = const VerificationMeta(
    'gradeLabel',
  );
  @override
  late final GeneratedColumn<String> gradeLabel = GeneratedColumn<String>(
    'grade_label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    systemId,
    minPercentage,
    gradeValue,
    gradeLabel,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'custom_grading_scales';
  @override
  VerificationContext validateIntegrity(
    Insertable<CustomGradingScale> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('system_id')) {
      context.handle(
        _systemIdMeta,
        systemId.isAcceptableOrUnknown(data['system_id']!, _systemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_systemIdMeta);
    }
    if (data.containsKey('min_percentage')) {
      context.handle(
        _minPercentageMeta,
        minPercentage.isAcceptableOrUnknown(
          data['min_percentage']!,
          _minPercentageMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_minPercentageMeta);
    }
    if (data.containsKey('grade_value')) {
      context.handle(
        _gradeValueMeta,
        gradeValue.isAcceptableOrUnknown(data['grade_value']!, _gradeValueMeta),
      );
    } else if (isInserting) {
      context.missing(_gradeValueMeta);
    }
    if (data.containsKey('grade_label')) {
      context.handle(
        _gradeLabelMeta,
        gradeLabel.isAcceptableOrUnknown(data['grade_label']!, _gradeLabelMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CustomGradingScale map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomGradingScale(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      systemId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}system_id'],
      )!,
      minPercentage: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}min_percentage'],
      )!,
      gradeValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}grade_value'],
      )!,
      gradeLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}grade_label'],
      ),
    );
  }

  @override
  $CustomGradingScalesTable createAlias(String alias) {
    return $CustomGradingScalesTable(attachedDatabase, alias);
  }
}

class CustomGradingScale extends DataClass
    implements Insertable<CustomGradingScale> {
  final int id;
  final int systemId;
  final double minPercentage;
  final double gradeValue;
  final String? gradeLabel;
  const CustomGradingScale({
    required this.id,
    required this.systemId,
    required this.minPercentage,
    required this.gradeValue,
    this.gradeLabel,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['system_id'] = Variable<int>(systemId);
    map['min_percentage'] = Variable<double>(minPercentage);
    map['grade_value'] = Variable<double>(gradeValue);
    if (!nullToAbsent || gradeLabel != null) {
      map['grade_label'] = Variable<String>(gradeLabel);
    }
    return map;
  }

  CustomGradingScalesCompanion toCompanion(bool nullToAbsent) {
    return CustomGradingScalesCompanion(
      id: Value(id),
      systemId: Value(systemId),
      minPercentage: Value(minPercentage),
      gradeValue: Value(gradeValue),
      gradeLabel: gradeLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(gradeLabel),
    );
  }

  factory CustomGradingScale.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomGradingScale(
      id: serializer.fromJson<int>(json['id']),
      systemId: serializer.fromJson<int>(json['systemId']),
      minPercentage: serializer.fromJson<double>(json['minPercentage']),
      gradeValue: serializer.fromJson<double>(json['gradeValue']),
      gradeLabel: serializer.fromJson<String?>(json['gradeLabel']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'systemId': serializer.toJson<int>(systemId),
      'minPercentage': serializer.toJson<double>(minPercentage),
      'gradeValue': serializer.toJson<double>(gradeValue),
      'gradeLabel': serializer.toJson<String?>(gradeLabel),
    };
  }

  CustomGradingScale copyWith({
    int? id,
    int? systemId,
    double? minPercentage,
    double? gradeValue,
    Value<String?> gradeLabel = const Value.absent(),
  }) => CustomGradingScale(
    id: id ?? this.id,
    systemId: systemId ?? this.systemId,
    minPercentage: minPercentage ?? this.minPercentage,
    gradeValue: gradeValue ?? this.gradeValue,
    gradeLabel: gradeLabel.present ? gradeLabel.value : this.gradeLabel,
  );
  CustomGradingScale copyWithCompanion(CustomGradingScalesCompanion data) {
    return CustomGradingScale(
      id: data.id.present ? data.id.value : this.id,
      systemId: data.systemId.present ? data.systemId.value : this.systemId,
      minPercentage: data.minPercentage.present
          ? data.minPercentage.value
          : this.minPercentage,
      gradeValue: data.gradeValue.present
          ? data.gradeValue.value
          : this.gradeValue,
      gradeLabel: data.gradeLabel.present
          ? data.gradeLabel.value
          : this.gradeLabel,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomGradingScale(')
          ..write('id: $id, ')
          ..write('systemId: $systemId, ')
          ..write('minPercentage: $minPercentage, ')
          ..write('gradeValue: $gradeValue, ')
          ..write('gradeLabel: $gradeLabel')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, systemId, minPercentage, gradeValue, gradeLabel);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomGradingScale &&
          other.id == this.id &&
          other.systemId == this.systemId &&
          other.minPercentage == this.minPercentage &&
          other.gradeValue == this.gradeValue &&
          other.gradeLabel == this.gradeLabel);
}

class CustomGradingScalesCompanion extends UpdateCompanion<CustomGradingScale> {
  final Value<int> id;
  final Value<int> systemId;
  final Value<double> minPercentage;
  final Value<double> gradeValue;
  final Value<String?> gradeLabel;
  const CustomGradingScalesCompanion({
    this.id = const Value.absent(),
    this.systemId = const Value.absent(),
    this.minPercentage = const Value.absent(),
    this.gradeValue = const Value.absent(),
    this.gradeLabel = const Value.absent(),
  });
  CustomGradingScalesCompanion.insert({
    this.id = const Value.absent(),
    required int systemId,
    required double minPercentage,
    required double gradeValue,
    this.gradeLabel = const Value.absent(),
  }) : systemId = Value(systemId),
       minPercentage = Value(minPercentage),
       gradeValue = Value(gradeValue);
  static Insertable<CustomGradingScale> custom({
    Expression<int>? id,
    Expression<int>? systemId,
    Expression<double>? minPercentage,
    Expression<double>? gradeValue,
    Expression<String>? gradeLabel,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (systemId != null) 'system_id': systemId,
      if (minPercentage != null) 'min_percentage': minPercentage,
      if (gradeValue != null) 'grade_value': gradeValue,
      if (gradeLabel != null) 'grade_label': gradeLabel,
    });
  }

  CustomGradingScalesCompanion copyWith({
    Value<int>? id,
    Value<int>? systemId,
    Value<double>? minPercentage,
    Value<double>? gradeValue,
    Value<String?>? gradeLabel,
  }) {
    return CustomGradingScalesCompanion(
      id: id ?? this.id,
      systemId: systemId ?? this.systemId,
      minPercentage: minPercentage ?? this.minPercentage,
      gradeValue: gradeValue ?? this.gradeValue,
      gradeLabel: gradeLabel ?? this.gradeLabel,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (systemId.present) {
      map['system_id'] = Variable<int>(systemId.value);
    }
    if (minPercentage.present) {
      map['min_percentage'] = Variable<double>(minPercentage.value);
    }
    if (gradeValue.present) {
      map['grade_value'] = Variable<double>(gradeValue.value);
    }
    if (gradeLabel.present) {
      map['grade_label'] = Variable<String>(gradeLabel.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomGradingScalesCompanion(')
          ..write('id: $id, ')
          ..write('systemId: $systemId, ')
          ..write('minPercentage: $minPercentage, ')
          ..write('gradeValue: $gradeValue, ')
          ..write('gradeLabel: $gradeLabel')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TermsTable terms = $TermsTable(this);
  late final $CoursesTable courses = $CoursesTable(this);
  late final $GradingComponentsTable gradingComponents =
      $GradingComponentsTable(this);
  late final $AssessmentsTable assessments = $AssessmentsTable(this);
  late final $CustomGradingSystemsTable customGradingSystems =
      $CustomGradingSystemsTable(this);
  late final $CustomGradingScalesTable customGradingScales =
      $CustomGradingScalesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    terms,
    courses,
    gradingComponents,
    assessments,
    customGradingSystems,
    customGradingScales,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'courses',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('grading_components', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'grading_components',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('assessments', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'custom_grading_systems',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('custom_grading_scales', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$TermsTableCreateCompanionBuilder =
    TermsCompanion Function({
      Value<int> id,
      required String name,
      Value<bool> isActive,
    });
typedef $$TermsTableUpdateCompanionBuilder =
    TermsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<bool> isActive,
    });

final class $$TermsTableReferences
    extends BaseReferences<_$AppDatabase, $TermsTable, Term> {
  $$TermsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CoursesTable, List<Course>> _coursesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.courses,
    aliasName: $_aliasNameGenerator(db.terms.id, db.courses.termId),
  );

  $$CoursesTableProcessedTableManager get coursesRefs {
    final manager = $$CoursesTableTableManager(
      $_db,
      $_db.courses,
    ).filter((f) => f.termId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_coursesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TermsTableFilterComposer extends Composer<_$AppDatabase, $TermsTable> {
  $$TermsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> coursesRefs(
    Expression<bool> Function($$CoursesTableFilterComposer f) f,
  ) {
    final $$CoursesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.courses,
      getReferencedColumn: (t) => t.termId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CoursesTableFilterComposer(
            $db: $db,
            $table: $db.courses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TermsTableOrderingComposer
    extends Composer<_$AppDatabase, $TermsTable> {
  $$TermsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TermsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TermsTable> {
  $$TermsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  Expression<T> coursesRefs<T extends Object>(
    Expression<T> Function($$CoursesTableAnnotationComposer a) f,
  ) {
    final $$CoursesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.courses,
      getReferencedColumn: (t) => t.termId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CoursesTableAnnotationComposer(
            $db: $db,
            $table: $db.courses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TermsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TermsTable,
          Term,
          $$TermsTableFilterComposer,
          $$TermsTableOrderingComposer,
          $$TermsTableAnnotationComposer,
          $$TermsTableCreateCompanionBuilder,
          $$TermsTableUpdateCompanionBuilder,
          (Term, $$TermsTableReferences),
          Term,
          PrefetchHooks Function({bool coursesRefs})
        > {
  $$TermsTableTableManager(_$AppDatabase db, $TermsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TermsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TermsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TermsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
              }) => TermsCompanion(id: id, name: name, isActive: isActive),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<bool> isActive = const Value.absent(),
              }) =>
                  TermsCompanion.insert(id: id, name: name, isActive: isActive),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$TermsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({coursesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (coursesRefs) db.courses],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (coursesRefs)
                    await $_getPrefetchedData<Term, $TermsTable, Course>(
                      currentTable: table,
                      referencedTable: $$TermsTableReferences._coursesRefsTable(
                        db,
                      ),
                      managerFromTypedResult: (p0) =>
                          $$TermsTableReferences(db, table, p0).coursesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.termId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TermsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TermsTable,
      Term,
      $$TermsTableFilterComposer,
      $$TermsTableOrderingComposer,
      $$TermsTableAnnotationComposer,
      $$TermsTableCreateCompanionBuilder,
      $$TermsTableUpdateCompanionBuilder,
      (Term, $$TermsTableReferences),
      Term,
      PrefetchHooks Function({bool coursesRefs})
    >;
typedef $$CoursesTableCreateCompanionBuilder =
    CoursesCompanion Function({
      Value<int> id,
      required String code,
      required String name,
      required double units,
      required double targetGwa,
      required String colorHex,
      required int termId,
    });
typedef $$CoursesTableUpdateCompanionBuilder =
    CoursesCompanion Function({
      Value<int> id,
      Value<String> code,
      Value<String> name,
      Value<double> units,
      Value<double> targetGwa,
      Value<String> colorHex,
      Value<int> termId,
    });

final class $$CoursesTableReferences
    extends BaseReferences<_$AppDatabase, $CoursesTable, Course> {
  $$CoursesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TermsTable _termIdTable(_$AppDatabase db) => db.terms.createAlias(
    $_aliasNameGenerator(db.courses.termId, db.terms.id),
  );

  $$TermsTableProcessedTableManager get termId {
    final $_column = $_itemColumn<int>('term_id')!;

    final manager = $$TermsTableTableManager(
      $_db,
      $_db.terms,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_termIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$GradingComponentsTable, List<GradingComponent>>
  _gradingComponentsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.gradingComponents,
        aliasName: $_aliasNameGenerator(
          db.courses.id,
          db.gradingComponents.courseId,
        ),
      );

  $$GradingComponentsTableProcessedTableManager get gradingComponentsRefs {
    final manager = $$GradingComponentsTableTableManager(
      $_db,
      $_db.gradingComponents,
    ).filter((f) => f.courseId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _gradingComponentsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CoursesTableFilterComposer
    extends Composer<_$AppDatabase, $CoursesTable> {
  $$CoursesTableFilterComposer({
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

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get units => $composableBuilder(
    column: $table.units,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get targetGwa => $composableBuilder(
    column: $table.targetGwa,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get colorHex => $composableBuilder(
    column: $table.colorHex,
    builder: (column) => ColumnFilters(column),
  );

  $$TermsTableFilterComposer get termId {
    final $$TermsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.termId,
      referencedTable: $db.terms,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TermsTableFilterComposer(
            $db: $db,
            $table: $db.terms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> gradingComponentsRefs(
    Expression<bool> Function($$GradingComponentsTableFilterComposer f) f,
  ) {
    final $$GradingComponentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.gradingComponents,
      getReferencedColumn: (t) => t.courseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GradingComponentsTableFilterComposer(
            $db: $db,
            $table: $db.gradingComponents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CoursesTableOrderingComposer
    extends Composer<_$AppDatabase, $CoursesTable> {
  $$CoursesTableOrderingComposer({
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

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get units => $composableBuilder(
    column: $table.units,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get targetGwa => $composableBuilder(
    column: $table.targetGwa,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get colorHex => $composableBuilder(
    column: $table.colorHex,
    builder: (column) => ColumnOrderings(column),
  );

  $$TermsTableOrderingComposer get termId {
    final $$TermsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.termId,
      referencedTable: $db.terms,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TermsTableOrderingComposer(
            $db: $db,
            $table: $db.terms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CoursesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CoursesTable> {
  $$CoursesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get units =>
      $composableBuilder(column: $table.units, builder: (column) => column);

  GeneratedColumn<double> get targetGwa =>
      $composableBuilder(column: $table.targetGwa, builder: (column) => column);

  GeneratedColumn<String> get colorHex =>
      $composableBuilder(column: $table.colorHex, builder: (column) => column);

  $$TermsTableAnnotationComposer get termId {
    final $$TermsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.termId,
      referencedTable: $db.terms,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TermsTableAnnotationComposer(
            $db: $db,
            $table: $db.terms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> gradingComponentsRefs<T extends Object>(
    Expression<T> Function($$GradingComponentsTableAnnotationComposer a) f,
  ) {
    final $$GradingComponentsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.gradingComponents,
          getReferencedColumn: (t) => t.courseId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$GradingComponentsTableAnnotationComposer(
                $db: $db,
                $table: $db.gradingComponents,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$CoursesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CoursesTable,
          Course,
          $$CoursesTableFilterComposer,
          $$CoursesTableOrderingComposer,
          $$CoursesTableAnnotationComposer,
          $$CoursesTableCreateCompanionBuilder,
          $$CoursesTableUpdateCompanionBuilder,
          (Course, $$CoursesTableReferences),
          Course,
          PrefetchHooks Function({bool termId, bool gradingComponentsRefs})
        > {
  $$CoursesTableTableManager(_$AppDatabase db, $CoursesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CoursesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CoursesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CoursesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double> units = const Value.absent(),
                Value<double> targetGwa = const Value.absent(),
                Value<String> colorHex = const Value.absent(),
                Value<int> termId = const Value.absent(),
              }) => CoursesCompanion(
                id: id,
                code: code,
                name: name,
                units: units,
                targetGwa: targetGwa,
                colorHex: colorHex,
                termId: termId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String code,
                required String name,
                required double units,
                required double targetGwa,
                required String colorHex,
                required int termId,
              }) => CoursesCompanion.insert(
                id: id,
                code: code,
                name: name,
                units: units,
                targetGwa: targetGwa,
                colorHex: colorHex,
                termId: termId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CoursesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({termId = false, gradingComponentsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (gradingComponentsRefs) db.gradingComponents,
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
                        if (termId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.termId,
                                    referencedTable: $$CoursesTableReferences
                                        ._termIdTable(db),
                                    referencedColumn: $$CoursesTableReferences
                                        ._termIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (gradingComponentsRefs)
                        await $_getPrefetchedData<
                          Course,
                          $CoursesTable,
                          GradingComponent
                        >(
                          currentTable: table,
                          referencedTable: $$CoursesTableReferences
                              ._gradingComponentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CoursesTableReferences(
                                db,
                                table,
                                p0,
                              ).gradingComponentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.courseId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CoursesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CoursesTable,
      Course,
      $$CoursesTableFilterComposer,
      $$CoursesTableOrderingComposer,
      $$CoursesTableAnnotationComposer,
      $$CoursesTableCreateCompanionBuilder,
      $$CoursesTableUpdateCompanionBuilder,
      (Course, $$CoursesTableReferences),
      Course,
      PrefetchHooks Function({bool termId, bool gradingComponentsRefs})
    >;
typedef $$GradingComponentsTableCreateCompanionBuilder =
    GradingComponentsCompanion Function({
      Value<int> id,
      required String name,
      required double weightPercent,
      required int courseId,
    });
typedef $$GradingComponentsTableUpdateCompanionBuilder =
    GradingComponentsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<double> weightPercent,
      Value<int> courseId,
    });

final class $$GradingComponentsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $GradingComponentsTable,
          GradingComponent
        > {
  $$GradingComponentsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CoursesTable _courseIdTable(_$AppDatabase db) =>
      db.courses.createAlias(
        $_aliasNameGenerator(db.gradingComponents.courseId, db.courses.id),
      );

  $$CoursesTableProcessedTableManager get courseId {
    final $_column = $_itemColumn<int>('course_id')!;

    final manager = $$CoursesTableTableManager(
      $_db,
      $_db.courses,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_courseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$AssessmentsTable, List<Assessment>>
  _assessmentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.assessments,
    aliasName: $_aliasNameGenerator(
      db.gradingComponents.id,
      db.assessments.componentId,
    ),
  );

  $$AssessmentsTableProcessedTableManager get assessmentsRefs {
    final manager = $$AssessmentsTableTableManager(
      $_db,
      $_db.assessments,
    ).filter((f) => f.componentId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_assessmentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$GradingComponentsTableFilterComposer
    extends Composer<_$AppDatabase, $GradingComponentsTable> {
  $$GradingComponentsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weightPercent => $composableBuilder(
    column: $table.weightPercent,
    builder: (column) => ColumnFilters(column),
  );

  $$CoursesTableFilterComposer get courseId {
    final $$CoursesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.courseId,
      referencedTable: $db.courses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CoursesTableFilterComposer(
            $db: $db,
            $table: $db.courses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> assessmentsRefs(
    Expression<bool> Function($$AssessmentsTableFilterComposer f) f,
  ) {
    final $$AssessmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.assessments,
      getReferencedColumn: (t) => t.componentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssessmentsTableFilterComposer(
            $db: $db,
            $table: $db.assessments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GradingComponentsTableOrderingComposer
    extends Composer<_$AppDatabase, $GradingComponentsTable> {
  $$GradingComponentsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightPercent => $composableBuilder(
    column: $table.weightPercent,
    builder: (column) => ColumnOrderings(column),
  );

  $$CoursesTableOrderingComposer get courseId {
    final $$CoursesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.courseId,
      referencedTable: $db.courses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CoursesTableOrderingComposer(
            $db: $db,
            $table: $db.courses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GradingComponentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GradingComponentsTable> {
  $$GradingComponentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get weightPercent => $composableBuilder(
    column: $table.weightPercent,
    builder: (column) => column,
  );

  $$CoursesTableAnnotationComposer get courseId {
    final $$CoursesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.courseId,
      referencedTable: $db.courses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CoursesTableAnnotationComposer(
            $db: $db,
            $table: $db.courses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> assessmentsRefs<T extends Object>(
    Expression<T> Function($$AssessmentsTableAnnotationComposer a) f,
  ) {
    final $$AssessmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.assessments,
      getReferencedColumn: (t) => t.componentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssessmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.assessments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GradingComponentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GradingComponentsTable,
          GradingComponent,
          $$GradingComponentsTableFilterComposer,
          $$GradingComponentsTableOrderingComposer,
          $$GradingComponentsTableAnnotationComposer,
          $$GradingComponentsTableCreateCompanionBuilder,
          $$GradingComponentsTableUpdateCompanionBuilder,
          (GradingComponent, $$GradingComponentsTableReferences),
          GradingComponent,
          PrefetchHooks Function({bool courseId, bool assessmentsRefs})
        > {
  $$GradingComponentsTableTableManager(
    _$AppDatabase db,
    $GradingComponentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GradingComponentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GradingComponentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GradingComponentsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double> weightPercent = const Value.absent(),
                Value<int> courseId = const Value.absent(),
              }) => GradingComponentsCompanion(
                id: id,
                name: name,
                weightPercent: weightPercent,
                courseId: courseId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required double weightPercent,
                required int courseId,
              }) => GradingComponentsCompanion.insert(
                id: id,
                name: name,
                weightPercent: weightPercent,
                courseId: courseId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$GradingComponentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({courseId = false, assessmentsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (assessmentsRefs) db.assessments],
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
                    if (courseId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.courseId,
                                referencedTable:
                                    $$GradingComponentsTableReferences
                                        ._courseIdTable(db),
                                referencedColumn:
                                    $$GradingComponentsTableReferences
                                        ._courseIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (assessmentsRefs)
                    await $_getPrefetchedData<
                      GradingComponent,
                      $GradingComponentsTable,
                      Assessment
                    >(
                      currentTable: table,
                      referencedTable: $$GradingComponentsTableReferences
                          ._assessmentsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$GradingComponentsTableReferences(
                            db,
                            table,
                            p0,
                          ).assessmentsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.componentId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$GradingComponentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GradingComponentsTable,
      GradingComponent,
      $$GradingComponentsTableFilterComposer,
      $$GradingComponentsTableOrderingComposer,
      $$GradingComponentsTableAnnotationComposer,
      $$GradingComponentsTableCreateCompanionBuilder,
      $$GradingComponentsTableUpdateCompanionBuilder,
      (GradingComponent, $$GradingComponentsTableReferences),
      GradingComponent,
      PrefetchHooks Function({bool courseId, bool assessmentsRefs})
    >;
typedef $$AssessmentsTableCreateCompanionBuilder =
    AssessmentsCompanion Function({
      Value<int> id,
      required String name,
      required double scoreObtained,
      required double totalItems,
      Value<bool> isExcused,
      Value<bool> isGoal,
      required int componentId,
    });
typedef $$AssessmentsTableUpdateCompanionBuilder =
    AssessmentsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<double> scoreObtained,
      Value<double> totalItems,
      Value<bool> isExcused,
      Value<bool> isGoal,
      Value<int> componentId,
    });

final class $$AssessmentsTableReferences
    extends BaseReferences<_$AppDatabase, $AssessmentsTable, Assessment> {
  $$AssessmentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $GradingComponentsTable _componentIdTable(_$AppDatabase db) =>
      db.gradingComponents.createAlias(
        $_aliasNameGenerator(
          db.assessments.componentId,
          db.gradingComponents.id,
        ),
      );

  $$GradingComponentsTableProcessedTableManager get componentId {
    final $_column = $_itemColumn<int>('component_id')!;

    final manager = $$GradingComponentsTableTableManager(
      $_db,
      $_db.gradingComponents,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_componentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AssessmentsTableFilterComposer
    extends Composer<_$AppDatabase, $AssessmentsTable> {
  $$AssessmentsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get scoreObtained => $composableBuilder(
    column: $table.scoreObtained,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalItems => $composableBuilder(
    column: $table.totalItems,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isExcused => $composableBuilder(
    column: $table.isExcused,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isGoal => $composableBuilder(
    column: $table.isGoal,
    builder: (column) => ColumnFilters(column),
  );

  $$GradingComponentsTableFilterComposer get componentId {
    final $$GradingComponentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.componentId,
      referencedTable: $db.gradingComponents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GradingComponentsTableFilterComposer(
            $db: $db,
            $table: $db.gradingComponents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AssessmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $AssessmentsTable> {
  $$AssessmentsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get scoreObtained => $composableBuilder(
    column: $table.scoreObtained,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalItems => $composableBuilder(
    column: $table.totalItems,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isExcused => $composableBuilder(
    column: $table.isExcused,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isGoal => $composableBuilder(
    column: $table.isGoal,
    builder: (column) => ColumnOrderings(column),
  );

  $$GradingComponentsTableOrderingComposer get componentId {
    final $$GradingComponentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.componentId,
      referencedTable: $db.gradingComponents,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GradingComponentsTableOrderingComposer(
            $db: $db,
            $table: $db.gradingComponents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AssessmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AssessmentsTable> {
  $$AssessmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get scoreObtained => $composableBuilder(
    column: $table.scoreObtained,
    builder: (column) => column,
  );

  GeneratedColumn<double> get totalItems => $composableBuilder(
    column: $table.totalItems,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isExcused =>
      $composableBuilder(column: $table.isExcused, builder: (column) => column);

  GeneratedColumn<bool> get isGoal =>
      $composableBuilder(column: $table.isGoal, builder: (column) => column);

  $$GradingComponentsTableAnnotationComposer get componentId {
    final $$GradingComponentsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.componentId,
          referencedTable: $db.gradingComponents,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$GradingComponentsTableAnnotationComposer(
                $db: $db,
                $table: $db.gradingComponents,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$AssessmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AssessmentsTable,
          Assessment,
          $$AssessmentsTableFilterComposer,
          $$AssessmentsTableOrderingComposer,
          $$AssessmentsTableAnnotationComposer,
          $$AssessmentsTableCreateCompanionBuilder,
          $$AssessmentsTableUpdateCompanionBuilder,
          (Assessment, $$AssessmentsTableReferences),
          Assessment,
          PrefetchHooks Function({bool componentId})
        > {
  $$AssessmentsTableTableManager(_$AppDatabase db, $AssessmentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AssessmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AssessmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AssessmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double> scoreObtained = const Value.absent(),
                Value<double> totalItems = const Value.absent(),
                Value<bool> isExcused = const Value.absent(),
                Value<bool> isGoal = const Value.absent(),
                Value<int> componentId = const Value.absent(),
              }) => AssessmentsCompanion(
                id: id,
                name: name,
                scoreObtained: scoreObtained,
                totalItems: totalItems,
                isExcused: isExcused,
                isGoal: isGoal,
                componentId: componentId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required double scoreObtained,
                required double totalItems,
                Value<bool> isExcused = const Value.absent(),
                Value<bool> isGoal = const Value.absent(),
                required int componentId,
              }) => AssessmentsCompanion.insert(
                id: id,
                name: name,
                scoreObtained: scoreObtained,
                totalItems: totalItems,
                isExcused: isExcused,
                isGoal: isGoal,
                componentId: componentId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AssessmentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({componentId = false}) {
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
                    if (componentId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.componentId,
                                referencedTable: $$AssessmentsTableReferences
                                    ._componentIdTable(db),
                                referencedColumn: $$AssessmentsTableReferences
                                    ._componentIdTable(db)
                                    .id,
                              )
                              as T;
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

typedef $$AssessmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AssessmentsTable,
      Assessment,
      $$AssessmentsTableFilterComposer,
      $$AssessmentsTableOrderingComposer,
      $$AssessmentsTableAnnotationComposer,
      $$AssessmentsTableCreateCompanionBuilder,
      $$AssessmentsTableUpdateCompanionBuilder,
      (Assessment, $$AssessmentsTableReferences),
      Assessment,
      PrefetchHooks Function({bool componentId})
    >;
typedef $$CustomGradingSystemsTableCreateCompanionBuilder =
    CustomGradingSystemsCompanion Function({
      Value<int> id,
      required String name,
      Value<bool> isHigherBetter,
    });
typedef $$CustomGradingSystemsTableUpdateCompanionBuilder =
    CustomGradingSystemsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<bool> isHigherBetter,
    });

final class $$CustomGradingSystemsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $CustomGradingSystemsTable,
          CustomGradingSystem
        > {
  $$CustomGradingSystemsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<
    $CustomGradingScalesTable,
    List<CustomGradingScale>
  >
  _customGradingScalesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.customGradingScales,
        aliasName: $_aliasNameGenerator(
          db.customGradingSystems.id,
          db.customGradingScales.systemId,
        ),
      );

  $$CustomGradingScalesTableProcessedTableManager get customGradingScalesRefs {
    final manager = $$CustomGradingScalesTableTableManager(
      $_db,
      $_db.customGradingScales,
    ).filter((f) => f.systemId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _customGradingScalesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CustomGradingSystemsTableFilterComposer
    extends Composer<_$AppDatabase, $CustomGradingSystemsTable> {
  $$CustomGradingSystemsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isHigherBetter => $composableBuilder(
    column: $table.isHigherBetter,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> customGradingScalesRefs(
    Expression<bool> Function($$CustomGradingScalesTableFilterComposer f) f,
  ) {
    final $$CustomGradingScalesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.customGradingScales,
      getReferencedColumn: (t) => t.systemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomGradingScalesTableFilterComposer(
            $db: $db,
            $table: $db.customGradingScales,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CustomGradingSystemsTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomGradingSystemsTable> {
  $$CustomGradingSystemsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isHigherBetter => $composableBuilder(
    column: $table.isHigherBetter,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CustomGradingSystemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomGradingSystemsTable> {
  $$CustomGradingSystemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<bool> get isHigherBetter => $composableBuilder(
    column: $table.isHigherBetter,
    builder: (column) => column,
  );

  Expression<T> customGradingScalesRefs<T extends Object>(
    Expression<T> Function($$CustomGradingScalesTableAnnotationComposer a) f,
  ) {
    final $$CustomGradingScalesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.customGradingScales,
          getReferencedColumn: (t) => t.systemId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CustomGradingScalesTableAnnotationComposer(
                $db: $db,
                $table: $db.customGradingScales,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$CustomGradingSystemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CustomGradingSystemsTable,
          CustomGradingSystem,
          $$CustomGradingSystemsTableFilterComposer,
          $$CustomGradingSystemsTableOrderingComposer,
          $$CustomGradingSystemsTableAnnotationComposer,
          $$CustomGradingSystemsTableCreateCompanionBuilder,
          $$CustomGradingSystemsTableUpdateCompanionBuilder,
          (CustomGradingSystem, $$CustomGradingSystemsTableReferences),
          CustomGradingSystem,
          PrefetchHooks Function({bool customGradingScalesRefs})
        > {
  $$CustomGradingSystemsTableTableManager(
    _$AppDatabase db,
    $CustomGradingSystemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomGradingSystemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomGradingSystemsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CustomGradingSystemsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<bool> isHigherBetter = const Value.absent(),
              }) => CustomGradingSystemsCompanion(
                id: id,
                name: name,
                isHigherBetter: isHigherBetter,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<bool> isHigherBetter = const Value.absent(),
              }) => CustomGradingSystemsCompanion.insert(
                id: id,
                name: name,
                isHigherBetter: isHigherBetter,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CustomGradingSystemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({customGradingScalesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (customGradingScalesRefs) db.customGradingScales,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (customGradingScalesRefs)
                    await $_getPrefetchedData<
                      CustomGradingSystem,
                      $CustomGradingSystemsTable,
                      CustomGradingScale
                    >(
                      currentTable: table,
                      referencedTable: $$CustomGradingSystemsTableReferences
                          ._customGradingScalesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CustomGradingSystemsTableReferences(
                            db,
                            table,
                            p0,
                          ).customGradingScalesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.systemId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CustomGradingSystemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CustomGradingSystemsTable,
      CustomGradingSystem,
      $$CustomGradingSystemsTableFilterComposer,
      $$CustomGradingSystemsTableOrderingComposer,
      $$CustomGradingSystemsTableAnnotationComposer,
      $$CustomGradingSystemsTableCreateCompanionBuilder,
      $$CustomGradingSystemsTableUpdateCompanionBuilder,
      (CustomGradingSystem, $$CustomGradingSystemsTableReferences),
      CustomGradingSystem,
      PrefetchHooks Function({bool customGradingScalesRefs})
    >;
typedef $$CustomGradingScalesTableCreateCompanionBuilder =
    CustomGradingScalesCompanion Function({
      Value<int> id,
      required int systemId,
      required double minPercentage,
      required double gradeValue,
      Value<String?> gradeLabel,
    });
typedef $$CustomGradingScalesTableUpdateCompanionBuilder =
    CustomGradingScalesCompanion Function({
      Value<int> id,
      Value<int> systemId,
      Value<double> minPercentage,
      Value<double> gradeValue,
      Value<String?> gradeLabel,
    });

final class $$CustomGradingScalesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $CustomGradingScalesTable,
          CustomGradingScale
        > {
  $$CustomGradingScalesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CustomGradingSystemsTable _systemIdTable(_$AppDatabase db) =>
      db.customGradingSystems.createAlias(
        $_aliasNameGenerator(
          db.customGradingScales.systemId,
          db.customGradingSystems.id,
        ),
      );

  $$CustomGradingSystemsTableProcessedTableManager get systemId {
    final $_column = $_itemColumn<int>('system_id')!;

    final manager = $$CustomGradingSystemsTableTableManager(
      $_db,
      $_db.customGradingSystems,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_systemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CustomGradingScalesTableFilterComposer
    extends Composer<_$AppDatabase, $CustomGradingScalesTable> {
  $$CustomGradingScalesTableFilterComposer({
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

  ColumnFilters<double> get minPercentage => $composableBuilder(
    column: $table.minPercentage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get gradeValue => $composableBuilder(
    column: $table.gradeValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gradeLabel => $composableBuilder(
    column: $table.gradeLabel,
    builder: (column) => ColumnFilters(column),
  );

  $$CustomGradingSystemsTableFilterComposer get systemId {
    final $$CustomGradingSystemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.systemId,
      referencedTable: $db.customGradingSystems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomGradingSystemsTableFilterComposer(
            $db: $db,
            $table: $db.customGradingSystems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CustomGradingScalesTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomGradingScalesTable> {
  $$CustomGradingScalesTableOrderingComposer({
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

  ColumnOrderings<double> get minPercentage => $composableBuilder(
    column: $table.minPercentage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get gradeValue => $composableBuilder(
    column: $table.gradeValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gradeLabel => $composableBuilder(
    column: $table.gradeLabel,
    builder: (column) => ColumnOrderings(column),
  );

  $$CustomGradingSystemsTableOrderingComposer get systemId {
    final $$CustomGradingSystemsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.systemId,
          referencedTable: $db.customGradingSystems,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CustomGradingSystemsTableOrderingComposer(
                $db: $db,
                $table: $db.customGradingSystems,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$CustomGradingScalesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomGradingScalesTable> {
  $$CustomGradingScalesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get minPercentage => $composableBuilder(
    column: $table.minPercentage,
    builder: (column) => column,
  );

  GeneratedColumn<double> get gradeValue => $composableBuilder(
    column: $table.gradeValue,
    builder: (column) => column,
  );

  GeneratedColumn<String> get gradeLabel => $composableBuilder(
    column: $table.gradeLabel,
    builder: (column) => column,
  );

  $$CustomGradingSystemsTableAnnotationComposer get systemId {
    final $$CustomGradingSystemsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.systemId,
          referencedTable: $db.customGradingSystems,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CustomGradingSystemsTableAnnotationComposer(
                $db: $db,
                $table: $db.customGradingSystems,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$CustomGradingScalesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CustomGradingScalesTable,
          CustomGradingScale,
          $$CustomGradingScalesTableFilterComposer,
          $$CustomGradingScalesTableOrderingComposer,
          $$CustomGradingScalesTableAnnotationComposer,
          $$CustomGradingScalesTableCreateCompanionBuilder,
          $$CustomGradingScalesTableUpdateCompanionBuilder,
          (CustomGradingScale, $$CustomGradingScalesTableReferences),
          CustomGradingScale,
          PrefetchHooks Function({bool systemId})
        > {
  $$CustomGradingScalesTableTableManager(
    _$AppDatabase db,
    $CustomGradingScalesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomGradingScalesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomGradingScalesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CustomGradingScalesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> systemId = const Value.absent(),
                Value<double> minPercentage = const Value.absent(),
                Value<double> gradeValue = const Value.absent(),
                Value<String?> gradeLabel = const Value.absent(),
              }) => CustomGradingScalesCompanion(
                id: id,
                systemId: systemId,
                minPercentage: minPercentage,
                gradeValue: gradeValue,
                gradeLabel: gradeLabel,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int systemId,
                required double minPercentage,
                required double gradeValue,
                Value<String?> gradeLabel = const Value.absent(),
              }) => CustomGradingScalesCompanion.insert(
                id: id,
                systemId: systemId,
                minPercentage: minPercentage,
                gradeValue: gradeValue,
                gradeLabel: gradeLabel,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CustomGradingScalesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({systemId = false}) {
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
                    if (systemId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.systemId,
                                referencedTable:
                                    $$CustomGradingScalesTableReferences
                                        ._systemIdTable(db),
                                referencedColumn:
                                    $$CustomGradingScalesTableReferences
                                        ._systemIdTable(db)
                                        .id,
                              )
                              as T;
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

typedef $$CustomGradingScalesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CustomGradingScalesTable,
      CustomGradingScale,
      $$CustomGradingScalesTableFilterComposer,
      $$CustomGradingScalesTableOrderingComposer,
      $$CustomGradingScalesTableAnnotationComposer,
      $$CustomGradingScalesTableCreateCompanionBuilder,
      $$CustomGradingScalesTableUpdateCompanionBuilder,
      (CustomGradingScale, $$CustomGradingScalesTableReferences),
      CustomGradingScale,
      PrefetchHooks Function({bool systemId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TermsTableTableManager get terms =>
      $$TermsTableTableManager(_db, _db.terms);
  $$CoursesTableTableManager get courses =>
      $$CoursesTableTableManager(_db, _db.courses);
  $$GradingComponentsTableTableManager get gradingComponents =>
      $$GradingComponentsTableTableManager(_db, _db.gradingComponents);
  $$AssessmentsTableTableManager get assessments =>
      $$AssessmentsTableTableManager(_db, _db.assessments);
  $$CustomGradingSystemsTableTableManager get customGradingSystems =>
      $$CustomGradingSystemsTableTableManager(_db, _db.customGradingSystems);
  $$CustomGradingScalesTableTableManager get customGradingScales =>
      $$CustomGradingScalesTableTableManager(_db, _db.customGradingScales);
}

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(database)
final databaseProvider = DatabaseProvider._();

final class DatabaseProvider
    extends $FunctionalProvider<AppDatabase, AppDatabase, AppDatabase>
    with $Provider<AppDatabase> {
  DatabaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'databaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$databaseHash();

  @$internal
  @override
  $ProviderElement<AppDatabase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppDatabase create(Ref ref) {
    return database(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppDatabase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppDatabase>(value),
    );
  }
}

String _$databaseHash() => r'e5a1fa0e8ff9aa131f847f28519ec2098e6d0f76';
