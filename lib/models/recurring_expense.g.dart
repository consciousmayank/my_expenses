// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurring_expense.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RecurringExpenseAdapter extends TypeAdapter<RecurringExpense> {
  @override
  final int typeId = 1;

  @override
  RecurringExpense read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RecurringExpense(
      name: fields[0] as String,
      description: fields[1] as String?,
      amount: fields[2] as double,
      startDate: fields[3] as DateTime,
      endDate: fields[4] as DateTime,
      type: fields[5] as RecurringExpenseType,
      customIntervalDays: fields[6] as int?,
      id: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, RecurringExpense obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.description)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.startDate)
      ..writeByte(4)
      ..write(obj.endDate)
      ..writeByte(5)
      ..write(obj.type)
      ..writeByte(6)
      ..write(obj.customIntervalDays)
      ..writeByte(7)
      ..write(obj.id);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecurringExpenseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RecurringExpenseTypeAdapter extends TypeAdapter<RecurringExpenseType> {
  @override
  final int typeId = 3;

  @override
  RecurringExpenseType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return RecurringExpenseType.daily;
      case 1:
        return RecurringExpenseType.weekly;
      case 2:
        return RecurringExpenseType.monthly;
      case 3:
        return RecurringExpenseType.quarterly;
      case 4:
        return RecurringExpenseType.annually;
      case 5:
        return RecurringExpenseType.custom;
      default:
        return RecurringExpenseType.daily;
    }
  }

  @override
  void write(BinaryWriter writer, RecurringExpenseType obj) {
    switch (obj) {
      case RecurringExpenseType.daily:
        writer.writeByte(0);
        break;
      case RecurringExpenseType.weekly:
        writer.writeByte(1);
        break;
      case RecurringExpenseType.monthly:
        writer.writeByte(2);
        break;
      case RecurringExpenseType.quarterly:
        writer.writeByte(3);
        break;
      case RecurringExpenseType.annually:
        writer.writeByte(4);
        break;
      case RecurringExpenseType.custom:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecurringExpenseTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
