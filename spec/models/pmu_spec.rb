require 'spec_helper'

describe Pmu do
  it 'has a valid factory' do
      FactoryGirl.create(:pmu).should be_valid
  end

  before do
      @attendee = FactoryGirl.create(:pmu)
      @driver = FactoryGirl.create(:pmu, pmu_type: 'car sharing')
  end

  subject { @attendee }

  # Test default values
  its(:pmu_type) {should == "uncommitted"}
  its(:completed) {should == false}

end
