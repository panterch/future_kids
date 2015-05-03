#!/bin/sh

bundle exec cap staging deploy:migrations
bundle exec cap aoz deploy:migrations
bundle exec cap phtg deploy:migrations
