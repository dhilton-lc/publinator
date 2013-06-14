require_dependency "publinator/application_controller"

module Publinator
  class Manage::ContentBlocksController < Publinator::ManageController
    layout "publinator/manage"

    before_filter :find_page
    before_filter :find_or_build_content_block

    def sort
      if params[:content_block].has_key?( :area )
        @content_block.area = params[:content_block].delete(:area)
      end
      @content_block.update_attributes( params[:content_block] )
      @content_block.save
      respond_to do |format|
        format.js { render :layout => false }
      end
    end

    def index
      begin
        render 'manage/content_blocks/index'
      rescue ActionView::MissingTemplate
        render 'publinator/manage/content_blocks/index'
      end
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
        edit = true
        unless @content_block.save
          flash[:error] = 'Content block could not be created'
        else
          if @content_block.content_type.present?
            unless @content_block.content_id
              @content_block.build_content( {} )
            else
              edit = false
            end
          end
        end
        format.js do
          if ( edit )
            begin
              render :text => render_to_string(:partial => 'manage/content_blocks/edit', :locals => {:content_block => @content_block})
            rescue ActionView::MissingTemplate
              render :text => render_to_string(:partial => 'publinator/manage/content_blocks/edit', :locals => {:content_block => @content_block})
            end
          else
            begin
              render :text => render_to_string(:partial => 'manage/content_blocks/preview', :locals => {:content_block => @content_block})
            rescue ActionView::MissingTemplate
              render :text => render_to_string(:partial => 'publinator/manage/content_blocks/preview', :locals => {:content_block => @content_block})
            end
          end
        end
      end
    end

    def update
      respond_to do |format|
        shared = params[:content_block].delete(:shared?)
        shared_title = params[:content_block].delete(:shared_title)

        @content_block.update_attributes(params[:content_block])

        unless @content_block.save
          flash[:error] = 'Content block could not be updated.'
        else
          if ( shared )
            @content_block.share( shared_title )
          end
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
        # FIXME Destroy unless content is shared?
        #if ( @content_block.content.present? )
        #  @content_block.content.destroy
        #end
        if @content_block.shared? && params[:delete_all]
          Publinator::ContentBlock.delete_all({:content_type => @content_block.content_type, :content_id => @content_block.content_id})
        else
          @content_block.destroy
        end
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
      @content_blocks = @page.publication.content_blocks
    end

    def find_or_build_content_block
      blocks = @page.publication.content_blocks
      if params[:id]
        @content_block = blocks.find(params[:id])
      elsif params[:content_block]
        block_params = params[:content_block]
        type_id = block_params[:content_type].split('|')
        block_params[:content_type] = type_id[0]
        if ( type_id.count == 2 )
          block_params[:content_id] = type_id[1]
        end
        @content_block = blocks.build(block_params)
      else
        @content_block = blocks.build({})
      end
    end

  end
end
