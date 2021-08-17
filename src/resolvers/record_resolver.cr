module Resolvers
  class CellLoader
    @@loaders = {} of Record => CellLoader

    def self.for(rec : Record)
      @@loaders.fetch(rec) do
        CellLoader.new(rec)
      end
    end

    property rec : Record
    property fields : Array(String)

    def initialize(rec : Record)
      @rec = rec
      @fields = [] of String
      @cache = {} of String => Graphql::Lazy(JSON::Any)
    end

    def resolve
      return if resolved?

      load_keys = @fields
      @fields = [] of String

      perform(load_keys)
    end

    def perform(load_keys : Array(String))
      cells = Cell.where(record_id: rec.id, name: load_keys)
      cells.each do |cell|
        fulfill(cell.name, cell.value.raw)
      end
    end

    def resolved?
      @fields.empty?
    end

    def load(field : String)
      fields << field

      @cache[field] ||= Graphql::Lazy(JSON::Any).new {
        resolve
      }
    end

    private def fulfill(key, value)
      promise = @cache[key]
      promise.fulfill(value)
    end
  end

  class RecordResolver < Graphql::Schema::Resolver
    def initialize
    end

    def resolve(r : Record, field_name, argument_values)
      if field_name == "id"
        r.id
      else
        loader = CellLoader.for(r)
        loader.load(field_name)
      end
    end
  end
end