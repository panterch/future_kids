# Contributing to Future Kids

Looking forward to contribute to future kids? Then please take a moment to review this document in order to make the contribution process easy and effective for everyone involved.

Here are some guidelines that needs to be followed:

## Pre-requisite
* Rails , preferable with rbenv wrapper
* Postgresql
* ImageMagick

## Issue Tracker

* Please be sure that you verify if there is any [issue](https://github.com/panterch/future_kids/issues) reported or fixed before reporting a new [issue](https://github.com/panterch/future_kids/issues).
* Please make sure that __clear title__ and __description__ is given while creating new issue.

## Installation Instructions and Pull Requests

Please follow the below process to share your contribution via PR.

1. [Fork](https://help.github.com/articles/fork-a-repo) the repository, and configure the remotes:
    ```
    # Clone your fork of the repo into the current directory
    git clone https://github.com/panterch/future_kids.git
    # Navigate to the newly cloned directory
    cd future_kids
    ```
2. After cloning, the ruby version is configured in .ruby-version, then its dependencies are installed as follows:
    ```
    bundle install
    bundle exec rake db:create 
    bundle exec rake db:migrate 
    bundle exec rake db:seed
    bundle exec rails server
    ```
3. Make your contributions.
4. [Open a Pull Request](https://help.github.com/articles/about-pull-requests/) with __clear title__ and __description__ against the _master_ branch.

__Note:__ It would be great to have an automated tests included and running test suite.
