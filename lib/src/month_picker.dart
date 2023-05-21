import 'package:flutter/material.dart';

import 'header.dart';
import 'month_view.dart';
import 'show_date_picker_dialog.dart';

/// A scrollable grid of months to allow picking a month.
///
/// The month picker widget is rarely used directly. Instead, consider using
/// [showDatePickerDialog], which will create a dialog that uses this as well as
/// provides a text entry option.
///
/// See also:
///
///  * [showDatePickerDialog], which creates a Dialog that contains a
///    [DatePicker] and provides an optional compact view where the
///
class MonthPicker extends StatefulWidget {
  /// Creates a month picker.
  ///
  /// The [maxDate], [minDate], [initialDate] arguments
  /// must be non-null. The [minDate] must be after the [maxDate].
  MonthPicker({
    super.key,
    this.onChange,
    required this.minDate,
    required this.maxDate,
    required this.initialDate,
    this.onLeadingDateTap,
    this.enabledMonthsColor,
    this.disbaledMonthsColor,
    this.currentMonthColor,
    this.selectedMonthColor,
    this.selectedMonthFillColor,
  }) : assert(!minDate.isAfter(maxDate), "minDate can't be after maxDate");

  /// Called when the user picks a month.
  final ValueChanged<DateTime>? onChange;

  /// The earliest date the user is permitted to pick.
  ///
  /// This date must be on or before the [maxDate].
  final DateTime minDate;

  /// The latest date the user is permitted to pick.
  ///
  /// This date must be on or after the [minDate].
  final DateTime maxDate;

  /// The date which will be displayed on first opening.
  final DateTime initialDate;

  /// Called when the user tap on the leading date.
  final VoidCallback? onLeadingDateTap;

  /// The color of enabled month which are selectable.
  ///
  /// defaults to [ColorScheme.onSurface].
  final Color? enabledMonthsColor;

  /// The color of disabled months which are not selectable.
  ///
  /// defaults to [ColorScheme.onSurface] with 30% opacity.
  final Color? disbaledMonthsColor;

  /// The color of the current month.
  ///
  /// defaults to [ColorScheme.primary].
  final Color? currentMonthColor;

  /// The color of the selected month.
  ///
  /// defaults to [ColorScheme.onPrimary].
  final Color? selectedMonthColor;

  /// The fill color of the selected month.
  ///
  /// defaults to [ColorScheme.primary].
  final Color? selectedMonthFillColor;

  @override
  State<MonthPicker> createState() => _MonthPickerState();
}

class _MonthPickerState extends State<MonthPicker> {
  DateTime? _displayedYear;
  DateTime? _selectedMonth;

  final GlobalKey _pageViewKey = GlobalKey();
  late final PageController _pageController;

  int get yearsCount => (widget.maxDate.year - widget.minDate.year) + 1;

  @override
  void initState() {
    _displayedYear = widget.initialDate;
    // _selectedMonth = widget.selectedDate;
    _pageController = PageController(
      initialPage: (widget.initialDate.year - widget.minDate.year),
    );
    super.initState();
  }

  @override
  void didUpdateWidget(covariant MonthPicker oldWidget) {
    // for makeing debuging easy, we will navigate to the initial date again
    // if it changes.
    if (oldWidget.initialDate.year != widget.initialDate.year) {
      _pageController
          .jumpToPage((widget.initialDate.year - widget.minDate.year));
    }
    // if (oldWidget.selectedDate != widget.selectedDate) {
    //   _selectedMonth = widget.selectedDate;
    // }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildItems(BuildContext context, int index) {
    final DateTime yearDate = DateTime(
        widget.minDate.year + index, widget.minDate.month, widget.minDate.day);

    return MonthView(
      key: ValueKey<DateTime>(yearDate),
      currentDate: DateTime.now(),
      minDate: widget.minDate,
      maxDate: widget.maxDate,
      displayedYear: yearDate,
      selectedMonth: _selectedMonth,
      currentMonthColor: widget.currentMonthColor,
      disbaledMonthsColor: widget.disbaledMonthsColor,
      enabledMonthsColor: widget.enabledMonthsColor,
      selectedMonthColor: widget.selectedMonthColor,
      selectedMonthFillColor: widget.selectedMonthFillColor,
      onChanged: (value) {
        widget.onChange?.call(value);
        setState(() {
          _selectedMonth = value;
        });
      },
    );
  }

  void _handleYearPageChanged(int yearPage) {
    final DateTime yearDate = DateTime(widget.minDate.year + yearPage,
        widget.minDate.month, widget.minDate.day);

    setState(() {
      _displayedYear = yearDate;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Header(
          onDateTap: () => widget.onLeadingDateTap?.call(),
          displayedDate: _displayedYear!.year.toString(),
          onNextPage: () {
            _pageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.ease,
            );
          },
          onPreviousPage: () {
            _pageController.previousPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.ease,
            );
          },
        ),
        const SizedBox(height: 10),
        AnimatedContainer(
          height: 78 * 4,
          duration: const Duration(milliseconds: 200),
          child: PageView.builder(
            scrollDirection: Axis.horizontal,
            key: _pageViewKey,
            controller: _pageController,
            itemCount: yearsCount,
            itemBuilder: _buildItems,
            onPageChanged: _handleYearPageChanged,
          ),
        ),
      ],
    );
  }
}