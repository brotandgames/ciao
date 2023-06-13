# frozen_string_literal: true

class AddTlsExpiresInDaysToChecks < ActiveRecord::Migration[6.1]
  def change
    add_column :checks, :tls_expires_in_days, :integer
  end
end
