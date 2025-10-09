import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/widgets/custom_profile_fields/models/custom_profile_data.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/widgets/custom_profile_fields/models/custom_profile_field_model.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'dart:convert';

class CustomProfileDropdown extends StatefulWidget {
  final CustomField customField;
  final CustomProfileData? initialValue;
  final ValueChanged<CustomProfileData>? onChanged;

  const CustomProfileDropdown({
    super.key,
    required this.customField,
    this.initialValue,
    this.onChanged,
  });

  @override
  State<CustomProfileDropdown> createState() => _CustomProfileDropdownState();
}

class _CustomProfileDropdownState extends State<CustomProfileDropdown> {
  final Map<String, String?> _selectedValues = {};
  late final List<String> _levels;

  @override
  void initState() {
    super.initState();
    _levels = _extractLevels(widget.customField.customFieldData ?? []);

    // Initialize selected values map with null values
    for (final level in _levels) {
      _selectedValues[level] = null;
    }

    // Set initial values if provided
    if (widget.initialValue != null) {
      _setInitialValues(widget.initialValue!);
    }

    debugPrint('DEBUG: Levels found: $_levels');
  }

  // Set initial values from CustomFieldValue object
  void _setInitialValues(CustomProfileData initialValue) {
    // Sort values by level to ensure parent values are set before children
    final sortedValues = List<AttributeValue>.from(initialValue.values ?? [])
      ..sort((a, b) => a.level.compareTo(b.level));

    // Set each value in the correct order
    for (final valueObj in sortedValues) {
      // Find the corresponding field name in our levels
      final fieldName = valueObj.attributeName;
      if (_levels.contains(fieldName)) {
        // Compare values after converting to lowercase
        _selectedValues[fieldName] = valueObj.value;
      }
    }

    debugPrint('DEBUG: Initial values set: $_selectedValues');
  }

  // Extract levels (field names) in hierarchical order
  List<String> _extractLevels(List<CustomFieldData> nodes) {
    final List<String> levels = [];
    void traverse(CustomFieldData node) {
      if (!levels.contains(node.fieldName)) levels.add(node.fieldName);
      if (node.fieldValues.isNotEmpty) traverse(node.fieldValues.first);
    }

    if (nodes.isNotEmpty) traverse(nodes.first);
    return levels;
  }

  // Get available options for a dropdown, filtered by selections in higher levels
  List<String> _getOptionsForField(String fieldName) {
    List<CustomFieldData>? pool = widget.customField.customFieldData;
    int idx = _levels.indexOf(fieldName);

    for (int i = 0; i < idx; i++) {
      final parentFieldName = _levels[i];
      final parentValue = _selectedValues[parentFieldName];
      if (parentValue != null && pool != null) {
        final match = pool.firstWhere(
          (e) => e.fieldValue == parentValue,
          orElse: () => pool!.first,
        );
        pool = match.fieldValues;
      }
    }

    final Set<String> options = {};
    void collect(List<CustomFieldData>? nodes) {
      if (nodes == null) return;
      for (final node in nodes) {
        if (node.fieldName == fieldName) options.add(node.fieldValue);
        if (node.fieldValues.isNotEmpty) collect(node.fieldValues);
      }
    }

    collect(pool);
    return options.toList();
  }

  // Find all parent values for a selected value using both reversedOrderCustomFieldData and
  // parentFieldName/parentFieldValue attributes
  Map<String, String> _findAllParents(String fieldName, String? value) {
    debugPrint('DEBUG: Finding parents for $fieldName=$value');
    Map<String, String> result = {};

    if (value == null) return result;

    // Method 1: Use reversedOrderCustomFieldData (most reliable)
    if (widget.customField.reversedOrderCustomFieldData != null &&
        widget.customField.reversedOrderCustomFieldData!.isNotEmpty) {
      // Find the matching node in reversed data
      CustomFieldData? findNode(List<CustomFieldData> nodes) {
        for (final node in nodes) {
          if (node.fieldName == fieldName && node.fieldValue == value) {
            return node;
          }

          final found = findNode(node.fieldValues);
          if (found != null) return found;
        }
        return null;
      }

      // Extract parents from a reversed tree node (which points from leaf to root)
      void extractParents(CustomFieldData node) {
        // Process immediate parents from fieldValues
        for (final parent in node.fieldValues) {
          result[parent.fieldName] = parent.fieldValue;

          // Recursively get grandparents, etc.
          extractParents(parent);
        }
      }

      final node = findNode(widget.customField.reversedOrderCustomFieldData!);
      if (node != null) {
        extractParents(node);
      }
    }

    // Method 2: If the above fails, use parentFieldName/parentFieldValue attributes
    if (result.isEmpty) {
      // Find the node in the forward tree
      CustomFieldData? findNodeInForward(List<CustomFieldData> nodes) {
        for (final node in nodes) {
          if (node.fieldName == fieldName && node.fieldValue == value) {
            return node;
          }

          final found = findNodeInForward(node.fieldValues);
          if (found != null) return found;
        }
        return null;
      }

      // Function to build the chain of parents using parentFieldName/parentFieldValue
      void buildParentChain(CustomFieldData node) {
        if (node.parentFieldName != null && node.parentFieldValue != null) {
          result[node.parentFieldName!] = node.parentFieldValue!;

          // Find the parent node
          final parentNode =
              findNodeInForward(widget.customField.customFieldData ?? []);
          if (parentNode != null) {
            buildParentChain(parentNode);
          }
        }
      }

      final node = findNodeInForward(widget.customField.customFieldData ?? []);
      if (node != null) {
        buildParentChain(node);
      }
    }

    debugPrint('DEBUG: Found parents: $result');
    return result;
  }

  void _onDropdownChanged(String fieldName, String? value) {
    debugPrint('DEBUG: Dropdown changed: $fieldName -> $value');
    debugPrint('DEBUG: Before change: $_selectedValues');

    // Create a copy of the current state
    final Map<String, String?> newValues = Map.from(_selectedValues);

    // 1. Set the current selection
    newValues[fieldName] = value;

    // 2. Get the current field's index in the levels
    final idx = _levels.indexOf(fieldName);

    // 3. Update all parent fields if this isn't the top level
    if (idx > 0 && value != null) {
      final parents = _findAllParents(fieldName, value);
      for (int i = 0; i < idx; i++) {
        final parentField = _levels[i];
        if (parents.containsKey(parentField)) {
          newValues[parentField] = parents[parentField];
        }
      }
    }

    // 4. Clear all child fields
    for (int i = idx + 1; i < _levels.length; i++) {
      newValues[_levels[i]] = null;
    }

    // 5. Update state
    setState(() {
      _selectedValues.clear();
      _selectedValues.addAll(newValues);
    });

    debugPrint('DEBUG: After change: $_selectedValues');
    _notifyOnChanged();
  }

  // Modified to create a CustomFieldValue object
  void _notifyOnChanged() {
    if (widget.onChanged != null) {
      // Filter out null values
      final nonNullValues = <String, String>{};
      _selectedValues.forEach((key, value) {
        if (value != null) nonNullValues[key] = value;
      });

      // Only notify if there are non-null values
      if (nonNullValues.isEmpty) return;

      // Create the list of AttributeValue objects
      final valuesList = _levels
          .where((level) => nonNullValues.containsKey(level))
          .map((level) => AttributeValue(
                attributeName: level,
                value: nonNullValues[level]!,
                level: _levels.indexOf(level) + 1,
              ))
          .toList();

      // Create the CustomFieldValue object
      final result = CustomProfileData(
        customFieldId: widget.customField.customFieldId,
        type: widget.customField.type,
        attributeName: widget.customField.attributeName,
        values: valuesList,
      );

      // Debug output
      debugPrint(
          'DEBUG: Notifying parent with: ${json.encode(result.toJson())}');

      // Call the callback with the CustomFieldValue object
      widget.onChanged!(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16.w),
        Row(
          children: [
            Text(
              Helper.capitalize(widget.customField.name),
              style: GoogleFonts.lato(
                  fontSize: 14.sp, fontWeight: FontWeight.w600),
            ),
            if (widget.customField.isMandatory)
              Text(
                '*',
                style: GoogleFonts.lato(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.mandatoryRed,
                ),
              ),
          ],
        ),
        SizedBox(height: 16.w),
        ..._levels.map((fieldName) {
          final options = _getOptionsForField(fieldName);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                Helper.capitalize(fieldName),
                style: GoogleFonts.lato(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.greys60),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedValues[fieldName],
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 10.0).r,
                  border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(50))),
                ),
                items: options
                    .map((item) =>
                        DropdownMenuItem(value: item, child: Text(item)))
                    .toList(),
                onChanged: (val) {
                  _onDropdownChanged(fieldName, val);
                },
                validator: (val) => widget.customField.isMandatory &&
                        (val == null || val.isEmpty)
                    ? "${Helper.capitalize(fieldName)} is required"
                    : null,
              ),
              SizedBox(height: 12.w),
            ],
          );
        }),
      ],
    );
  }
}
