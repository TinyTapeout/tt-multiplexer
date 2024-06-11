MAGIC_RC ?= $(PDK_ROOT)/sky130A/libs.tech/magic/sky130A.magicrc
TCL_BASE = $(dir $(lastword $(MAKEFILE_LIST)))

%.lvs.spice: %.mag
	magic -rcfile $(MAGIC_RC) -noconsole -dnull $(TCL_BASE)/magic_extract_lvs.tcl $*

%.pex.spice: %.mag
	magic -rcfile $(MAGIC_RC) -noconsole -dnull $(TCL_BASE)/magic_extract_pex.tcl $*

lvs.report: $(PROJECT_NAME).lvs.spice ../xschem/simulation/$(PROJECT_NAME).spice
	netgen -batch eval "set project $(PROJECT_NAME) ; source $(TCL_BASE)/lvs.tcl"

lvs: lvs.report
	@propOk=1; match=0; port=1; \
    if grep -q "match uniquely" lvs.report; then \
        match=1; \
    fi; \
    if grep -q "Property errors were found" lvs.report; then \
        propOk=0; \
    fi; \
    if grep -q "failed pin matching" lvs.report; then \
        match=0; \
    fi; \
    if grep -q "Final result: Netlists do not match" lvs.report; then \
        match=0; \
    fi; \
    if grep -q "port errors" lvs.report; then \
        port=0; \
    fi; \
    if grep -q "Final result: Circuits match uniquely\." lvs.report; then \
        match=1; \
    fi; \
	if [ $$match -eq 1 ] && [ $$propOk -eq 1 ] && [ $$port -eq 1 ]; then \
        echo "LVS OK"; \
	    exit 0; \
    else \
        echo "LVS FAIL: match=$$match properties=$$propOk port=$$port"; \
	    exit 1; \
    fi

drc:
	magic -rcfile $(MAGIC_RC) -noconsole -dnull $(TCL_BASE)/magic_drc.tcl $(PROJECT_NAME)

update_gds:
	mkdir -p ../gds ../lef
	magic -rcfile $(MAGIC_RC) -noconsole -dnull $(TCL_BASE)/update_gds_lef.tcl $(PROJECT_NAME)

clean:
	rm -Rf ext
	rm -f lvs.report *.nodes *.spice *.sim

.PHONY: lvs drc update_gds clean
