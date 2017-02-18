Sequel.migration do
  change do
    create_table(:job_apps) do
      primary_key :id
      String :first_name, null: false
      String :last_name, null: false
      String :phone, null: false
      String :email, null: false
    end
  end
end
