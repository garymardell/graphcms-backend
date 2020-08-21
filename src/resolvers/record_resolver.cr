module Resolvers
  class RecordResolver < Graphql::Schema::Resolver
    def resolve(r : Record, field_name, argument_values)
      if field_name == "id"
        r.id
      else
        if cell = r.cells.find_by(name: field_name)
          cell.value.raw
        end
      end
    end
  end
end