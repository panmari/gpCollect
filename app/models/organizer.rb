# frozen_string_literal: true
class Organizer < ActiveRecord::Base
  has_many :run_days
end
