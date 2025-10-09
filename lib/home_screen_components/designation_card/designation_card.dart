import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:karmayogi_mobile/constants/_constants/storage_constants.dart';
import 'package:karmayogi_mobile/respositories/_respositories/profile_repository.dart';
import 'package:karmayogi_mobile/ui/widgets/_home/designation_update_card.dart';
import 'package:provider/provider.dart';

class DesignationCard extends StatefulWidget {
  final Map<String, dynamic> designationCardData;
  const DesignationCard({super.key, required this.designationCardData});

  @override
  State<DesignationCard> createState() => _DesignationCardState();
}

class _DesignationCardState extends State<DesignationCard> {
  final _storage = FlutterSecureStorage();
  Future<Map<String, dynamic>?>? designationUpdate;
  @override
  void initState() {
    designationUpdate = Future.value(widget.designationCardData);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
        future: designationUpdate,
        builder: (context, snapshot) {
          if (snapshot.data != null && snapshot.data!['enabled']) {
            _storage.write(
                key: Storage.designationConfig,
                value: jsonEncode(snapshot.data));
            return Consumer<ProfileRepository>(
                builder: (contxt, profileRepo, child) {
              return DesignationUpdateCard(
                  designationConfig: snapshot.data!,
                  isupdated: profileRepo.designationUpdateStatus);
            });
          } else {
            return SizedBox();
          }
        });
  }
}
