FROM ruby:2-alpine

# Add command line argument variables used to cusomise the image at build-time.
ARG ETSY_API_KEY
ARG ETSY_API_SECRET
ARG SECRET_KEY_BASE
ARG AIRBRAKE_PROJECT_ID
ARG AIRBRAKE_PROJECT_KEY
ARG FORCE_SSL
ARG RACK_ENV=production

# Add Gemfiles.
ADD Gemfile /app/
ADD Gemfile.lock /app/


# Set the working DIR.
WORKDIR /app

# Install system and application dependencies.
RUN echo "Environment (RACK_ENV): $RACK_ENV" && \
    apk --update add --virtual build-dependencies build-base ruby-dev nodejs && \
    gem install bundler --no-ri --no-rdoc && \
    if [ "$RACK_ENV" == "production" ]; then \
      bundle install --without development test --path vendor/bundle; \
      apk del build-dependencies; \
    else \
      bundle install --path vendor/bundle; \
    fi

# Copy the application onto our image.
ADD . /app

# Make sure our user owns the application directory.
RUN if [ "$RACK_ENV" == "production" ]; then \
      chown -R nobody:nogroup /app; \
    else \
      chown -R nobody:nogroup /app /usr/local/bundle; \
    fi

# Set up our user and environment
USER nobody
ENV ETSY_API_KEY $ETSY_API_KEY
ENV ETSY_API_SECRET $ETSY_API_SECRET
ENV SECRET_KEY_BASE $SECRET_KEY_BASE
ENV AIRBRAKE_PROJECT_ID $AIRBRAKE_PROJECT_ID
ENV AIRBRAKE_PROJECT_KEY $AIRBRAKE_PROJECT_KEY
ENV FORCE_SSL $FORCE_SSL
ENV RACK_ENV $RACK_ENV

# Precompile assets
RUN bundle exec rails assets:precompile

# Add additional labels to our image
ARG GIT_SHA=unknown
ARG GIT_TAG=unknown
LABEL git-sha=$GIT_SHA \
	    git-tag=$GIT_TAG \
	    rack-env=$RACK_ENV \
	    maintainer=hello@rayner.io

# Expose port 3000
EXPOSE 3000

# Launch puma
CMD ["bundle", "exec", "rails", "s", "-b", "0.0.0.0"]