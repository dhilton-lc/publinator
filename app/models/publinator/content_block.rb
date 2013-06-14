module Publinator
  class ContentBlock < ActiveRecord::Base
    include RankedModel

    attr_accessible :layout_order, :layout_order_position,
      :publication, :publication_id,
      :content_id, :content_type, :content_attributes,
      :area

    belongs_to :content, :polymorphic => true, :autosave => true
    belongs_to :publication

    accepts_nested_attributes_for :content

    ranks :layout_order, :with_same => [ :publication_id, :area ]

    default_scope order('layout_order')

    def attributes=(attributes = {})
      # FIXME Validate content type
      self.content_type = attributes[:content_type]
      super
    end

    def content_attributes=(attributes)
      # FIXME Validate content type
      my_content = self.content_type.constantize.find_or_initialize_by_id(self.content_id)
      my_content.attributes = attributes
      self.content = my_content
    end

    def build_content(params)
      self.content = self.content_type.constantize.new(params)
    end

    def render
      if self.content.present?
        self.content.render
      else
        ""
      end
    end

  end
end
