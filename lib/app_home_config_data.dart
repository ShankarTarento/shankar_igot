import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:igot_http_service_helper/services/http_service.dart';
import 'package:http/http.dart';
import 'package:karmayogi_mobile/constants/_constants/api_endpoints.dart';
import 'package:karmayogi_mobile/util/network_helper.dart';

class HomeConfigRepository {
  static Future<Map<String, dynamic>> getHomeConfig() async {
    Map<String, dynamic>? homeConfigData;
    try {
      Map request = {
        "request": {
          "type": "page",
          "subType": "mobile-home",
          "action": "page-configuration",
          "component": "mobile",
          "rootOrgId": "*"
        }
      };
      Response response = await HttpService.post(
        body: request,
        headers: NetworkHelper.postHeaders('', '', ''),
        apiUri: Uri.parse(ApiUrl.baseUrl + ApiUrl.getMicroSiteFormData),
      );
      if (response.statusCode == 200) {
        var content = jsonDecode(response.body);
        homeConfigData = content['result']['form']['data'];
      }
    } catch (e) {
      debugPrint("Exception during API call: $e");
    } finally {
      if (homeConfigData == null) homeConfigData = await getHomeConfigData();
    }
    return homeConfigData;
  }

  static Map<String, dynamic> getHomeConfigData() {
    return {
      "mentorshipEnabled": true,
      "enableFirebaseNotification": false,
      "appUpdate": {
        "optionalUpdate": {
          "enabled": true,
          "enableCloseButton": true,
          "enableUpdateButton": true,
          "updateMessage": "New Version Of App Available!",
          "buttonText": "Update"
        },
        "mandatoryUpdate": {
          "enabled": true,
          "enableIgnore": true,
          "mandatoryIosVersion": "4.2.5",
          "mandatoryAndroidVersion": "4.2.5",
          "title": "App Update Available",
          "buttonText": "Update"
        }
      },
      "themeData": {
        "enabled": false,
        "logoUrl":
            "/assets/instances/eagle/app_logos/mobile_animation_file.json",
        "logoText": "79th Republic Day",
        "backgroundColors": ["0xffF8DACE", "0xffFFFFFF", "0xffCBEED2"]
      },
      "data": [
        {
          "type": "hubs",
          "enabled": true,
          "enableTheme": true,
          "backgroundColor": "0xfffffff",
          "data": [
            {
              "enabled": true,
              "title": {
                "hiText": "सामग्री का \nपता लगाएँ",
                "enText": "Explore\ncontent",
                "id": "explore_content"
              },
              "description": {
                "hiText":
                    "सामग्री की खोज करें जो आपकी प्राथमिकताओं और हितों से मेल खाती हो",
                "enText":
                    "Discover content that matches your preferences and interests.",
                "id": "explore_content"
              },
              "imageUrl": "/assets/icons/hubs/course-cataloguee.svg",
              "telemetryId": "",
              "navigationRoute": "/exploreContent",
              "iconColor": "0xFFFFFFFF",
              "backgroundColor": "0xFF1B4CA1"
            },
            {
              "enabled": true,
              "title": {"hiText": "सीखें", "enText": "Learn", "id": "learn"},
              "description": {
                "hiText": "सैकड़ों ऑनलाइन कोर्स के साथ अपने कौशल को निखारें",
                "enText":
                    "Sharpen your skills with hundreds of online courses.",
                "id": "learn"
              },
              "imageUrl": "/assets/icons/hubs/school.svg",
              "telemetryId": "",
              "navigationRoute": "/learningHub"
            },
            {
              "enabled": true,
              "isNew": true,
              "title": {
                "hiText": "चर्चा करें",
                "enText": "Discuss",
                "id": "discuss"
              },
              "description": {
                "hiText":
                    "कोई सवाल है? कोई विचार है? अपने साथियों से चर्चा करें!",
                "enText":
                    "Have a question? Have an idea? Discuss with your peers!",
                "id": "discuss"
              },
              "imageUrl": "/assets/icons/hubs/forum.svg",
              "telemetryId": "",
              "navigationRoute": "/discussionHub"
            },
            {
              "enabled": true,
              "title": {
                "hiText": "इवेंट्स",
                "enText": "Events",
                "id": "events"
              },
              "description": {
                "hiText": "अपने ईवेंट जोड़ें",
                "enText": "Add your events.",
                "id": "events"
              },
              "imageUrl": "/assets/icons/hubs/event.svg",
              "telemetryId": "",
              "navigationRoute": "/eventsHub"
            },
            {
              "enabled": true,
              "title": {
                "hiText": "AGK",
                "enText": "AGK",
                "id": "amritGyaanKosh"
              },
              "description": {
                "hiText":
                    "नई नीतियाँ, परिपत्र और सभी ज्ञान संसाधन प्राप्त करें",
                "enText":
                    "Find the latest policies, circulars and all available knowledge resources.",
                "id": "amritGyaanKosh"
              },
              "imageUrl": "/assets/icons/hubs/knowledge%20resources.svg",
              "telemetryId": "",
              "navigationRoute": "/knowledgeResourcesPage"
            },
            {
              "enabled": true,
              "title": {
                "hiText": "नेटवर्क",
                "enText": "Network",
                "id": "network"
              },
              "description": {
                "hiText": "दिलचस्प लोगों से जुड़ें और जानें वे क्या कर रहे हैं",
                "enText":
                    "Connect with interesting people, see what they are upto",
                "id": "network"
              },
              "imageUrl": "/assets/icons/hubs/group.svg",
              "telemetryId": "",
              "navigationRoute": "/networkHub"
            }
          ]
        },
        {
          "type": "homeThemeDataStrip",
          "enabled": true,
          "enableTheme": true,
          "backgroundColor": "0xffeff3f9"
        },
        {
          "type": "updateDesignation",
          "enabled": false,
          "enableTheme": true,
          "backgroundColor": "0xffeff3f9",
          "imageUrl": "assets/icons/desigantion-card.svg",
          "imageUrlMobile": "/assets/icons/desigantion-card.svg",
          "header":
              "Your organization designation master has been updated so Please update your designation at your earliest convenience.",
          "headerHi":
              "आपके संगठन पदनाम मास्टर को अपडेट कर दिया गया है, इसलिए कृपया यथाशीघ्र अपना पदनाम अपडेट करें।",
          "headerGu":
              "તમારા સંસ્થાના હોદ્દાનો માસ્ટર અપડેટ કરવામાં આવ્યો છે તેથી કૃપા કરીને તમારી સગવડતા મુજબ તમારું હોદ્દો અપડેટ કરો.",
          "hintText":
              "Not able to find your designation, please write us at <u>mission.karmayogi@gov.in</u> with the with the organization and designation name.",
          "hintTextHi":
              "यदि आपको अपना पदनाम नहीं मिल पा रहा है, तो कृपया हमें अपने संगठन और पदनाम के साथ <u>mission.karmayogi@gov.in</u> पर लिखें।",
          "hintTextGu":
              "તમારું હોદ્દો શોધવામાં અસમર્થ, કૃપા કરીને અમને <u>mission.karmayogi@gov.in</u> પર સંસ્થા અને હોદ્દા નામ સાથે લખો.",
          "hintTextMobile":
              "Not able to find your designation, please write us at <a href='mission.karmayogi@gov.in'>mission.karmayogi@gov.in</a> with the with the organization and designation name.",
          "hintTextMobileHi":
              "यदि आपको अपना पदनाम नहीं मिल पा रहा है, तो कृपया हमें अपने संगठन और पदनाम के साथ <a href='mission.karmayogi@gov.in'>mission.karmayogi@gov.in</a> पर लिखें।",
          "hintTextMobileGu":
              "તમારું હોદ્દો શોધવામાં અસમર્થ, કૃપા કરીને અમને <a href='mission.karmayogi@gov.in'>mission.karmayogi@gov.in</a> પર સંસ્થા અને હોદ્દા નામ સાથે લખો.",
          "buttonText": "Submit",
          "buttonTextHi": "जमा करें",
          "buttonTextGu": "સબમિટ કરો"
        },
        {
          "type": "notMyUser",
          "enabled": true,
          "enableTheme": true,
          "backgroundColor": "0xffeff3f9"
        },
        {
          "type": "userDataError",
          "enabled": true,
          "enableTheme": true,
          "backgroundColor": "0xffeff3f9"
        },
        {
          "type": "learningWeek",
          "enabled": true,
          "enableTheme": true,
          "backgroundColor": "0xffeff3f9",
          "data": [
            {
              "type": "nationalLearningWeek",
              "enabled": false,
              "startDate": "24-03-2025",
              "endDate": "30-03-2025",
              "title": {
                "enText": "Celebrate National Learning Week",
                "hiText": "राष्ट्रीय शिक्षा सप्ताह मनाएँ",
                "id": "celebrateNationalLearningWeek"
              },
              "description": {
                "enText":
                    "Digital Marketing conference dedicated to delivering actionable methods and strategies covering all aspects of online marketing",
                "hiText":
                    "ऑनलाइन विपणन के सभी पहलुओं को शामिल करते हुए कार्रवाई योग्य तरीकों और रणनीतियों को प्रदान करने के लिए समर्पित डिजिटल विपणन सम्मेलन",
                "id": "digitalMarketingConference"
              },
              "buttonText": {
                "enText": "View More",
                "hiText": "अधिक देखें",
                "id": "viewMore"
              }
            },
            {
              "type": "stateLearningWeek",
              "data": [
                {
                  "enabled": false,
                  "startDate": "24-03-2025",
                  "endDate": "30-03-2025",
                  "subtitle": {
                    "enText": "Celebrating",
                    "hiText": "जश्न मना रहे हैं",
                    "id": "celebrate"
                  },
                  "title": {
                    "enText": "Celebrate State Learning Week",
                    "hiText": "राष्ट्रीय शिक्षा सप्ताह मनाएँ",
                    "id": "celebrateNationalLearningWeek"
                  },
                  "description": {
                    "enText":
                        "Digital Marketing conference dedicated to delivering actionable methods and strategies covering all aspects of online marketing",
                    "hiText":
                        "ऑनलाइन विपणन के सभी पहलुओं को शामिल करते हुए कार्रवाई योग्य तरीकों और रणनीतियों को प्रदान करने के लिए समर्पित डिजिटल विपणन सम्मेलन",
                    "id": "digitalMarketingConference"
                  },
                  "buttonText": {
                    "enText": "View More",
                    "hiText": "अधिक देखें",
                    "id": "viewMore"
                  },
                  "orgId": "01397282245867929648",
                  "orgName": "ANDAMAN and NICOBAR"
                },
                {
                  "enabled": true,
                  "startDate": "07-03-2025",
                  "endDate": "13-03-2025",
                  "subtitle": {
                    "enText": "Celebrating",
                    "hiText": "जश्न मना रहे हैं",
                    "id": "celebrate"
                  },
                  "title": {
                    "enText": "Celebrate State Learning Week",
                    "hiText": "राष्ट्रीय शिक्षा सप्ताह मनाएँ",
                    "id": "celebrateNationalLearningWeek"
                  },
                  "description": {
                    "enText":
                        "Digital Marketing conference dedicated to delivering actionable methods and strategies covering all aspects of online marketing",
                    "hiText":
                        "ऑनलाइन विपणन के सभी पहलुओं को शामिल करते हुए कार्रवाई योग्य तरीकों और रणनीतियों को प्रदान करने के लिए समर्पित डिजिटल विपणन सम्मेलन",
                    "id": "digitalMarketingConference"
                  },
                  "buttonText": {
                    "enText": "View More",
                    "hiText": "अधिक देखें",
                    "id": "viewMore"
                  },
                  "orgId": "0140908831042437120",
                  "orgName": "Finance and Budget"
                }
              ]
            }
          ]
        },
        {
          "type": "myActivityCard",
          "enabled": true,
          "enableTheme": true,
          "backgroundColor": "0xffeff3f9"
        },
        {
          "type": "informationCard",
          "enabled": false,
          "enableTheme": true,
          "backgroundColor": "0xffeff3f9",
          "data": {
            "backgroundColor": "0xfff8b861",
            "title": {
              "enText": "Take the iGOT Survey, help us make iGOT even better!",
              "hiText":
                  "आई. जी. ओ. टी. सर्वेक्षण लें, आई. जी. ओ. टी. को और भी बेहतर बनाने में हमारी मदद करें!",
              "id": "takeIgotSurvey"
            },
            "content": {
              "enText":
                  "Take a few minutes to complete this survey and contribute to enhancing the iGOT learning experience",
              "hiText":
                  "इस सर्वेक्षण को पूरा करने के लिए कुछ मिनट निकालें और आई. जी. ओ. टी. सीखने के अनुभव को बढ़ाने में योगदान दें।",
              "id": "completeSurvey"
            },
            "btnTitle": {
              "enText": "Click here",
              "hiText": "यहाँ क्लिक करें",
              "id": "clickHere"
            },
            "imageUrl": "/assets/icons/learner-advisory/surveyEdit.png",
            "surveyUrl":
                "https://portal.igotkarmayogi.gov.in/surveyml/668e250da8bfb500083136b1"
          }
        },
        {
          "type": "scheduledAssesment",
          "enabled": true,
          "enableTheme": true,
          "backgroundColor": "0xffeff3f9"
        },
        {
          "type": "homeBlendedProgramAttendance",
          "enabled": true,
          "enableTheme": true,
          "backgroundColor": "0xffeff3f9"
        },
        {
          "type": "mySpace",
          "title": {
            "hiText": "मेरा स्थान",
            "enText": "My Space",
            "id": "mySpace"
          },
          "enabled": true,
          "enableTheme": true,
          "backgroundColor": "0xffeff3f9",
          "enrollmentApi": {
            "url": "/api/course/v4/user/enrollment/details/userid",
            "request": {
              "request": {"courseId": []}
            }
          },
          "cbpApiUrl": "/api/user/v1/cbplan",
          "tabItems": [
            {
              "enabled": true,
              "title": {
                "hiText": "मेरा iGOT",
                "enText": "My iGOT",
                "id": "MyIGOT"
              },
              "telemetryPrimaryCategory": "course",
              "telemetrySubType": "trending-in-department-tab",
              "telemetryIdentifier": "courses-tab",
              "type": "cbpCourses",
              "filterItems": [
                {
                  "hiText": "एपीएआर",
                  "enText": "APAR",
                  "id": "apar"
                },
                {
                  "hiText": "आने वाला है",
                  "enText": "Upcoming",
                  "id": "upcoming"
                },
                {"hiText": "अतिदेय", "enText": "Overdue", "id": "overdue"},
                {
                  "hiText": "पूरा किया",
                  "enText": "Completed",
                  "id": "completed"
                },
                {"hiText": "सभी", "enText": "All", "id": "all"}
              ]
            },
            {
              "enabled": true,
              "type": "igotAi",
              "infoText": "AI driven recommendation for you ",
              "telemetryPrimaryCategory": "course",
              "telemetrySubType": "trending-in-department-tab",
              "telemetryIdentifier": "courses-tab",
              "title": {
                "hiText": "मेरा झुकाव",
                "enText": "iGOT AI",
                "id": "igotAi"
              }
            },
            {
              "enabled": true,
              "title": {
                "hiText": "आपके विभाग में रुझान",
                "enText": "Trending in Your Department",
                "id": "peerLearning"
              },
              "type": "recommendedLearning",
              "telemetryPrimaryCategory": "course",
              "telemetrySubType": "trending-in-department-tab",
              "telemetryIdentifier": "courses-tab",
              "filterItems": [
                {"hiText": "उपलब्ध", "enText": "Available", "id": "available"},
                {
                  "hiText": "प्रगति में",
                  "enText": "In Progress",
                  "id": "inProgress"
                },
                {
                  "hiText": "पूरा किया",
                  "enText": "Completed",
                  "id": "completed"
                }
              ]
            }
          ]
        },
        {
          "type": "learnerTips",
          "enabled": true,
          "enableTheme": true,
          "backgroundColor": "0xffeff3f9",
          "data": [
            {
              "id": 1,
              "tip": {
                "enText":
                    "Watch content at a speed that ensures understanding and retention.",
                "hiText":
                    "सामग्री को उस गति पर देखें जो समझ और संग्रहण को सुनिश्चित करती है।",
                "id": "1"
              },
              "imagePath":
                  "https://portal.igotkarmayogi.gov.in/content-store/content/do_1140802453413806081626/artifact/do_1140802453413806081626_1718780481751_learner_advisory_1.png"
            },
            {
              "id": 2,
              "tip": {
                "enText": "Avoid fast-forwarding and speeding through.",
                "hiText": "तेजी से आगे बढ़ने और तेजी से गुजरने से बचें।",
                "id": "2"
              },
              "imagePath":
                  "https://portal.igotkarmayogi.gov.in/content-store/content/do_1140802453413806081626/artifact/do_1140802453413806081626_1718786566296_learner_advisory_2.png"
            },
            {
              "id": 3,
              "tip": {
                "enText": "Follow the sequence of content as presented.",
                "hiText":
                    "सामग्री की क्रमबद्धता का पालन करें जैसा कि प्रस्तुत किया गया है।",
                "id": "3"
              },
              "imagePath":
                  "https://portal.igotkarmayogi.gov.in/content-store/content/do_1140802453413806081626/artifact/do_1140802453413806081626_1718786660979_learner_advisory_3.png"
            },
            {
              "id": 4,
              "tip": {
                "enText":
                    "Take one course at a time instead of consuming multiple courses across multiple devices.",
                "hiText":
                    "कई उपकरणों पर कई पाठ्यक्रमों का सेवन करने की बजाय एक समय में एक पाठ्यक्रम लें।",
                "id": "4"
              },
              "imagePath":
                  "https://portal.igotkarmayogi.gov.in/content-store/content/do_1140802453413806081626/artifact/do_1140802453413806081626_1718786699994_learner_advisory_4.png"
            },
            {
              "id": 5,
              "tip": {
                "enText":
                    "Participate in discussions at the Discussion Forum regularly.",
                "hiText": "वार्ता मंच पर नियमित रूप से चर्चा में भाग लें।",
                "id": "5"
              },
              "imagePath":
                  "https://portal.igotkarmayogi.gov.in/content-store/content/do_1140802453413806081626/artifact/do_1140802453413806081626_1718786740083_learner_advisory_5.png"
            },
            {
              "id": 6,
              "tip": {
                "enText":
                    "Don't rush through assessments without understanding, reflecting.",
                "hiText": "समझने, परिचिति के बिना मूल्यांकन में जल्दी न करें।",
                "id": "6"
              },
              "imagePath":
                  "https://portal.igotkarmayogi.gov.in/content-store/content/do_1140802453413806081626/artifact/do_1140802453413806081626_1718786815836_learner_advisory_6.png"
            },
            {
              "id": 7,
              "tip": {
                "enText": "Use supplementary resources and readings.",
                "hiText": "सहायक संसाधनों और पाठों का उपयोग करें।",
                "id": "7"
              },
              "imagePath":
                  "https://portal.igotkarmayogi.gov.in/content-store/content/do_1140802453413806081626/artifact/do_1140802453413806081626_1718786853526_learner_advisory_7.png"
            },
            {
              "id": 8,
              "tip": {
                "enText": "Minimize distractions during study sessions.",
                "hiText": "अध्ययन सत्र के दौरान विचलन को कम करें।",
                "id": "8"
              },
              "imagePath":
                  "https://portal.igotkarmayogi.gov.in/content-store/content/do_1140802453413806081626/artifact/do_1140802453413806081626_1718786883633_learner_advisory_8.png"
            },
            {
              "id": 9,
              "tip": {
                "enText": "Seek clarification and assistance when needed.",
                "hiText": "आवश्यक होने पर स्पष्टीकरण और सहायता की खोज करें।",
                "id": "9"
              },
              "imagePath":
                  "https://portal.igotkarmayogi.gov.in/content-store/content/do_1140802453413806081626/artifact/do_1140802453413806081626_1718786937192_learner_advisory_9.png"
            },
            {
              "id": 10,
              "tip": {
                "enText": "Allocate dedicated time for learning activities.",
                "hiText": "अध्ययन क्रियाओं के लिए विशेष समय का आवंटन करें।",
                "id": "10"
              },
              "imagePath":
                  "https://portal.igotkarmayogi.gov.in/content-store/content/do_1140802453413806081626/artifact/do_1140802453413806081626_1718786997837_learner_advisory_10.png"
            },
            {
              "id": 13,
              "tip": {
                "enText":
                    "Use the new section Gyaan Karmayogi regularly, to go over case studies and other learning material.",
                "hiText":
                    "मामला अध्ययन और अन्य शिक्षा सामग्री को समीक्षित करने के लिए नए खंड ज्ञान कर्मयोगी का नियमित रूप से उपयोग करें।",
                "id": "11"
              },
              "imagePath":
                  "https://portal.igotkarmayogi.gov.in/content-store/content/do_1140802453413806081626/artifact/do_1140802453413806081626_1718787068070_learner_advisory_11.png"
            },
            {
              "id": 11,
              "tip": {
                "enText": "Update your profile regularly if required.",
                "hiText":
                    "आवश्यकता होने पर नियमित रूप से अपना प्रोफाइल अपडेट करें।",
                "id": "12"
              },
              "imagePath":
                  "https://portal.igotkarmayogi.gov.in/content-store/content/do_1140802453413806081626/artifact/do_1140802453413806081626_1718787103116_learner_advisory_12.png"
            },
            {
              "id": 12,
              "tip": {
                "enText": "Follow suggestions at My iGOT.",
                "hiText": "मेरा आईजीओटी पर सुझावों का पालन करें।",
                "id": "13"
              },
              "imagePath":
                  "https://portal.igotkarmayogi.gov.in/content-store/content/do_1140802453413806081626/artifact/do_1140802453413806081626_1718787141133_learner_advisory_13.png"
            }
          ]
        },
        {
          "type": "homeLiveEventsStrip",
          "enabled": true,
          "enableTheme": true,
          "backgroundColor": "0xffeff3f9"
        },
        {
          "type": "tab",
          "title": {
            "hiText": "मेरा झुकाव",
            "enText": "My Learning",
            "id": "myLearning"
          },
          "enabled": true,
          "enableTheme": true,
          "backgroundColor": "0xffeff3f9",
          "tabItems": [
            {
              "title": {
                "hiText": "सामग्री",
                "enText": "Contents",
                "id": "Contents"
              },
              "enabled": true,
              "telemetryIdentifier": "card-content",
              "telemetrySubType": "my-learning-contents",
              "type": "myLearningCourses",
              "enrollmentApi": {
                "url": "/api/course/v4/user/enrollment/list/userId",
                "request": {
                  "request": {
                    "retiredCoursesEnabled": false,
                    "status": "Completed",
                    "limit": 15
                  }
                }
              },
              "filterItems": [
                {
                  "hiText": "प्रगति में",
                  "enText": "In progress",
                  "id": "In-Progress"
                },
                {
                  "hiText": "पूरा किया",
                  "enText": "Completed",
                  "id": "Completed"
                }
              ]
            },
            {
              "title": {"hiText": "घटनाएँ", "enText": "Events", "id": "events"},
              "enabled": true,
              "type": "myLearningEvents",
              "enrollmentApi": {
                "url": "/api/user/events/list/userId",
                "request": {
                  "request": {
                    "retiredCoursesEnabled": false,
                    "status": "In-Progress",
                    "limit": 15
                  }
                }
              },
              "telemetryIdentifier": "card-content",
              "telemetrySubType": "my-learning-events",
              "filterItems": [
                {
                  "hiText": "प्रगति में",
                  "enText": "In progress",
                  "id": "In-Progress"
                },
                {
                  "hiText": "पूरा किया",
                  "enText": "Completed",
                  "id": "Completed"
                }
              ]
            }
          ]
        },
        {
          "type": "karmaProgram",
          "title": {
            "hiText": "कर्म कार्यक्रम",
            "enText": "Karma Program",
            "id": "karmaProgram"
          },
          "enabled": true,
          "enableTheme": true,
          "backgroundColor": "0xffeff3f9",
          "apiUrl": "/api/playList/v2/search",
          "request": {
            "filterCriteriaMap": {"type": "program"},
            "pageNumber": 0,
            "pageSize": 20,
            "orderBy": "createdOn",
            "orderDirection": "ASC",
            "facets": ["category", "orgId"]
          }
        },
        {
          "type": "tab",
          "title": {"hiText": "लर्न हब", "enText": "For You", "id": "learnHub"},
          "enabled": true,
          "enableTheme": false,
          "backgroundColor": "0xffffffff",
          "tabItems": [
            {
              "title": {
                "hiText": "पाठ्यक्रम",
                "enText": "Courses",
                "id": "courses"
              },
              "type": "dropdown",
              "enabled": true,
              "filterItems": [
                {
                  "title": {
                    "hiText": "विभागों में ट्रेंडिंग",
                    "enText": "Trending Across Department",
                    "id": "trendingAcrossDepartment"
                  },
                  "data": {
                    "type": "courseStrip",
                    "enabled": true,
                    "apiUrl": "/api/trending/search",
                    "telemetryPrimaryCategory": "course",
                    "telemetrySubType": "trending-across-department-courses",
                    "telemetryIdentifier": "card-content",
                    "request": {
                      "request": {
                        "filters": {
                          "contextType": ["courses"],
                          "organisation": "across"
                        },
                        "limit": 20
                      },
                      "query": ""
                    }
                  }
                },
                {
                  "title": {
                    "hiText": "हाल ही में जोड़ा गया",
                    "enText": "Recently Added",
                    "id": "recentlyAdded"
                  },
                  "data": {
                    "type": "courseStrip",
                    "enabled": true,
                    "apiUrl": "/api/composite/v1/search",
                    "telemetryPrimaryCategory": "course",
                    "telemetrySubType": "recently-added-courses",
                    "telemetryIdentifier": "card-content",
                    "request": {
                      "request": {
                        "filters": {
                          "primaryCategory": ["Course"],
                          "contentType": ["Course"]
                        },
                        "query": "",
                        "sort_by": {"lastUpdatedOn": "desc"},
                        "fields": [
                          "name",
                          "appIcon",
                          "instructions",
                          "description",
                          "purpose",
                          "mimeType",
                          "gradeLevel",
                          "identifier",
                          "medium",
                          "pkgVersion",
                          "board",
                          "subject",
                          "resourceType",
                          "primaryCategory",
                          "contentType",
                          "channel",
                          "organisation",
                          "trackable",
                          "license",
                          "posterImage",
                          "idealScreenSize",
                          "learningMode",
                          "creatorLogo",
                          "duration",
                          "avgRating",
                          "languageMapV1"
                        ],
                        "limit": 20,
                        "offset": 0
                      }
                    }
                  }
                }
              ]
            },
            {
              "title": {
                "hiText": "कार्यक्रम",
                "enText": "Program",
                "id": "program"
              },
              "enabled": true,
              "type": "dropdown",
              "filterItems": [
                {
                  "title": {
                    "hiText": "हाल ही में जोड़ा गया",
                    "enText": "Recently Added",
                    "id": "recentlyAdded"
                  },
                  "data": {
                    "type": "courseStrip",
                    "enabled": true,
                    "apiUrl": "/api/composite/v1/search",
                    "telemetryPrimaryCategory": "program",
                    "telemetrySubType": "recently-added-programs",
                    "telemetryIdentifier": "card-content",
                    "request": {
                      "request": {
                        "filters": {
                          "primaryCategory": ["Curated Program"],
                          "contentType": ["Course"]
                        },
                        "sort_by": {"lastUpdatedOn": "desc"},
                        "fields": [
                          "name",
                          "appIcon",
                          "instructions",
                          "description",
                          "purpose",
                          "mimeType",
                          "gradeLevel",
                          "identifier",
                          "medium",
                          "pkgVersion",
                          "board",
                          "subject",
                          "resourceType",
                          "primaryCategory",
                          "contentType",
                          "channel",
                          "organisation",
                          "trackable",
                          "license",
                          "posterImage",
                          "idealScreenSize",
                          "learningMode",
                          "creatorLogo",
                          "duration",
                          "avgRating"
                        ],
                        "query": "",
                        "limit": 20,
                        "offset": 0
                      }
                    }
                  }
                },
                {
                  "title": {
                    "hiText": "विभाग में ट्रेंडिंग",
                    "enText": "Trending In Department",
                    "id": "trendingInDepartment"
                  },
                  "data": {
                    "type": "courseStrip",
                    "telemetryPrimaryCategory": "program",
                    "telemetrySubType": "trending-in-department-events",
                    "telemetryIdentifier": "card-content",
                    "enabled": true,
                    "apiUrl": "/api/trending/search",
                    "request": {
                      "request": {
                        "filters": {
                          "contextType": ["programs"],
                          "organisation": "rootOrgId"
                        },
                        "limit": 20
                      }
                    }
                  }
                },
                {
                  "title": {
                    "hiText": "विभागों में ट्रेंडिंग",
                    "enText": "Trending Across Department",
                    "id": "trendingAcrossDepartment"
                  },
                  "data": {
                    "type": "courseStrip",
                    "enabled": true,
                    "apiUrl": "/api/trending/search",
                    "telemetryPrimaryCategory": "program",
                    "telemetrySubType": "trending-across-department-events",
                    "telemetryIdentifier": "card-content",
                    "request": {
                      "request": {
                        "filters": {
                          "contextType": ["programs"],
                          "organisation": "across"
                        },
                        "limit": 20
                      }
                    }
                  }
                }
              ]
            }
          ]
        },
        {
          "type": "tab",
          "enabled": true,
          "enableTheme": false,
          "backgroundColor": "0xffffffff",
          "title": {
            "hiText": "साझेदार",
            "enText": "Partners",
            "id": "partners"
          },
          "tabItems": [
            {
              "title": {
                "hiText": "प्रशिक्षण संस्थान",
                "enText": "Training Institutes",
                "id": "trainingInstitutes"
              },
              "enabled": true,
              "type": "trainingInstitutes",
              "apiUrl": "/api/content/v1/read/"
            },
            {
              "title": {
                "hiText": "प्रदाता",
                "enText": "Providers",
                "id": "providers"
              },
              "enabled": true,
              "type": "providers",
              "apiUrl": "/api/cios/v1/search/content",
              "request": {
                "filterCriteriaMap": {},
                "requestedFields": [
                  "topic",
                  "name",
                  "appIcon",
                  "duration",
                  "externalId",
                  "objectives",
                  "description",
                  "redirectUrl",
                  "contentId",
                  "createdOn",
                  "lastUpdatedOn",
                  "isActive",
                  "contentPartner"
                ],
                "pageNumber": 0,
                "pageSize": 10,
                "facets": ["topic"],
                "orderBy": "createdOn",
                "orderDirection": "desc"
              }
            }
          ]
        },
        {
          "type": "mdoChannel",
          "title": {
            "hiText": "एमडीओ चैनल",
            "enText": "MDO channels",
            "id": "mdoChannels"
          },
          "enabled": true,
          "enableTheme": false,
          "backgroundColor": "0xffffffff",
          "apiUrl": "/api/orgBookmark/v1/read/"
        },
        {
          "type": "courseStrip",
          "enabled": true,
          "enableTheme": false,
          "backgroundColor": "0xffffffff",
          "telemetryPrimaryCategory": "program",
          "telemetrySubType": "blended-program",
          "telemetryIdentifier": "card-content",
          "title": {
            "hiText": "मिश्रित कार्यक्रम",
            "enText": "Blended Program",
            "id": "upcoming"
          },
          "filterWithDate": true,
          "apiUrl": "/api/composite/v1/search",
          "request": {
            "request": {
              "filters": {
                "primaryCategory": ["Blended Program"],
                "contentType": ["Course"],
                "batches.enrollmentEndDate": {}
              },
              "offset": 0,
              "limit": 20,
              "query": "",
              "sort_by": {"lastUpdatedOn": "desc"},
              "fields": [
                "name",
                "appIcon",
                "instructions",
                "description",
                "purpose",
                "mimeType",
                "gradeLevel",
                "identifier",
                "medium",
                "pkgVersion",
                "board",
                "subject",
                "resourceType",
                "primaryCategory",
                "contentType",
                "channel",
                "organisation",
                "trackable",
                "license",
                "posterImage",
                "idealScreenSize",
                "learningMode",
                "creatorLogo",
                "duration",
                "version",
                "programDuration",
                "avgRating"
              ]
            },
            "query": ""
          }
        },
        {
          "type": "courseStrip",
          "enabled": true,
          "enableTheme": false,
          "backgroundColor": "0xffffffff",
          "telemetryPrimaryCategory": "courses",
          "telemetrySubType": "learning-under-30-minutes",
          "telemetryIdentifier": "card-content",
          "title": {
            "hiText": "30 मिनट के भीतर सीखना",
            "enText": "Learning Under 30 min",
            "id": "learningUnder30Min"
          },
          "apiUrl": "/api/trending/search",
          "request": {
            "request": {
              "filters": {
                "contextType": ["under_30_mins"],
                "organisation": "across"
              },
              "limit": 20
            }
          }
        },
        {
          "type": "carouselStrip",
          "enabled": true,
          "enableTheme": false,
          "backgroundColor": "0xffffffff",
          "title": {
            "hiText": "सप्ताह का प्रमाणपत्र",
            "enText": "Certificate of the week",
            "id": "certificateOfTheWeek"
          },
          "telemetrySubType": "certifications-of-the-week",
          "telemetryPrimaryCategory": "Certificate",
          "apiUrl": "/api/trending/search",
          "request": {
            "request": {
              "filters": {
                "contextType": ["certifications"],
                "organisation": "across"
              },
              "limit": 20
            }
          }
        },
        {
          "type": "banner",
          "enabled": true,
          "enableTheme": true,
          "backgroundColor": "0xffeff3f9",
          "data": [
            {
              "imageUrl": {
                "hiUrl":
                    "https://portal.igotkarmayogi.gov.in/assets/instances/eagle/banners/orgs/new-banner/10/l.jpg",
                "enUrl":
                    "https://portal.igotkarmayogi.gov.in/assets/instances/eagle/banners/orgs/new-banner/10/l.jpg"
              },
              "redirectionUrl":
                  "https://portal.igotkarmayogi.gov.in/app/globalsearch"
            },
            {
              "imageUrl": {
                "hiUrl":
                    "https://portal.igotkarmayogi.gov.in/assets/instances/eagle/banners/orgs/new-banner/7/l.jpg",
                "enUrl":
                    "https://portal.igotkarmayogi.gov.in/assets/instances/eagle/banners/orgs/new-banner/7/l.jpg"
              },
              "redirectionUrl":
                  "https://ncrb.gov.in/uploads/SankalanPortal/Index.html"
            },
            {
              "imageUrl": {
                "hiUrl":
                    "https://portal.igotkarmayogi.gov.in/assets/instances/eagle/banners/orgs/new-banner/8/l.jpg",
                "enUrl":
                    "https://portal.igotkarmayogi.gov.in/assets/instances/eagle/banners/orgs/new-banner/8/l.jpg"
              },
              "redirectionUrl": ""
            },
            {
              "imageUrl": {
                "hiUrl":
                    "https://portal.igotkarmayogi.gov.in/assets/instances/eagle/banners/orgs/new-banner/2/m.png",
                "enUrl":
                    "https://portal.igotkarmayogi.gov.in/assets/instances/eagle/banners/orgs/new-banner//2/m.png"
              },
              "redirectionUrl": ""
            }
          ]
        },
        {
          "type": "discussHub",
          "enabled": false,
          "enableTheme": true,
          "backgroundColor": "0xffeff3f9"
        },
        {
          "type": "networkHub",
          "enabled": true,
          "enableTheme": true,
          "backgroundColor": "0xffeff3f9"
        },
        {
          "type": "topProviderStrip",
          "enabled": true,
          "enableTheme": true,
          "backgroundColor": "0xffeff3f9"
        },
        {
          "type": "socialMedia",
          "enabled": true,
          "enableTheme": true,
          "backgroundColor": "0xffeff3f9"
        }
      ],
      "surveyPopup": {
        "enabled": false,
        "data": {
          "imageUrl": {
            "hiUrl":
                "assets/instances/eagle/survey-img/survey_pop_up_mobile.png",
            "enUrl":
                "assets/instances/eagle/survey-img/survey_pop_up_mobile.png"
          },
          "btnTitle": {
            "hiText": "सर्वेक्षण लें",
            "id": "takeSurvey",
            "enText": "Take Survey"
          },
          "surveyUrl": "/surveyml/668e250da8bfb500083136b1"
        }
      },
      "serverUnderMaintenance": {
        "enabled": false,
        "greet": {
          "enText": "Namaste Karmayogi",
          "hiText": "नमस्ते कर्मयोगी",
          "id": "namasteKarmayogi"
        },
        "title": {
          "enText": "We will be back soon!",
          "hiText": "हम जल्दी ही वापस आएंगे!",
          "id": "weWillBeBackSoon"
        },
        "subTitle": {
          "enText": "From 06th September, 10 PM to 02 AM",
          "hiText": "06 सितंबर, 10 बजे से 02 बजे तक",
          "id": "maintenancePeriod"
        },
        "description": {
          "enText":
              "Our Application is undergoing a major technology upgrade to bring you a better experience and enhance your learning journey at iGOT.",
          "hiText":
              "हमारा एप्लिकेशन एक प्रमुख तकनीकी उन्नयन से गुजर रहा है ताकि हम आपको बेहतर अनुभव प्रदान कर सकें और iGOT पर आपकी अध्ययन यात्रा को बेहतर बना सकें।",
          "id": "appUndergoingUpgrade"
        },
        "thumbnailTitle": {
          "enText": "Meanwhile, Explore Karmayogi Talks & Course on YouTube.",
          "hiText":
              "इस बीच, YouTube पर कर्मयोगी टॉक्स और कोर्स एक्सप्लोर करें।",
          "id": "exploreKarmayogiTalks"
        },
        "thumbnails": [
          {
            "image": "assets/maintenance/karmayogi-talk.png",
            "redirectionUrl":
                "https://www.youtube.com/playlist?list=PLMzVnzbHaB8tpuYUiTTITmSgMfH8uZWMN",
            "title": {
              "enText": "Karmayogi Talks",
              "hiText": "कर्मयोगी टॉक्स",
              "id": "karmayogiTalks"
            }
          },
          {
            "image": "assets/maintenance/Course-preview.png",
            "redirectionUrl":
                "https://www.youtube.com/playlist?list=PLMzVnzbHaB8uqc3APlK_oXkDaOhmMmrrY",
            "title": {
              "enText": "Course Preview",
              "hiText": "कोर्स पूर्वावलोकन",
              "id": "coursePreview"
            }
          }
        ]
      },
      "mdoChannelMobile": {
        "dev": {"active": true, "id": "76f2eb70-5972-11ef-a96f-77be375b05e1"},
        "qa": {"active": true, "id": "38fd55c0-2723-11ef-b7bd-6754f54dd52f"},
        "uat": {"active": true, "id": "d8603620-3775-11ef-922d-897d09cffbf2"},
        "prod": {"active": false, "id": "4d4e9400-818a-11ef-99c5-a7f9cd9185b1"}
      },
      "micrositeMobile": {
        "dev": {"active": true, "id": ""},
        "qa": {"active": true, "id": "do_1140809843675136001224"},
        "uat": {"active": true, "id": "do_114081134376157184129"},
        "prod": {"active": true, "id": "do_1140809851011317761688"}
      },
      "clientList": [
        {
          "orgId": "01355681440917913657",
          "clientImageUrl":
              "assets/icons/top-providers/0d400bdf-4ad8-45bf-914c-be44018c2d07.png",
          "clientName":
              "Department for Promotion of Industry and Internal Trade",
          "clientUrl":
              "https://portal.igotkarmayogi.gov.in/app/learn/browse-by/provider/Department for Promotion of Industry and Internal Trade/all-CBP"
        },
        {
          "orgId": "01341209715000115258",
          "clientImageUrl":
              "assets/icons/top-providers/1becfffa-956e-48ba-8ffd-77c19cd720c8.jpeg",
          "clientName": "RAKNPA",
          "clientUrl":
              "https://portal.igotkarmayogi.gov.in/app/learn/browse-by/provider/RAKNPA/all-CBP"
        },
        {
          "orgId": "013590658732466176131",
          "clientImageUrl":
              "assets/icons/top-providers/1d76c041-a7c9-437c-94d9-36d997f3804c.jpeg",
          "clientName":
              "Lal Bahadur Shastri National Academy of Administration (LBSNAA)",
          "clientUrl":
              "https://portal.igotkarmayogi.gov.in/app/learn/browse-by/provider/LBSNAA/all-CBP"
        },
        {
          "orgId": "0135536923694202881",
          "clientImageUrl":
              "assets/icons/top-providers/1fb72c3f-1c96-4600-8e22-09871a85e6c4.jpeg",
          "clientName": "Ministry of Environment, Forest and Climate Change",
          "clientUrl":
              "https://portal.igotkarmayogi.gov.in/app/learn/browse-by/provider/Ministry of Environment, Forest and Climate Change/all-CBP"
        },
        {
          "orgId": "0133872821604761600",
          "clientImageUrl":
              "assets/icons/top-providers/6f046f76-b778-476a-987b-8669e106b44c.jpeg",
          "clientName": "Institute of Secretariat Training and Management",
          "clientUrl":
              "https://portal.igotkarmayogi.gov.in/app/learn/browse-by/provider/Institute of Secretariat Training and Management/all-CBP"
        },
        {
          "orgId": "0134156658793594880",
          "clientImageUrl":
              "assets/icons/top-providers/7f6df809-6930-44f4-abcf-c8297363d3e0.png",
          "clientName": "Department of Expenditure",
          "clientUrl":
              "https://portal.igotkarmayogi.gov.in/app/learn/browse-by/provider/Department%20of%20Expenditure%20/all-CBP"
        },
        {
          "orgId": "01341136245758361636",
          "clientImageUrl": "assets/icons/top-providers/dopt.png",
          "clientName": "Department of Personnel and Training DoPT",
          "clientUrl":
              "https://portal.igotkarmayogi.gov.in/app/learn/browse-by/provider/Department%20of%20Personnel%20and%20Training%20DoPT/all-CBP"
        },
        {
          "orgId": "0138119804691087361299",
          "clientImageUrl":
              "assets/icons/top-providers/7f8cab8e-9d22-44ba-a41e-83b907e5a5f0.jpeg",
          "clientName": "Indian Cybercrime Coordination Centre - I4C",
          "clientUrl":
              "https://portal.igotkarmayogi.gov.in/app/learn/browse-by/provider/Indian%20Cybercrime%20Coordination%20Centre%20-%20I4C/all-CBP"
        },
        {
          "orgId": "0134001680852664321",
          "clientImageUrl":
              "assets/icons/top-providers/33e9c66f-312f-4244-901e-7d7525ae8847.jpeg",
          "clientName": "Capacity Building Commission",
          "clientUrl":
              "https://portal.igotkarmayogi.gov.in/app/learn/browse-by/provider/Capacity Building Commission/all-CBP"
        },
        {
          "orgId": "01373417051866726412130",
          "clientImageUrl":
              "assets/icons/top-providers/36d93700-c43f-499e-ab3c-68ea76388a2a.png",
          "clientName": "Ministry of Railways",
          "clientUrl":
              "https://portal.igotkarmayogi.gov.in/app/learn/browse-by/provider/Ministry of Railways/all-CBP"
        },
        {
          "orgId": "0134086213264506888",
          "clientImageUrl":
              "assets/icons/top-providers/385ff4a0-41af-4114-8015-10d26c1e8af4.jpeg",
          "clientName": "World Bank",
          "clientUrl":
              "https://portal.igotkarmayogi.gov.in/app/learn/browse-by/provider/World Bank/all-CBP"
        },
        {
          "orgId": "013616592545947648401",
          "clientImageUrl":
              "assets/icons/top-providers/778b56bf-8946-45fe-87d3-358203f2faf4.png",
          "clientName": "Sashastra Seema Bal (SSB)",
          "clientUrl":
              "https://portal.igotkarmayogi.gov.in/app/learn/browse-by/provider/Sashastra%20Seema%20Bal%20%28SSB%29/all-CBP"
        },
        {
          "orgId": "013413016323874816106",
          "clientImageUrl":
              "assets/icons/top-providers/2862d2e5-473e-4c55-abaa-8a2f86e5eee4.jpeg",
          "clientName": "SVPNPA",
          "clientUrl":
              "https://portal.igotkarmayogi.gov.in/app/learn/browse-by/provider/SVPNPA/all-CBP"
        },
        {
          "orgId": "0136364025461473287707",
          "clientImageUrl":
              "assets/icons/top-providers/53407dd6-d22c-4dba-a394-015fae667636.png",
          "clientName": "Microsoft",
          "clientUrl":
              "https://portal.igotkarmayogi.gov.in/app/learn/browse-by/provider/Microsoft/all-CBP"
        },
        {
          "orgId": "01341211756679987273",
          "clientImageUrl":
              "assets/icons/top-providers/869960d7-2dc7-4205-8c4b-11321d901060.jpeg",
          "clientName": "Indian Institute of Public Administration",
          "clientUrl":
              "https://portal.igotkarmayogi.gov.in/app/learn/browse-by/provider/Indian Institute of Public Administration/all-CBP"
        },
        {
          "orgId": "013596952457666560294",
          "clientImageUrl":
              "assets/icons/top-providers/4183673f-9063-4fa9-bf84-1e8856c8e531.jpeg",
          "clientName": "Food Corporation of India (FCI)",
          "clientUrl":
              "https://portal.igotkarmayogi.gov.in/app/learn/browse-by/provider/Food%20Corporation%20of%20India%20%28FCI%29/all-CBP"
        },
        {
          "orgId": "0134156658793594880",
          "clientImageUrl":
              "assets/icons/top-providers/a976f025-e990-49b0-a52a-9bd0a8e43584.jpeg",
          "clientName":
              "National Telecommunications Institute for Policy Research, Innovation and Training",
          "clientUrl":
              "https://portal.igotkarmayogi.gov.in/app/learn/browse-by/provider/NTIPRIT/all-CBP"
        },
        {
          "orgId": "01364991683959193671",
          "clientImageUrl":
              "assets/icons/top-providers/abbb8f64-84db-4a92-85c9-1b394ffab71c.png",
          "clientName": "The Art of Living",
          "clientUrl":
              "https://portal.igotkarmayogi.gov.in/app/learn/browse-by/provider/The Art of Living/all-CBP"
        },
        {
          "orgId": "013568638827937792416",
          "clientImageUrl":
              "assets/icons/top-providers/b6bf0be6-7e29-4187-a29d-da6db1db7c69.jpeg",
          "clientName": "National Institute of Communication Finance",
          "clientUrl":
              "https://portal.igotkarmayogi.gov.in/app/learn/browse-by/provider/National Institute of Communication Finance/all-CBP"
        },
        {
          "orgId": "013594775897538560248",
          "clientImageUrl":
              "assets/icons/top-providers/cf567f4c-d0fa-447f-aba4-cb378ea3c90d.png",
          "clientName": "Department of Posts",
          "clientUrl":
              "https://portal.igotkarmayogi.gov.in/app/learn/browse-by/provider/Department of Posts/all-CBP"
        },
        {
          "orgId": "01341099780408934432",
          "clientImageUrl":
              "assets/icons/top-providers/ef8a88cf-33cc-42de-bdc3-7deed1ab2418.png",
          "clientName": "IIMB",
          "clientUrl":
              "https://portal.igotkarmayogi.gov.in/app/learn/browse-by/provider/IIMB/all-CBP"
        },
        {
          "orgId": "013618933546754048361",
          "clientImageUrl":
              "assets/icons/top-providers/f445c11b-ff73-4ca4-9dea-8d8945d92a4a.png",
          "clientName": "Government e Market Place(GeM)",
          "clientUrl":
              "https://portal.igotkarmayogi.gov.in/app/learn/browse-by/provider/Government%20e%20Market%20Place%28GeM%29/all-CBP"
        },
        {
          "orgId": "0135346646711500804337",
          "clientImageUrl":
              "assets/icons/top-providers/fc67226a-4bbc-449a-8c5c-e1b338716545.png",
          "clientName": "Bharat Sanchar Nigam Limited(BSNL)",
          "clientUrl":
              "https://portal.igotkarmayogi.gov.in/app/learn/browse-by/provider/Bharat%20Sanchar%20Nigam%20Limited%28BSNL%29/all-CBP"
        },
        {
          "orgId": "0135997900135055367644",
          "clientImageUrl":
              "assets/icons/top-providers/fccdb487-a389-48d9-bce0-c4d64315b546.png",
          "clientName": "Defence Accounts Department (DAD)",
          "clientUrl":
              "https://portal.igotkarmayogi.gov.in/app/learn/browse-by/provider/Defence%20Accounts%20Department%20%28DAD%29/all-CBP"
        },
        {
          "orgId": "0137924892561899523",
          "clientImageUrl":
              "assets/icons/top-providers/fcde4c60-7ccd-456e-a5df-260dcfa2d3ee.png",
          "clientName": "Morarji Desai National Institute of Yoga (MDNIY)",
          "clientUrl":
              "https://portal.igotkarmayogi.gov.in/app/learn/browse-by/provider/Morarji%20Desai%20National%20Institute%20of%20Yoga%20%28MDNIY%29/all-CBP"
        }
      ]
    };
  }
}
