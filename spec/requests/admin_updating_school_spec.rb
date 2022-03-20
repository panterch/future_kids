require 'requests/acceptance_helper'

feature 'ADMIN::UPDATE:SCHOOL', '
    As an admin
    I want to modify an existing school
  'do
  background do
    log_in(create(:admin))
    create(:school, name: 'SSIG')
  end

  scenario 'should be able to modify an existing school' do
    click_link 'Schule'
    click_link 'SSIG'
    click_link 'Bearbeiten'

    fill_in 'Name', with: 'Colab Zurich'
    fill_in 'Strasse, Nr.', with: 'Zentralstrasse'
    click_button 'Schule aktualisieren'

    expect(page).to have_content('Colab Zurich')
  end
end
