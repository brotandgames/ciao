class AddActiveToChecks < ActiveRecord::Migration[6.0]
  def change
    add_column :checks, :active, :boolean
  end
end
