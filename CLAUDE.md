# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Future Kids is a Rails 7 application that manages a mentoring program connecting university students (mentors) with primary school children who need academic support. The application tracks mentor-kid relationships, schedules, journal entries, assessments, and communications.

## Key Commands

### Development
- `bundle install` - Install Ruby gems
- `bin/rails server` - Start development server (port 3000)
- `bin/rails console` - Open Rails console
- `bin/rails db:migrate` - Run database migrations
- `bin/rails db:seed` - Seed database with initial data

### Testing
- `bundle exec rspec` - Run all RSpec tests
- `bundle exec rspec spec/models/` - Run model tests only
- `bundle exec rubocop` - Run Ruby linter/formatter

### Asset Management
- Assets are compiled using Sprockets with SCSS and CoffeeScript
- JavaScript components use React (via react-rails gem)
- Run `bin/rails assets:precompile` for production builds

## Architecture Overview

### Core Models & Relationships
- **User** (STI base class) → **Mentor**, **Teacher**, **Principal**, **Admin**
- **Kid** - Central model representing students needing support
- **School** - Educational institutions where kids attend
- **KidMentorRelation** - Manages mentor-student assignments
- **Journal** - Weekly meeting logs between mentors and kids
- **Schedule** - Polymorphic model for person availability
- **Review**/**Assessment** - Evaluation forms (first year, termination)

### Key Associations
- Kids can have primary/secondary mentors and teachers
- Mentors belong to schools and have many kids
- Journals track weekly meetings with duration and goals
- Schedules are polymorphic (attached to mentors or kids)
- MentorMatching handles mentor assignment workflow

### Authentication & Authorization
- Devise for authentication
- CanCanCan for role-based authorization via Ability model
- Different user types (Admin, Mentor, Teacher, Principal) have distinct permissions

### Key Features
- **Mentor-Kid Matching**: Algorithm-based assignment system
- **Journal Tracking**: Weekly meeting documentation with goals/progress
- **Schedule Management**: Availability coordination between mentors/kids
- **Assessment System**: First-year and termination evaluations
- **Multi-language Support**: German localization (primary language)
- **Geolocation**: Address geocoding for mentor-kid proximity matching

### File Structure
- `/app/models/` - Core domain models with business logic
- `/app/controllers/` - RESTful controllers with concern modules
- `/app/views/` - HAML templates with responsive Bootstrap styling
- `/spec/` - RSpec test suite with FactoryBot factories
- `/config/routes.rb` - Nested resource routing structure

### Important Patterns
- Single Table Inheritance (STI) for User types
- Polymorphic associations for Schedules
- Validation concerns and callbacks for data integrity
- Excel export functionality via Axlsx gem
- Phone number validation for Swiss formats only

## Database
- PostgreSQL in production
- Uses Rails migrations and ActiveRecord ORM
- Geographic data stored for distance calculations
- Soft deletion patterns (inactive flags rather than hard deletes)