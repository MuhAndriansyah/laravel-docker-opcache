#!/bin/sh
app=${CONTAINER_ROLE:-app}

php /var/www/html/artisan optimize

if [ ! -f "vendor/autoload.php" ]; then
    composer install --optimize-autoloader --no-interaction --no-progress
fi

if [ ! -f ".env" ]; then
    echo "Creating env file for env $APP_ENV"
    cp .env.example .env
else
    echo "env file exists."
fi

php artisan key:generate

if [ "$app" = "app" ]; then

    echo "Running the app..."
    /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf

elif [ "$app" = "queue" ]; then

    echo "Running the queue..."
    php artisan queue:work --queue=default --sleep=3 --tries=3

elif [ "$app" = "scheduler" ]; then

    echo "Running the scheduler..."
    php artisan schedule:work

else
    echo "Could not match the container app \"$app\""
    exit 1
fi
