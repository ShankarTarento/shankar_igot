import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/common_components/common_service/home_telemetry_service.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/models/_arguments/course_toc_model.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/model/profile_model.dart';
import 'package:karmayogi_mobile/respositories/_respositories/profile_repository.dart';
import 'package:karmayogi_mobile/ui/pages/_pages/gyaan_karmayogi_v2/pages/details_screen/details_screen.dart';
import 'package:karmayogi_mobile/ui/widgets/igot_ai/models/ai_chat_bot_response.dart';
import 'package:karmayogi_mobile/ui/widgets/igot_ai/repository/igot_ai_repository.dart';
import 'package:karmayogi_mobile/ui/widgets/igot_ai/ai_widgets/ai_chat_bot_message_field.dart';
import 'package:karmayogi_mobile/ui/widgets/igot_ai/ai_widgets/ai_loading_widget.dart';
import 'package:karmayogi_mobile/ui/widgets/igot_ai/ai_widgets/ai_welcome_text.dart';
import 'package:karmayogi_mobile/ui/widgets/igot_ai/ai_widgets/message_screen.dart';
import 'package:karmayogi_mobile/util/faderoute.dart';
import 'package:provider/provider.dart';

class IgotAiChatbot extends StatefulWidget {
  const IgotAiChatbot({super.key});

  @override
  State<IgotAiChatbot> createState() => _IgotAiChatbotState();
}

class _IgotAiChatbotState extends State<IgotAiChatbot> {
  List<Message> messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? _searchQuery;
  bool isLoading = false;
  Profile? profile;

  @override
  void initState() {
    super.initState();
    profile =
        Provider.of<ProfileRepository>(context, listen: false).profileDetails;
  }

  void searchIgotPlatform() async {
    if (_controller.text.isNotEmpty) {
      _searchQuery = _controller.text;
      String userInput = _controller.text;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(
            _scrollController.position.maxScrollExtent,
          );
        }
      });
      setState(() {
        isLoading = true;
        messages.add(Message(userMessage: userInput));
      });

      _controller.clear();

      try {
        Message botMessage =
            await IgotAiRepository.searchIgotPlatform(query: userInput);
        HomeTelemetryService.generateInteractTelemetryData(
            subType: TelemetrySubType.aiGlobalSearch,
            TelemetryIdentifier.aiGlobalSearch);
        setState(() {
          messages.add(botMessage);
        });
      } catch (e) {
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void retrySearch() async {
    isLoading = true;
    setState(() {});

    try {
      Message botMessage =
          await IgotAiRepository.searchIgotPlatform(query: _searchQuery ?? '');
      HomeTelemetryService.generateInteractTelemetryData(
          subType: TelemetrySubType.aiGlobalSearch,
          TelemetryIdentifier.aiGlobalSearch);
      setState(() {
        messages.add(botMessage);
      });
    } catch (e) {
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void searchDataFromInternet() async {
    setState(() {
      isLoading = true;
    });
    try {
      Message response =
          await IgotAiRepository.getDataFromInternet(query: _searchQuery ?? '');
      HomeTelemetryService.generateInteractTelemetryData(
          subType: TelemetrySubType.aiGlobalSearch,
          TelemetryIdentifier.aiGlobalSearch);
      setState(() {
        messages.add(response);
      });
    } catch (e) {
      debugPrint('Error fetching data from internet: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/img/igot_sarthi.png'),
          fit: BoxFit.fill,
          opacity: 0.07,
        ),
      ),
      child: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8, top: 8).r,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        messages.isEmpty
                            ? AiWelcomeText(
                                name: profile?.firstName ?? '',
                              )
                            : MessageScreen(
                                retrySearch: retrySearch,
                                searchInternet: searchDataFromInternet,
                                onTap: navigateToPlayer,
                                messages: messages,
                                onFeedbackChanged: (Message message) {}),
                        if (isLoading)
                          AiLoadingWidget(
                            isloading: isLoading,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 80.w),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AiChatBotMessageField(
              isLoading: isLoading,
              controller: _controller,
              scrollController: _scrollController,
              sendMessage: searchIgotPlatform,
            ),
          ),
        ],
      ),
    );
  }

  void navigateToPlayer(
      {required RetrievedChunk data, required BuildContext context}) {
    HomeTelemetryService.generateInteractTelemetryData(data.identifier,
        clickId: TelemetryClickId.cardContent,
        subType: TelemetrySubType.aiGlobalSearch);
    if (data.mimeType == EMimeTypes.mp4 || data.mimeType == EMimeTypes.pdf) {
      Navigator.push(
          context,
          FadeRoute(
              page: ResourceDetailsScreenV2(
            resourceId: data.identifier,
            startAt: int.tryParse(data.contentStart ?? '0') ?? 0,
          )));
    }
    if (data.mimeType == EMimeTypes.collection) {
      Navigator.pushNamed(context, AppUrl.courseTocPage,
          arguments: CourseTocModel.fromJson({
            'courseId': data.identifier,
          }));
    }
  }
}
