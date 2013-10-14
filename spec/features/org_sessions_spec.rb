require 'spec_helper'


  describe "OrgSessions", 'simulate sign up and log in activity', :js => true do
    self.use_transactional_fixtures = false

    it 'creates/deletes sessions for organizers and redirects to root' do
      Capybara.default_wait_time = 5
      Capybara.reset_sessions!
      @organizer = FactoryGirl.create(:organizer)

      #Failed log-in
      visit root_path
      find("#root_log_in").click
      find("#organizer_log_in").click
      within "#login_form" do
        fill_in 'email', with: @organizer.email
        fill_in 'password', with: 'wrong password'
      end
      find("#login_button").click
      current_path.should eq(root_path)
      page.should have_content("Email or password is invalid")

      # Successful log-in
      visit root_path
      find("#root_log_in").click
      find("#organizer_log_in").click
      within "#login_form" do
          fill_in 'email', with: @organizer.email
          fill_in 'password', with: @organizer.password
      end
      find("#login_button").click
      current_path.should eq(root_path)
      page.should have_content("Logged in!")

      # Successful log-out
      visit org_logout_path
      current_path.should eq(root_path)
      page.should have_content("Logged out!")

    end
end
