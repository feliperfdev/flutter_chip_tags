library flutter_chip_tags;

import 'package:flutter/material.dart';
import 'package:flutter_chip_tags/src/core/util/enum.dart';

export './src/core/util/enum.dart';

class ChipTags extends StatefulWidget {
  const ChipTags({
    Key? key,
    this.iconColor,
    this.chipColor,
    this.textColor,
    this.decoration,
    this.keyboardType,
    this.separators,
    this.createTagOnSubmit = false,
    this.chipPosition = ChipPosition.below,
    this.inputController,
    this.onTapOutside,
    this.ignoreInput = false,
    this.ignoreChips = false,
    this.validator,
    this.onRemoveIconTap,
    this.onSeparatorApplied,
    required this.list,
  }) : super(key: key);

  ///sets the remove icon Color
  final Color? iconColor;

  ///sets the chip background color
  final Color? chipColor;

  ///sets the color of text inside chip
  final Color? textColor;

  ///container decoration
  final InputDecoration? decoration;

  ///set keyboardType
  final TextInputType? keyboardType;

  ///customer symbol to separate tags by default
  ///it is " " space.
  final List<String>? separators;

  //sets a custom TextEditingController
  final TextEditingController? inputController;

  /// list of String to display
  final List<String> list;

  final ChipPosition chipPosition;

  /// Default `createTagOnSubmit = false`
  /// Creates new tag if user submit.
  /// If true they separator will be ignored.
  final bool createTagOnSubmit;

  final void Function(PointerDownEvent)? onTapOutside;

  final bool ignoreInput;
  final bool ignoreChips;
  final String? Function(String?)? validator;
  final Function(String)? onSeparatorApplied;
  final Function(String)? onRemoveIconTap;

  @override
  _ChipTagsState createState() => _ChipTagsState();
}

class _ChipTagsState extends State<ChipTags>
    with SingleTickerProviderStateMixin {
  FocusNode _focusNode = FocusNode();

  ///Form key for TextField
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _inputController;

  @override
  void initState() {
    _inputController = widget.inputController ?? TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        if (widget.chipPosition == ChipPosition.above)
          _chipListPreview(widget.ignoreChips),
        IgnorePointer(
          ignoring: widget.ignoreInput,
          child: Form(
            key: _formKey,
            child: TextFormField(
              onTapOutside: widget.onTapOutside,
              controller: _inputController,
              validator: widget.validator,
              decoration: widget.decoration ??
                  InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    hintText: widget.decoration?.hintText,
                  ),
              keyboardType: widget.keyboardType ?? TextInputType.text,
              textInputAction: TextInputAction.done,
              focusNode: _focusNode,
              onFieldSubmitted: widget.createTagOnSubmit
                  ? (value) {
                      widget.list.add(value);

                      ///setting the controller to empty
                      _inputController.clear();

                      ///resetting form
                      _formKey.currentState!
                        ..reset()
                        ..save();

                      ///refreshing the state to show new data
                      setState(() {});
                      _focusNode.requestFocus();
                    }
                  : null,
              onChanged: widget.createTagOnSubmit
                  ? null
                  : (value) {
                      ///check if user has send separator so that it can break the line
                      ///and add that word to list
                      if (widget.separators
                              ?.any((sep) => value.endsWith(sep)) ??
                          false) {
                        ///check for ' ' and duplicate tags
                        if (!widget.separators!.any((sep) => value == sep) &&
                            !widget.list.contains(value.trim())) {
                          final detectedSep = value.split('').firstWhere(
                                (c) =>
                                    widget.separators!.any((sep) => sep == c),
                                orElse: () => ' ',
                              );

                          widget.onSeparatorApplied?.call(
                            value.replaceFirst(detectedSep, '').trim(),
                          );
                        }

                        ///setting the controller to empty
                        _inputController.clear();

                        ///resetting form
                        _formKey.currentState!
                          ..reset()
                          ..save();

                        ///refreshing the state to show new data
                        setState(() {});
                      }
                    },
            ),
          ),
        ),
        if (widget.chipPosition == ChipPosition.below)
          _chipListPreview(widget.ignoreChips),
      ],
    );
  }

  Widget _chipListPreview(bool ignoreChips) {
    if (widget.list.isEmpty) return const SizedBox.shrink();

    return IgnorePointer(
      ignoring: ignoreChips,
      child: Wrap(
        children: widget.list
            .map(
              (text) => Padding(
                padding: const EdgeInsets.all(5),
                child: FilterChip(
                  backgroundColor: widget.chipColor ?? Colors.blue,
                  label: Text(
                    text,
                    style: TextStyle(color: widget.textColor ?? Colors.white),
                  ),
                  avatar: Icon(Icons.remove_circle_outline,
                      color: widget.iconColor ?? Colors.white),
                  onSelected: (value) {
                    widget.onRemoveIconTap?.call(text);
                    setState(() {});
                  },
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
