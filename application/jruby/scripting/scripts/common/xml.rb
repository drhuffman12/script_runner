module Scripting
  module Scripts
    module Common

#      Class needs:
          require 'rexml/document'

      module Xml # Scripting::Scripts::Common::Xml

        include REXML

        # Convenience method for getting all matching elements:
        def get_tags(doc,xpath_root,tag_name)
          tags = []
          doc.elements.each(xpath_root) do |element|
            tags = XPath.match( element, tag_name )
          end
          tags
        end

        # Convenience method for getting text from all matching elements:
        def get_tag_texts(doc,xpath_root,tag_name)
          tag_text = []
          tags = get_tags(doc,xpath_root,tag_name)
          tags.each do |tag|
#                tag_text << {:index => tag.index_in_parent, :innerHTML => tag.text}
            tag_text << {:index => tag.index_in_parent, :text => tag.text}
          end
          tag_text
        end
      end # module Exportable
    end # module Maximo
  end # module Scripts
end # module Scripting