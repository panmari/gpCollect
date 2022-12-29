# frozen_string_literal: true

module CategoriesHelper
  def category_button_group(categories, active_category,
                            button_class = 'btn-default')
    content_tag :div, class: 'row' do
      split_index = categories.size / 2
      [categories[0...split_index], categories[split_index..-1]].map do |category_slice|
        content_tag :div, class: 'col-sm-6' do
          content_tag :div, class: 'btn-group d-flex', role: 'group' do
            basic_css_class = 'btn w-100 ' + button_class
            category_slice.map do |c|
              css_class = if c == active_category
                            basic_css_class + ' active'
                          else
                            basic_css_class
                          end
              link_to(c.name, c, class: css_class)
            end.join.html_safe
          end
        end
      end.join.html_safe
    end
  end
end
