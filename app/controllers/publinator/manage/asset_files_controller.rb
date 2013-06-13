require_dependency "publinator/application_controller"

module Publinator
  class Manage::AssetFilesController < Publinator::ManageController
    layout "publinator/manage"

    respond_to :js, :html

    crudify "Publinator::AssetFile", :singular_name => "asset_file", :plural_name => "asset_files", :class_name => "Publinator::AssetFile", :redirect_to_url => 'manage_asset_files_url'

    def index
      search_all_asset_files
      paginate_all_asset_files
      respond_to do |format|
        format.js do
          find_all_asset_files
          render :layout => false
        end
        format.html
      end
    end

    def edit
      session[:return_to] ||= request.referer

      respond_to do |format|
        format.js { render :layout => false }
      end
    end

    def new
      @asset_file = Publinator::AssetFile.new
      session[:return_to] ||= request.referer

      respond_to do |format|
        format.js { render :layout => false }
      end
    end

    def after_success
      if ( params[:action] == 'update' || params[:action] == 'create' ) && request.xhr?
        flash.now[:notice] = flash[:notice]
        flash.discard(:notice)
        respond_to do |format|
          format.js { render :layout => false }
        end
      else
        super
      end
    end
    def after_fail
      if ( params[:action] == 'update' || params[:action] == 'create' ) && request.xhr?
        flash.now[:error] = [flash[:error], @instance.errors.collect{|key,value| "#{key} #{value}"}.join("<br/>")]
        flash.discard(:error)
        respond_to do |format|
          format.js { render :partial => "#{params[:action]}_error", :layout => false }
        end
      else
        super
      end
    end

    def redirect_back_or_default( default )
      redirect_to( session[:return_to] || manage_asset_files_url )
      session[:return_to] = nil
    end
  end
end
