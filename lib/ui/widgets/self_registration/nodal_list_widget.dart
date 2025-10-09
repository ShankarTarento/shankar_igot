import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../constants/index.dart';
import '../../../models/_models/nodal_model.dart';
import '../../../util/index.dart';

class NodalListWidget extends StatefulWidget {
  final List<NodalModel> nodalList;

  const NodalListWidget({Key? key, required this.nodalList}) : super(key: key);

  @override
  _NodalListWidgetState createState() => _NodalListWidgetState();
}

class _NodalListWidgetState extends State<NodalListWidget> {
  String _searchText = '';
  late List<NodalModel> _filteredList;

  @override
  void initState() {
    super.initState();
    _filteredList = widget.nodalList;
  }

  void _filterList(String value) {
    setState(() {
      _searchText = value.toLowerCase();
      _filteredList = widget.nodalList.where((nodal) {
        return nodal.organization.toLowerCase().contains(_searchText) ||
            nodal.nodalName.toLowerCase().contains(_searchText) ||
            nodal.nodalEmail.toLowerCase().contains(_searchText);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Align(
          alignment: Alignment.topRight,
          child: IconButton(
              padding: EdgeInsets.only(top: 30).r,
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close)),
        ),
        // Search Bar
        Padding(
          padding:
              const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0, top: 20)
                  .r,
          child: TextField(
            style: Theme.of(context).textTheme.titleMedium,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.mCommonSearch,
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
              prefixIconColor: AppColors.grey84,
              labelStyle: Theme.of(context).textTheme.bodyMedium,
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.darkBlue),
              ),
            ),
            onChanged: _filterList,
          ),
        ),
        // List
        Expanded(
          child: ListView.builder(
            itemCount: _filteredList.length,
            itemBuilder: (context, index) {
              final nodal = _filteredList[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4).r,
                child: ListTile(
                  title: Text(nodal.nodalName,
                      style: Theme.of(context).textTheme.titleMedium),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8.h),
                      Text(nodal.organization,
                          style: Theme.of(context).textTheme.bodyMedium),
                      SizedBox(height: 8.h),
                      Text(nodal.ministry,
                          style: Theme.of(context).textTheme.bodyMedium),
                      SizedBox(height: 8.h),
                      GestureDetector(
                        onTap: () => Helper.mailTo(
                            Helper.decodeEmailPlaceholders(nodal.nodalEmail)),
                        child: Text(nodal.nodalEmail,
                            style: Theme.of(context).textTheme.bodyLarge),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
