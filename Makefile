RAILS_ENV = test
BUNDLE = RAILS_ENV=${RAILS_ENV} bundle
BUNDLE_OPTIONS = -j 2
RSPEC = rspec

all: test

test: bundler/install
	${BUNDLE} exec ${RSPEC} spec 2>&1

bundler/install:
	if ! gem list bundler -i > /dev/null; then \
	  gem install bundler; \
	fi
	${BUNDLE} install ${BUNDLE_OPTIONS}
