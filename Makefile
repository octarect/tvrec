INVENTORY_FILE ?= generator.yml

.PHONY: new-overlay
new-overlay:
ifndef OVERLAY_NAME
	$(error OVERLAY_NAME is undefined)
endif
	$(info generating k8s/overlays/$(OVERLAY_NAME))
	@mkdir -p k8s/overlays/$(OVERLAY_NAME)
	@docker run --rm \
		-v $(PWD)/scripts/templates:/templates \
		-v $(PWD):/work \
		dinutac/jinja2docker:latest \
		/templates/k8s-overlays-kustomization.yaml.j2 \
		/work/$(INVENTORY_FILE) --format=yaml \
		> k8s/overlays/$(OVERLAY_NAME)/kustomization.yaml
