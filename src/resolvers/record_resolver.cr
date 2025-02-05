module Resolvers
  abstract class Loader(Q)
    property queue : Array(Q)

    def initialize
      @queue = [] of Q
      @cache = {} of Q => Graphql::Lazy(String | Nil)
    end

    def resolve
      return if resolved?

      load_keys = @queue
      @queue = [] of Q

      perform(load_keys)
      resolve_unfulfilled_promises
    end

    abstract def perform(load_keys : Array(Q))

    def resolved?
      queue.empty?
    end

    def load(item : Q)
      queue << item

      @cache[item] ||= Graphql::Lazy(String | Nil).new {
        resolve
      }
    end

    private def fulfill(key, value)
      return unless @cache.has_key?(key)

      promise = @cache[key]
      promise.fulfill(value)
    end

    private def resolve_unfulfilled_promises
      @cache.values.reject(&.fulfilled?).each do |promise|
        promise.fulfill(nil)
      end
    end
  end

  class CellLoader < Loader(Tuple(Int64, String))
    def perform(load_keys : Array(Q))
      record_ids = load_keys.map { |(record_id, _name)| record_id }.uniq
      fields = load_keys.map { |(_record_id, name)| name }.uniq

      cells = Cell.where(record_id: record_ids, name: fields)
      cells.each do |cell|
        fulfill({ cell.record_id, cell.name }, cell.data)
      end
    end
  end

  class RecordResolver < Graphql::Schema::Resolver
    property loader : CellLoader

    def initialize
      @loader = CellLoader.new
    end

    def resolve(r : Record, field_name, argument_values)
      if field_name == "id"
        r.id
      else
        loader.load({r.id.not_nil!, field_name})
      end
    end
  end
end