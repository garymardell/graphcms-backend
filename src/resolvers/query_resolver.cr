module Resolvers
  class QueryResolver < Graphql::Schema::Resolver
    def resolve(object, field_name, argument_values)
      if argument_values.has_key?("id")
        model = Model.find_by!(singular: field_name)
        model.records.find(argument_values["id"].to_s.to_i32)
      else
        model = Model.find_by!(plural: field_name)
        model.records.to_a
      end
    end
  end
end