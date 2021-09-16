#!/bin/bash
echo "Removing composer.lock..."
rm -rf composer.lock
echo "Running command..."
composer require $1:$2
echo "Cleaning up directories..."
rm -rf public/wp-content/themes
rm -rf public/wp-content/plugins
