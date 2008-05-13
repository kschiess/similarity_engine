ActiveRecord::Schema.define do
  create_table :similarity_coefficients, :force => true do |t|
    t.column :model_klass, :string, :null => false
    t.column :id_lo, :integer, :null => false
    t.column :id_hi, :integer, :null => false
    t.column :coeff, :float, :null => false
    t.column :updated_at, :datetime, :null => false
  end
  
  add_index :similarity_coefficients, [:model_klass, :id_lo, :id_hi]
end