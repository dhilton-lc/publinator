namespace :publinator do
  desc "Dump DB, then repopulate it."
  task :repopulate => :environment do
    ["db:drop", "publinator:install:migrations", "db:create", "db:migrate", "db:seed"].each do |t|
      Rake::Task[t].execute
      `touch tmp/restart.txt`
    end
  end

  desc "Migrate asset items to asset files"
  task :migrate_attachments => :environment do
    puts 'Migrating asset_items to asset_files ...'

    Publinator::AssetItem.all.each do |item|
      #puts "\t#{item.asset_file_name}"

      file = Publinator::AssetFile.where( :asset_file_name => item.asset_file_name ).first

      if ( !file )
        puts "\t\tCreating new file..."

        file = Publinator::AssetFile.new

        file.asset_type = item.asset_type
        file.extracted_text = item.extracted_text
        file.citation = item.citation
        file.author = item.author
        file.title = item.title

        begin
          file.asset = item.asset
          file.save
        rescue Paperclip::Errors::NotIdentifiedByImageMagickError
          puts "Ooops.  Not Identified by Image Magick!"
        else
          if ( item.assetable && item.assetable.publication )
            join = Publinator::PublicationAssetFile.new
            join.asset_file = file
            join.publication = item.assetable.publication
            join.position = item.position
            join.save!
          end
        end
      else
        puts "\t\tFile already exists..."
      end
    end

    Publinator::AssetFile.order('asset_file_name, id ASC').all.each do |file|
      publications = []
      file.publication_joins.each do |j|
        unless publications.include?( j.publication_id )
          puts "#{file.id} <> #{j.publication_id} preserved"
          publications << j.publication_id
        else
          puts "#{file.id} <> #{j.publication_id} destroyed"
          j.destroy
        end
      end
    end
  end

  desc "Create new pages from current sections."
  task :convert_sections => :environment do
    #+ Create home page
    home_page = Publinator::Page.find( :first, :conditions => { :title => "Home" } );
    if home_page.nil?
      home_page = Publinator::Page.send(:new, {
        :title            => "Home",
        :layout           => 0,
        :publication => Publinator::Publication.new(
          :publish_at       => 1.day.from_now.beginning_of_day + 8.hours,
          :archive_at       => 31.days.from_now.beginning_of_day,
          :site_id          => 3,
          :publishable_type => "Publinator::Page",
          :slug             => ""
        )
      })
      home_page.save!
    end


    section_page_map = {}
    new_pages = []
    Publinator::Section.all().each do |section|
      puts "Section: '#{section.title}'; Slug: '#{section.slug}'; id: #{section.id}"
      #+ First fetch our page if it already exists
      page = Publinator::Page.send(:new, {
        :title            => section.title,
        :layout           => section.layout,
        :section_id       => section.parent_id,
        :publication => Publinator::Publication.new(
          :publish_at       => 1.day.from_now.beginning_of_day + 8.hours,
          :archive_at       => 31.days.from_now.beginning_of_day,
          :site_id          => section.site_id,
          :publishable_type => "Publinator::Page",
          :slug             => section.slug,
          :section_id       => section.parent_id # Maybe not?
        )
      })
      page.save!
      new_pages << page
      section_page_map[section.id] = page
      section.publishables.each do |child|
        if child.publishable_type == "Publinator::Page"
          unless child.publishable_id == page.id
            child.publishable.parent = page
            child.publishable.save!
          end
        end
      end
    end
    # Establish heirarchy among new pages
    new_pages.each do |p|
      if ( p.section_id )
        p.parent = section_page_map[p.section_id]
      else
        p.parent = home_page
      end
      p.save!
    end
  end
end
