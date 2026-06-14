require "rails_helper"

RSpec.describe Team, type: :model do
  describe "validations" do
    subject { build(:team) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:slug) }
    it { is_expected.to validate_uniqueness_of(:slug) }
  end

  describe "associations" do
    it { is_expected.to have_many(:team_memberships).dependent(:destroy) }
    it { is_expected.to have_many(:users).through(:team_memberships) }
    it { is_expected.to have_many(:jobs).dependent(:destroy) }
    it { is_expected.to have_many(:candidates).dependent(:destroy) }
    it { is_expected.to have_many(:activity_logs).dependent(:destroy) }
  end

  describe "#generate_slug" do
    it "generates slug from name on create" do
      team = create(:team, name: "My Awesome Team")
      expect(team.slug).to eq("my-awesome-team")
    end
  end
end
