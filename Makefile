# The MIT License (MIT)
#
# Copyright (c) 2023-2024 Objectionary.com
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

.ONESHELL:
.SHELLFLAGS: -e -o pipefail -c
.PHONY: all clean
.PRECIOUS: %.jar after before
.EXPORT_ALL_VARIABLES:

SHELL=bash
TOTAL=10000000
MULTIPLIER=40

EO_VERSION=0.38.4
JEO_VERSION=0.4.6
OPEO_VERSION=0.2.2
INEO_VERSION=0.3.1
JD_VERSION=1.2.1

all: env results.md html/summary.html
	set -e

html/summary.html: ./src/main/perl/create-html-summary.pl
	mkdir -p html
	./src/main/perl/create-html-summary.pl
	echo "<html><body><a href='summary.html'>summary</a></body></html>" > html/index.html

README.md: results.md src/main/perl/inject-into-readme.pl
	src/main/perl/inject-into-readme.pl

env:
	if [[ "$(MAKE_VERSION)" =~ ^[1-3] ]]; then
	    echo "Make must be 4+: $(MAKE_VERSION)"
	    exit 1
	fi

results.md: before.time before.jit-time after.time after.jit-time src/main/bash/assemble-results.sh
	src/main/bash/assemble-results.sh > results.md

%.time: %.jar Makefile
	set -e
	echo "Testing that .JAR works..."
	java -jar $< 1
	#java -cp $< org.eolang.benchmark.FactorialApplication 1
	echo "Running JAR (without JIT), please wait..."
	#time=$$(java -Xint -cp $< org.eolang.benchmark.FactorialApplication "${TOTAL}" | cut -d' ' -f2 | cut -d'=' -f2)
	time=$$(java -Xint -jar $< ${TOTAL} | grep "time=" | awk -F'time=' '{print $$2}' | awk '{print $$1}')
	echo "$${time}" > $@
	echo "Took $${time}ms to run JAR (without JIT)"

%.jit-time: %.jar Makefile
	set -e
	#java -cp $< org.eolang.benchmark.FactorialApplication 1
	java -jar $< 1
	echo "Collecting the machine binary code of the App.run() method"
	mkdir -p binary
	phase=$(subst .jar,,$<)
	#java '-XX:+UnlockDiagnosticVMOptions' '-XX:CompileCommand=print,*App.run' -cp $< org.eolang.benchmark.FactorialApplication 10000 > binary/$${phase}.txt
	java '-XX:+UnlockDiagnosticVMOptions' '-XX:CompileCommand=print,*App.run' -jar $< 10000000 > binary/$${phase}.txt
	t=$$(echo ${TOTAL} \* ${MULTIPLIER} | bc | xargs)
	echo "Running JAR (with JIT), please wait..."
	#time=$$(java -cp $< org.eolang.benchmark.FactorialApplication $${t} | cut -d' ' -f2 | cut -d'=' -f2)
	time=$$(java -jar $< $${t} | grep "time=" | awk -F'time=' '{print $$2}' | awk '{print $$1}')
	echo "$${time}" > $@
	echo "Took $${time}ms to run JAR (with JIT)"

%.jar: pom.xml Makefile src/main/java/org/eolang/benchmark/*.java
	set -e
	base=$(basename $@)
	mvn --activate-profiles "$${base}" --update-snapshots clean package "-DfinalName=$${base}" "-Ddirectory=$${base}" \
		-Djeo.version=${JEO_VERSION} \
		-Deo.version=${EO_VERSION} \
		-Dopeo.version=${OPEO_VERSION} \
		-Dineo.version=${INEO_VERSION} \
		-Djd.version=${JD_VERSION}
	cp "$${base}/$${base}.jar" "$${base}.jar"

quick:
	set -e
	rm -f before.jar
	make before.jar
	rm -f target/benchmark-synthetic.jar
	mvn package
	T=10000000
	JIT_OPTS=-XX:+EliminateAllocations
	set -x
	java $${JIT_OPTS} -cp before.jar org.eolang.benchmark.FactorialApplication $${T}
	java $${JIT_OPTS} -cp target/benchmark-synthetic.jar org.eolang.benchmark.FactorialApplication $${T}

clean:
	set -e
	rm -f *.time
	rm -f *.jit-time
	rm -f *.jar
	rm -f results.md
	rm -rf before
	rm -rf after
	rm -rf target