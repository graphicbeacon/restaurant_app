import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class RestaurantItem extends StatelessWidget {
  final Restaurant restaurant;

  RestaurantItem(this.restaurant);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          children: [
            restaurant.thumbnail != null && restaurant.thumbnail.isNotEmpty
                ? Ink(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.blueGrey,
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(restaurant.thumbnail),
                      ),
                    ),
                  )
                : Container(
                    height: 100,
                    width: 100,
                    color: Colors.blueGrey,
                    child: Icon(
                      Icons.restaurant,
                      size: 30,
                      color: Colors.white,
                    ),
                  ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      restaurant.name,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 7),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Colors.redAccent,
                          size: 15,
                        ),
                        SizedBox(width: 5),
                        Text(restaurant.locality),
                      ],
                    ),
                    SizedBox(height: 5),
                    RatingBarIndicator(
                      rating: double.parse(restaurant.rating),
                      itemBuilder: (_, __) {
                        return Icon(
                          Icons.star,
                          color: Colors.amber,
                        );
                      },
                      itemSize: 20,
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class Restaurant {
  final String id;
  final String name;
  final String address;
  final String locality;
  final String rating;
  final int reviews;
  final String thumbnail;

  Restaurant._({
    this.id,
    this.name,
    this.address,
    this.locality,
    this.rating,
    this.reviews,
    this.thumbnail,
  });
  factory Restaurant(Map json) => Restaurant._(
      id: json['restaurant']['id'],
      name: json['restaurant']['name'],
      address: json['restaurant']['location']['address'],
      locality: json['restaurant']['location']['locality'],
      rating: json['restaurant']['user_rating']['aggregate_rating']?.toString(),
      reviews: json['restaurant']['all_reviews_count'],
      thumbnail:
          json['restaurant']['featured_image'] ?? json['restaurant']['thumb']);
}
