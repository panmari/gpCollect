# frozen_string_literal: true

class Feedback < ActiveRecord::Base
  validates_presence_of :email, :text
end
