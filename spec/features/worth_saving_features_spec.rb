require 'spec_helper'

feature 'WorthSaving' do
  let(:fred) { given_user 'Fred Flintstone' }
  let(:barney) { given_user 'Barney Rubble' }

  scenario "A user begins work on a new page and sees recovery option when refreshing the page", js: true do
    login fred
    visit new_page_path
    within '.worth-saving-standard-form-container .worth-saving-form-container' do
      fill_in_form
    end
    chill_out_long_enough_to_draft
    visit current_path
    within '.worth-saving-header-message' do
      expect(page).to have_content "It appears you were working on a draft that didn't get saved"
    end
    within '.worth-saving-recovery-form-container #new_page' do
      verify_blank_form
    end
    within '.worth-saving-recovery-form-container #recovered_new_page' do
      verify_form({}, true)
    end
  end

  scenario "As a user I start work on a new page, refresh and see draft, but another user can't see it", js: true do
    login fred
    visit new_page_path
    within '.worth-saving-standard-form-container .worth-saving-form-container' do
      fill_in_form
    end
    chill_out_long_enough_to_draft
    visit current_path
    within '.worth-saving-header-message' do
      expect(page).to have_content "It appears you were working on a draft that didn't get saved"
    end
    login barney
    visit new_page_path
    page.should_not have_css '.worth-saving-header-message'
  end

  scenario "One user creates a page.  Another edits that page, and drafts do not get saved because of methods in ApplicationController", js: true do
    login fred
    visit new_page_path
    within '.worth-saving-standard-form-container .worth-saving-form-container' do
      fill_in_form
    end
    click_on 'Create Page'
    path = current_path
    login barney
    visit path
    within '.worth-saving-standard-form-container .worth-saving-form-container' do
      fill_in 'Content', with: "Here is some new content that I will not expect to see"
    end
    chill_out_long_enough_to_draft
    within '.worth-saving-form-message.error' do
      page.should have_content "Not authorized to draft this Page"
    end
  end

  scenario "No user logged in, draft cannot save and provides error message", js: true do
    logout
    visit new_page_path
    within '.worth-saving-standard-form-container .worth-saving-form-container' do
      fill_in 'Title', with: 'gibberish'
    end
    chill_out_long_enough_to_draft
    within '.worth-saving-form-message.error' do
      page.should have_content "Cannot save draft for new record without scopeable record. Be sure to build draft from Page with a non-nil user."
    end
  end
end
