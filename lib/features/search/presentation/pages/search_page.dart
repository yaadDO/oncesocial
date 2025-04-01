//Provides a UI for searching users. It interacts with the SearchCubit to manage the search process and display the results dynamically based on the current state
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../web/constrained_scaffold.dart';
import '../../../profile/presentation/components/user_tile.dart';
import '../cubits/search_cubits.dart';
import '../cubits/search_states.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController searchController = TextEditingController();
  //An instance of SearchCubit is retrieved using context.read<SearchCubit>()
  late final searchCubit = context.read<SearchCubit>();

  //A method that gets called whenever the user types something in the search bar.
  //It reads the query from searchController and calls searchUsers() on searchCubit to initiate the search
  void onSearchChanged() {
    final query = searchController.text;
    searchCubit.searchUsers(query);
  }

  @override
  void initState() {
    super.initState();
    //Adds a listener to the searchController when the page is initialized, so the onSearchChanged() method will be triggered whenever the input changes.
    searchController.addListener(onSearchChanged);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ConstrainedScaffold(
      appBar: AppBar(
        title: TextField(
          controller: searchController,
          decoration: InputDecoration(
            hintText: l10n.searchUsers,
            hintStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
        ),
      ),
      body: BlocBuilder<SearchCubit, SearchState>(builder: (context, state) {
        if (state is SearchLoaded) {
          if (state.users.isEmpty) {
            return Center(
              child: Text(l10n.userNotFound),
            );
          }

          return ListView.builder(
            itemCount: state.users.length,
            itemBuilder: (context, index) {
              final user = state.users[index];
              return UserTile(user: user!);
            },
          );
        } else if (state is SearchLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is SearchError) {
          return Center(child: Text(state.message));
        }

        //If no search has been performed yet (initial state)
        return Center(
          child: Text(l10n.startSearching),
        );
      }),
    );
  }
}

//BlocBuilder: A Flutter Bloc widget that listens to the SearchCubit and rebuilds the UI whenever the state changes.
