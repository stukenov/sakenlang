build:
	raco exe -o sakenlang run.rkt

clean:
	rm -f sakenlang
	rm -rf compiled

.PHONY: build clean
