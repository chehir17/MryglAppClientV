class Paginate {
  int? currentPage;
  int? lastPage;
  String? nextPageUrl;
  String? prevPageUrl;

  Paginate(this.currentPage,
      {this.lastPage = 0, this.nextPageUrl = '', this.prevPageUrl = ''});

  Paginate.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      // print(jsonMap);
      currentPage = jsonMap['current_page'];
      lastPage = jsonMap['last_page'];
      nextPageUrl = jsonMap['next_page_url'].toString();
      prevPageUrl = jsonMap['prev_page_url'].toString();
    } catch (e) {}
  }

  Map<String, dynamic> toMap() {
    return {
      'current_page': currentPage,
      'last_page': lastPage,
      'next_page_url': nextPageUrl,
      'prev_page_url': prevPageUrl,
    };
  }
}
