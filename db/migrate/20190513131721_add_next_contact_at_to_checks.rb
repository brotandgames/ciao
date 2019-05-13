class AddNextContactAtToChecks < ActiveRecord::Migration[6.0]
  def change
    add_column :checks, :next_contact_at, :datetime
  end
end
