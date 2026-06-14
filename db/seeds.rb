team = Team.create!(name: "Demo Company", slug: "demo-company")

admin = User.create!(
  email: "admin@hireflow.io",
  password: "password123",
  password_confirmation: "password123",
  first_name: "Admin",
  last_name: "User"
)

TeamMembership.create!(user: admin, team: team, role: "owner")

recruiter = User.create!(
  email: "recruiter@hireflow.io",
  password: "password123",
  password_confirmation: "password123",
  first_name: "Sarah",
  last_name: "Recruiter"
)

TeamMembership.create!(user: recruiter, team: team, role: "recruiter")

job = Job.create!(
  team: team,
  creator: admin,
  title: "Senior Software Engineer",
  description: "We're looking for an experienced engineer to join our team.",
  department: "Engineering",
  location: "Remote",
  employment_type: "full_time"
)

Seeds::DefaultStages.create_for(job)

first_stage = job.current_stages.first

3.times do |i|
  Candidate.create!(
    job: job,
    team: team,
    stage: first_stage,
    first_name: "Candidate#{i + 1}",
    last_name: "Test",
    email: "candidate#{i + 1}@example.com",
    source: "LinkedIn",
    pipeline_version: job.pipeline_version
  )
end

puts "Seed data created successfully!"
puts "Admin login: admin@hireflow.io / password123"
puts "Recruiter login: recruiter@hireflow.io / password123"
