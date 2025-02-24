build:
	docker build -f Dockerfile -t test-cuda:noble .

run:
	docker run --runtime=nvidia test-cuda:noble /cuda-samples/Samples/0_Introduction/clock/build/clock

run-it:
	docker run -it --runtime=nvidia test-cuda:noble /bin/bash