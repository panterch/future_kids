# Contributing to Future Kids

Looking forward to contributing to Future Kids? Then please take a moment to review this document, it keeps the contribution process easy and effective for everyone involved.

## Prerequisites

* Ruby in the version given in `.ruby-version`, for example installed with rbenv
* PostgreSQL
* libvips (image variants)

## Issue Tracker

* Before reporting a new [issue](https://github.com/panterch/future_kids/issues), please check whether it has already been reported or fixed.
* Please give a new issue a __clear title__ and __description__.

## Setup

1. Clone the repository. Without write access, [fork](https://help.github.com/articles/fork-a-repo) it first and clone your fork instead:
    ```
    git clone https://github.com/panterch/future_kids.git
    cd future_kids
    ```
2. Install the dependencies, create and seed the database and start the app:
    ```
    bin/setup
    ```
    The script can be run again at any time, for example after pulling changes. It ends by starting the development server (`bin/dev`, port 3000); pass `--skip-server` to leave that out. The seeds create a few sample users to sign in with, see `db/seeds.rb`.

## Tests

1. Initialize the test database:
    ```
    bin/rails db:test:prepare
    ```
2. Run the specs:
    ```
    bundle exec rspec
    ```

Please add or adapt specs for what you change.

## Pull Requests

[Open a Pull Request](https://help.github.com/articles/about-pull-requests/) with a __clear title__ and __description__ against the _develop_ branch.
