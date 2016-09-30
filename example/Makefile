REBAR ?= ./rebar3

top:
	$(REBAR) compile
	../escriptize example

clean:
	$(REBAR) clean
	-rm rebar.lock
	-rm -rf _build
	-rm example
	-rm -rf .example
	-rm compile_commands.json

