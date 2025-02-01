//Handles different states during a search operation
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oncesocial/features/search/domain/search_repo.dart';
import 'package:oncesocial/features/search/presentation/cubits/search_states.dart';

class SearchCubit extends Cubit<SearchState> {
  //SearchRepo is a repository interface responsible for fetching users from a data source
  final SearchRepo searchRepo;

  //Initializes the SearchCubit with an initial state of SearchInitial
  SearchCubit({required this.searchRepo}) : super(SearchInitial());


  Future<void> searchUsers(String query) async {
    //If the query string is empty, it resets the state to SearchInitial and returns early without performing any search.
    if (query.isEmpty) {
      emit(SearchInitial());
      return;
    }
    try {
      emit(SearchLoading());
      //Calls searchUsers(query) on searchRepo, which fetches a list of users matching the query.
      final users = await searchRepo.searchUsers(query);
      emit(SearchLoaded(users));
    } catch (e) {
      emit(SearchError('Error fetching search results'));
    }
  }
}