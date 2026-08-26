# Notes App

A Ruby on Rails application for managing notes with collections, friend sharing, and notification-based collaboration.

## Tech Stack

- **Ruby** 3.3.0
- **Rails** 7.1.3.2
- **Database** MongoDB (via Mongoid 8.1.5)
- **Frontend** Bootstrap 5, Hotwire (Turbo + Stimulus), TinyMCE 7
- **Auth** Custom session-based with bcrypt
- **File Uploads** CarrierWave
- **Container** Docker + docker-compose

## Requirements

- Ruby 3.3.0
- MongoDB 7+ (local or MongoDB Atlas)

## Local Setup

```bash
git clone <repo-url>
cd WebSystemsLab
bundle install
cp .env.example .env
# Edit .env with your MongoDB URI
bin/rails server
```

## Docker Setup

```bash
docker-compose up
```

## Testing

```bash
bin/rails test
```

## Code Quality

```bash
bundle exec rubocop
bundle exec brakeman
```
