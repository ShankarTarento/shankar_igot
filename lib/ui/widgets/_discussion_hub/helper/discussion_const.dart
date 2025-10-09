
enum MediaSource { image, video, file }

class MediaConst {
  static const String image = 'image';
  static const String video = 'video';
  static const String file = 'document';
  static const String link = 'link';
}

enum DiscussionType { feeds, pinned, links, docs, yourPost, bookmarked, globalFeeds }

class PostTypeConst {
  static const String question = 'question';
  static const String answerPost = 'answerPost';
  static const String answerPostReply = 'answerPostReply';
}

const int SEARCH_START_LIMIT = 3;
const int COMMUNITY_CARD_DISPLAY_LIMIT = 5;
const int COMMUNITY_TOPIC_CARD_DISPLAY_LIMIT = 3;
const int maxImageUploadCount = 5;
const int maxVideoUploadCount = 5;
const int maxFileUploadCount = 5;
const int maxMediaUploadCount = 10;
const double maxMediaSizeInMB = 10;
const double maxFileSizeInMB = 50;
const String communityDefaultBannerImage = '/assets/instances/eagle/banners/discussion/community-default-mb-banner.png';
