PROJECT_NAME = threaded_pipeline
VOLUMES = -v $$PWD:/tmp/src -w /tmp/src
LOCAL_LINK=-v $(PWD):/tmp/src -w /tmp/src

image:
	rm -f Gemfile.lock
	docker build -t $(PROJECT_NAME) .

shell: image
	docker run -it $(VOLUMES) $(PROJECT_NAME) sh

console: image
	docker run -it $(VOLUMES) $(PROJECT_NAME)

guard: image
	docker run -it $(VOLUMES) $(PROJECT_NAME) bundle exec guard -c

doc: image
	docker run $(VOLUMES) $(PROJECT_NAME) yard
	open doc/index.html

test: image
	docker run $(VOLUMES) $(PROJECT_NAME) rake

test_jruby:
	rm -f Gemfile.lock
	docker run --rm $(VOLUMES) jruby bash -c "bundle -j 4 && rake"

test_multiple: test test_jruby

gem: image
	rm -f $(PROJECT_NAME)*.gem
	docker run $(LOCAL_LINK) $(PROJECT_NAME) gem build $(PROJECT_NAME)

# Requires rubygems be installed on host
gem_release: gem
	gem push $(PROJECT_NAME)*.gem
