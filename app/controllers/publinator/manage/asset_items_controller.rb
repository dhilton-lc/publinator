require_dependency "publinator/application_controller"

module Publinator
  class Manage::AssetItemsController < Publinator::ManageController
    layout "publinator/manage"
    def new
    end

    def create
    end

    def update
    end

    def edit
    end

    def destroy
      @item = Publinator::AssetItem.find(params[:id])
      @item.destroy
      respond_to do |format|
        format.html { redirect_to manage_asset_items_url, :notice => "Asset deleted." }
        format.json { head :no_content }
      end
    end

    def index
      @asset_items = Publinator::AssetItem.all
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @asset_items }
      end
    end

    def show
    end
  end
end
