# frozen_string_literal: true
class MergeRunnersRequestDecorator < Draper::Decorator
  delegate_all
  decorates_association :runners

  def self.collection_decorator_class
    PaginationDecorator
  end

  def runners_formatted
    object.runners.map { |r| h.link_to r.id, r }.join(', ').html_safe
  end
end
