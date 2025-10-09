import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karmayogi_mobile/constants/_constants/app_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/app_routes.dart';
import 'package:karmayogi_mobile/constants/_constants/color_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/storage_constants.dart';
import 'package:karmayogi_mobile/constants/_constants/telemetry_constants.dart';
import 'package:karmayogi_mobile/models/_arguments/course_toc_model.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/model/profile_model.dart';
import 'package:karmayogi_mobile/respositories/_respositories/profile_repository.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/gyaan_karmayogi_v2/pages/details_screen/details_screen.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/toc/util/toc_helper.dart';
import 'package:karmayogi_mobile/ui/widgets/igot_ai/igot_ai_tutor/igot_ai_tutor.dart';
import 'package:karmayogi_mobile/ui/widgets/igot_ai/models/ai_tutor_type.dart';
import 'package:karmayogi_mobile/ui/widgets/igot_ai/igot_ai_tutor/widgets/ai_tutor_app_bar.dart';
import 'package:karmayogi_mobile/ui/widgets/igot_ai/models/ai_chat_bot_response.dart';
import 'package:karmayogi_mobile/ui/widgets/igot_ai/repository/igot_ai_repository.dart';
import 'package:karmayogi_mobile/util/faderoute.dart';
import 'package:karmayogi_mobile/util/telemetry_repository.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AiTutorButton extends StatefulWidget {
  final String resourceId;
  final List resourceNavigationItems;
  final Function(RetrievedChunk) onTap;
  final BuildContext tocContext;

  const AiTutorButton({
    super.key,
    required this.tocContext,
    required this.resourceId,
    required this.onTap,
    required this.resourceNavigationItems,
  });

  @override
  State<AiTutorButton> createState() => _AiTutorButtonState();
}

class _AiTutorButtonState extends State<AiTutorButton> {
  late WebSocketChannel _channel;
  final _storage = FlutterSecureStorage();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final ValueNotifier<bool> _isLoading = ValueNotifier(false);
  final ValueNotifier<List<Message>> _messages = ValueNotifier([]);
  String? _searchQuery;

  Profile? _profile;
  AiTutorType? _selectedType;
  List<AiTutorType> _aiTutorTypes = [];

  @override
  void initState() {
    super.initState();
    _loadProfileAndConnect();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeAiTutorTypes();
    _selectedType ??= _aiTutorTypes.isNotEmpty ? _aiTutorTypes[0] : null;
  }

  void _initializeAiTutorTypes() {
    _aiTutorTypes = AiTutorType.getAiTutorTypes(context);
    if (_selectedType == null && _aiTutorTypes.isNotEmpty) {
      _selectedType = _aiTutorTypes[0];
    }
  }

  Future<void> _loadProfileAndConnect() async {
    _profile =
        Provider.of<ProfileRepository>(context, listen: false).profileDetails;

    String? token = await _storage.read(key: Storage.authToken);
    if (token == null || _selectedType == null) {
      debugPrint('Token or selectedType not found!');
      return;
    }
    String finalUrl = _selectedType!.socketUrl.replaceAll("<jwt_token>", token);

    _channel = WebSocketChannel.connect(Uri.parse(finalUrl));

    _channel.stream.listen(
      (message) => _handleSocketResponse(message),
      onError: (_) {
        debugPrint('=============WebSocket error occurred=============');
        // Helper.showSnackBarMessage(
        //   context: context,
        //   text: AppLocalizations.of(context)!.mStaticErrorMessage,
        //   bgColor: Colors.red,
        // );
      },
      onDone: () {
        debugPrint('WebSocket connection closed');
      },
    );
  }

  void _handleSocketResponse(dynamic message) {
    try {
      var response = jsonDecode(message);
      if (response['type'] == "answer") {
        final aiChatBotResponse = Message(
          aiChatBotResponse: AiChatBotResponse.fromJson(response),
        );
        _messages.value = [..._messages.value, aiChatBotResponse];
        _isLoading.value = false;
      }
    } catch (e) {
      _isLoading.value = false;
      debugPrint('Error parsing response: $e');
    }
  }

  void _sendMessage() async {
    final userInput = _controller.text;
    if (userInput.isEmpty) return;
    _searchQuery = userInput;

    _generateInteractTelemetryData(
      contentId: widget.resourceId,
      clickId: TelemetryIdentifier.aiTutorPlayerPage,
    );

    _messages.value = [..._messages.value, Message(userMessage: userInput)];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });

    _controller.clear();
    _isLoading.value = true;

    try {
      _channel.sink.add(jsonEncode({
        "message": userInput,
        "query": userInput,
        "folder_name": widget.resourceId,
      }));
    } catch (e) {
      debugPrint('Error sending message: $e');
      _isLoading.value = false;
    }
  }

  Future<void> _searchDataFromInternet() async {
    String userInput = _searchQuery ?? _controller.text;

    _isLoading.value = true;
    try {
      final response =
          await IgotAiRepository.getDataFromInternet(query: userInput);
      _messages.value = [..._messages.value, response];
    } catch (e) {
      debugPrint('Error fetching data from internet: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  @override
  void dispose() {
    _isLoading.dispose();
    _messages.dispose();
    _channel.sink.close();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _openBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return SizedBox(
          height: 0.9.sh,
          child: Scaffold(
            appBar: AiTutorAppBar(
              aiTutorTypes: _aiTutorTypes,
              selectedType: _selectedType!,
              onTypeSelected: (value) {
                setState(() {
                  _selectedType = value;
                  _loadProfileAndConnect();
                });
              },
            ),
            body: ValueListenableBuilder<List<Message>>(
              valueListenable: _messages,
              builder: (context, messages, _) {
                return ValueListenableBuilder<bool>(
                  valueListenable: _isLoading,
                  builder: (context, isLoading, _) {
                    return IgotAiTutor(
                      retrySearch: _searchDataFromInternet,
                      onTapCard: (chunk, contextx) {
                        if (TocHelper.checkResourceStatus(
                          resourceNavigationItems:
                              widget.resourceNavigationItems,
                          resourceId: chunk.identifier,
                        )) {
                          widget.onTap(chunk);
                          Navigator.pop(contextx);
                        } else {
                          _navigateToPlayer(data: chunk, context: contextx);
                        }
                      },
                      searchInternet: _searchDataFromInternet,
                      controller: _controller,
                      scrollController: _scrollController,
                      isLoading: isLoading,
                      messages: messages,
                      onSend: _sendMessage,
                      profile: _profile,
                      onFeedbackChanged: (updatedMessage) {
                        final index = messages.indexWhere(
                          (msg) =>
                              msg.userMessage == updatedMessage.userMessage &&
                              msg.aiChatBotResponse ==
                                  updatedMessage.aiChatBotResponse &&
                              msg.internetSearchResponse ==
                                  updatedMessage.internetSearchResponse &&
                              msg.isErrorMessage ==
                                  updatedMessage.isErrorMessage,
                        );
                        if (index != -1) {
                          final updatedList = List<Message>.from(messages);
                          updatedList[index] = updatedMessage;
                          _messages.value = updatedList;
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _navigateToPlayer({
    required RetrievedChunk data,
    required BuildContext context,
  }) {
    _generateInteractTelemetryData(
      contentId: data.identifier,
      subType: _selectedType?.telemetrySubType,
      clickId: TelemetryIdentifier.aiTutorCardContent,
    );

    if (data.mimeType == EMimeTypes.mp4 || data.mimeType == EMimeTypes.pdf) {
      Navigator.push(
        context,
        FadeRoute(
          page: ResourceDetailsScreenV2(
            resourceId: data.identifier,
            startAt: int.tryParse(data.contentStart ?? '0') ?? 0,
          ),
        ),
      );
    } else if (data.mimeType == EMimeTypes.collection) {
      Navigator.pushNamed(
        context,
        AppUrl.courseTocPage,
        arguments: CourseTocModel.fromJson({
          'courseId': data.identifier,
        }),
      );
    }
  }

  Future<void> _generateInteractTelemetryData({
    String? contentId,
    String? subType,
    required String clickId,
  }) async {
    final telemetryRepository = TelemetryRepository();
    final eventData = telemetryRepository.getInteractTelemetryEvent(
      pageIdentifier: TelemetryPageIdentifier.learnPageId,
      contentId: contentId ?? "",
      subType: subType ?? "",
      clickId: clickId,
      env: TelemetryEnv.learn,
    );
    await telemetryRepository.insertEvent(eventData: eventData);
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        _generateInteractTelemetryData(
          contentId: widget.resourceId,
          clickId: TelemetryIdentifier.aiTutorPlayerPage,
        );
        _openBottomSheet(context);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.darkBlue,
        elevation: 0,
        side: BorderSide(color: AppColors.darkBlue),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 24.w,
            child: Image.asset('assets/img/bot body.png'),
          ),
          const SizedBox(width: 4),
          Text(
            AppLocalizations.of(context)!.mAiTutor,
            style: GoogleFonts.lato(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
