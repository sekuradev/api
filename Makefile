BUF?=buf
PLANTUML?=plantuml

all: gen/python/sekura_grpc.py

gen:
	mkdir -p gen

doc:
	mkdir -p doc

gen/%: sekuraapi/v1/sekura.proto gen
	$(BUF) generate

doc/index.html: gen/openapiv2/sekuraapi/v1/sekura.swagger.yaml doc
	docker run --rm -w /local -v ${PWD}:/local openapitools/openapi-generator-cli generate -i /local/$< -g html2 -o /local/doc

doc/schemas.plantuml: gen/openapiv2/sekura/v1/sekura.swagger.yaml doc
	docker run --rm -w /local -v ${PWD}:/local openapitools/openapi-generator-cli generate -i /local/$< -g plantuml -o /local/doc

doc/schemas.png: doc/schemas.plantuml
	$(PLANTUML) $<

.PHONY: documentation
documentation: doc/index.html doc/schemas.plantuml doc/schemas.png

.PHONY: watch-doc
watch-doc:
	iwatch -c "PLANTUML=~/.local/bin/plantuml BUF=~/.local/bin/buf make documentation" -e close_write -t "sekura.proto" sekuraapi/v1

watch-lint:
	iwatch -c "~/.local/bin/buf lint" -e close_write -t "sekura.proto" sekuraapi/v1
