require 'support/features/helpers'

module Features
end

RSpec.configure do |config|
  config.include Features::Helpers, type: :feature
end