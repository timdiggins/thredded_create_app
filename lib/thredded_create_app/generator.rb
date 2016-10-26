# frozen_string_literal: true
require 'fileutils'
require 'thredded_create_app/tasks/base'
require 'thredded_create_app/tasks/create_rails_app'
module ThreddedCreateApp
  class Generator < Tasks::Base

    def initialize(**options)
      super
      @options = options
    end

    def summary
      tasks.map { |t| "* #{t.summary}" }.join("\n")
    end

    def generate
      log_verbose "Started: #{inspect}"
      FileUtils.mkdir_p(app_path)
      Bundler.with_clean_env do
        Dir.chdir(app_path) do
          run 'git init .'
          @tasks.each(&:before_bundle)
          bundle
          @tasks.each(&:after_bundle)
        end
      end
    end

    private

    def tasks
      @tasks ||= [
          Tasks::CreateRailsApp,
          # Tasks::AddDevise,
          # Tasks::AddThredded,
          # Tasks::AddRailsEmailPreview,
          # Tasks::AddI18nTasks,
          # Tasks::SetupDatabase
      ].map { |task_class| task_class.new(@options) }
    end

    def gems
      tasks.flat_map(&:gems)
    end

    # @final
    def bundle
      File.open('Gemfile', 'a') do |f|
        log_info 'Writing gems to Gemfile'
        gems.each do |(name, version, groups)|
          f.puts ["gem '#{name}'",
                  (version if version),
                  ("groups: %i(#{groups * ' '})" if groups)].compact.join(', ')
        end
        run 'bundle install --quiet'
      end
      git_commit "Add gems: #{gems.map { |(name, *)| name } * ', '}"
    end
  end
end
