require "rails_helper"

RSpec.describe User, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_presence_of(:last_name) }
    it { is_expected.to validate_presence_of(:email) }
  end

  describe "associations" do
    it { is_expected.to have_many(:team_memberships).dependent(:destroy) }
    it { is_expected.to have_many(:teams).through(:team_memberships) }
    it { is_expected.to have_many(:created_jobs) }
  end

  describe "#full_name" do
    it "returns first and last name" do
      user = build(:user, first_name: "John", last_name: "Doe")
      expect(user.full_name).to eq("John Doe")
    end
  end

  describe "#role_in" do
    let(:user) { create(:user) }
    let(:team) { create(:team) }

    it "returns the role for the team" do
      create(:team_membership, user: user, team: team, role: "admin")
      expect(user.role_in(team)).to eq("admin")
    end

    it "returns nil when not a member" do
      expect(user.role_in(team)).to be_nil
    end
  end
end
