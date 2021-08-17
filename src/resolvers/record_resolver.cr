module Resolvers
  class CellLoader
    @@loaders = {} of Int64 => CellLoader

    def self.for(rec : Record)
      unless @@loaders.has_key?(rec.id)
        @@loaders[rec.id.not_nil!] = CellLoader.new(rec)
      end

      @@loaders[rec.id.not_nil!]
    end

    property rec : Record
    property fields : Array(String)

    def initialize(rec : Record)
      @rec = rec
      @fields = [] of String
      @cache = {} of String => Graphql::Lazy(String | Nil)
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
        fulfill(cell.name, cell.data)
      end
    end

    def resolved?
      @fields.empty?
    end

    def load(field : String)
      fields << field

      @cache[field] ||= Graphql::Lazy(String | Nil).new {
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