# frozen_string_literal: true
require 'thredded_create_app/tasks/base'
module ThreddedCreateApp
  module Tasks
    class CreateRailsApp < Base
      def summary
        "Create Rails app #{app_name.inspect} with postgresql and rspec"
      end

      def before_bundle
        run 'gem update --system --no-document --quiet'
        run 'gem install bundler rails --no-document'
        run 'rails new . --skip-bundle --database=postgresql ' \
           '--skip-test --quiet'
        add_gem 'rspec-rails', groups: %i(test)
        git_commit summary
      end

      def after_bundle
        run 'bundle exec rails g rspec:install --quiet'
        git_commit 'rails g rspec:install'
      end
    end
  end
end