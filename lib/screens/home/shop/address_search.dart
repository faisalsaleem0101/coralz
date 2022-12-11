import 'package:coralz/screens/home/shop/Place.dart';
import 'package:coralz/screens/home/shop/places_services.dart';
import 'package:flutter/material.dart';

class AddressSearch extends SearchDelegate<Place?> {

  late PlaceApiProvider provider;

  AddressSearch(){
    provider = PlaceApiProvider();
  }
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        tooltip: 'Clear',
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      tooltip: 'Back',
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container(
              padding: EdgeInsets.all(16.0),
              child: Text('Address not found'),
            );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder(
      // We will put the api call here
      future: query.isNotEmpty ? provider.fetchSuggestions(query, 'en') : null,
      builder: (context, AsyncSnapshot<List> snapshot) => query == ''
          ? Container(
              padding: EdgeInsets.all(16.0),
              child: Text('Enter your address'),
            )
          : snapshot.hasData
              ? ListView.builder(
                  itemBuilder: (context, index) => ListTile(
                    // we will display the data returned from our future here
                    title:
                        Text(snapshot.data![index].description),
                    onTap: () async {

                      Place place = await provider.getPlaceDetailFromId(snapshot.data![index].placeId);
                      close(context, place);
                    },
                  ),
                  itemCount: snapshot.data!.length,
                )
              : Container(child: Text('Loading...')),
    );
  }
}