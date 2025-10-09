import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:karmayogi_mobile/constants/index.dart';
import 'package:karmayogi_mobile/localization/index.dart';
import 'package:karmayogi_mobile/respositories/_respositories/login_respository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:karmayogi_mobile/ui/screens/_screens/profile/ui/pages/profile_dashboard.dart';
import 'package:karmayogi_mobile/ui/widgets/_common/page_loader.dart';
import 'package:karmayogi_mobile/ui/widgets/custom_tabs.dart';
import 'package:karmayogi_mobile/util/helper.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'models/_models/login_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'ui/screens/_screens/profile/utils/profile_constants.dart';
import 'ui/screens/_screens/profile/utils/profile_helper.dart';

class OAuth2Login extends StatefulWidget {
  const OAuth2Login({Key? key}) : super(key: key);
  @override
  _OAuth2LoginState createState() => _OAuth2LoginState();
}

class _OAuth2LoginState extends State<OAuth2Login> {
  late WebViewController _controller;
  final _storage = FlutterSecureStorage();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppColors.greys)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
          onHttpError: (error) => debugPrint(
              'Login WebView error: ${error.request}, error response ${error.response}'),
          onSslAuthError: (request) => debugPrint(
              'Login WebView SSL error: ${request.certificate}, error response ${request.proceed}'),
          onWebResourceError: (WebResourceError error) {
            debugPrint('Login WebView error: ${error.description}');
          },
          onNavigationRequest: (NavigationRequest request) async {
            _storage.write(key: Storage.showReminder, value: EnglishLang.yes);
            if (request.url == "${ApiUrl.baseUrl}/") {
              await Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => OAuth2Login(),
                ),
              );
              return NavigationDecision.prevent;
            }
            if (request.url.startsWith(ApiUrl.loginRedirectUrl)) {
              try {
                Uri url = Uri.parse(request.url);
                String? code = url.queryParameters[Storage.code];
                if (code != null) {
                  await _storage.write(key: Storage.code, value: code);
                  Login _loginDetails = await Provider.of<LoginRespository>(
                          context,
                          listen: false)
                      .fetchOAuthTokens(code);
                  if (_loginDetails.accessToken != null) {
                    if (await ProfileHelper().isRestrictedUser()) {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) =>
                            ProfileDashboard(type: ProfileConstants.notMyUser),
                      ));
                    } else if (await ProfileHelper.checkCustomProfileFields()) {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => ProfileDashboard(
                            type: ProfileConstants.customProfileTab),
                      ));
                    } else {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => CustomTabs(
                              customIndex: 0,
                              token: _loginDetails.accessToken,
                              isFromSignIn: true),
                        ),
                      );
                    }
                  }
                }
              } catch (e) {
                throw e;
              }
              return NavigationDecision.prevent;
            }
            if (request.url.startsWith(ApiUrl.parichayLoginRedirectUrl)) {
              Uri url = Uri.parse(request.url);
              String? code = url.queryParameters[Storage.code];
              await _storage.write(key: Storage.parichayCode, value: code);
              if (code != null) {
                await Provider.of<LoginRespository>(context, listen: false)
                    .fetchParichayToken(
                  code,
                  context,
                );
              } else {
                await Helper.showErrorScreen(
                    context, EnglishLang.codeParamsMissing);
              }
              return NavigationDecision.prevent;
            }
            if (request.url.startsWith(ApiUrl.parichayAuthLoginUrl)) {
              Uri url = Uri.parse(request.url);
              String? redirectUrl = url.queryParameters[Storage.redirectUrl];
              await _storage.write(
                  key: Storage.redirectUrl, value: redirectUrl);
            }
            if (request.url == ApiUrl.signUpWebUrl) {
              Navigator.of(context).pushNamed(AppUrl.selfRegister);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..enableZoom(false)
      ..setUserAgent(
          'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 Chrome/83.0.4103.106 Mobile Safari/537.36')
      ..loadRequest(Uri.parse(ApiUrl.baseUrl + ApiUrl.loginUrl));
  }

  @override
  Widget build(BuildContext context) {
    WebViewWidget webViewWidget = WebViewWidget(controller: _controller);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
        Navigator.pushNamedAndRemoveUntil(
            context, AppUrl.onboardingScreen, (route) => false);
      },
      child: Scaffold(
        backgroundColor: AppColors.appBarBackground,
        appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.mCommonSignIn,
                textAlign: TextAlign.right,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontSize: 16.sp,
                    )),
            automaticallyImplyLeading: false,
            leading: IconButton(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                    context, AppUrl.onboardingScreen, (route) => false),
                icon: Icon(
                  Icons.arrow_back,
                  color: AppColors.greys87,
                  size: 24.sp,
                ))),
        body: Container(
          color: AppColors.appBarBackground,
          child: Stack(
            children: [
              SafeArea(child: webViewWidget),
              if (_isLoading)
                Center(
                  child: PageLoader(isLoginPage: true),
                )
            ],
          ),
        ),
      ),
    );
  }

  String scriptToRemoveHelpButton() {
    return "document.getElementById('needHelpBtn').remove();";
  }
}
