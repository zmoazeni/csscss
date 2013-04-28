require "sass"

Sass::Tree::MixinDefNode.class_eval do
  def children
    first_child = @children.first

    # not sure why/how we can get here with empty children, but it
    # causes issues
    unless @children.empty? || (first_child.is_a?(Sass::Tree::CommentNode) && first_child.value.first =~ /CSSCSS START/)
      begin_comment = Sass::Tree::CommentNode.new(["/* CSSCSS START MIXIN: #{name} */"], :normal)
      end_comment = Sass::Tree::CommentNode.new(["/* CSSCSS END MIXIN: #{name} */"], :normal)

      begin_comment.options = end_comment.options = {}
      @children.unshift(begin_comment)
      @children.push(end_comment)
    end

    @children
  end
end
