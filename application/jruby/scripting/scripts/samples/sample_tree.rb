module Scripting
  module Scripts
    module Samples

#      module Sr07476

        require 'java'
#        require 'rubygems'
#        require ENV['AppRoot'].to_s + '/' + 'jdbcmssql-gems'
#        require 'active_support' # Used here for 'ActiveSupport::JSON.encode(...)'
#        require 'overview_tree'

        JTree = Java::javax.swing.JTree unless defined?(JTree)
        DefaultTreeModel = Java::javax.swing.tree.DefaultTreeModel unless defined?(DefaultTreeModel)
        DefaultMutableTreeNode = Java::javax.swing.tree.DefaultMutableTreeNode unless defined?(DefaultMutableTreeNode)

        # SampleTree = Scripting::Scripts::Samples::SampleTree unless defined?(SampleTree)
        class SampleTree < DefaultTreeModel # JTree # DefaultTreeModel
          def initialize # (root)
            # super(root)
#            super(DefaultMutableTreeNode.new("SampleTree"))
#            @jtree_root = DefaultMutableTreeNode.new("SampleTree")
#            self.setRoot(@jtree_root)

          end


        end

#      end # module Sr07476
    end # module Samples
  end # module Db
end # module Scripting
