require "kemal"
# require "gzip"
# require "flate"

require "../config/database.cr"

require "graphql"

require "./models/**"
require "./generators/schema_generator"

get "/" do
  "Hello!"
end

post "/graphql" do |env|
  schema = Generators::SchemaGenerator.new.generate

  runtime = Graphql::Execution::Runtime.new(
    schema,
    Graphql::Query.new(env.params.json["query"].as(String))
  )

  runtime.execute
end

Kemal.run