class CreateNotes < ActiveRecord::Migration
  def change
    create_table :notes do |t|
      t.text :body, null: false
      t.references :noteable, polymorphic: true, index: true

      t.timestamps null: false
    end
  end
end
