module Solarize
  module ParserMethods
    protected
    def parse_results(solr_data, options = {})
      results = {
        :docs => [],
        :total => 0
      }
      results[:docs] = solr_data.data['response']['docs'].collect {|doc| doc["#{solr_configuration[:primary_key_field]}"] }
      results[:total] = solr_data.data['response']['numFound'] 
      results
    end

    # Method used to do a search
    def parse_query(query=nil, options={}, models=nil)
      valid_options = [:offset, :limit, :models, :results_format, :order, :scores, :operator]
      query_options = {}

      return nil if (query.nil? || query.strip == '')

      raise "Invalid parameters: #{(options.keys - valid_options).join(',')}" unless (options.keys - valid_options).empty?
      begin
        query_options[:start]    = options[:offset]
        query_options[:rows]     = options[:limit]
        query_options[:operator] = options[:operator]
        if models.nil?
          models = "AND #{solr_configuration[:type_field]}:#{self.name}"
          field_list = solr_configuration[:primary_key_field]
        else
          field_list = "id"
        end
        query_options[:field_list] = [field_list, 'score']
        query = "(#{query.gsub(/ *: */,"_t:")}) #{models}"
        query_options[:query] = query
        #Solarize::Post.execute(Solr::Request::Standard.new({:field_list=>["pk_i", "score"], :query=>"(112) AND type_t:Note", :start=>nil, :rows=>nil, :operator=>nil})
        Solarize::Post.execute(Solr::Request::Standard.new(query_options))
      rescue
        raise "There was a problem with search query"
      end
    end
  end
end
