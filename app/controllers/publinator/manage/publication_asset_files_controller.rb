require_dependency "publinator/application_controller"

module Publinator
  class Manage::PublicationAssetFilesController < ApplicationController
    layout "publinator/manage"

    before_filter :get_publication_asset_file

    def sort
      render :nothing => true
    end

    def destroy
      @id = @publication_asset_file.id
      @publication_asset_file.destroy
      respond_to do |format|
        format.html { render :nothing => true }
        format.js { render :layout => false }
      end
    end

  private

    def get_publication_asset_file
      @publication_asset_file = PublicationAssetFile.find( params[:id] )
    end

  end
end
