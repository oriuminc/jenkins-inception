desc "Programmatically sign up for a free Hosted Chef server with Opscode."
task :opscode_signup do
  require 'highline/import'

  form_fields = %w{
    user_first_name
    user_last_name
    user_unique_name
    user_email_address
    user_company
    user_country
    user_state
    user_phone_number
    user_password
    user_password_confirmation
  }

  form_values = {}
  form_fields.each do |field|
    form_values[field] = ask("Enter your #{field.gsub('user_', '').gsub('_', ' ')}:  ") do |q|
      q.echo = true
    end
  end

  require 'watir-webdriver'
  b = Watir::Browser.new
  b.goto 'https://community.opscode.com/users/new'
  form_values.each do |id, value|
    b.text_field(:id => id).set value
  end
  b.element.h2(:class => 'captcha').wd.location_once_scrolled_into_view
  b.checkbox(:id => 'accept_terms_of_service').set

  captcha = ask("What does the CAPTCHA in the browser say?  ") do |q|
    q.echo = true
  end
  b.text_field(:id => 'recaptcha_response_field').set captcha

  b.button(:id => 'submit').click

  #if b.text.include? "Username has already been taken" do
  #  form_values['user_unique_name'] = ask("Username already taken. Please try another:  ") do |q|
  #    q.echo = true
  #  end
  #  b.button(:id => 'submit').click
  #end

end
