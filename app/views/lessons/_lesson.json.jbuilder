json.extract! lesson, :id, :name, :weekday, :start_time, :end_time, :teacher, :room, :created_at, :updated_at
json.url lesson_url(lesson, format: :json)
