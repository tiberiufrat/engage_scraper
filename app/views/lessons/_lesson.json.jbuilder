json.extract! lesson, :id, :name, :weekday, :start_time, :end_time, :teacher, :room, :created_at, :updated_at, :user_id
json.url lessons_url(lesson, format: :json)
