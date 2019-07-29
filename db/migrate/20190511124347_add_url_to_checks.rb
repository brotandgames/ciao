# frozen_string_literal: true

class AddUrlToChecks < ActiveRecord::Migration[6.0]
  def change
    add_column :checks, :url, :string
  end
end
