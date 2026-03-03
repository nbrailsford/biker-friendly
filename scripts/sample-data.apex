// Sample Data Load for Biker Friendly
// Run via: sf apex run --file scripts/sample-data.apex --target-org biker-friendly

// ---- Amenities ----
List<Amenity__c> amenities = new List<Amenity__c>{
    new Amenity__c(Name = 'Bike Rack'),
    new Amenity__c(Name = 'Indoor Seating'),
    new Amenity__c(Name = 'Outdoor Patio'),
    new Amenity__c(Name = 'Restroom'),
    new Amenity__c(Name = 'Water Fountain'),
    new Amenity__c(Name = 'Air Pump'),
    new Amenity__c(Name = 'Repair Station'),
    new Amenity__c(Name = 'Wi-Fi'),
    new Amenity__c(Name = 'Food'),
    new Amenity__c(Name = 'Coffee'),
    new Amenity__c(Name = 'Covered Area'),
    new Amenity__c(Name = 'Bike Storage')
};
insert amenities;

Map<String, Id> amenityMap = new Map<String, Id>();
for (Amenity__c a : amenities) {
    amenityMap.put(a.Name, a.Id);
}

// ---- Venues (Denver metro area) ----
List<Venue__c> venues = new List<Venue__c>();

venues.add(new Venue__c(
    Name = 'Denver Bicycle Cafe',
    Address__c = '1308 E 17th Ave',
    City__c = 'Denver', State__c = 'CO', Zip__c = '80218',
    Location__Latitude__s = 39.7408, Location__Longitude__s = -104.9735,
    Phone__c = '(303) 333-2453',
    Website__c = 'https://denverbicyclecafe.com',
    Hours__c = 'Mon-Fri 7AM-7PM, Sat-Sun 8AM-6PM',
    Status__c = 'Verified',
    Source__c = 'Community-Added'
));

venues.add(new Venue__c(
    Name = 'Raices Brewing Co',
    Address__c = '2060 W Colfax Ave',
    City__c = 'Denver', State__c = 'CO', Zip__c = '80204',
    Location__Latitude__s = 39.7400, Location__Longitude__s = -105.0084,
    Phone__c = '(720) 485-6801',
    Website__c = 'https://raicesbrewing.com',
    Hours__c = 'Tue-Thu 3PM-10PM, Fri-Sat 12PM-11PM, Sun 12PM-8PM',
    Status__c = 'Verified',
    Source__c = 'Community-Added'
));

venues.add(new Venue__c(
    Name = 'Cheesman Park Pavilion',
    Address__c = '1599 E 8th Ave',
    City__c = 'Denver', State__c = 'CO', Zip__c = '80218',
    Location__Latitude__s = 39.7316, Location__Longitude__s = -104.9672,
    Hours__c = 'Dawn to Dusk',
    Status__c = 'Verified',
    Source__c = 'Community-Added'
));

venues.add(new Venue__c(
    Name = 'REI Denver Flagship',
    Address__c = '1416 Platte St',
    City__c = 'Denver', State__c = 'CO', Zip__c = '80202',
    Location__Latitude__s = 39.7580, Location__Longitude__s = -105.0078,
    Phone__c = '(303) 756-3100',
    Website__c = 'https://rei.com',
    Hours__c = 'Mon-Sat 10AM-9PM, Sun 10AM-7PM',
    Status__c = 'Verified',
    Source__c = 'Community-Added'
));

venues.add(new Venue__c(
    Name = 'Tattered Cover - Colfax',
    Address__c = '2526 E Colfax Ave',
    City__c = 'Denver', State__c = 'CO', Zip__c = '80206',
    Location__Latitude__s = 39.7401, Location__Longitude__s = -104.9546,
    Phone__c = '(303) 322-7727',
    Website__c = 'https://tatteredcover.com',
    Hours__c = 'Mon-Sat 9AM-9PM, Sun 10AM-6PM',
    Status__c = 'Verified',
    Source__c = 'Community-Added'
));

venues.add(new Venue__c(
    Name = 'Whole Foods - Capitol Hill',
    Address__c = '900 E 11th Ave',
    City__c = 'Denver', State__c = 'CO', Zip__c = '80218',
    Location__Latitude__s = 39.7341, Location__Longitude__s = -104.9774,
    Phone__c = '(303) 832-7701',
    Website__c = 'https://wholefoodsmarket.com',
    Hours__c = 'Daily 7AM-10PM',
    Status__c = 'Verified',
    Source__c = 'Community-Added'
));

venues.add(new Venue__c(
    Name = 'Stellas Coffee Haus',
    Address__c = '1476 S Pearl St',
    City__c = 'Denver', State__c = 'CO', Zip__c = '80210',
    Location__Latitude__s = 39.6915, Location__Longitude__s = -104.9871,
    Phone__c = '(303) 777-1031',
    Hours__c = 'Daily 6AM-6PM',
    Status__c = 'Verified',
    Source__c = 'Community-Added'
));

venues.add(new Venue__c(
    Name = 'Washington Park Boathouse',
    Address__c = '701 S Franklin St',
    City__c = 'Denver', State__c = 'CO', Zip__c = '80209',
    Location__Latitude__s = 39.7010, Location__Longitude__s = -104.9773,
    Hours__c = 'Dawn to Dusk',
    Status__c = 'Verified',
    Source__c = 'Community-Added'
));

venues.add(new Venue__c(
    Name = 'Bicycle Village - Littleton',
    Address__c = '8061 S Broadway',
    City__c = 'Littleton', State__c = 'CO', Zip__c = '80122',
    Location__Latitude__s = 39.5837, Location__Longitude__s = -104.9875,
    Phone__c = '(303) 346-3490',
    Website__c = 'https://bicyclevillage.com',
    Hours__c = 'Mon-Fri 10AM-7PM, Sat 10AM-6PM, Sun 11AM-5PM',
    Status__c = 'Verified',
    Source__c = 'Community-Added'
));

venues.add(new Venue__c(
    Name = 'Aurora Public Library - Central',
    Address__c = '14949 E Alameda Pkwy',
    City__c = 'Aurora', State__c = 'CO', Zip__c = '80012',
    Location__Latitude__s = 39.7085, Location__Longitude__s = -104.8308,
    Phone__c = '(303) 739-6630',
    Website__c = 'https://auroralibrary.org',
    Hours__c = 'Mon-Thu 9AM-8PM, Fri-Sat 10AM-5PM, Sun 1PM-5PM',
    Status__c = 'Verified',
    Source__c = 'Community-Added'
));

insert venues;

Map<String, Id> venueMap = new Map<String, Id>();
for (Venue__c v : venues) {
    venueMap.put(v.Name, v.Id);
}

// ---- Venue-Amenity Junctions ----
List<Venue_Amenity__c> junctions = new List<Venue_Amenity__c>();

for (String a : new List<String>{'Bike Rack','Indoor Seating','Restroom','Wi-Fi','Coffee','Food','Air Pump','Repair Station','Bike Storage'}) {
    junctions.add(new Venue_Amenity__c(Venue__c = venueMap.get('Denver Bicycle Cafe'), Amenity__c = amenityMap.get(a)));
}
for (String a : new List<String>{'Bike Rack','Indoor Seating','Outdoor Patio','Restroom','Food','Wi-Fi'}) {
    junctions.add(new Venue_Amenity__c(Venue__c = venueMap.get('Raices Brewing Co'), Amenity__c = amenityMap.get(a)));
}
for (String a : new List<String>{'Covered Area','Restroom','Water Fountain'}) {
    junctions.add(new Venue_Amenity__c(Venue__c = venueMap.get('Cheesman Park Pavilion'), Amenity__c = amenityMap.get(a)));
}
for (String a : new List<String>{'Bike Rack','Indoor Seating','Restroom','Water Fountain','Air Pump','Repair Station'}) {
    junctions.add(new Venue_Amenity__c(Venue__c = venueMap.get('REI Denver Flagship'), Amenity__c = amenityMap.get(a)));
}
for (String a : new List<String>{'Bike Rack','Indoor Seating','Restroom','Wi-Fi','Coffee'}) {
    junctions.add(new Venue_Amenity__c(Venue__c = venueMap.get('Tattered Cover - Colfax'), Amenity__c = amenityMap.get(a)));
}
for (String a : new List<String>{'Bike Rack','Indoor Seating','Restroom','Water Fountain','Food','Coffee'}) {
    junctions.add(new Venue_Amenity__c(Venue__c = venueMap.get('Whole Foods - Capitol Hill'), Amenity__c = amenityMap.get(a)));
}
for (String a : new List<String>{'Bike Rack','Indoor Seating','Outdoor Patio','Restroom','Wi-Fi','Coffee'}) {
    junctions.add(new Venue_Amenity__c(Venue__c = venueMap.get('Stellas Coffee Haus'), Amenity__c = amenityMap.get(a)));
}
for (String a : new List<String>{'Covered Area','Restroom','Water Fountain','Bike Rack'}) {
    junctions.add(new Venue_Amenity__c(Venue__c = venueMap.get('Washington Park Boathouse'), Amenity__c = amenityMap.get(a)));
}
for (String a : new List<String>{'Bike Rack','Indoor Seating','Restroom','Air Pump','Repair Station','Bike Storage'}) {
    junctions.add(new Venue_Amenity__c(Venue__c = venueMap.get('Bicycle Village - Littleton'), Amenity__c = amenityMap.get(a)));
}
for (String a : new List<String>{'Bike Rack','Indoor Seating','Restroom','Wi-Fi','Water Fountain','Covered Area'}) {
    junctions.add(new Venue_Amenity__c(Venue__c = venueMap.get('Aurora Public Library - Central'), Amenity__c = amenityMap.get(a)));
}

insert junctions;

// ---- Sample Reviews ----
List<Review__c> reviews = new List<Review__c>();

reviews.add(new Review__c(Venue__c = venueMap.get('Denver Bicycle Cafe'), Rating__c = 5, Comment__c = 'Best spot in Denver for cyclists. Coffee is great, repair tools available, and they actually understand bike culture.'));
reviews.add(new Review__c(Venue__c = venueMap.get('Denver Bicycle Cafe'), Rating__c = 5, Comment__c = 'Got caught in a hailstorm on 17th. Ducked in here and had the best latte of my life while it passed.'));
reviews.add(new Review__c(Venue__c = venueMap.get('Denver Bicycle Cafe'), Rating__c = 4, Comment__c = 'Great concept, solid coffee. Can get crowded on weekends.'));
reviews.add(new Review__c(Venue__c = venueMap.get('Raices Brewing Co'), Rating__c = 4, Comment__c = 'Solid bike rack situation and the beer is excellent. Patio is perfect for summer rides.'));
reviews.add(new Review__c(Venue__c = venueMap.get('Raices Brewing Co'), Rating__c = 5, Comment__c = 'Love that they support the cycling community. Food trucks outside are a bonus.'));
reviews.add(new Review__c(Venue__c = venueMap.get('Cheesman Park Pavilion'), Rating__c = 3, Comment__c = 'Good covered area but no food or water. Decent for a quick rain stop.'));
reviews.add(new Review__c(Venue__c = venueMap.get('Cheesman Park Pavilion'), Rating__c = 4, Comment__c = 'Beautiful park. The pavilion kept me dry during an unexpected afternoon shower.'));
reviews.add(new Review__c(Venue__c = venueMap.get('REI Denver Flagship'), Rating__c = 4, Comment__c = 'Free air pump and basic tools outside. Staff is helpful if you need bike advice.'));
reviews.add(new Review__c(Venue__c = venueMap.get('REI Denver Flagship'), Rating__c = 5, Comment__c = 'Broke a spoke on the Platte trail. REI was right there and saved my ride.'));
reviews.add(new Review__c(Venue__c = venueMap.get('Tattered Cover - Colfax'), Rating__c = 4, Comment__c = 'Great bookstore to kill time during bad weather. Coffee shop inside too.'));
reviews.add(new Review__c(Venue__c = venueMap.get('Stellas Coffee Haus'), Rating__c = 5, Comment__c = 'Pearl Street gem. Best patio for post-ride coffee. They even have a bike pump.'));
reviews.add(new Review__c(Venue__c = venueMap.get('Stellas Coffee Haus'), Rating__c = 4, Comment__c = 'Cozy spot on the S Pearl bike route. Good pastries.'));
reviews.add(new Review__c(Venue__c = venueMap.get('Washington Park Boathouse'), Rating__c = 3, Comment__c = 'Covered area by the lake. No amenities but the view is nice while you wait out rain.'));
reviews.add(new Review__c(Venue__c = venueMap.get('Bicycle Village - Littleton'), Rating__c = 4, Comment__c = 'Full service bike shop. Friendly staff, good selection. Nice stop on the Mary Carter trail.'));
reviews.add(new Review__c(Venue__c = venueMap.get('Aurora Public Library - Central'), Rating__c = 4, Comment__c = 'AC in summer, warmth in winter. Free Wi-Fi and water. Underrated cyclist refuge.'));

insert reviews;

System.debug('=== SAMPLE DATA LOADED ===');
System.debug('Amenities: ' + amenities.size());
System.debug('Venues: ' + venues.size());
System.debug('Junctions: ' + junctions.size());
System.debug('Reviews: ' + reviews.size());
