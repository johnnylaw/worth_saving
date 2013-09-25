require 'spec_helper'

feature 'WorthSaving' do
  let(:fred) { given_user 'Fred Flintstone' }

  scenario "A user begins work on a new page and sees recovery option when refreshing the page", js: true do
    login fred
    visit new_admin_page_path

    within '.worth-saving-standard-form-container .worth-saving-form-container' do
      fill_in 'Content', with: 'Something to get drafted...'
    end

    expect_draft_form_to_have_path /\/worth_saving\/admin\/drafts$/
    chill_out_long_enough_to_draft
    expect_draft_form_to_have_path /\/worth_saving\/admin\/drafts\/[\d]+$/

    visit current_path

    within 'form#new_page' do
      expect(page.find('#page_content').value).to eq ''
    end

    within 'form#recovered_new_page' do
      expect(page.find('#recovered_page_content').value).to eq 'Something to get drafted...'
    end

    within '.worth-saving-header-message' do
      expect(page).to have_content "It appears you were working on a draft that didn't get saved"
    end

    within '.worth-saving-recovery-form-container form#new_page' do
      click_on 'Choose this copy'
    end
  end
end