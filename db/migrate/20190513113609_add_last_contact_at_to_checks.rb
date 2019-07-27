# frozen_string_literal: true

class AddLastContactAtToChecks < ActiveRecord::Migration[6.0]
  def change
    add_column :checks, :last_contact_at, :datetime
  end
end
