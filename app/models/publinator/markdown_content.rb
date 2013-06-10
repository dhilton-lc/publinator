module Publinator
  class MarkdownContent < ActiveRecord::Base
    include Publinator::ApplicationHelper

    attr_accessible :body

    has_many :content_blocks, :as => :content

    def render
      m self.body
    end

  end
end
