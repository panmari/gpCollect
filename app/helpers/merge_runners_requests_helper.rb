module MergeRunnersRequestsHelper
  MERGE_CANDIDATES_SHOWN_ATTRIBUTES = %i[first_name last_name club_or_hometown sex nationality].freeze

  def merge_candidates_table(merge_candidates)
    content_tag :table, class: 'table table-hover' do
      MERGE_CANDIDATES_SHOWN_ATTRIBUTES.map do |attr|
        content_tag :tr do
          content_tag(:th, Runner.human_attribute_name(attr)) <<
            merge_candidates.each.map { |mc| content_tag :td, mc.send(attr) }.join.html_safe
        end
      end.join.html_safe
    end
  end
end
