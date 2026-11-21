import 'package:flutter/material.dart';

class ExpenseCategory {
  const ExpenseCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });

  final String id;
  final String name;
  final IconData icon;
  final Color color;

  String get label => name;

  ExpenseCategory copyWith({
    String? id,
    String? name,
    IconData? icon,
    Color? color,
  }) {
    return ExpenseCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'iconCode': icon.codePoint,
        'colorValue': color.value,
      };

  factory ExpenseCategory.fromJson(Map<String, dynamic> json) =>
      ExpenseCategory(
        id: json['id'] as String,
        name: (json['name'] as String?) ?? 'Categoria',
        icon: IconData(
          // ignore: non_const_argument_for_const_parameter
          (json['iconCode'] as num?)?.toInt() ??
              Icons.receipt_long_outlined.codePoint,
          fontFamily: 'MaterialIcons',
        ),
        color: Color((json['colorValue'] as num?)?.toInt() ?? 0xFF475569),
      );

  static ExpenseCategory resolve(
    dynamic raw, [
    List<ExpenseCategory>? categories,
  ]) {
    final pool = categories ?? defaultCategories;
    if (raw == null) {
      return pool.isNotEmpty ? pool.last : defaultCategories.last;
    }
    if (raw is Map<String, dynamic>) {
      final id = raw['id'] as String?;
      if (id != null) {
        for (final c in pool) {
          if (c.id == id) return c;
        }
      }
      return ExpenseCategory.fromJson(raw);
    }
    if (raw is String) {
      for (final c in pool) {
        if (c.id == raw || c.name == raw) return c;
      }
    }
    return pool.isNotEmpty ? pool.last : defaultCategories.last;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpenseCategory &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  static const List<ExpenseCategory> defaultCategories = [
    ExpenseCategory(
      id: 'venue',
      name: 'Espaço / Local',
      icon: Icons.location_city_outlined,
      color: Color(0xFF2563EB),
    ),
    ExpenseCategory(
      id: 'catering',
      name: 'Buffet e Bebidas',
      icon: Icons.restaurant_outlined,
      color: Color(0xFFD97706),
    ),
    ExpenseCategory(
      id: 'decorations',
      name: 'Decoração',
      icon: Icons.celebration_outlined,
      color: Color(0xFF7C3AED),
    ),
    ExpenseCategory(
      id: 'entertainment',
      name: 'Entretenimento',
      icon: Icons.music_note_outlined,
      color: Color(0xFF0D9488),
    ),
    ExpenseCategory(
      id: 'gifts',
      name: 'Lembrancinhas',
      icon: Icons.card_giftcard_outlined,
      color: Color(0xFFDB2777),
    ),
    ExpenseCategory(
      id: 'photography',
      name: 'Fotografia',
      icon: Icons.camera_alt_outlined,
      color: Color(0xFF4F46E5),
    ),
    ExpenseCategory(
      id: 'invitations',
      name: 'Convites',
      icon: Icons.mail_outline,
      color: Color(0xFF0284C7),
    ),
    ExpenseCategory(
      id: 'other',
      name: 'Outros',
      icon: Icons.receipt_long_outlined,
      color: Color(0xFF475569),
    ),
  ];
}

class ExpenseItem {
  const ExpenseItem({
    required this.id,
    required this.title,
    required this.vendor,
    required this.amount,
    required this.category,
    required this.date,
    required this.isPaid,
    this.notes = '',
  });

  final String id;
  final String title;
  final String vendor;
  final double amount;
  final ExpenseCategory category;
  final DateTime date;
  final bool isPaid;
  final String notes;

  ExpenseItem copyWith({
    String? id,
    String? title,
    String? vendor,
    double? amount,
    ExpenseCategory? category,
    DateTime? date,
    bool? isPaid,
    String? notes,
  }) {
    return ExpenseItem(
      id: id ?? this.id,
      title: title ?? this.title,
      vendor: vendor ?? this.vendor,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      isPaid: isPaid ?? this.isPaid,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'vendor': vendor,
        'amount': amount,
        'category': category.toJson(),
        'date': date.toIso8601String(),
        'isPaid': isPaid,
        'notes': notes,
      };

  factory ExpenseItem.fromJson(
    Map<String, dynamic> json, {
    List<ExpenseCategory>? categories,
  }) =>
      ExpenseItem(
        id: json['id'] as String,
        title: json['title'] as String,
        vendor: (json['vendor'] as String?) ?? '',
        amount: (json['amount'] as num).toDouble(),
        category: ExpenseCategory.resolve(json['category'], categories),
        date: DateTime.parse(json['date'] as String),
        isPaid: (json['isPaid'] as bool?) ?? false,
        notes: (json['notes'] as String?) ?? '',
      );
}

class PersonalEvent {
  const PersonalEvent({
    required this.id,
    required this.name,
    required this.eventDate,
    required this.venue,
    required this.budget,
    required this.expenses,
    this.notes = '',
    this.isArchived = false,
  });

  final String id;
  final String name;
  final DateTime eventDate;
  final String venue;
  final double budget;
  final List<ExpenseItem> expenses;
  final String notes;
  final bool isArchived;

  double get totalSpent =>
      expenses.fold<double>(0, (sum, item) => sum + item.amount);

  double get paidAmount => expenses
      .where((e) => e.isPaid)
      .fold<double>(0, (sum, item) => sum + item.amount);

  double get unpaidAmount => expenses
      .where((e) => !e.isPaid)
      .fold<double>(0, (sum, item) => sum + item.amount);

  double get budgetRemaining => budget - totalSpent;

  bool get hasBudget => budget > 0;

  double get budgetUtilization =>
      budget <= 0 ? 0 : (totalSpent / budget).clamp(0.0, 1.5);

  int get paidCount => expenses.where((e) => e.isPaid).length;

  Map<ExpenseCategory, double> get categoryTotals {
    final map = <ExpenseCategory, double>{};
    for (final expense in expenses) {
      map[expense.category] = (map[expense.category] ?? 0) + expense.amount;
    }
    return map;
  }

  PersonalEvent copyWith({
    String? id,
    String? name,
    DateTime? eventDate,
    String? venue,
    double? budget,
    List<ExpenseItem>? expenses,
    String? notes,
    bool? isArchived,
  }) {
    return PersonalEvent(
      id: id ?? this.id,
      name: name ?? this.name,
      eventDate: eventDate ?? this.eventDate,
      venue: venue ?? this.venue,
      budget: budget ?? this.budget,
      expenses: expenses ?? this.expenses,
      notes: notes ?? this.notes,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'eventDate': eventDate.toIso8601String(),
        'venue': venue,
        'budget': budget,
        'notes': notes,
        'isArchived': isArchived,
        'expenses': expenses.map((e) => e.toJson()).toList(),
      };

  factory PersonalEvent.fromJson(
    Map<String, dynamic> json, {
    List<ExpenseCategory>? categories,
  }) =>
      PersonalEvent(
        id: json['id'] as String,
        name: json['name'] as String,
        eventDate: DateTime.parse(json['eventDate'] as String),
        venue: (json['venue'] as String?) ?? '',
        budget: (json['budget'] as num).toDouble(),
        notes: (json['notes'] as String?) ?? '',
        isArchived: (json['isArchived'] as bool?) ?? false,
        expenses: (json['expenses'] as List<dynamic>? ?? [])
            .map((e) => ExpenseItem.fromJson(
                  e as Map<String, dynamic>,
                  categories: categories,
                ))
            .toList(),
      );
}
