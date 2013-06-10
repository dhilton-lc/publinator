require_dependency "publinator/application_controller"

module Publinator
  class Manage::PagesController < Publinator::ManageController
    layout "publinator/manage"

    before_filter :get_pages
    before_filter :get_page, :only => [:show, :edit, :update, :destroy, :sort, :add_asset_files]

    def sort
      if params[:page].has_key?( :parent_id )
        @page.parent_id = params[:page].delete(:parent_id)
      end
      @page.update_attributes( params[:page] )
      @page.save
      render :nothing => true # FIXME Re-render 'subtree' since path depends on parent

      #@pages.each do |page|
      #  page.position = params['page'].index(page.id.to_s) + 1
      #  page.save
      #end
      #render :nothing => true
    end

    def index
      begin
        render "manage/pages/index"
      rescue ActionView::MissingTemplate
        render "publinator/manage/pages/index"
      end
    end

    def sitemap
      @home = Page.find( :first, :conditions => { :title => "Home" } )
      @roots = Page.roots
      begin
        render "manage/pages/sitemap"
      rescue ActionView::MissingTemplate
        render "publinator/manage/pages/sitemap"
      end
    end

    def add_asset_files
      begin
        render "manage/pages/edit"
      rescue ActionView::MissingTemplate
        render "publinator/manage/pages/edit"
      end
    end

    def show
      begin
        render "manage/pages/show"
      rescue ActionView::MissingTemplate
        render "publinator/manage/pages/show"
      end
    end

    def new
      @home = Page.find( :first, :conditions => { :title => "Home" } )
      @page = Publinator::Page.send(:new, {
        :publication => Publinator::Publication.new(
          :publish_at       => 1.day.from_now.beginning_of_day + 8.hours,
          :archive_at       => 31.days.from_now.beginning_of_day,
          :site             => current_site,
          :publishable_type => "Publinator::Page",
          :ancestry => @home.publication.id.to_s,
          :row_order_position => :last
        ),
        :ancestry => @home.id.to_s,
        :row_order_position => :last,
        :site_id => 3 # FIXME
      })
      @page.asset_items.build
      @field_names = @page.editable_fields.collect{ |an| an.to_sym }
      begin
        render "manage/pages/new"
      rescue ActionView::MissingTemplate
        render "publinator/manage/pages/new"
      end
    end

    def preview
      render :text => RDiscount.new(params[:preview_text]).to_html.html_safe, :layout => false
    end

    def edit
      session[:return_to] ||= request.referer
      @field_names = @page.editable_fields.collect{ |an| an.to_sym }
      @page.asset_items.build
      begin
        render "manage/pages/edit"
      rescue ActionView::MissingTemplate
        render "publinator/manage/pages/edit"
      end
    end

    def create
      @home = Page.find( :first, :conditions => { :title => "Home" } )
      @page = Publinator::Page.new(params[:page])
      @page.publication.site = current_site
      @page.ancestry = @home.id.to_s
      @page.publication.ancestry = @home.publication.id.to_s
      @page.row_order = RankedModel::MAX_RANK_VALUE
      @page.publication.row_order = RankedModel::MAX_RANK_VALUE

      if @page.save
        redirect_to "/manage/publications/sitemap", :notice => "Page created."
      else
        begin
          render "manage/pages/new", :notice => "Page could not be created."
        rescue ActionView::MissingTemplate
          render "publinator/manage/pages/new", :notice => "Page could not be created."
        end
      end
    end

    def update
      @page.update_attributes(params[:page])
      @page.publication.site = current_site
      if @page.save!
        # redirect_to( session.delete(:return_to) || "/manage/publications/sitemap", :notice => "Page updated." )
        redirect_to( edit_manage_page_path(@page), :notice => "Page updated." )
      else
        begin
          render "manage/page/edit", :notice => "Page could not be updated."
        rescue ActionView::MissingTemplate
          render "publinator/manage/pages/edit", :notice => "Page could not be updated."
        end
      end
    end

    def destroy
      @page.destroy
      respond_to do |format|
        format.html { redirect_to "/manage/publications/sitemap", :notice => "Page deleted." }
        format.json { head :no_content }
      end
    end

    private

      def get_pages
        @pages = Publinator::Page.unscoped.where(:site_id => current_site.id).rank(:row_order) #order("updated_at desc")
      end

      def get_page
        @page = @pages.find(params[:id])
      end
  end
end
