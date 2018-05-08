module ApplicationHelper
  # Override kaminari paginate method to always use bootstrap theme.
  def paginate(objects, options = {})
    options.reverse_merge!(theme: 'twitter-bootstrap-4')
    super(objects, options)
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

  def flash_messages
    flash.map do |style, msg|
      context = 'danger' if style.to_sym == :error
      context = 'info' if style.to_sym == :notice
      alert_box(msg, context: context, dismissible: true)
    end.join.html_safe
  end
end
