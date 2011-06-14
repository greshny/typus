module Admin
  module DataTypes
    module TransversalHelper

      def table_transversal_field(attribute, item)
        field_1, field_2 = attribute.split(".")
        (related_item = item.send(field_1)) ? related_item.send(field_2) : "&mdash;".html_safe
      end

    end
  end
end