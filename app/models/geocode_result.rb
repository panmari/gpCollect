class GeocodeResult < ActiveRecord::Base
  has_many :runners
  before_destroy :remove_from_runners

  private

  def remove_from_runners
    runners.update_all(geocode_result_id: nil)
  end
end
