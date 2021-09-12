class FormsController < ApplicationController
  before_action :authenticate_user!
  
  before_action :set_form, only: %i[ show edit update destroy ]

  def index
    @search = Form.reverse_chronologically.ransack(params[:q])

    respond_to do |format|
      format.any(:html, :json) { @forms = set_page_and_extract_portion_from @search.result }
      format.csv { render csv: @search.result }
    end
  end

  def show
    fresh_when etag: @form
  end

  def new
    @form = Form.new
  end

  def edit
  end

  def create
    @form = Form.new(form_params)
    @form.save!

    respond_to do |format|
      format.html { redirect_to @form, notice: 'Form was successfully created.' }
      format.json { render :show, status: :created }
    end
  end

  def update
    @form.update!(form_params)
    respond_to do |format|
      format.html { redirect_to @form, notice: 'Form was successfully updated.' }
      format.json { render :show }
    end
  end

  def destroy
    @form.destroy
    respond_to do |format|
      format.html { redirect_to forms_url, notice: 'Form was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def set_form
      @form = Form.find(params[:id])
    end

    def form_params
      params.require(:form).permit(:name, :form_tutor)
    end
end
