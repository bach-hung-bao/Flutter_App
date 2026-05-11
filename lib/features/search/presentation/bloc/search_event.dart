abstract class SearchEvent {
  const SearchEvent();
}

class LoadFeaturedHotelsEvent extends SearchEvent {
  final int pageSize;
  const LoadFeaturedHotelsEvent({this.pageSize = 8});
}

class SearchQueryChangedEvent extends SearchEvent {
  final String query;
  final int searchMode; // 0: by name, 1: by province

  const SearchQueryChangedEvent(this.query, this.searchMode);
}
