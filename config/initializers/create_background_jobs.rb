# Create all Rufus Scheduler Jobs for active checks on Application Start
# Prevent the initializer to be run during rake tasks
if defined?(Rails::Server) && ActiveRecord::Base.connection.table_exists?('checks')
  Check.active.each do |check|
    check.create_job
  end
end
