def log_in(user, options={})
  visit "/user_profiles/sign_in"
  fill_in "user_profile_email", :with => user.email
  fill_in "user_profile_password", :with => user.password
  click_button "Login"
  user
end
