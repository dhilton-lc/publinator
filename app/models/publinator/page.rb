module Publinator
  class Page < ActiveRecord::Base
    self.table_name = 'publinator_pages'
    acts_as_publishable
    attr_accessible :body, :kicker, :subtitle, :teaser, :title, :section, :asset_items

    def asset_types
      ['header']
    end
  end
end