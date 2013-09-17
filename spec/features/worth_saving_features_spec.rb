require 'spec_helper'

feature 'WorthSaving' do
  scenario "edits done to a new page will appear in a recovery form when refreshing the page", js: true do
    fred, barney = given_users('Fred Flinstone', 'Barney Rubble')
    login fred
    visit new_page_path
    within '.worth-saving-standard-form-container .worth-saving-form-container' do
      fill_in_form
    end
    chill_out_long_enough_to_draft

    visit current_path

    # expect the recovery message

    within '.worth-saving-recovery-form-container #new_page' do
      verify_blank_form
    end

    within '.worth-saving-recovery-form-container #recovered_new_page' do
      verify_form({}, true)
    end
  end
end
