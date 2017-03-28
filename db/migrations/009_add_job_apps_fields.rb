Sequel.migration do
  change do
    add_column :job_apps, :gender, :text
    add_column :job_apps, :selective_service, :text
    add_column :job_apps, :recently_laid_off, :boolean
    add_column :job_apps, :veteran, :boolean
    add_column :job_apps, :work_authorization, :text
    add_column :job_apps, :education, :text
    add_column :job_apps, :current_school, :text
    add_column :job_apps, :current_employment_status, :text
    add_column :job_apps, :unemployment_insurance, :text
    add_column :job_apps, :household_size, :integer
    add_column :job_apps, :six_month_income, :numeric
    add_column :job_apps, :employer, :text
    add_column :job_apps, :wage, :numeric
    add_column :job_apps, :hours_worked, :numeric
    add_column :job_apps, :date_last_worked, :text
    add_column :job_apps, :farm_work, :boolean
    add_column :job_apps, :termination_notice, :text
    add_column :job_apps, :looking_for_work, :boolean
    add_column :job_apps, :desired_job, :text
    add_column :job_apps, :military_caregiver, :boolean
    add_column :job_apps, :military, :boolean
    add_column :job_apps, :military_dependent, :boolean
    add_column :job_apps, :tanf, :boolean
    add_column :job_apps, :snap, :boolean
    add_column :job_apps, :general_assistance, :boolean
    add_column :job_apps, :refugee_cash_assistance, :boolean
    add_column :job_apps, :expungement, :boolean
    add_column :job_apps, :case_manager, :boolean
  end
end
