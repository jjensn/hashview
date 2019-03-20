Sequel.migration do
  up do
    create_table(:masks) do
      primary_key :id, type: :Bignum
      DateTime :lastupdated
      String :name, size: 256
      String :path, size: 2000
      String :size, size: 100
      String :scope, size: 25
      index [:name], name: :ix_mask_uq, unique: true
    end
    add_column :tasks, :visible, TrueClass
  end

  down do
    drop_table :masks
  end
end