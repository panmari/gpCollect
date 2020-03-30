# frozen_string_literal: true

# Monkey patch address class
module Faker
  class Address
    def self.nationality
      %w[SUI NED USA AFG ALB AND].sample
    end
  end

  class Name
    def self.sex
      %w[M W].sample
    end
  end
end

FactoryBot.define do
  factory :category do
    sex { %w[M W].sample }
    age_min { [20, 30, 40, 50, 60, 70].sample }

    factory :category_MU20 do
      sex { 'M' }
      age_min { nil }
      age_max { 20 }
    end

    factory :category_M20 do
      sex { 'M' }
      age_min { 20 }
    end

    factory :category_W20 do
      sex { 'W' }
      age_min { 20 }
    end

    factory :category_M30 do
      sex { 'M' }
      age_min { 30 }
    end
  end

  factory :organizer do
    name { Faker::Lorem.words(number: 3) }
  end

  factory :route do
    length { Faker::Number.between(from: 1, to: 42) }
  end

  factory :feedback do
    email { Faker::Internet.email }
    text { Faker::Lorem.words(number: 300) }
    ip { Faker::Internet.ip_v4_address }
  end

  factory :run_day do
    organizer
    route
    date { Faker::Date.between(from: 18.years.ago, to: Date.today) }

    factory :run_day_1y_ago do
      date { 1.year.ago }
    end
  end

  factory :run_day_category_aggregate do
    category
    run_day
    mean_duration { Faker::Number.between(from: 4_618_000, to: 5_366_200) }
    min_duration { Faker::Number.between(from: 2_618_000, to: 4_366_200) }
    runs_count { Faker::Number.between(from: 100, to: 200) }
  end

  factory :run do
    duration { Faker::Number.between(from: 4_618_000, to: 5_366_200) }
    interim_times do
      [Faker::Number.between(from: 1_618_000, to: 2_366_200),
       Faker::Number.between(from: 2_618_000, to: 3_366_200)]
    end
    category
    run_day
    runner
    run_day_category_aggregate
  end

  factory :geocode_result do
    address { Faker::Address.city }
  end

  factory :runner do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    club_or_hometown { Faker::Address.city }
    birth_date { Faker::Date.between(from: 50.years.ago, to: 20.years.ago) }
    nationality { Faker::Address.nationality }
    sex { Faker::Name.sex }

    factory :runner_with_runs do
      transient do
        runs_count { 3 }
      end

      # the after(:create) yields two values; the user instance itself and the
      # evaluator, which stores all values from the factory, including transient
      # attributes; `create_list`'s second argument is the number of records
      # to create and we make sure the user is associated properly to the post
      after(:create) do |runner, evaluator|
        create_list(:run, evaluator.runs_count, runner: runner)
      end
    end
    geocode_result

    factory :hans do
      first_name { 'Hans' }
      last_name { 'Muster' }
      club_or_hometown { 'Bern' }
      birth_date { 50.years.ago }
      nationality { 'SUI' }
      sex { 'M' }
    end
  end

  factory :admin do
    email { 'test@tester.com' }
    password { 'test1234' }
  end
end
