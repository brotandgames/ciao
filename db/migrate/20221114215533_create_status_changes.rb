# frozen_string_literal: true

class CreateStatusChanges < ActiveRecord::Migration[6.1]
  def change
    create_table :status_changes do |t|
      t.string :status
      t.references :check, null: false, foreign_key: true

      t.timestamps
    end
  end
end
