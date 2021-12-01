# frozen_string_literal: true

module ApplicationHelper
  # Override kaminari paginate method to always use bootstrap theme.
  def paginate(objects, options = {})
    options.reverse_merge!(theme: 'twitter-bootstrap-4')
    super(objects)
  end

  # Creates a horizontal, twitter bootstrap styled simple form.
  # TODO: allow specifying additional wrapper mappings/class settings.
  def horizontal_simple_form_for(record, options = {}, &block)
    options.merge!(html: { class: 'form-horizontal' },
                   wrapper: :horizontal_form,
                   wrapper_mappings: {
                     check_boxes: :horizontal_radio_and_checkboxes,
                     radio_buttons: :horizontal_radio_and_checkboxes,
                     file: :horizontal_file_input,
                     boolean: :horizontal_boolean
                   })
    simple_form_for(record, options, &block)
  end

  def nav_item(label, link, link_options = {})
    link_options[:class] = 'nav-link'
    nav_classes = 'nav-item ' + (current_page?(link) ? 'active' : '')
    content_tag(:li, link_to(label, link, link_options), class: nav_classes)
  end

  def bootstrap_class_for_flash(flash_type)
    case flash_type
    when 'success'
      'alert-success'
    when 'error'
      'alert-danger'
    when 'alert'
      'alert-warning'
    when 'notice'
      'alert-info'
    else
      flash_type.to_s
    end
  end

  def flash_messages
    safe_join(flash.map do |flash_type, msg|
      classes = 'alert alert-dismissable fade show ' + bootstrap_class_for_flash(flash_type)
      content_tag(:div, class: classes) do
        concat msg
        concat content_tag(:button, '&times;'.html_safe, 'data-dismiss': 'alert', class: 'close')
      end
    end)
  end
end
