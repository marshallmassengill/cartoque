require 'spec_helper'

describe User do
  before do
    @user = Factory(:user)
  end

  describe "#settings" do
    it "should always be a hash" do
      @user.update_attribute(:settings, nil)
      @user.reload.settings.should eq Hash.new
    end

    it "should serialize settings" do
      hsh = { :a => "b" }
      @user.settings = hsh
      @user.save
      @user.reload.settings.should eq hsh
    end
  end

  describe "#set_setting" do
    it "should set a setting (without saving the user)" do
      @user.settings.should be_blank
      @user.set_setting(:a, "b")
      @user.save
      @user.reload.settings[:a].should eq "b"
    end
  end

  describe "#update_setting" do
    it "should set a setting and save the user" do
      @user.settings.should be_blank
      @user.update_setting(:a, "b")
      @user.reload.settings[:a].should eq "b"
    end
  end

  describe "#seen_now!" do
    it "should update seen_on column" do
      @user.seen_on.should be_blank
      @user.seen_now!
      @user.seen_on.should_not be_blank
      @user.seen_on.should be_a Date
      (Date.today - @user.seen_on).should be < 2
    end
  end
end
