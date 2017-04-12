require 'rspec'
require 'capybara/rspec'
require 'capybara-webkit'
require './app'
require './models/job_app'

Capybara.app = WorkForwardNola::App
Capybara.javascript_driver = :webkit

Capybara::Webkit.configure do |config|
  config.allow_unknown_urls
  config.raise_javascript_errors = true
end

WorkForwardNola::App.show_exceptions = true

describe 'preparation materials', type: :feature do
  it 'should show inputted information', js: true do
    visit '/'

    expect(page).to have_content 'Looking for work?'

    click_link 'Start'

    expect(page).to have_content 'Prepare for a visit to a Career Center'

    fill_in 'First Name', with: 'Sandie'
    fill_in 'Last Name', with: 'Go'
    fill_in 'Phone Number', with: '555-555-5555'
    select 'Not Employed', from: 'What is your current employment status?'
    fill_in 'If you are no longer working at this job, what was the date you last worked?', with: '1/2/2013'
    choose 'unemployment_insurance_yes'
    choose 'veteran_no'
    choose 'tanf_yes'
    choose 'snap_yes'
    choose 'general_assistance_no'
    select "Bachelor's degree", from: 'What is your highest level of education?'
    fill_in 'Employer', with: 'Ballast Point'
    fill_in 'What type of work are you looking for?', with: 'Food Service'

    click_button 'Next'

    expect(page).to have_content 'Make a CalJobs profile'

    click_button 'Next'

    expect(page).to have_content "You're all set!"

    click_button 'Download application'
  end

  it 'renders the intake form correctly' do
    job_app = WorkForwardNola::JobApp.create(
        last_name: 'Go',
        first_name: 'Sandie',
        email: '',
        phone: '555-555-5555',
        veteran: false,
        education: "Bachelor's degree",
        current_employment_status: 'not employed',
        unemployment_insurance: 'yes',
        employer: 'Ballast Point',
        date_last_worked: '1/2/2013',
        desired_job: 'Food Service',
        tanf: true,
        snap: true,
        refugee_cash_assistance: false,
    )

    visit "/intake/#{job_app.id}"

    expect(page).to have_content 'Orientation Customer Intake Assessment'
    expect(page).to have_content 'Customer Name: Sandie Go'
    expect(page).to have_content "Customer's phone: 555-555-5555"
    expect(page).to have_content 'Employment status not employed'
    expect(page).to have_content 'Date last worked 1/2/2013'
    expect(page).to have_content 'Receiving unemployment insurance? yes'
    expect(page).to have_content 'Are you a veteran? no'
    expect(page).to have_content 'Public assistance TANF, SNAP'
    expect(page).to have_content "Highest education level Bachelor's degree"
    expect(page).to have_content 'Most recent employer Ballast Point'
    expect(page).to have_content 'What type of work are you looking for? Food Service'
  end
end
