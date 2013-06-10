#module Publinator
  class Publinator::PublicationAssetFile < ActiveRecord::Base
    attr_accessible :publication, :asset_file, :position, :publication_id, :asset_file_id
    # TODO: Ranked model?

    belongs_to :publication
    belongs_to :asset_file

    default_scope order('position asc')

  end
#end
