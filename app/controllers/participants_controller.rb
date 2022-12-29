# frozen_string_literal: true

class ParticipantsController < ApplicationController
  def index
    @chart = ParticipantsOverallChart.new
    @participants_by_age_chart = ParticipantsByAgeChart.new
  end
end
