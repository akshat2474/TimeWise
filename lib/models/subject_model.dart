import 'package:uuid/uuid.dart';

enum SubjectType { theory, practical, elective }
enum CreditType { fourCredit, twoCredit }

class Subject {
  final String id; // UUID for stable identification
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

  // Calculate total hours based on credit and type
  int get totalTheoryHours {
    if (creditType == CreditType.fourCredit) {
      return hasPractical ? 42 : 42; // 4-credit: 42 theory (with or without practical)
    } else {
      // 2-credit
      if (subjectType == SubjectType.elective) {
        return 28; // 2-credit elective: 28 hours total
      } else {
        return 14; // 2-credit practical: 14 theory + 28 practical
      }
    }
  }

  int get totalPracticalHours {
    if (!hasPractical) return 0;
    
    if (creditType == CreditType.fourCredit) {
      return 28; // 4-credit practical: 28 practical hours
    } else {
      return 28; // 2-credit practical: 28 practical hours
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

  // Create a copy with updated name (keeping same ID)
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
