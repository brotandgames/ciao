# Create all Rufus Scheduler Jobs for active checks on Application Start
Check.active.each do |check|
  check.create_job
end
