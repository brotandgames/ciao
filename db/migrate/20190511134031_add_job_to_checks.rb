class AddJobToChecks < ActiveRecord::Migration[6.0]
  def change
    add_column :checks, :job, :string
  end
end
