PROJECT_NAME = threaded_pipeline
VOLUMES = -v $$PWD:/tmp/src -w /tmp/src

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
	docker run $(VOLUMES) $(PROJECT_NAME) yard

test_multiple:
	rm -f Gemfile.lock
	docker run --rm $(VOLUMES) ruby bash -c "bundle -j 4 && rake"
	rm -f Gemfile.lock
	docker run --rm $(VOLUMES) jruby bash -c "bundle -j 4 && rake"
