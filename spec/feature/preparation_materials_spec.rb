require 'rspec'
require 'capybara/rspec'
require './app'

Capybara.app = WorkForwardNola::App
WorkForwardNola::App.show_exceptions = false

describe 'preparation materials', type: :feature do
  it 'should show inputted information' do
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
    select "Bachelor's degree", from: 'What level of education do you have?'
    fill_in 'Employer', with: 'Ballast Point'

    click_button 'Next'

    expect(page).to have_content 'Make a CalJobs profile'

    click_link 'Next'

    expect(page).to have_content "You're all set!"

    click_link 'Download application'

    id = current_path.split('/').last

    visit "/intake/#{id}"

    expect(page).to have_content 'Orientation Customer Intake Assessment'
    expect(page).to have_content 'Customer Name: Sandie Go'
    expect(page).to have_content "Customer's phone: 555-555-5555"
    expect(page).to have_content 'Employment Status: not employed'
    expect(page).to have_content 'Date Last Worked: 1/2/2013'
    expect(page).to have_content 'Receiving Unemployment Insurance? yes'
    expect(page).to have_content 'Are you a veteran? no'
    expect(page).to have_content 'Public assistance: TANF SNAP'
    expect(page).to have_content "Highest education level: Bachelor's degree"
    expect(page).to have_content 'Most recent employer: Ballast Point'
  end
end
