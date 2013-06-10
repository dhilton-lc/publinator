class Publinator::AssetFile < ActiveRecord::Base
  attr_accessible :asset, :asset_type, :extracted_text, :citation, :position, :author, :title

  has_many :publication_joins, :class_name => "Publinator::PublicationAssetFile", :uniq => true, :dependent => :destroy
  has_many :publications, :through => :publication_joins, :uniq => true do
    def <<(new_publication)
      super( Array(new_publication) - proxy_association.owner.publications )
    end
  end

  has_attached_file :asset,
    :storage => :fog,
    :fog_credentials => { :aws_access_key_id => "AKIAITQAV6AXKGTE27PQ", :aws_secret_access_key => "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", :provider => 'AWS' },
    :fog_directory => 'files.amedica.dev',
#    :s3_credentials => { :access_key_id => "AKIAITQAV6AXKGTE27PQ", :secret_access_key => "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" },
#    :s3_bucket => 'files.amedica.dev',
    :path => ":env_id/:style_file"

  default_scope order('updated_at desc')

  #after_save :schedule_extraction

  def editable_fields
    ['citation', 'position', 'author', 'title']
  end

  def hidden_fields
      ["extracted_text"]
  end

  def extract_text
    http_url    = asset.url
    http_domain = http_url.gsub('http://','').split('/')[0]
    http_path   = '/' + http_url.gsub('http://','').split('/')[1..999].join('/')
    file_name = File.basename(http_url)
    tmpfile_path = File.join('.', File.basename(file_name))
    temp = Tempfile.new(tmpfile_path)
    contents = ""
    Net::HTTP.start(http_domain) { |http|
      resp = http.get(http_path)
      temp.binmode
      temp.write(resp.body)
      temp.close
      reader = PDF::Reader.new(temp.path)
      reader.pages.each do |page|
        contents << page.text
      end
      temp.close
    }
    if contents.blank?
      contents = "[no text extracted]"
    end
    self.extracted_text = contents
    save
  end

  def schedule_extraction
    if self.asset_content_type == 'application/pdf' && self.extracted_text.blank?
      self.delay.extract_text
    end
  end

  #define_index do
  #  indexes asset_file_name, :sortable => true
  #  indexes extracted_text
  #  indexes assetable(:title), :as => :assetable_type, :sortable => true
  #  has created_at, updated_at
  #end
private

  Paperclip.interpolates :env_id do |attachment, style|
    if Rails.env == 'production'
      attachment.instance.id
    else
      "#{Rails.env}/#{attachment.instance.id}"
    end
  end

  Paperclip.interpolates :style_file do |attachment, style|
    filename = Paperclip::Interpolations.filename( attachment, style )
    if style.blank?
      filename
    else
      "#{style}/#{filename}"
    end
  end

end
