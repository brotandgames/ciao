# frozen_string_literal: true

class AddTlsJobToChecks < ActiveRecord::Migration[6.1]
  def change
    add_column :checks, :tls_job, :string
  end
end
