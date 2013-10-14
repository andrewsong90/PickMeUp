require 'spec_helper'

describe Organizer do

  before do
    @organizer = Organizer.new(email: "rails@example.com",
                                password: 'goodjob',
                                password_confirmation: 'goodjob')
  end

  subject { @organizer }

  it { should respond_to(:email) }
  it { should respond_to(:password_digest) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }
  it { should be_valid }

  describe "when email is not present" do
    before { @organizer.email = " " }
    it { should_not be_valid }
  end

  describe "when email address is already taken and not case sensitive" do
    before do
      organizer_with_same_email = @organizer.dup
      organizer_with_same_email.email = @organizer.email.upcase
      organizer_with_same_email.save
    end
    it {should_not be_valid}
  end

  describe "when password is not present" do
    before { @organizer.password = @organizer.password_confirmation = " " }
    it { should_not be_valid }
  end

  describe "when password is shorter than six characters" do
    before { @organizer.password = 'abcde' }
    it { should_not be_valid }
  end

  describe "when password doesn't match confirmation" do
    before { @organizer.password_confirmation = "mismatch" }
    it { should_not be_valid }
  end

  describe "when password confirmation is nil" do
    before { @organizer.password_confirmation = nil }
    it { should_not be_valid }
  end

end
