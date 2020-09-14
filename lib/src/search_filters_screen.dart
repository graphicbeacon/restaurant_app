import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class SearchFilters extends StatefulWidget {
  final locations = ['city', 'subzone', 'zone', 'landmark', 'metro', 'group'];
  final sort = ['cost', 'rating'];
  final order = ['asc', 'desc'];
  final double count = 20;

  final Dio dio;

  final Function(SearchOptions filters) onSetFilters;

  SearchFilters({this.onSetFilters, this.dio});

  @override
  _SearchFiltersState createState() => _SearchFiltersState();
}

class _SearchFiltersState extends State<SearchFilters> {
  List<Category> _categories;
  SearchOptions _searchOptions;

  Future<List<Category>> getCategories() async {
    final response = await widget.dio.get('categories');
    final data = response.data['categories'];
    return data
        .map<Category>((json) => Category(
              json['categories']['id'],
              json['categories']['name'],
            ))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _searchOptions = SearchOptions(
      location: widget.locations.first,
      sort: widget.sort.first,
      order: widget.order.first,
      count: widget.count,
    );

    getCategories().then((categories) {
      setState(() {
        _categories = categories;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Filter your search'),
        backgroundColor: Colors.red,
      ),
      body: Container(
        child: ListView(
          children: [
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Categories:',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _categories is List<Category>
                      ? Wrap(
                          spacing: 10,
                          children: List<Widget>.generate(_categories.length,
                              (index) {
                            final category = _categories[index];
                            final isSelected =
                                _searchOptions.categories.contains(category.id);

                            return FilterChip(
                              label: Text(category.name),
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Theme.of(context)
                                        .textTheme
                                        .bodyText1
                                        .color,
                                fontWeight: FontWeight.bold,
                              ),
                              selected: isSelected,
                              selectedColor: Colors.redAccent,
                              checkmarkColor: Colors.white,
                              onSelected: (bool selected) {
                                setState(() {
                                  if (selected) {
                                    _searchOptions.categories.add(category.id);
                                  } else {
                                    _searchOptions.categories
                                        .remove(category.id);
                                  }
                                });
                              },
                            );
                          }),
                        )
                      : Center(
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                  SizedBox(height: 30),
                  Text(
                    'Location type:',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  DropdownButton<String>(
                      isExpanded: true,
                      value: _searchOptions.location,
                      items: widget.locations.map<DropdownMenuItem<String>>(
                        (value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        },
                      ).toList(),
                      onChanged: (value) {
                        setState(() {
                          _searchOptions.location = value;
                        });
                      }),
                  SizedBox(height: 30),
                  Text(
                    'Order by:',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  for (int idx = 0; idx < widget.order.length; idx++)
                    RadioListTile(
                        title: Text(widget.order[idx]),
                        value: widget.order[idx],
                        groupValue: _searchOptions.order,
                        onChanged: (selection) {
                          setState(() {
                            _searchOptions.order = selection;
                          });
                        }),
                  SizedBox(height: 30),
                  Text(
                    'Sort by:',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Wrap(
                    spacing: 10,
                    children: widget.sort.map<ChoiceChip>((sort) {
                      return ChoiceChip(
                        label: Text(sort),
                        selected: _searchOptions.sort == sort,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _searchOptions.sort = sort;
                            });
                          }
                        },
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 30),
                  Text(
                    '# of results to show:',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Slider(
                      value: _searchOptions.count ?? 5,
                      min: 5,
                      max: widget.count,
                      label: _searchOptions.count?.round().toString(),
                      divisions: 3,
                      onChanged: (value) {
                        setState(() {
                          _searchOptions.count = value;
                          widget.onSetFilters(_searchOptions);
                        });
                      }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchOptions {
  String location;
  String order;
  String sort;
  double count;
  List<int> categories = [];

  SearchOptions({
    this.location,
    this.order,
    this.sort,
    this.count,
  });

  Map<String, dynamic> toJson() => {
        'location': location,
        'sort': sort,
        'order': order,
        'count': count,
        'category': categories.join(',')
      };
}

class Category {
  final int id;
  final String name;
  const Category(this.id, this.name);
}
