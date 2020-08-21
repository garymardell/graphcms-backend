class RecordData
  def self.from_json(json)
    new(JSON.parse(json))
  end

  property data : JSON::Any

  def initialize(@data)
  end

  def [](field_name)
    data[field_name]
  end
end

class Record < Granite::Base
  connection postgres

  table records

  belongs_to model : Model

  has_many cells : Cell

  column id : Int64, primary: true
end