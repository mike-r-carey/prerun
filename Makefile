#!/usr/bin/env make

.PHONY: test

test:
	@which bats
	bats tests/*.bats

# prerun.Makefile
