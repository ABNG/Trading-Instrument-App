import 'package:flutter/material.dart';
import 'package:trading_instruments/data/model/symbol_model.dart';

class SearchScreen extends SearchDelegate<SymbolModel> {
  final Map<String, SymbolModel> inMemoryDB;

  SearchScreen({required this.inMemoryDB});
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
          // When pressed here the query will be cleared from the search bar.
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => Navigator.of(context).pop(),
      // Exit from the search screen.
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final List<MapEntry<String, SymbolModel>> searchResults = inMemoryDB.entries
        .where((entry) => entry.key.toLowerCase().contains(query.toLowerCase()))
        .toList();
    return ListView.separated(
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        final model = searchResults[index].value;
        return ListTile(
          title: Text(
            model.symbol ?? "",
            style: TextStyle(fontSize: 10),
          ),
          trailing: Text(
            (model.price ?? 0.0) == 0.0 ? "-" : model.price.toString(),
            style: TextStyle(
              color: model.isPriceIncreasing == null
                  ? null
                  : model.isPriceIncreasing!
                      ? Colors.green
                      : Colors.red,
            ),
          ),
        );
      },
      separatorBuilder: (context, index) => Divider(),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Center(
      child: Text("Type to search..."),
    );
  }
}
