# frozen_string_literal: true

# Create all Rufus Scheduler Jobs for active checks on Application Start
# Prevent the initializer to be run during rake tasks

Rails.application.config.after_initialize do
  if defined?(Rails::Server) && ActiveRecord::Base.connection.table_exists?("checks")
    Check.active.each(&:create_job)
    Check.active.each(&:create_tls_job)
  end
end
