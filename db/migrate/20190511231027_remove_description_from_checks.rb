class RemoveDescriptionFromChecks < ActiveRecord::Migration[6.0]
  def change

    remove_column :checks, :description, :text
  end
end
