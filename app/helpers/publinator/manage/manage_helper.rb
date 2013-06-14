module Publinator
  module Manage
    module ManageHelper
      def flash_class(level)
        case level
          when :notice then "flash alert alert-info"
          when :success then "flash alert alert-success"
          when :error then "flash alert alert-error"
          when :alert then "flash alert alert-alert"
        end
      end

      def shared_content_options
        shared = Publinator::ContentBlock.shared
        options = []
        shared.each do |blk|
          options << [ blk.title, "#{blk.content_type}|#{blk.content_id}" ]
        end
        return options
      end
    end
  end
end
