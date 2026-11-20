import 'package:flutter/material.dart';

enum ExpenseCategory {
  venue('Espaço / Local', Icons.location_city_outlined, Color(0xFF2563EB)),
  catering('Buffet e Bebidas', Icons.restaurant_outlined, Color(0xFFD97706)),
  decorations('Decoração', Icons.celebration_outlined, Color(0xFF7C3AED)),
  entertainment('Entretenimento', Icons.music_note_outlined, Color(0xFF0D9488)),
  gifts('Lembrancinhas', Icons.card_giftcard_outlined, Color(0xFFDB2777)),
  photography('Fotografia', Icons.camera_alt_outlined, Color(0xFF4F46E5)),
  invitations('Convites', Icons.mail_outline, Color(0xFF0284C7)),
  other('Outros', Icons.receipt_long_outlined, Color(0xFF475569));

  const ExpenseCategory(this.label, this.icon, this.color);

  final String label;
  final IconData icon;
  final Color color;

  static ExpenseCategory fromName(String? value) {
    return ExpenseCategory.values.firstWhere(
      (c) => c.name == value,
      orElse: () => ExpenseCategory.other,
    );
  }
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
        'category': category.name,
        'date': date.toIso8601String(),
        'isPaid': isPaid,
        'notes': notes,
      };

  factory ExpenseItem.fromJson(Map<String, dynamic> json) => ExpenseItem(
        id: json['id'] as String,
        title: json['title'] as String,
        vendor: (json['vendor'] as String?) ?? '',
        amount: (json['amount'] as num).toDouble(),
        category: ExpenseCategory.fromName(json['category'] as String?),
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
  });

  final String id;
  final String name;
  final DateTime eventDate;
  final String venue;
  final double budget;
  final List<ExpenseItem> expenses;
  final String notes;

  double get totalSpent =>
      expenses.fold<double>(0, (sum, item) => sum + item.amount);

  double get paidAmount => expenses
      .where((e) => e.isPaid)
      .fold<double>(0, (sum, item) => sum + item.amount);

  double get unpaidAmount => expenses
      .where((e) => !e.isPaid)
      .fold<double>(0, (sum, item) => sum + item.amount);

  double get budgetRemaining => budget - totalSpent;

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
  }) {
    return PersonalEvent(
      id: id ?? this.id,
      name: name ?? this.name,
      eventDate: eventDate ?? this.eventDate,
      venue: venue ?? this.venue,
      budget: budget ?? this.budget,
      expenses: expenses ?? this.expenses,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'eventDate': eventDate.toIso8601String(),
        'venue': venue,
        'budget': budget,
        'notes': notes,
        'expenses': expenses.map((e) => e.toJson()).toList(),
      };

  factory PersonalEvent.fromJson(Map<String, dynamic> json) => PersonalEvent(
        id: json['id'] as String,
        name: json['name'] as String,
        eventDate: DateTime.parse(json['eventDate'] as String),
        venue: (json['venue'] as String?) ?? '',
        budget: (json['budget'] as num).toDouble(),
        notes: (json['notes'] as String?) ?? '',
        expenses: (json['expenses'] as List<dynamic>? ?? [])
            .map((e) => ExpenseItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
