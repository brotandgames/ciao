# frozen_string_literal: true

# Create all Rufus Scheduler Jobs for active checks on Application Start
# Prevent the initializer to be run during rake tasks

if defined?(Rails::Server) && ActiveRecord::Base.connection.table_exists?('checks') # rubocop:disable Style/IfUnlessModifier
  Check.active.each(&:create_job)
end
