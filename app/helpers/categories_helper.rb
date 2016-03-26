module CategoriesHelper

  def category_button_group(categories)
    content_tag :div, class: 'btn-group btn-group-justified', role: 'group' do
      categories.map {|c| link_to(c.name, c, class: 'btn btn-default')}.join('').html_safe
    end
  end
end
