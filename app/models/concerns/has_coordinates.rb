module HasCoordinates
  extend ActiveSupport::Concern

  included do
    geocoded_by :full_address
    after_validation :geocode, if: lambda { |obj|
      (obj.address.present? || obj.city.present?) and obj.full_address_changed?
    }
    after_validation :location_found?
  end

  def full_address
    [address, city].reject(&:blank?).join(' ')
  end

  def full_address_changed?
    :address_changed? || :city_changed?
  end

  # Check if location was found by geocoder.
  # If full address is blank, set coords to nil
  # If full adress has changed, but coords did not, it means geocoder was unable to find new location
  def location_found?
    if (full_address.blank?)
      self.latitude = nil
      self.longitude = nil
      return true
    end
    if (full_address_changed?)
      if !(self.latitude_changed?)
        self.errors.add(:address, "Adresse wurde nicht gefunden")
        return false
      end
    end
  end
end
