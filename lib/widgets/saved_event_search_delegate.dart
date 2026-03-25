import 'package:flutter/material.dart';
import '../models/event_model.dart';

class SavedEventSearchDelegate extends SearchDelegate<EventModel?> {
  final List<EventModel> events;

  SavedEventSearchDelegate(this.events);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    if (query.isEmpty) {
      return const Center(
        child: Text('Enter a search term'),
      );
    }

    final results = events.where((event) {
      final title = event.title.toLowerCase();
      final description = event.description.toLowerCase();
      final location = event.location.toLowerCase();
      final searchLower = query.toLowerCase();

      return title.contains(searchLower) ||
          description.contains(searchLower) ||
          location.contains(searchLower);
    }).toList();

    if (results.isEmpty) {
      return const Center(
        child: Text('No results found'),
      );
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final event = results[index];
        return ListTile(
          title: Text(event.title),
          subtitle: Text(
            '${event.startTime.toString().substring(0, 16)} - ${event.endTime.toString().substring(11, 16)}',
          ),
          onTap: () {
            close(context, event);
          },
        );
      },
    );
  }
}
