import 'package:flutter/material.dart';

extension TextStyleExtension on TextStyle {
  // Heading styles
  TextStyle get heading32 =>
      copyWith(fontSize: 32, fontWeight: FontWeight.bold);
  TextStyle get heading24 =>
      copyWith(fontSize: 24, fontWeight: FontWeight.bold);
  TextStyle get heading20 =>
      copyWith(fontSize: 20, fontWeight: FontWeight.bold);
  TextStyle get heading18 =>
      copyWith(fontSize: 18, fontWeight: FontWeight.bold);
  TextStyle get heading16 =>
      copyWith(fontSize: 16, fontWeight: FontWeight.bold);

  // Body text styles
  TextStyle get body16 => copyWith(fontSize: 16);
  TextStyle get body14 => copyWith(fontSize: 14);
  TextStyle get body12 => copyWith(fontSize: 12);

  // Caption styles
  TextStyle get caption12 => copyWith(fontSize: 12, color: Colors.grey);
  TextStyle get caption10 => copyWith(fontSize: 10, color: Colors.grey);

  // Button text styles
  TextStyle get button16 => copyWith(fontSize: 16, fontWeight: FontWeight.w500);
  TextStyle get button14 => copyWith(fontSize: 14, fontWeight: FontWeight.w500);

  // Label styles
  TextStyle get label14 => copyWith(fontSize: 14, fontWeight: FontWeight.w500);
  TextStyle get label12 => copyWith(fontSize: 12, fontWeight: FontWeight.w500);
}

/* Usage Examples:

1. Using with Theme's default text style:
Text(
  'Hello World',
  style: Theme.of(context).textTheme.bodyLarge?.body16,
)

2. Using with a custom TextStyle:
Text(
  'Hello World',
  style: TextStyle(color: Colors.blue).heading24,
)

3. Chaining multiple styles:
Text(
  'Hello World',
  style: TextStyle(color: Colors.blue).heading20.copyWith(letterSpacing: 1.2),
)

4. Using in a widget:
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(
      'Title',
      style: Theme.of(context).textTheme.titleLarge?.heading24,
    );
  }
}
*/
