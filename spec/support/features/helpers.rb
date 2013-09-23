module Features
  module Helpers
    class FormInput < Struct.new(:label, :dom_id, :value); end

    def create_reasonable_browswer_size
      page.driver.browser.manage.window.resize_to(1000, 800)
    end

    def login(user)
      visit login_path(user)
      create_reasonable_browswer_size
    end

    def logout
      visit logout_path
      create_reasonable_browswer_size
    end

    def given_user(name)
      FactoryGirl.create :user, name: name
    end

    def fill_in_form(opts = {})
      form_factory(opts).each do |input|
        case input.label
        when 'Approved'
          input.value ? check('Approved') : uncheck('Approved')
        when 'Page type'
          choose input.value
        when 'Position'
          select input.value
        else
          fill_in input.label, with: input.value
        end
      end
    end

    def verify_form(opts = {}, recovered = false)
      recovered = recovered ? 'recovered_' : ''
      form_factory(opts).each do |input|
        case input.label
        when 'Approved'
          input.value ?
            expect(page.find("##{recovered}page_approved")).to(be_checked) :
            expect(page.find("##{recovered}page_approved")).not_to(be_checked)
        when 'Page type'
          if input.value == 'Front'
            expect(page.find("##{recovered}page_page_type_front")).to(be_checked)
            expect(page.find("##{recovered}page_page_type_inner")).not_to(be_checked)
          else
            expect(page.find("##{recovered}page_page_type_front")).not_to(be_checked)
            expect(page.find("##{recovered}page_page_type_inner")).to(be_checked)
          end
        when 'Position'
          expect(page.find("##{recovered}page_position").value).to eq input.value
        else
          expect(page.find("##{recovered}#{input.dom_id}").value).to eq input.value
        end
      end
    end

    def verify_blank_form(recovered = false)
      recovered = recovered ? 'recovered_' : ''
      expect(page.find("##{recovered}page_title").value).to eq ''
      expect(page.find("##{recovered}page_content").value).to eq ''
      expect(page.find("##{recovered}page_subpages_attributes_0_subtitle").value).to eq ''
      expect(page.find("##{recovered}page_subpages_attributes_0_content").value).to eq ''
      expect(page.find("##{recovered}page_position").value).to eq ''
      expect(page.find("##{recovered}page_approved")).not_to be_checked
      expect(page.find("##{recovered}page_page_type_front")).not_to be_checked
      expect(page.find("##{recovered}page_page_type_inner")).not_to be_checked
    end

    def chill_out_long_enough_to_draft
      sleep(find('form')['data-worth-saving-interval'].to_i + 0.5)
    end

    private

    def form_factory(opts)
      [
        FormInput.new('Title', 'page_title',                 opts['Title'] || 'My Big Fat Title'),
        FormInput.new('Content', 'page_content',             opts['Content'] || 'Some page content to save...'),
        FormInput.new('Subtitle', 'page_subpages_attributes_0_subtitle',
                                                             opts['Subtitle'] || 'My Not-so-big Subtitle'),
        FormInput.new('Subpage content', 'page_subpages_attributes_0_content',
                                                             opts['Subpage content'] || 'Some subpage content here...'),
        FormInput.new('Approved', 'page_approved',           opts['Approved'] || true),
        FormInput.new('Page type', 'page_page_type',         opts['Page type'] || 'Front'),
        FormInput.new('Position', 'page_position',           opts['Position'] || 'Left')
      ]
    end
  end
end