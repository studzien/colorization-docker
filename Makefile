.PHONY: build colorize

SHELL=bash
container=colorization
image=colorization
extension=$(suffix $(input))

build:
	docker build . -t $(image)

colorize:
	-docker rm $(container)
	docker run -ti --name $(container) -v $(input):/input$(extension) $(image) -img_in=/input$(extension) -img_out=/output$(extension) --rgb=False
	docker cp $(container):/output$(extension) $(output)
