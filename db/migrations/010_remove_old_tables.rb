Sequel.migration do
  change do
    drop_table(:careers, cascade: true)
    drop_table(:traits, cascade: true)
    drop_table(:careers_traits)
  end
end
