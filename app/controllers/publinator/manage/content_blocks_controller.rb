require_dependency "publinator/application_controller"

module Publinator
  class Manage::ContentBlocksController < Publinator::ManageController
    layout "publinator/manage"

    before_filter :find_page
    before_filter :find_or_build_content_block

    def index
    end

    def new # Actually not sure I need the 'new' route
      raise "I don't need no new!" # FIXME
    end

    def edit
      respond_to do |format|
        format.js do
          begin
            render :text => render_to_string(:partial => 'manage/content_blocks/edit', :locals => {:content_block => @content_block})
          rescue ActionView::MissingTemplate
            render :text => render_to_string(:partial => 'publinator/manage/content_blocks/edit', :locals => {:content_block => @content_block})
          end
        end
      end
    end

    def create
      respond_to do |format|
        unless @content_block.save
          flash[:error] = 'Content block could not be created'
        end
        if @content_block.content_type.present?
          @content_block.build_content( {} )
        end
        format.js do
          begin
            render :text => render_to_string(:partial => 'manage/content_blocks/edit', :locals => {:content_block => @content_block})
          rescue ActionView::MissingTemplate
            render :text => render_to_string(:partial => 'publinator/manage/content_blocks/edit', :locals => {:content_block => @content_block})
          end
        end
      end
    end

    def update
      respond_to do |format|
        @content_block.update_attributes(params[:content_block])
        unless @content_block.save
          flash[:error] = 'Content block could not be updated.'
        end
        format.js do
          begin
            render :text => render_to_string(:partial => 'manage/content_blocks/preview', :locals => {:content_block => @content_block})
          rescue ActionView::MissingTemplate
            render :text => render_to_string(:partial => 'publinator/manage/content_blocks/preview', :locals => {:content_block => @content_block})
          end
        end
      end
    end

    def destroy
      respond_to do |format|
        @id = @content_block.id
        if ( @content_block.content.present? )
          @content_block.content.destroy
        end
        @content_block.destroy
        format.js do
          begin
            render :text => render_to_string(:partial => 'manage/content_blocks/destroy', :locals => {:id => @id})
          rescue ActionView::MissingTemplate
            render :text => render_to_string(:partial => 'publinator/manage/content_blocks/destroy', :locals => {:id => @id})
          end
        end
      end
    end

    def sort
      @content_block.update_attributes( params[:content_block] )
      @content_block.save
      render :nothing => true
    end

    private

    def find_page
      @page = Page.find(params[:page_id])
      raise ActiveRecord::RecordNotFound unless @page
    end

    def find_or_build_content_block
      blocks = @page.publication.content_blocks
      @content_block = params[:id] ? blocks.find(params[:id]) : blocks.build(params[:content_block])
    end

  end
end
