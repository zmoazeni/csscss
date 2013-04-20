require "sass"

module Csscss
  class SassMixinVisitor < Sass::Tree::Visitors::Base
    def self.visit(root)
      new.send(:visit, root)
    end

    def visit_mixindef(node)
      begin_comment = Sass::Tree::CommentNode.new(["/* CSSCSS START MIXIN: #{node.name} */"], :normal)
      end_comment = Sass::Tree::CommentNode.new(["/* CSSCSS END MIXIN: #{node.name} */"], :normal)

      begin_comment.options = end_comment.options = {}

      node.children.unshift(begin_comment)
      node.children.push(end_comment)
    end
  end
end
