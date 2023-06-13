# frozen_string_literal: true

class AddTlsExpiresAtToChecks < ActiveRecord::Migration[6.1]
  def change
    add_column :checks, :tls_expires_at, :datetime
    add_index :checks, :tls_expires_at
  end
end
