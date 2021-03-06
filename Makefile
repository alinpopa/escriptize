ERLS := $(wildcard src/*.erl)
BEAMS := $(ERLS:src/%.erl=ebin/%.beam)

ebin/%.beam: src/%.erl
	erlc -o ebin $<

top: escriptize
	make -C example

ebin:
	mkdir -p ebin

escriptize: ebin $(BEAMS) escriptize0
	./escriptize0 escriptize
	chmod +x ./escriptize

clean:
	make -C example clean
	-rm $(BEAMS)
	-rm escriptize
