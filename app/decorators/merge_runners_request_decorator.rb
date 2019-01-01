class MergeRunnersRequestDecorator < Draper::Decorator
  delegate_all
  decorates_association :runners

  def runners_formatted
    object.runners.map { |r| h.link_to r.id, r }.join(', ').html_safe
  end
end
