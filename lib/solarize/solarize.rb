module Solarize
  VERSION = '0.0.1'

  class << self
    def options
      @options ||= {:auto_commit => true}
    end
  end

  class Post
    class << self
      def execute(request)
        begin
          if File.exists?(Merb.root+'/config/solr.yml')
            config = YAML::load_file(Merb.root+'/config/solr.yml')
            url = config[Merb.env]['url']
            url ||= "http://#{config[Merb.env]['host']}:#{config[Merb.env]['port']}/#{config[Merb.env]['servlet_path']}"
          end
          connection = Solr::Connection.new(url, :autocommit => :on)
          Merb.logger.debug "execute"
          return connection.send(request)
        rescue
          raise "Couldn't connect to the Solr server at #{url}. #{$!}"
          false
        end
      end
    end
  end

  module Resource
    def self.included(base)
      #Merb.logger.debug "included base is:#{base.inspect} self is:#{self}"
      base.extend Solarize::ClassMethods
    end
  end

  module ClassMethods
    def solarize(options = {}, solr_options = {})
      include InstanceMethods
      include CommonMethods

      cattr_accessor :configuration
      cattr_accessor :solr_configuration

      self.configuration = {
        :fields => nil,
        :additional_fields => nil,
        :exclude_fields => [],
        :auto_commit => true,
        :include => nil,
        :facets => nil,
        :boost => nil,
        :if => "true"
      }
      self.solr_configuration = {
        :type_field => "type_t",
        :primary_key_field => "pk_i",
        :default_boost => 1.0
      }

      configuration[:solr_fields] = []

      configuration.update(options) if options.is_a?(Hash)
      solr_configuration.update(solr_options) if solr_options.is_a?(Hash)

      after :save, :solr_save
      before :destroy, :solr_destroy

      if configuration[:fields].respond_to?(:each)
        prepare_solr_fields
      else
      end
      #Merb.logger.debug "#{self.class} and #{self.properties.inspect} and configuration: #{configuration.inspect}"

    end


    private
    def prepare_solr_fields
      configuration[:fields].each do |field|
        next if field == :id
        configuration[:solr_fields] <<  field
      end
    end
  end
end
