# Monkey patch address class
module Faker
  class Address

    def self.nationality
      %w[SUI NED USA AFG ALB AND].sample
    end
  end

  class Name
    def self.sex
      %w(M W).sample
    end
  end
end

FactoryBot.define do
  factory :category do
    sex 'M'
    age_min 30
  end

  factory :organizer do
    name { Faker::Lorem.words(3) }
  end

  factory :route do
    length { Faker::Number.between(1, 42) }
  end

  factory :feedback do
    email { Faker::Internet.email }
    text { Faker::Lorem.words(300) }
    ip { Faker::Internet.ip_v4_address }
  end

  factory :run_day do
    organizer
    route
    date { 1.year.ago }
  end

  factory :run_day_category_aggregate do
    category
    run_day
    mean_duration { Faker::Number.between(4618000, 5366200) }
    min_duration { Faker::Number.between(2618000, 4366200) }
    runs_count { Faker::Number.between(100, 200) }
  end

  factory :run do
    duration { Faker::Number.between(4618000, 5366200) }
    interim_times { [Faker::Number.between(1618000, 2366200), Faker::Number.between(2618000, 3366200)] }
    category
    run_day
    runner
    run_day_category_aggregate
  end

  factory :runner do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    club_or_hometown { Faker::Address.city }
    birth_date { Faker::Date.between(50.years.ago, 20.years.ago) }
    nationality { Faker::Address.nationality }
    sex { Faker::Name.sex }

    factory :runner_with_runs do
      transient do
        runs_count 3
      end

      # the after(:create) yields two values; the user instance itself and the
      # evaluator, which stores all values from the factory, including transient
      # attributes; `create_list`'s second argument is the number of records
      # to create and we make sure the user is associated properly to the post
      after(:create) do |runner, evaluator|
        create_list(:run, evaluator.runs_count, runner: runner)
      end
    end
  end

  factory :admin do
    email 'test@tester.com'
    password 'test1234'
  end
end
