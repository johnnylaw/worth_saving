require 'spec_helper'

FactoryGirl.define do
  factory :user do
    name 'John Doe'
  end

  factory :page do
    user
    title    'My Big Fat Greek Page'
    content  <<-EOS
Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt
ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco
laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in
voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat
cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
EOS
    approved    false
    page_type   'Front'
    position    'Left'
  end

  factory :subpage do
    page
    subtitle  'My Not-so-big Subtitle'
    content   'This is some content that goes in here.  Not a lot.'
  end

  factory :author do
    name 'Benjamin Franklin'
  end
end
