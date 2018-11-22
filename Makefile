PROJECT_NAME = threaded_pipeline
VOLUMES = -v $$PWD:/tmp/src -w /tmp/src

image:
	docker build -t $(PROJECT_NAME) .

shell: image
	docker run -it $(VOLUMES) $(PROJECT_NAME) sh

console: image
	docker run -it $(VOLUMES) $(PROJECT_NAME)

guard: image
	docker run -it $(VOLUMES) $(PROJECT_NAME) bundle exec guard -c
