require 'mechanize'
require 'csv'
require_relative 'scrape_helpers'

namespace :db do
  desc "Scrapes data from the public website and writes it to a csv file (2007-2012)"
  task scrape_data: :environment do
    COMPATIBLE_YEARS = (2007..2012)
    COMPATIBLE_YEARS.each do |year|
      agent = Mechanize.new
      url = if year <= 2008
              "http://results.mikatiming.de/#{year}/bern/index.php?page=1&content=search&event=GP&lang=DE&num_results=100&search[name]=&search[firstname]=&search[club]=&search[nation]=&search[start_no]=&search[city]=&search[region]=&search_sort=name&search_sort_order=ASC&split=FINISHNET"
            else
              "http://bern.mikatiming.de/#{year}/?page=1&event=GP&num_results=100&pid=search&search%5Bclub%5D=%25&search%5Bage_class%5D=%25&search%5Bsex%5D=%25&search%5Bnation%5D=%25&search%5Bstate%5D=%25&search_sort=name"
            end
      mech_page = agent.get(url)
      page_number = 1
      # TODO: total is only estimate.
      progressbar = ProgressBar.create(title: "Scraping #{year}", total: 160,
                                       format: '%t %B %R pages/s, %a', :throttle_rate => 0.1)

      CSV.open("db/data/gp_bern_10m_#{year}.csv", 'wb', col_sep: ';') do |csv|
        while mech_page
          html_rows = if page_number == 1
                        # For first page, also parse table header
                        mech_page.search('table tr')
                      else
                        mech_page.search('table tbody tr')
                      end
          rows = html_rows.map { |i| i.css('td').map do |td|
            # Once in a while an attribute is truncated, marked by trailing '...'.
            # The full string can then be parsed by getting the title attribute of the span contained.
            if td.content.include? '...'
              td.css('span')[0][:title]
            else
              td.content
            end.gsub('»', '').gsub(',  ', ', ').strip # Further clean string
          end
          }
          rows.each { |row| csv << row }
          page_number += 1
          progressbar.increment
          next_link = mech_page.link_with(:text => page_number.to_s)
          break unless next_link
          mech_page = next_link.click
        end
      end
      progressbar.finish
    end
  end

  desc "Scrapes data from the public website and writes it to a csv file (1999-2006)."
  task scrape_old_data: :environment do
    require 'open-uri'
    COMPATIBLE_YEARS = (1999..2006)
    STOP_WORDS = ['Total', 'Grand Prix', 'Kategorie', '-------', 'Stand', 'Rangliste']
    COMPATIBLE_YEARS.each do |year|
      progressbar = ProgressBar.create(title: "Scraping #{year}", total: 26,
                                       format: '%t %B %R pages/s, %a', :throttle_rate => 0.1)
      CSV.open("db/data/gp_bern_10m_#{year}.csv", 'wb', col_sep: ';') do |csv|
        # header lined
        csv << 'Platz;Pl.AK;Pl.(M/W);Nr.;Name;AK;Verein/Ort;Rel *;5km;10km;Zielzeit;Jahrgang'.split(';')
        ('A'..'Z').each do |character|
          url = if year == 2000
                  "http://services.datasport.com/#{year}/lauf/gp/Rangliste/ALFA#{character}.HTM"
                else
                  "http://services.datasport.com/#{year}/lauf/gp/Alfa#{character}.htm"
                end
          doc = Nokogiri::HTML(open(url))
          text_block = doc.css('pre').first
          if text_block
            rows = text_block.text.split("\r\n").map { |row| row.split(/[¦ (]{2,}/) }
            options = if year >= 2001
                        {start_number_column: 5}
                      else
                        {}
                      end
            options.merge!(with_interim_times: true) if year >= 2004
            rows.each do |row|
              # skip header, filler rows, disqualified
              next if row.size == 0 or
                  STOP_WORDS.any? {|stop_word| row[0].include?(stop_word) } or
                  %w(DNF DSQ ---).any? { |disq_marker| row[1] == disq_marker }

              begin
                csv_row = ScrapeHelpers::old_html_row_to_csv_row(row, options)
                unless csv_row.nil?
                  csv << csv_row
                end
              rescue Exception => e
                puts "Failed on #{row}"
                raise e
              end
            end
          end
          progressbar.increment
        end
        progressbar.finish
      end
    end
  end

  desc "Try to merge runners that are most probably the same person"
  task merge_runners: :environment do
    require_relative '../../db/merge_runners_helpers'
    MergeRunnersHelpers::merge_duplicates
  end

  desc "Create aggregates to keep some often queried attributes cached."
  task create_run_aggregates: :environment do
    RunDayCategoryAggregate.delete_all
    ActiveRecord::Base.connection.reset_pk_sequence!(RunDayCategoryAggregate.table_name)

    Category.all.each do |category|
      RunDay.all.each do |run_day|
        # Attributes are computed with hooks.
        RunDayCategoryAggregate.create!(category: category, run_day: run_day)
      end
    end
  end
end
