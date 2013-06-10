require_dependency "publinator/application_controller"

module Publinator
  class Manage::AssetFilesController < Publinator::ManageController
    layout "publinator/manage"

    crudify "Publinator::AssetFile", :singular_name => "asset_file", :plural_name => "asset_files", :class_name => "Publinator::AssetFile"

    def index
      search_all_asset_files
      paginate_all_asset_files
      respond_to do |format|
        format.js {
          find_all_asset_files
          render :layout => false
        }
        format.html
      end
    end

  end
end
