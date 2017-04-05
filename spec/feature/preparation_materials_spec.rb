require 'rspec'
require 'capybara/rspec'
require './app'

Capybara.app = WorkForwardNola::App

describe 'preparation materials', type: :feature do
  it 'should show inputted information' do
    visit '/'

    expect(page).to have_content 'Looking for work?'

    click_link 'Start'

    expect(page).to have_content 'Prepare for a visit to a Career Center'

    fill_in 'First Name', with: 'Sandie'
    fill_in 'Last Name', with: 'Go'

    click_button 'Next'

    expect(page).to have_content 'Make a CalJobs profile'

    click_link 'Next'

    expect(page).to have_content "You're all set!"

    click_link 'Download application'
  end
end
