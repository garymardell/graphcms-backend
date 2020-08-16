require "kemal"
require "gzip"
require "flate"

require "../config/database.cr"

require "graphql"

require "./models/**"

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

class ModelResolver < Graphql::Schema::Resolver
  def resolve(r : Record, field_name, argument_values)
    if field_name == "id"
      r.id
    else
      r.cells.find_by(name: field_name).try &.data
    end
  end
end

get "/" do
  "Hello!"
end

post "/graphql" do |env|
  fields = Model.all.flat_map do |model|
    model_fields = model.fields.map do |field|
      Graphql::Schema::Field.new(
        name: field.name,
        type: Graphql::Type::String.new
      )
    end

    model_object = Graphql::Type::Object.new(
      typename: model.name,
      resolver: ModelResolver.new,
      fields: [
        Graphql::Schema::Field.new(
          name: "id",
          type: Graphql::Type::Id.new
        )
      ] + model_fields
    )


    [
      Graphql::Schema::Field.new(
        name: model.singular,
        arguments: [
          Graphql::Schema::Argument.new(
            name: "id",
            type: Graphql::Type::Id.new
          )
        ],
        type: model_object,
      ),
      Graphql::Schema::Field.new(
        name: model.plural,
        type: Graphql::Type::List.new(
          of_type: model_object
        )
      )
    ]
  end

  query_type = Graphql::Type::Object.new(
    typename: "Query",
    resolver: QueryResolver.new,
    fields: fields
  )

  schema = Graphql::Schema.new(
    query: query_type
  )

  runtime = Graphql::Execution::Runtime.new(
    schema,
    Graphql::Query.new(env.params.json["query"].as(String))
  )

  runtime.execute.to_json
end

Kemal.run