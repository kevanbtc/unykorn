.PHONY: test ci release
test: ; npm test
ci: test
release:
	@echo "Releasing project (placeholder)"
