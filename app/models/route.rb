# frozen_string_literal: true

class Route < ActiveRecord::Base
  has_many :run_days
end
