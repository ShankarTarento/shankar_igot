import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/models/_models/batch_model.dart';

class BlendedProgramLocation extends StatefulWidget {
  final Batch selectedBatch;

  const BlendedProgramLocation({Key? key, required this.selectedBatch})
      : super(key: key);

  @override
  State<BlendedProgramLocation> createState() => _BlendedProgramLocationState();
}

class _BlendedProgramLocationState extends State<BlendedProgramLocation> {
  List<int> _encodedBytes = [];
  String? _locationDetails;

  @override
  void initState() {
    super.initState();
    _updateLocationDetails();
  }

  @override
  void didUpdateWidget(covariant BlendedProgramLocation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedBatch.batchId != widget.selectedBatch.batchId) {
      _updateLocationDetails();
    }
  }

  void _updateLocationDetails() {
    final locationString =
        widget.selectedBatch.batchAttributes?.batchLocationDetails;

    if (locationString != null && locationString.isNotEmpty) {
      _encodedBytes = locationString.codeUnits;
      _locationDetails = _decodeLocation(_encodedBytes);
    } else {
      _encodedBytes = [];
      _locationDetails = null;
    }
  }

  String? _decodeLocation(List<int> bytes) {
    if (bytes.isEmpty) return null;

    try {
      return utf8.decode(bytes);
    } catch (e) {
      debugPrint("UTF-8 decoding failed, falling back to fromCharCodes: $e");
      try {
        return String.fromCharCodes(bytes);
      } catch (e2) {
        debugPrint("fromCharCodes decoding also failed: $e2");
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (_locationDetails == null) return const SizedBox();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w).copyWith(top: 24.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.darkBlueGradient8,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Icon(
            Icons.location_on,
            color: AppColors.darkBlue,
          ),
          SizedBox(width: 16.w),
          Flexible(
            child: Text(
              _locationDetails!,
              style: GoogleFonts.lato(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
