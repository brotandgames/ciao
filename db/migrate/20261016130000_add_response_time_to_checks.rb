# frozen_string_literal: true

class AddResponseTimeToChecks < ActiveRecord::Migration[8.1]
  def change
    # Duration of the last HTTP request in seconds, nil on errors
    add_column :checks, :response_time, :float
  end
end
