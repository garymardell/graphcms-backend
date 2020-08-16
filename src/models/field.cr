class Field < Granite::Base
  connection postgres

  table fields

  belongs_to :model

  column id : Int64, primary: true
  column name : String
end