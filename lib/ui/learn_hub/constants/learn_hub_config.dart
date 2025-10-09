class LearnHubConfig {
  Map<String, dynamic> getLearnHubConfig() {
    return {
      "data": [
        {
          "type": "enrollmentCourseStrip",
          "enabled": true,
          "enableTheme": false,
          "requestType": "GET",
          "backgroundColor": "0xffffffff",
          "telemetryPrimaryCategory": "courses",
          "telemetrySubType": "your-learning",
          "telemetryIdentifier": "card-content",
          "title": {
            "hiText": "आपका सीखना",
            "enText": "Your Learning",
            "id": "yourLearning"
          },
          "toolTipMessage": {
            "hiText": "आपका सीखना",
            "enText": "Your Learning",
            "id": "yourLearningTooltip"
          },
          "apiUrl": "/api/course/v4/user/enrollment/list/",
          "request": {
            "request": {
              "retiredCoursesEnabled": true,
              "status": "In-Progress",
            }
          }
        },
        {
          "type": "courseStrip",
          "enabled": true,
          "enableTheme": false,
          "backgroundColor": "0xffffffff",
          "telemetryPrimaryCategory": "courses",
          "telemetrySubType": "moderated-program",
          "telemetryIdentifier": "card-content",
          "title": {
            "hiText": "30 मिनट के भीतर सीखना",
            "enText": "Moderated Program",
            "id": "moderatedProgram"
          },
          "toolTipMessage": {
            "hiText": "आपके लिए नियंत्रित कार्यक्रम और नियंत्रित मूल्यांकन",
            "enText": "Moderated Programs and Moderated Assessments for you",
            "id": "moderatedProgramTooltip"
          },
          "apiUrl": "/api/composite/v4/search",
          "request": {
            "request": {
              "query": "",
              "filters": {
                "courseCategory": [
                  "moderated course",
                  "moderated program",
                  "moderated assessment"
                ],
                "contentType": ["course"],
                "status": ["Live"],
                "identifier": []
              },
              "sort_by": {"lastUpdatedOn": "desc"},
              "facets": ["mimeType"],
              "limit": 20,
              "offset": 0
            }
          }
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
          "apiUrl": "/api/composite/v4/search",
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
              "fields": []
            },
            "query": ""
          }
        },
        {
          "type": "featuredCourseStrip",
          "enabled": true,
          "enableTheme": false,
          "requestType": "GET",
          "backgroundColor": "0xffffffff",
          "telemetryPrimaryCategory": "courses",
          "telemetrySubType": "featured-courses",
          "telemetryIdentifier": "card-content",
          "title": {
            "hiText": "विशेष कोर्स",
            "enText": "Featured Courses",
            "id": "featuredCourses"
          },
          "apiUrl": "/api/course/v2/explore",
        },
        {
          "type": "courseStrip",
          "enabled": true,
          "enableTheme": false,
          "backgroundColor": "0xffffffff",
          "telemetryPrimaryCategory": "courses",
          "telemetrySubType": "curated-program",
          "telemetryIdentifier": "card-content",
          "title": {
            "hiText": "क्यूरेटेड कार्यक्रम",
            "enText": "Curated Program",
            "id": "curatedProgram"
          },
          "apiUrl": "/api/composite/v4/search",
          "request": {
            "request": {
              "filters": {
                "primaryCategory": ["Curated Program"],
                "mimeType": [],
                "source": [],
                "mediaType": [],
                "contentType": [],
                "identifier": []
              },
              "status": ["Live"],
              "fields": [],
              "query": "",
              "sort_by": {"lastUpdatedOn": "desc"},
              "limit": 20,
              "offset": 0
            }
          }
        },
        {
          "type": "courseStrip",
          "enabled": true,
          "enableTheme": false,
          "backgroundColor": "0xffffffff",
          "telemetryPrimaryCategory": "program",
          "telemetrySubType": "program",
          "telemetryIdentifier": "card-content",
          "title": {
            "hiText": "कार्यक्रम",
            "enText": "Program",
            "id": "program"
          },
          "apiUrl": "/api/composite/v4/search",
          "request": {
            "request": {
              "filters": {
                "primaryCategory": ["program"],
                "mimeType": [],
                "source": [],
                "mediaType": [],
                "contentType": [],
                "identifier": []
              },
              "status": ["Live"],
              "fields": [],
              "query": "",
              "sort_by": {"lastUpdatedOn": "desc"},
              "limit": 20,
              "offset": 0
            }
          }
        },
        {
          "type": "courseStrip",
          "enabled": true,
          "enableTheme": false,
          "backgroundColor": "0xffffffff",
          "telemetryPrimaryCategory": "courses",
          "telemetrySubType": "recently-added",
          "telemetryIdentifier": "card-content",
          "title": {
            "hiText": "हाल ही में जोड़ा गया",
            "enText": "Recently Added",
            "id": "recentlyAdded"
          },
          "apiUrl": "/api/composite/v4/search",
          "request": {
            "request": {
              "filters": {
                "primaryCategory": ["course"],
                "courseCategory": ["course"],
                "mimeType": [],
                "source": [],
                "mediaType": [],
                "contentType": [],
                "identifier": []
              },
              "status": ["Live"],
              "fields": [],
              "query": "",
              "sort_by": {"lastUpdatedOn": "desc"},
              "limit": 20,
              "offset": 0
            }
          }
        },
        {
          "type": "courseStrip",
          "enabled": true,
          "enableTheme": false,
          "backgroundColor": "0xffffffff",
          "telemetryPrimaryCategory": "courses",
          "telemetrySubType": "standalone-assessment",
          "telemetryIdentifier": "card-content",
          "title": {
            "hiText": "स्वतंत्र आकलन",
            "enText": "Standalone Assessment",
            "id": "standaloneAssessment"
          },
          "apiUrl": "/api/composite/v4/search",
          "request": {
            "request": {
              "filters": {
                "primaryCategory": ["standalone assessment"],
                "mimeType": [],
                "source": [],
                "mediaType": [],
                "contentType": [],
                "identifier": []
              },
              "status": ["Live"],
              "fields": [],
              "query": "",
              "sort_by": {"lastUpdatedOn": "desc"},
              "limit": 20,
              "offset": 0
            }
          }
        },
      ]
    };
  }
}
