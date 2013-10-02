require 'spec_helper'

feature 'WorthSaving' do
  let(:fred) { given_user 'Fred Flintstone' }
  let(:barney) { given_user 'Barney Rubble' }

  scenario "TinyMCE are in place for textareas, user makes edits to new doc without saving", js: true do
    login fred
    visit new_page_path editor: 'ckeditor'

    within_frame 0 do
      page.find('.cke_editable').native.send_keys 'Astonishingly insightful content'
    end

    within_frame 1 do
      page.find('.cke_editable').native.send_keys 'A subpage to match'
    end

    chill_out_long_enough_to_draft
    visit new_page_path # Can't use current_path as page refresh triggers form submit in CKEditor

    within_frame 0 do
      expect(page).not_to have_content('Astonishingly insightful content')
    end

    within_frame 1 do
      expect(page).not_to have_content('A subpage to match')
    end

    within_frame 2 do
      expect(page).to have_content('Astonishingly insightful content')
    end

    within_frame 3 do
      expect(page).to have_content('A subpage to match')
    end
  end
end
