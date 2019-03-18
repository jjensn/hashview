Sequel.migration do
  up do
    add_column :wordlists, :mask_file, TrueClass
  end

  down do
    drop_column :wordlists, :mask_file
  end
end