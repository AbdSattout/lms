abstract class HomeEvent {}

class GetHomeDataEvent extends HomeEvent {}
class SearchQueryChanged extends HomeEvent {
  final String query;
  SearchQueryChanged(this.query);
}

class ClearSearch extends HomeEvent {}