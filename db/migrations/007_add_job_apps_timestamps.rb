Sequel.migration do
  change do
    add_column :job_apps, :created_at, DateTime
    add_column :job_apps, :updated_at, DateTime
  end
end