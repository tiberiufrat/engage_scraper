require "application_system_test_case"

class FormsTest < ApplicationSystemTestCase
  setup do
    @form = forms(:one)
  end

  test "visiting the index" do
    visit forms_url
    assert_selector "h1", text: "Forms"
  end

  test "creating a Form" do
    visit forms_url
    click_on "New Form"

    fill_in "Form tutor", with: @form.form_tutor
    fill_in "Name", with: @form.name
    click_on "Create Form"

    assert_text "Form was successfully created."
    click_on "Back"
  end

  test "updating a Form" do
    visit forms_url
    click_on "Edit it", match: :first

    fill_in "Form tutor", with: @form.form_tutor
    fill_in "Name", with: @form.name
    click_on "Update Form"

    assert_text "Form was successfully updated."
    click_on "Back"
  end

  test "destroying a Form" do
    visit forms_url
    page.accept_confirm do
      click_on "Destroy it", match: :first
    end

    assert_text "Form was successfully destroyed."
  end
end
