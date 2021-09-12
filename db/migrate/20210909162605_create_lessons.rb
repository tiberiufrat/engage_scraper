class CreateLessons < ActiveRecord::Migration[6.1]
  def change
    create_table :lessons do |t|
      t.string :name
      t.string :weekday
      t.string :start_time
      t.string :end_time
      t.string :teacher
      t.string :room

      t.timestamps
    end
  end
end
