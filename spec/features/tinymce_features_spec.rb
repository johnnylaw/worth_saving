require 'spec_helper'

feature 'WorthSaving' do
  let(:fred) { given_user 'Fred Flintstone' }
  let(:barney) { given_user 'Barney Rubble' }

  scenario "TinyMCE are in place for textareas, user makes edits to new doc without saving", js: true do
    login fred
    visit new_page_path editor: 'tinymce'

    within_frame("page_content_ifr") do
      editor = page.find_by_id('tinymce')
      editor.native.send_keys 'Test the page content'
    end

    within_frame("page_subpages_attributes_0_content_ifr") do
      editor = page.find_by_id('tinymce')
      editor.native.send_keys 'Test the subpage content'
    end

    chill_out_long_enough_to_draft
    visit current_path

    within_frame("page_content_ifr") do
      expect(page).not_to have_content('Test the page content')
    end

    within_frame("page_subpages_attributes_0_content_ifr") do
      expect(page).not_to have_content('Test the subpage content')
    end

    within_frame("recovered_page_content_ifr") do
      expect(page).to have_content('Test the page content')
    end

    within_frame("recovered_page_subpages_attributes_0_content_ifr") do
      expect(page).to have_content('Test the subpage content')
    end
  end
end
