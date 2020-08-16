class Model < Granite::Base
  connection postgres

  table models

  has_many fields : Field
  has_many records : Record

  column id : Int64, primary: true
  column name : String
  column singular : String
  column plural : String
end