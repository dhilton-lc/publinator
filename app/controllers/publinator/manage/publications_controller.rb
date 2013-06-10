require_dependency "publinator/application_controller"

module Publinator
  class Manage::PublicationsController < Publinator::ManageController
    layout "publinator/manage"

    before_filter :get_publications
    before_filter :get_publication, :only => [:show, :edit, :update, :destroy, :sort, :add_asset_files]
    respond_to :html, :js

    def sort
      if params[:publication].has_key?( :parent_id )
        @publication.parent_id = params[:publication].delete(:parent_id)
      end
      @publication.update_attributes( params[:publication] )
      @publication.save
      respond_to do |format|
        format.js { render :layout => false }
      end
    end

    def index
      begin
        render "manage/publications/index"
      rescue ActionView::MissingTemplate
        render "publinator/manage/publications/index"
      end
    end

    def sitemap
      @home = Page.find( :first, :conditions => { :title => "Home" } ).publication # FIXME
      @roots = Publinator::Publication.roots

      @pt_roots = Publinator::Publication.find(:all, :conditions => {:publishable_type => 'Publinator::PublishableType'})

      begin
        render "manage/publications/sitemap"
      rescue ActionView::MissingTemplate
        render "publinator/manage/publications/sitemap"
      end
    end

    def add_asset_files
      begin
        render "manage/publications/edit"
      rescue ActionView::MissingTemplate
        render "publinator/manage/publications/edit"
      end
    end

    def show
      begin
        render "manage/publications/show"
      rescue ActionView::MissingTemplate
        render "publinator/manage/publications/show"
      end
    end

    # FIXME new?

    # FIXME preview?

    # FIXME edit?

    # FIXME create?

    # FIXME update?

    # FIXME destroy?

    private

      def get_publications
        @publications = Publinator::Publication.unscoped.where(:site_id => current_site.id).rank(:row_order) #order("updated_at desc")
      end

      def get_publication
        @publication = @publications.find(params[:id])
      end
  end
end
