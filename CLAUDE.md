# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Future Kids is a Rails 8 application that manages a mentoring program connecting university students (mentors) with primary school children who need academic support. The application tracks mentor-kid relationships, schedules, journal entries, assessments, and communications.

## Key Commands

### Development
- `bundle install` - Install Ruby gems
- `bin/dev` - Start development server (port 3000) plus the SCSS watcher (`bin/rails server` alone won't recompile stylesheets, see Procfile.dev)
- `bin/rails console` - Open Rails console
- `bin/rails db:migrate` - Run database migrations
- `bin/rails db:seed` - Seed database with initial data

### Testing
- `bundle exec rspec` - Run all RSpec tests
- `bundle exec rspec spec/models/` - Run model tests only
- `bundle exec rubocop` - Run Ruby linter/formatter

### Asset Management
- Assets are served by Propshaft; SCSS (`app/assets/stylesheets/`) is compiled by dartsass-rails
- The one React component (kid_mentor_schedules.js) uses vendored React via importmap, written with htm (no JSX)
- Run `bin/rails assets:precompile` for production builds

## Architecture Overview

### Core Models & Relationships
- **User** (STI base class) → **Mentor**, **Teacher**, **Principal**, **Admin**
- **Kid** - Central model representing students needing support
- **School** - Educational institutions where kids attend
- **KidMentorRelation** - Read-only model backed by an SQL view, used to filter kid/mentor relations (assignment itself is the `mentor`/`secondary_mentor` columns on Kid)
- **RelationLog** - History of mentor/teacher assignment changes per kid
- **Journal** - Weekly meeting logs between mentors and kids; **Comment** - comments on journals (sends notifications)
- **Schedule** - Polymorphic model for person availability
- **Review** - Conversations/check-ins about a kid; **FirstYearAssessment**/**TerminationAssessment** - evaluation forms
- **Substitution** - Temporary replacement mentor for a kid
- **Reminder** - Missing-journal reminders for mentors
- **Document** (+ **DocumentTreeview**) - Uploaded files organised in a category tree
- **PrincipalSchoolRelation** - Principals ↔ schools
- **Site** - Singleton (`Site.load`) for per-deployment settings: logo, texts, AI provider config (encrypted token)

### Key Associations
- Kids have a `mentor` and `secondary_mentor`, up to three teachers (`teacher`, `secondary_teacher`, `third_teacher`), an `admin` and a `school`
- Mentors belong to schools and have many kids
- Journals track weekly meetings with duration and goals
- Schedules are polymorphic (attached to mentors or kids)

### Authentication & Authorization
- Devise for authentication
- CanCanCan for role-based authorization via Ability model
- Different user types (Admin, Mentor, Teacher, Principal) have distinct permissions

### Key Features
- **Mentor-Kid Assignment**: Manual assignment by admins, logged in RelationLog
- **Journal Tracking**: Weekly meeting documentation with goals/progress
- **Schedule Management**: Availability coordination between mentors/kids
- **Assessment System**: First-year and termination evaluations
- **Multi-language Support**: German localization (primary language)
- **AI Kid Summaries**: `JournalSummarizer` (`app/services/`) sends a kid's markdown profile (`kids/show.md.erb`, also at `/kids/:id.md`) to an OpenAI-compatible API configured per Site. Real names are replaced by placeholders via `NameRedactor`/`PersonDictionary` before sending and restored afterwards; `/kids/:id.md?redacted=true` previews what is sent
- **File uploads**: Active Storage for user photos, the site logo and documents (photos/logo served as resized, metadata-stripped variants)

### File Structure
- `/app/models/` - Core domain models with business logic
- `/app/controllers/` - RESTful controllers with concern modules
- `/app/services/` - Service objects (AI summary, name redaction)
- `/app/views/` - HAML templates with responsive Bootstrap styling
- `/spec/` - RSpec test suite with FactoryBot factories
- `/config/routes.rb` - Nested resource routing structure

### Important Patterns
- Single Table Inheritance (STI) for User types
- Polymorphic associations for Schedules
- Validation concerns and callbacks for data integrity
- Excel export via caxlsx / caxlsx_rails

## Database
- PostgreSQL in production
- Uses Rails migrations and ActiveRecord ORM
- Soft deletion patterns (inactive flags rather than hard deletes)