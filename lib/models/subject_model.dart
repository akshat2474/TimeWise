import 'package:uuid/uuid.dart';

enum SubjectType { theory, practical, elective }

enum CreditType { fourCredit, twoCredit }

class Subject {
  final String id;
  String name;
  final bool hasPractical;
  final CreditType creditType;
  final SubjectType subjectType;

  Subject({
    String? id,
    required this.name,
    required this.hasPractical,
    required this.creditType,
    required this.subjectType,
  }) : id = id ?? const Uuid().v4();
  int get totalTheoryHours {
    if (creditType == CreditType.fourCredit) {
      return hasPractical ? 42 : 42;
    } else {
      if (subjectType == SubjectType.elective) {
        return 28;
      } else {
        return 14;
      }
    }
  }

  int get totalPracticalHours {
    if (!hasPractical) return 0;

    if (creditType == CreditType.fourCredit) {
      return 28;
    } else {
      return 28;
    }
  }

  int get totalHours => totalTheoryHours + totalPracticalHours;

  String get creditDescription {
    if (creditType == CreditType.fourCredit) {
      return hasPractical
          ? '4-Credit (42h Theory + 28h Practical)'
          : '4-Credit Theory (42h)';
    } else {
      if (subjectType == SubjectType.elective) {
        return '2-Credit Elective (28h)';
      } else {
        return '2-Credit Practical (14h Theory + 28h Practical)';
      }
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'hasPractical': hasPractical,
      'creditType': creditType.name,
      'subjectType': subjectType.name,
    };
  }

  static Subject fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'],
      name: json['name'],
      hasPractical: json['hasPractical'],
      creditType: CreditType.values.firstWhere(
        (e) => e.name == json['creditType'],
      ),
      subjectType: SubjectType.values.firstWhere(
        (e) => e.name == json['subjectType'],
      ),
    );
  }

  Subject copyWith({String? name}) {
    return Subject(
      id: id,
      name: name ?? this.name,
      hasPractical: hasPractical,
      creditType: creditType,
      subjectType: subjectType,
    );
  }
}
