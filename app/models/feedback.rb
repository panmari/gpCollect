class Feedback < ActiveRecord::Base
  validates_presence_of :email, :text
end
