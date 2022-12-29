# frozen_string_literal: true
module MergeRunnersRequestsHelper
  MERGE_CANDIDATES_SHOWN_ATTRIBUTES = %i[first_name last_name club_or_hometown sex nationality].freeze

  def merged_attributes_table(object, with_merged = true)
    content_tag(:table, class: 'table table-hover') do
      concat(content_tag(:tr) do
        concat(content_tag(:th, 'ID'))
        concat(safe_join(object.runners.map { |r| content_tag(:td, link_to(r.id, r)) }))
        concat(content_tag(:th, 'Merged')) if with_merged
      end)
      concat(safe_join(MERGE_CANDIDATES_SHOWN_ATTRIBUTES.map do |attr|
        content_tag(:tr) do
          concat(content_tag(:th, Runner.human_attribute_name(attr).html_safe))
          concat(safe_join(object.runners.map { |r| content_tag(:td, r[attr]) }))
          concat(content_tag(:td, content_tag(:strong, object["merged_#{attr}"]))) if with_merged
        end
      end))
    end
  end
end
