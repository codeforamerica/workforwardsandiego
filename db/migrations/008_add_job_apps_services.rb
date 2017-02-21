Sequel.migration do
  change do
    add_column :job_apps, :services, :text
    add_column :job_apps, :other, :text
  end
end
