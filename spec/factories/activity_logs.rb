FactoryBot.define do
  factory :activity_log do
    team
    user
    action { "test.action" }
    metadata { {} }
  end
end
