
class getStartedContent{
  final String icon;
  final String title;
  final String subtitle;

  getStartedContent({
    required this.icon,
    required this.title,
    required this.subtitle,
});

 static List<getStartedContent> getStartedData = [
    getStartedContent(
        icon:"assets/images/onboard_img1.png" ,
        title: "Explore Your City",
        subtitle: "Navigate through events on an interactive map and never miss what's happening nearby"
    ),
    getStartedContent(
        icon:"assets/images/onboard_img2.png" ,
        title: "Discover Amazing Events",
        subtitle: "Find the hottest parties, concerts, and festivals happening around you"
    ),
    getStartedContent(
        icon:"assets/images/onboard_img3.png" ,
        title: "Connect & Share",
        subtitle: "Join the community, share experiences, and rate your favorite events"
    ),
  ];
}