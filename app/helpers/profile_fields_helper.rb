module ProfileFieldsHelper

  def profile_field_span_tag( profile_field )
    editable_span_tag css_class: "profile_field show", object: profile_field, controller: "profile_fields", id: profile_field.id do
      profile_field_span_tag_inner_html profile_field
    end
  end

  def profile_field_span_tag_inner_html( profile_field )
    value = profile_field.value
    if value
      value = value.gsub( /\n/, '<br />' )
      if profile_field.type == "Address"
        value = value.gsub( ', ', '<br />' )
        value += "<br />(" + link_to( profile_field.bv.name, profile_field.bv.becomes( Group ) ) + ")"
      end
    end

    [ content_tag( :dt, profile_field.label ),
      content_tag( :dd ) do
        if value
          value.html_safe
        elsif profile_field.children.count > 0
          content_tag :dl do
            profile_field.children.collect do |child_field|
              content_tag :span do
                profile_field_span_tag_inner_html child_field
              end
            end.join.html_safe
          end
        end
      end
    ].join.html_safe
  end

end
