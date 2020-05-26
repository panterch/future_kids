# set default units to kilometers:
Geocoder.configure(:units => :km)

# Setup testing
if Rails.env.test?
  Geocoder.configure(lookup: :test)
  
  # Panter stub
  Geocoder::Lookup::Test.add_stub(
    "Street 1 City", [
      {
        'latitude'     => 1.111,
        'longitude'    => 1.234,
        'address'      => 'Street 1, City',
        'country'      => 'Switzerland',
        'country_code' => 'CH'
      }
    ]
  )

  Geocoder::Lookup::Test.add_stub(
    "City", [
      {
        'latitude'     => 4.321,
        'longitude'    => 1.234,
        'address'      => 'City',
        'country'      => 'Switzerland',
        'country_code' => 'CH'
      }
    ]
  )

  # Default stub
  # Empty array to mimic not found address
  Geocoder::Lookup::Test.set_default_stub(
    []
  )
end