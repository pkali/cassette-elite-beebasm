BEEBASM?=beebasm
PYTHON?=python

# You can set the release that gets built by adding 'release=<rel>' to
# the make command, where <rel> is one of:
#
#   source-disc
#   text-sources
#
# So, for example:
#
#   make encrypt verify release=text-sources
#
# will build the version from the text sources on Ian Bell's site. If you
# omit the release parameter, it will build the source disc version.

ifeq ($(release), text-sources)
  rel-cassette=2
  folder-cassette=/text-sources
  suffix-cassette=-from-text-sources
else
  rel-cassette=1
  folder-cassette=/source-disc
  suffix-cassette=-from-source-disc
endif

.PHONY:build
build:
	echo _VERSION=1 > 1-source-files/main-sources/elite-header.h.asm
	echo _RELEASE=$(rel-cassette) >> 1-source-files/main-sources/elite-header.h.asm
	echo _REMOVE_CHECKSUMS=TRUE >> 1-source-files/main-sources/elite-header.h.asm
	$(BEEBASM) -i 1-source-files/main-sources/elite-source.asm -v > 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-bcfs.asm -v >> 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-loader.asm -v >> 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-readme.asm -v >> 3-assembled-output/compile.txt
	$(PYTHON) 2-build-files/elite-checksum.py -u -rel$(rel-cassette)
	$(BEEBASM) -i 1-source-files/main-sources/elite-disc.asm -do 5-compiled-game-discs/elite-cassette$(suffix-cassette).ssd -boot ELTdata -title "E L I T E"

.PHONY:encrypt
encrypt:
	echo _VERSION=1 > 1-source-files/main-sources/elite-header.h.asm
	echo _RELEASE=$(rel-cassette) >> 1-source-files/main-sources/elite-header.h.asm
	echo _REMOVE_CHECKSUMS=FALSE >> 1-source-files/main-sources/elite-header.h.asm
	$(BEEBASM) -i 1-source-files/main-sources/elite-source.asm -v > 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-bcfs.asm -v >> 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-loader.asm -v >> 3-assembled-output/compile.txt
	$(BEEBASM) -i 1-source-files/main-sources/elite-readme.asm -v >> 3-assembled-output/compile.txt
	$(PYTHON) 2-build-files/elite-checksum.py -rel$(rel-cassette)
	$(BEEBASM) -i 1-source-files/main-sources/elite-disc.asm -do 5-compiled-game-discs/elite-cassette$(suffix-cassette).ssd -boot ELTdata -title "E L I T E"

.PHONY:verify
verify:
	@$(PYTHON) 2-build-files/crc32.py 4-reference-binaries$(folder-cassette) 3-assembled-output
