require 'requests/acceptance_helper'

feature 'TEACHER::CREATE:KID', '
  As a teacher
  I want to fill out the new kid form
  So that I can create a new kid

' do
  background do
    @pw = 'welcome'
    @teacher = create(:teacher, password: @pw, password_confirmation: @pw)
    log_in(@teacher)
  end

  scenario 'should not create a new kid without the required values' do
    click_link 'Schüler/in'
    click_link 'Erfassen'
    click_button 'Schüler/in erstellen'
    expect(page.status_code).to eq(200)
    expect(page).to have_content('Schüler/in erfassen')
    expect(page).to have_content('muss ausgefüllt werden')
  end

  scenario 'should create a new kid with required values' do
    click_link 'Schüler/in'
    click_link 'Erfassen'
    fill_in 'kid_name', with: 'Last Name'
    fill_in 'kid_prename', with: 'First Name'
    click_button 'Schüler/in erstellen'
    expect(page.status_code).to eq(200)
    expect(page).to have_css('h1', text: 'Last Name First Name')
  end
    
  scenario 'should create a new kid with parent country' do
    click_link 'Schüler/in'
    click_link 'Erfassen'
    fill_in 'kid_name', with: 'Last Name'
    fill_in 'kid_prename', with: 'First Name'
    page.should have_select('kid_parent_country', :with_options => ['Albanien', 'Türkei', 'Sri Lanka', 'Kosovo', 'Spanien', 'Portugal'])
    select('Syrien, Arabische Republik', from: 'kid_parent_country')
    click_button 'Schüler/in erstellen'
    expect(page.status_code).to eq(200)
    expect(page).to have_css('h1', text: 'Last Name First Name')
  end
end

feature 'ADMIN::CREATE:KID', '
  As a teacher
  I want to fill out the new kid form
  So that I can create a new kid

' do
  background do
    @pw = 'welcome'
    @admin = create(:admin, password: @pw, password_confirmation: @pw)
    log_in(@admin)
  end

  scenario 'should not create a new kid without the required values' do
    click_link 'Schüler/in'
    click_link 'Erfassen'
    click_button 'Schüler/in erstellen'
    expect(page.status_code).to eq(200)
    expect(page).to have_content('Schüler/in erfassen')
    expect(page).to have_content('muss ausgefüllt werden')
  end

  scenario 'should create a new kid with required values' do
    click_link 'Schüler/in'
    click_link 'Erfassen'
    fill_in 'kid_name', with: 'Last Name'
    fill_in 'kid_prename', with: 'First Name'
    click_button 'Schüler/in erstellen'
    expect(page.status_code).to eq(200)
    expect(page).to have_css('h1', text: 'Last Name First Name')
  end
    
  scenario 'should create a new kid with parent country' do
    click_link 'Schüler/in'
    click_link 'Erfassen'
    fill_in 'kid_name', with: 'Last Name'
    fill_in 'kid_prename', with: 'First Name'
    page.should have_select('kid_parent_country', :with_options => ['Albanien', 'Türkei', 'Sri Lanka', 'Kosovo', 'Spanien', 'Portugal'])
    select('Syrien, Arabische Republik', from: 'kid_parent_country')
    click_button 'Schüler/in erstellen'
    expect(page.status_code).to eq(200)
    expect(page).to have_css('h1', text: 'Last Name First Name')
  end
end
