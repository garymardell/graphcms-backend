module Resolvers
  class CellLoader
    @@loaders = {} of Int64 => CellLoader

    def self.for(model : Model)
      unless @@loaders.has_key?(model.id)
        @@loaders[model.id.not_nil!] = CellLoader.new(model)
      end

      @@loaders[model.id.not_nil!]
    end

    property model : Model
    property records : Array(Int64)
    # property fields : Array(String)

    def initialize(@model : Model)
      @records = [] of Int64
      @cache = {} of Tuple(Int64, String) => Graphql::Lazy(String | Nil)
    end

    def resolve
      return if resolved?

      load_keys = @records
      @records = [] of Int64

      perform(load_keys)
    end

    def perform(load_keys : Array(Int64))
      cells = Cell.where(record_id: load_keys.uniq)
      cells.each do |cell|
        fulfill({ cell.record_id, cell.name }, cell.data)
      end
    end

    def resolved?
      @records.empty?
    end

    def load(id : Int64, field : String)
      records << id

      @cache[{id, field}] ||= Graphql::Lazy(String | Nil).new {
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
        loader = CellLoader.for(r.model)
        loader.load(r.id.not_nil!, field_name)
      end
    end
  end
end