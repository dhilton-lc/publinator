require_dependency "publinator/application_controller"

module Publinator
  class PublishableController < Publinator::ApplicationController

    #before_filter :find_page, :only => [ :page ]
    before_filter :find_publication, :only => [ :page ]

    def home
      begin
        render "home/index"
      rescue ActionView::MissingTemplate
        render "publinator/home/index", :layout => current_layout
      end
    end

    def index
      @publication = Publinator::Publication.find_by_publishable_type_and_slug(params[:publishable_type].classify, 'index')
      @publishable_type = Publinator::PublishableType.find_by_name(params[:publishable_type].classify)
      if @publication
        @publishable = @publication.publishable
        begin
          render "#{params[:publishable_type]}/show"
        rescue ActionView::MissingTemplate
          render "publinator/publishable/show"
        end
      else
        @publishables = params[:publishable_type].classify.constantize.all
        begin
          render "#{params[:publishable_type]}/index"
        rescue ActionView::MissingTemplate
          render "publinator/publishable/index"
        end
      end
    end

    def page
      if @publishable
        begin
          render "#{@publishable.pub_path}"
        rescue ActionView::MissingTemplate
          render "publinator/publishable/show"
        end

      else
        raise ActionController::RoutingError.new('Not Found')
      end
    end

    def show
      @publication = Publinator::Publication.find_by_publishable_type_and_slug(params[:publishable_type].classify, params[:id])
      @publishable = @publication.publishable
      @publishable_type = Publinator::PublishableType.find_by_name(params[:publishable_type].classify)
      begin
        render "#{params[:publishable_type]}/show"
      rescue ActionView::MissingTemplate
        render "publinator/publishable/show"
      end
    end

    protected

    def find_publication
      @publication = Publinator::Publication.decompose_slug( params[:slug] )
      if @publication
        @publishable = @publication.publishable
        if ( @publication.render_collection )
          @publishables = @publication.collection
        end
        if @publication.publishable_type == 'Publinator::Page'
          @page = @publishable
        end
        if @publication.require_user
          authenticate_user!
        end
      end
    end

    def find_page
      @page = Publinator::Page.decompose_slug( params[:slug] )
      if @page
        @publishable = @page
        @publication = @page.publication
        if @publication.require_user
          authenticate_user!
        end
      end
    end

  end
end
