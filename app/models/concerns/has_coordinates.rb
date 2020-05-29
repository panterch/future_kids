module HasCoordinates
  extend ActiveSupport::Concern

  included do
    after_validation :geocode, if: :full_address_changed?
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
