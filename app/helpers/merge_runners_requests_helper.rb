module MergeRunnersRequestsHelper
  MERGE_CANDIDATES_SHOWN_ATTRIBUTES = %i[first_name last_name club_or_hometown sex nationality].freeze

  def merge_candidates_table(merge_candidates)
    content_tag(:table, class: 'table table-hover') do
      concat(content_tag(:tr) do
        concat(content_tag(:th, 'ID'))
        concat(safe_join(merge_candidates.map { |mc| content_tag(:td, link_to(mc.id, mc)) }))
      end)
      concat(safe_join(MERGE_CANDIDATES_SHOWN_ATTRIBUTES.map do |attr|
        content_tag(:tr) do
          concat(content_tag(:th, Runner.human_attribute_name(attr).html_safe))
          concat(safe_join(merge_candidates.map { |mc| content_tag(:td, mc[attr]) }))
        end
      end))
    end
  end
end
