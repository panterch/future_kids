#!/bin/sh

bundle exec cap staging deploy:
bundle exec cap aoz deploy
bundle exec cap phtg deploy
