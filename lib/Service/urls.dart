class Urls {
  // Base URL - 10.0.2.2 for Android Emulator, machine IP for physical device
  static const String baseUrl = "http://10.10.7.50:5002/api/v1";
  // static const String baseUrl = "http://195.35.6.13:5002/api/v1";
  static const String googleMapsApiKey = "AIzaSyA6w5wid9n0Vii4W6YxQTn9BG69jI_scuM";

  //auth api
  static const String registrationUrl = "$baseUrl/auth/signup";
  static const String loginUrl = "$baseUrl/auth/login";
  static const String forgotpassUrl = "$baseUrl/auth/forget-password";
  static const String verifyOtpUrl = "$baseUrl/auth/verify-account";
  static const String resetPassUrl = "$baseUrl/auth/reset-password";
  static const String refreshTokenUrl = "$baseUrl/auth/refresh-token";
  static const String changePasswordUrl = "$baseUrl/auth/change-password";
  static const String deleteAccountUrl = "$baseUrl/auth/delete-account";
  static const String logoutUrl = "$baseUrl/auth/logout";

  static const String getAllEvent = "$baseUrl/event";
  static String getSingleEvent(String eventID) => "$baseUrl/event/$eventID";

  static const String reviewUrl = "$baseUrl/review";
  static String getSingleReviewUrl(String id) => "$baseUrl/review/$id";
  static String updateReviewUrl(String id) => "$baseUrl/review/$id";
  static String deleteReviewUrl(String id) => "$baseUrl/review/$id";

  static const String userProfileUrl = "$baseUrl/user/profile";
  static String getUserByIdUrl(String id) => "$baseUrl/user/$id";
  static const String updateProfileUrl = "$baseUrl/user/update-profile";

  static const String calculationsUrl = "$baseUrl/calculations";
  static const String calculationStatsUrl = "$baseUrl/calculations/stats";
  static const String calculationExportUrl = "$baseUrl/calculations/export";
  static String getSingleCalculationUrl(String id) => "$baseUrl/calculations/$id";
  static String deleteCalculationUrl(String id) => "$baseUrl/calculations/$id";

  static const String subscriptionPlansUrl = "$baseUrl/subscription/plans";
  static String getPlanDetailsUrl(String planId) => "$baseUrl/subscription/plans/$planId";
  static const String createSubscriptionUrl = "$baseUrl/subscription/create";
  static const String mySubscriptionUrl = "$baseUrl/subscription/my-subscription";
  static const String subscriptionStatusUrl = "$baseUrl/subscription/status";
  static const String createCheckoutSessionUrl = "$baseUrl/subscription/checkout-session";
  static const String billingPortalUrl = "$baseUrl/subscription/billing-portal";

  static const String addSaveEvent = "$baseUrl/saved";
  static const String getMySaveEvents = '$baseUrl/saved?filter=all';
  static String deleteSavedEvent(String id) => "$baseUrl/saved/$id";

  // chat api
  static String createChatUrl(String other_user_id) => "$baseUrl/chat/${other_user_id}";
  static const String getAllChatsUrl = "$baseUrl/chat";
  static String getMessagesUrl(String chatId) => "$baseUrl/message/${chatId}";
  static const String sendMessageUrl = "$baseUrl/message";

  // follow api
  static String followUserUrl(String userId) => "$baseUrl/follow/$userId";
  static String unfollowUserUrl(String userId) => "$baseUrl/follow/$userId/unfollow";
  static String getFollowStatsUrl(String userId, String type) => "$baseUrl/follow/$userId/followers?type=$type";

  //live chat message api
  static String getLiveMessageUrl(String roomId, {int page = 1, int limit = 50}) => 
      "$baseUrl/chatmessage/$roomId/messages?page=$page&limit=$limit";

  static String sentMessageUrl(String roomId) => "$baseUrl/chatmessage/$roomId/messages";

  static String likeMessageUrl(String messageId) => "$baseUrl/chatmessage/messages/$messageId/like";

  static String deleteMessageUrl(String messageId) => "$baseUrl/chatmessage/messages/$messageId";

  static String getChatParticipantsUrl(String roomId) => "$baseUrl/chatmessage/$roomId/participants";
  
  static const String userInterestUrl = "$baseUrl/user/interest";

  //Notification api
  static const String getAllNotificationUrl = "$baseUrl/notifications";
  static String getNotificationByIdUrl(String id) => "$baseUrl/notifications/$id";
  static const String readAllNotificationUrl = "$baseUrl/notifications/mark-all";
  static String readNotificationUrl(String id) => "$baseUrl/notifications/$id/read";

  //for user side create event
  static const String createUserEvent = "$baseUrl/userevent";
  static const String getUserEventsUrl = "$baseUrl/userevent";
  static String getSingleUserEvent(String id) => "$baseUrl/userevent/$id";

  static String searchLocation(String address) => "$baseUrl/event/locations?address=$address";

  // Support API
  static const String supportUrl = "$baseUrl/support";
  static String getSingleSupportUrl(String id) => "$baseUrl/support/$id";
}
