class LessonsController < ApplicationController
  before_action :set_lesson, only: %i[ show edit update destroy ]

  def index
    if params[:teacher].present?
      @lessons = Lesson.where({ teacher: params[:teacher] })

      respond_to do |format|
        format.any(:html, :json) { @lessons }
        format.csv { render csv: @lessons }
      end
    elsif params[:room].present?
      @lessons = Lesson.where({ room: params[:room] })

      respond_to do |format|
        format.any(:html, :json) { @lessons }
        format.csv { render csv: @lessons }
      end
    else
      @search = Lesson.reverse_chronologically.ransack(params[:q])

      respond_to do |format|
        format.any(:html, :json) { @lessons = set_page_and_extract_portion_from @search.result }
        format.csv { render csv: @search.result }
      end
    end
  end

  def show
    fresh_when etag: @lesson
  end

  def new
    @lesson = Lesson.new
  end

  def edit
  end

  def create
    @lesson = Lesson.new(lesson_params)
    @lesson.save!

    respond_to do |format|
      format.html { redirect_to @lesson, notice: 'Lesson was successfully created.' }
      format.json { render :show, status: :created }
    end
  end

  def update
    @lesson.update!(lesson_params)
    respond_to do |format|
      format.html { redirect_to @lesson, notice: 'Lesson was successfully updated.' }
      format.json { render :show }
    end
  end

  def destroy
    @lesson.destroy
    respond_to do |format|
      format.html { redirect_to lessons_url, notice: 'Lesson was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def set_lesson
      @lesson = Lesson.find(params[:id])
    end

    def lesson_params
      params.require(:lesson).permit(:name, :weekday, :start_time, :end_time, :teacher, :room)
    end
end
