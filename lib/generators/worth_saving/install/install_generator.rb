require 'rails/generators'
require 'rails/generators/migration'

module WorthSaving
  module Generators
    class InstallGenerator < ::Rails::Generators::Base
      include Rails::Generators::Migration

      def self.next_migration_number(*args)
        Time.now.utc.strftime("%Y%m%d%H%M%S").to_i.to_s
      end

      desc <<DESC
Description:
    Create worth_saving model and migration in your app.

DESC

      def self.source_root
        @source_root ||= File.expand_path(File.join(File.dirname(__FILE__), 'templates'))
      end

      def copy_model
        copy_file 'worth_saving_draft.rb', 'app/models/worth_saving_draft.rb'
      end

      def generate_migration
        migration_template 'create_worth_saving_drafts.rb', 'db/migrate/create_worth_saving_drafts.rb'
      end
    end
  end
end
