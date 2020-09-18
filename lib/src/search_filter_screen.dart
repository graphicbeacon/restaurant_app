import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'api.dart';
import 'app_state.dart';

class SearchFilterScreen extends StatefulWidget {
  @override
  _SearchFilterScreenState createState() => _SearchFilterScreenState();
}

class _SearchFilterScreenState extends State<SearchFilterScreen> {
  @override
  Widget build(BuildContext context) {
    final api = Provider.of<ZomatoApi>(context);
    final state = Provider.of<AppState>(context);

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
                  Wrap(
                    spacing: 10,
                    children:
                        List<Widget>.generate(api.categories.length, (index) {
                      final category = api.categories[index];
                      final isSelected =
                          state.searchOptions.categories.contains(category.id);

                      return FilterChip(
                        label: Text(category.name),
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : Theme.of(context).textTheme.bodyText1.color,
                          fontWeight: FontWeight.bold,
                        ),
                        selected: isSelected,
                        selectedColor: Colors.redAccent,
                        checkmarkColor: Colors.white,
                        onSelected: (bool selected) {
                          setState(() {
                            if (selected) {
                              state.searchOptions.categories.add(category.id);
                            } else {
                              state.searchOptions.categories
                                  .remove(category.id);
                            }
                          });
                        },
                      );
                    }),
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
                      value: state.searchOptions.location,
                      items: api.locations.map<DropdownMenuItem<String>>(
                        (value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        },
                      ).toList(),
                      onChanged: (value) {
                        setState(() {
                          state.searchOptions.location = value;
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
                  for (int idx = 0; idx < api.order.length; idx++)
                    RadioListTile(
                        title: Text(api.order[idx]),
                        value: api.order[idx],
                        groupValue: state.searchOptions.order,
                        onChanged: (selection) {
                          setState(() {
                            state.searchOptions.order = selection;
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
                    children: api.sort.map<ChoiceChip>((sort) {
                      return ChoiceChip(
                        label: Text(sort),
                        selected: state.searchOptions.sort == sort,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              state.searchOptions.sort = sort;
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
                      value: state.searchOptions.count ?? 5,
                      min: 5,
                      max: api.count,
                      label: state.searchOptions.count?.round().toString(),
                      divisions: 3,
                      onChanged: (value) {
                        setState(() {
                          state.searchOptions.count = value;
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
