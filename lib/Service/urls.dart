class Urls {
  //base url
  // static const String baseUrl = "https://mohosin5001.binarybards.online";
  //  static const String baseUrl = "http://10.10.7.50:4006";
  static const String baseUrl = "http://167.71.254.250:4006";
  static const String googleMapsApiKey = "AIzaSyA6w5wid9n0Vii4W6YxQTn9BG69jI_scuM";

  //auth api
  static const String registrationUrl = "$baseUrl/api/v1/auth/signup";

  static const String loginUrl = "$baseUrl/api/v1/auth/login";

  static const String forgotpassUrl = "$baseUrl/api/v1/auth/forget-password";

  static const String verifyOtpUrl = "$baseUrl/api/v1/auth/verify-account";

  static const String resetPassUrl = "$baseUrl/api/v1/auth/reset-password";
  static const String getAllEvent = "$baseUrl/api/v1/event";

  static String getSingleEvent(String eventID) =>
      "$baseUrl/api/v1/event/$eventID";

  static const String reviewUrl = "$baseUrl/api/v1/review";

  static const String getAllReviewUrl = "$baseUrl/api/v1/review";

  static String getReviewByEventIdUrl(String eventId) {
    return "$baseUrl/api/v1/review/$eventId/event";
  }

  static const String userProfileUrl = "$baseUrl/api/v1/user/profile";

  static String getUserByIdUrl(String id) => "$baseUrl/api/v1/user/$id";

  static const String updateProfileUrl = "$baseUrl/api/v1/user/profile";

  static const String addSaveEvent = "$baseUrl/api/v1/saved";

  static const String getMySaveEvents = '$baseUrl/api/v1/saved?filter=all';

  static String deleteSavedEvent(String id) => "$baseUrl/api/v1/saved/$id";

  // chat api
  static String chatUrl(String other_user_id) =>
      "$baseUrl/api/v1/chat/${other_user_id}";

  static const String getAllChatsUrl = "$baseUrl/api/v1/chat";

  static String getMessage(String chatId) =>
      "$baseUrl/api/v1/message/${chatId}";

  static String sendMessage = "$baseUrl/api/v1/message";

  // follow api
  static String followUserUrl(String userId) =>
      "$baseUrl/api/v1/follow/$userId";
  static String unfollowUserUrl(String userId) =>
      "$baseUrl/api/v1/follow/$userId/unfollow";
  static String getFollowStatsUrl(String userId, String type) =>
      "$baseUrl/api/v1/follow/$userId/followers?type=$type";
  // check in streaming
  // static const String checkInUrl = "$baseUrl/api/v1/ticket/check-in";

  //live chat message api
  //live chat message api
  // Endpoint: GET /api/v1/chatmessages/:roomId/messages
  static String getLiveMessageUrl(
    String roomId, {
    int page = 1,
    int limit = 50,
  }) => "$baseUrl/api/v1/chatmessage/$roomId/messages?page=$page&limit=$limit";

  // Endpoint: POST /api/v1/chatmessages/:roomId/messages
  static String sentMessageUrl(String roomId) =>
      "$baseUrl/api/v1/chatmessage/$roomId/messages";

  //like message api
  // Endpoint: POST /api/v1/chatmessages/messages/:messageId/like
  static String likeMessageUrl(String messageId) =>
      "$baseUrl/api/v1/chatmessage/messages/$messageId/like";

  //delete message
  // Endpoint: DELETE /api/v1/chatmessages/messages/:messageId
  static String deleteMessageUrl(String messageId) =>
      "$baseUrl/api/v1/chatmessage/messages/$messageId";

  // Get Participants
  // Endpoint: GET /api/v1/chatmessages/:roomId/participants
  static String getChatParticipantsUrl(String roomId) =>
      "$baseUrl/api/v1/chatmessage/$roomId/participants";
  static const String userInterestUrl = "$baseUrl/api/v1/user/interest";

  //Notification api
  static const String getAllNotificationUrl = "$baseUrl/api/v1/notifications";
  static String getNotificationByIdUrl(String id) =>
      "$baseUrl/api/v1/notifications/$id";

  static String readAllNotificationUrl =
      "$baseUrl/api/v1/notifications/mark-all";

  static String readNotificationUrl(String id) =>
      "$baseUrl/api/v1/notifications/$id/read";

  //for user side create event
  static const String createUserEvent = "$baseUrl/api/v1/userevent";

  static const String getUserEventsUrl = "$baseUrl/api/v1/userevent";

  static String getSingleUserEvent(String id) => "$baseUrl/api/v1/userevent/$id";

  static String searchLocation(String address) =>
      "$baseUrl/api/v1/event/locations?address=$address";
}
