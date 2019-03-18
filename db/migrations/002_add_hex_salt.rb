Sequel.migration do
  up do
    add_column :hashes, :hexed_salt, TrueClass
    from(:hashes).update(hexed_salt: false)
  end

  down do
    drop_column :hashes, :hexed_salt
  end
end