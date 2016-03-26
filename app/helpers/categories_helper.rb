module CategoriesHelper

  def category_button_group(categories, button_class='btn-default')
    content_tag :div, class: 'row' do
      split_index = categories.size / 2
      [categories[0...split_index], categories[split_index..-1]].map do |category_slice|
        content_tag :div, class: 'col-sm-6' do
          content_tag :div, class: 'btn-group btn-group-justified', role: 'group' do
            category_slice.map { |c| link_to(c.name, c, class: 'btn ' + button_class) }.join.html_safe
          end
        end
      end.join.html_safe
    end
  end
end
