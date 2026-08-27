puts "Seeding database..."

admin = User.find_or_create_by!(name: "admin") do |u|
  u.password = "admin123"
  u.password_confirmation = "admin123"
  u.role = "admin"
end

user1 = User.find_or_create_by!(name: "alice") do |u|
  u.password = "password123"
  u.password_confirmation = "password123"
  u.role = "user"
end

User.find_or_create_by!(name: "bob") do |u|
  u.password = "password123"
  u.password_confirmation = "password123"
  u.role = "user"
end

note1 = Note.find_or_create_by!(title: "Welcome Note", user: admin) do |n|
  n.content = "<p>Welcome to Notes App! This is a sample note.</p>"
end

Note.find_or_create_by!(title: "Alice's First Note", user: user1) do |n|
  n.content = "<p>Hello, I'm Alice and this is my first note.</p>"
end

Collection.find_or_create_by!(title: "Getting Started", user: admin) do |c|
  c.note_ids = [note1.id]
end

puts "Seeded: #{User.count} users, #{Note.count} notes, #{Collection.count} collections"
