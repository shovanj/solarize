module Solarize
  module InstanceMethods

    # Solr id is <class.name>:<id> to be unique across all models
    def solr_id
      "#{self.class.name}:#{record_id(self)}"
    end

    # saves to the Solr index
    def solr_save
      Merb.logger.debug "solr_save: #{self.class.name} : #{record_id(self)}"
      solr_add to_solr_doc
      solr_commit #if configuration[:auto_commit]
      true
    end

    # remove from index
    def solr_destroy
      Merb.logger.debug "solr_destroy: #{self.class.name} : #{record_id(self)}"
      solr_delete solr_id
      solr_commit if configuration[:auto_commit]
      true
    end

    # convert instance to Solr document
    # creating the Hash structure
    def to_solr_doc
      #Merb.logger.debug "to_solr_doc: creating doc for class: #{self.class.name}, id: #{record_id(self)}"
      doc = {}
      doc[:id] = solr_id
      doc[:type_t] = self.model.name
      doc[:pk_i] = self.id.to_s

      configuration[:solr_fields].each do |field|
        field_key = "#{field}_#{get_solr_field_type(get_field_type(field))}" 
        eval("doc[:#{field_key}] = self.#{field}")
      end
      Merb.logger.debug "to_solr_doc: #{doc.inspect}" 
      doc
    end

    private

  end
end

