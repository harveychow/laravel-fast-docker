# Laravel for Docker with fast builds
This Dockerfile makes optimal use of your Docker build cache. So you can deploy your projects faster without compromising your build.

The build is split in 4 parts:
1. Copy NPM files & download dependencies
2. Fetch PHP dependencies and build:
    * Copy composer files & download dependencies
    * Copy rest of project files & create composer autoload
3. Run NPM build
4. Build final container based on PHP + Apache

Basically what this setup does is leveraging Docker cache during build time by reusing previously built dependencies when there are no changes made to *composer* or *npm*. Usually when you're at a certain stage in development you make less changes to composer and npm, so it would be a waste of time and resources if you need to wait for the same dependencies each single build.

## How to use
1. Download this project
2. Put the files in the root of your Laravel project

## Notes
* You can change your desired PHP version by changing 7.3-apache to 7.x-apache
* You can change your desired NodeJS version by changing **both** node-12 to node-x
* Change the PHP extensions for composer build and and the webserver to your project requirements. These can sometime differ however. So for optimal build times and build size you should only include what's necessary.
* This setup is compatible with Laravel 5 and 6, but is not limited to Laravel. With minor changes you can use this for Symfony projects and other PHP projects as well.
* If your build is slow it might be because:
    * Your cache has been cleared by `docker system prune` or something similar.
    * You made changes to your *package.json* or *package-lock.json* which results in a rebuild.
    * You made changes to your *composer.json* or *composer.lock* which results in a rebuild after npm.