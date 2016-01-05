# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Category.create(name: "Sports")
Category.create(name: "Entertainment")
Category.create(name: "Food")
Category.create(name: "Other")

5.times do |n|
  Challenge.create(
    images: "asdf",
    title: "hello",
    category_id: Faker::Number.between(1, 4),
    description: "how is it going")
end

# User.create!(name:  "Peyton Manning",
#              email: "goat@utk.edu",
#              password:              "manning",
#              password_confirmation: "manning",
#              admin: true)

100.times do |n|
  name = Faker::Name.name
  email = "example-#{n+1}@railstutorial.org"
  password = "password"
  User.create!(name:  name,
               email: email,
               password:              password,
               password_confirmation: password)
end
