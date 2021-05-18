module HasCoordinates
  extend ActiveSupport::Concern
  extend Geocoder::Model::ActiveRecord

  included do
    after_validation :geocode, if: :full_address_changed?

    acts_as_mappable default_units: :kms,
      default_formula: :sphere,
      distance_field_name: :distance,
      lat_column_name: :latitude,
      lng_column_name: :longitude
  end

  def full_address
    full_address = [address, city].reject(&:blank?)
    return if full_address.none?

    full_address.join(' ')
  end

  def full_address_changed?
    address_changed? || city_changed?
  end

  def geocode
    results = Geocoder.search(full_address)
    if results.empty?
      self.latitude = nil
      self.longitude = nil
    else
      self.latitude = results.first.latitude
      self.longitude = results.first.longitude
    end
  end
end
