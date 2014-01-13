# Generates the markup expected by Foundation.
class FoundationFormBuilder < ActionView::Helpers::FormBuilder
  # Generates wrappers for most field helpers.
  (field_helpers - [:label, :check_box, :radio_button, :fields_for,
                    :hidden_field]).each do |selector|
    class_eval <<-RUBY_EVAL, __FILE__, __LINE__ + 1
      def #{selector}(attr, options = {})
        generic_field attr, options do |super_options|
          super attr, super_options
        end
      end
    RUBY_EVAL
  end

  # @private
  # check_box is special-cased because of its arguments.
  def check_box(attr, options = {}, checked_value = "1", unchecked_value = "0")
    generic_field attr, options do
      super
    end
  end

  # @private
  # radio_button is special-cased because of its arguments.
  def radio_button(attr, tag_value, options = {})
    generic_field attr, options do
      super
    end
  end

  # NOTE: hidden_field is not overridden.
  #       Hidden fields don't need extra strucutre.

  # NOTE: label isn't overridden, and is called to render the <label> element.
  #       Labels are rendered using label_wrapper.

  # Wraps a field in Foundation syntax.
  #
  # @param [String] attr the name of the attribute that the field is for
  # @param [Hash] options the options passed to the field helper
  # @option option [Hash, String] label passed to {#label_and_field}, which
  #   in turn passes most options to {ActionView::Helpers::FormBuilder#label};
  #   if a String is given, it is passed as the label's text; no <label> will
  #   be rendered if this option is explicitly set to false
  # @yield [options] Calls the block to render the field's <input> tag.
  # @yieldreturn [ActiveSupport::SafeBuffer] sanitized HTML markup for the
  #   field's <input> or <textarea> element
  def generic_field(attr, options = {})
    output = ''.html_safe
    output << '<div class="row">'.html_safe

    errors_html = errors_html_for attr

    if options[:label] != false
      label_options = options.delete(:label) || {}
      if label_options.is_a? String
        label_text = label_options
        label_options = {}
      else
        label_text = label_options.delete(:text)
      end
      field_html = yield options
      label_html = label_and_field field_html, errors_html, attr, label_text,
                                   label_options
      output << label_html
    else
      field_html = yield options
      output << field_html
      output << errors_html unless errors_html == nil
    end

    output << '</div>'.html_safe
    output
  end

  # HTML for an element that contains an attribute's validation errors.
  #
  # @private
  # Subclasses might want to override this.
  #
  # @param [String] attr the name of an attribute
  # @return [ActiveSupport::SafeBuffer] sanitized HTML markup for an element
  #   that renders the given attribute's validation errors; nil if the element
  #   has no errors
  def errors_html_for(attr)
    return nil unless object.respond_to?(:errors)
    return nil if object.errors[attr].empty?

    output = '<small class="error">'.html_safe
    output << object.errors.full_messages_for(attr).join(',')
    output << '</small>'.html_safe
    output
  end
  private :errors_html_for

  # HTML for a field's label and input element.
  #
  # @private
  # Subclasses can override this.
  #
  # @param [ActiveSupport::SafeBuffer] field_html sanitized HTML markup for the
  #   field's <input> or <textarea> element
  # @param [ActiveSupport::SafeBuffer] errors_html sanitized HTML markup for
  #   an element that contains the field's validation errors; nil if the field
  #   has no validation errors
  # @param [String] attr the name of the attribute
  # @param [String] label_text the text to be rendered inside the field's
  #   <label> element
  # @param [Hash] label_options the label option passed to the field helper
  # @return [ActiveSupport::SafeBuffer] sanitized HTML markup for the field's
  #   label and input elements
  def label_and_field(field_html, errors_html, attr, label_text, label_options)
    output = ''.html_safe
    output << label(attr, label_text, label_options)
    output << field_html
    output << errors_html if errors_html
    output
  end
end

# Foundation forms with fontawesome labels.
class FoundationFormBuilder::Icons < FoundationFormBuilder
  def label_and_field(field_html, errors_html, attr, label_text, label_options)
    output = '<div class="small-1 columns">'.html_safe
    label_options[:class] ||= ''
    label_options[:class] += ' inline right'
    if label_options[:icon]
      label_options[:title] ||= label_text
      label_text = label_options.delete(:icon)
    end
    label_options['data-tooltip'] ||= ''
    output << label(attr, label_text, label_options)
    if errors_html == nil
      output << '</div><div class="small-11 columns">'.html_safe
    else
      output << '</div><div class="small-11 columns error">'.html_safe
    end
    output << field_html
    output << errors_html if errors_html
    output << '</div>'.html_safe
    output
  end
end

