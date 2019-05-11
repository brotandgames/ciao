class CreateChecks < ActiveRecord::Migration[6.0]
  def change
    create_table :checks do |t|
      t.string :name
      t.text :description
      t.string :cron

      t.timestamps
    end
  end
end
