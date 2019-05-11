class AddStatusToChecks < ActiveRecord::Migration[6.0]
  def change
    add_column :checks, :status, :string
  end
end
