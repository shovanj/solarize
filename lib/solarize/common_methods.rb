module Solarize#:nodoc:

  module CommonMethods
    # objec.class => Note
    # Model.properties will give list of columns
    # property.primitive will give the datatype
    def get_field_type(field)
      self.class.properties.each do |property|
        column_type = property.primitive.to_s.downcase.to_sym
        if property.field.to_sym == field
          case column_type
          when :string   then return :text
          when :datetime then return :date
          when :time     then return :date
          else return column_type
          end
        end
      end
    end

    # Converts field types into Solr types
    def get_solr_field_type(field_type)
      if field_type.is_a?(Symbol)
        case field_type
        when :float:          return "f"
        when :integer:        return "i"
        when :boolean:        return "b"
        when :string:         return "s"
        when :date:           return "d"
        when :range_float:    return "rf"
        when :range_integer:  return "ri"
        when :facet:          return "facet"
        when :text:           return "t"
        else
          raise "Unknown field_type symbol: #{field_type}"
        end
      elsif field_type.is_a?(String)
        return field_type
      else
        raise "Unknown field_type class: #{field_type.class}: #{field_type}"
      end
    end

    # Sets a default value when value being set is nil.
    def set_value_if_nil(field_type)
      case field_type
      when "b", :boolean:                        return "false"
      when "s", "t", "d", :date, :string, :text: return ""
      when "f", "rf", :float, :range_float:      return 0.00
      when "i", "ri", :integer, :range_integer:  return 0
      else
        return ""
      end
    end

    # Sends an add command to Solr
    def solr_add(add_document)
      Solarize::Post.execute(Solr::Request::AddDocument.new(add_document))
    end

    # Sends the delete command to Solr
    def solr_delete(solr_id)
      Solarize::Post.execute(Solr::Request::Delete.new(:id => solr_id))
    end

    # Sends the commit command to Solr
    def solr_commit
      Solarize::Post.execute(Solr::Request::Commit.new)
    end

    # Optimize solar index
    def optimize_solr_index
      Solarize::Post.execute(Solr::Request::Optimize.new)
    end

    # Returns the id for the given instance
    def record_id(object)
      #eval "object.#{object.class.primary_key}"
      object.id
    end

  end

end
