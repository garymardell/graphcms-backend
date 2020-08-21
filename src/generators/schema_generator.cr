require "../resolvers/**"

module Generators
  class SchemaGenerator
    def generate
      Graphql::Schema.new(
        query: generate_query_type
      )
    end

    private def generate_query_type
      Graphql::Type::Object.new(
        typename: "Query",
        resolver: Resolvers::QueryResolver.new,
        fields: generate_query_fields
      )
    end

    private def generate_query_fields
      Model.all.flat_map do |model|
        [
          generate_singular_field_for_model(model),
          generate_plural_field_for_model(model)
        ]
      end
    end

    private def generate_object_for_model(model)
      Graphql::Type::Object.new(
        typename: model.name,
        resolver: Resolvers::RecordResolver.new,
        fields: [
          Graphql::Schema::Field.new(
            name: "id",
            type: Graphql::Type::Id.new
          )
        ] + generate_fields_for_model(model)
      )
    end

    def generate_fields_for_model(model)
      model.fields.map do |field|
        Graphql::Schema::Field.new(
          name: field.name,
          type: graphql_type_for_field(field)
        )
      end
    end

    def generate_singular_field_for_model(model)
      Graphql::Schema::Field.new(
        name: model.singular,
        arguments: [
          Graphql::Schema::Argument.new(
            name: "id",
            type: Graphql::Type::Id.new
          )
        ],
        type: generate_object_for_model(model),
      )
    end

    def generate_plural_field_for_model(model)
      Graphql::Schema::Field.new(
        name: model.plural,
        type: Graphql::Type::List.new(
          of_type: generate_object_for_model(model)
        )
      )
    end

    def graphql_type_for_field(field)
      case field.cell_type
      when "string"
        Graphql::Type::String.new
      when "int"
        Graphql::Type::Int.new
      when "float"
        Graphql::Type::Float.new
      when "boolean"
        Graphql::Type::Boolean.new
      else
        raise "Could not get type"
      end
    end
  end
end