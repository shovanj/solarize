require File.dirname(__FILE__) + '/common_methods'
require File.dirname(__FILE__) + '/parser_methods'


module Solarize
  module ClassMethods

    include CommonMethods
    include ParserMethods

    def get_by_solr(query, options = {})
      data = parse_query(query, options)
      Merb.logger.debug "get_by_solr => data:#{data.inspect}"
      parsed_data = parse_results(data, options) 
      return parsed_data
    end

    def rebuild_solr_index(batch_size, &finder)
      finder ||= lambda { |model, options| model.all(options) }
      if batch_size > 0

        number_of_items_processed = 0
        limit = batch_size
        offset = 0

        begin
          start_time = Time.now
          items = finder.call(self, {:limit => limit, :offset => offset})
          add_batch = items.collect { |content| content.to_solr_doc }

          if items.size > 0
            Merb.logger.debug "rebuild_solr_index: #{add_batch.inspect}"
            solr_add add_batch
            solr_commit
          end

          number_of_items_processed += items.size
          Merb.logger.debug "#{number_of_items_processed} items for #{self.name} have been indexed"
          offset  += items.size

        end while items.nil? || items.size > 0
      end

      Merb.logger.debug "Optimizing solr indices"
      Merb.logger.debug "#{number_of_items_processed} rows were indxed and optimized"
      optimize_solr_index
    end
  end
end
