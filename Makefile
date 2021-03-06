#---------------------------------------------------------------------------------
# Clear the implicit built in rules
#---------------------------------------------------------------------------------
.SUFFIXES:

ifeq ($(strip $(FXCGSDK)),)
export FXCGSDK := $(realpath ../../)
endif

include $(FXCGSDK)/common/prizm_rules


#---------------------------------------------------------------------------------
# TARGET is the name of the output
# BUILD is the directory where object files & intermediate files will be placed
# SOURCES is a list of directories containing source code
# INCLUDES is a list of directories containing extra header files
#---------------------------------------------------------------------------------
TARGET		:=	$(notdir $(CURDIR))
BUILD		:=	$(CONFIG)
SOURCES		:=	src src/ptune2_simple src/asm
DATA		:=	data  
INCLUDES	:=

#---------------------------------------------------------------------------------
# options for code and add-in generation
#---------------------------------------------------------------------------------

MKG3AFLAGS := -n basic:PrizoopN -i uns:../unselected.bmp -i sel:../selected.bmp

CBASEFLAGS	= -O2 \
		  -Wall \
		  -funroll-loops \
		  -fno-trapping-math \
		  -fno-trapv \
		  -Wno-switch \
		  $(MACHDEP) $(INCLUDE) $(DEFINES)
		  
CFLAGS	=	$(CBASEFLAGS) \
		  -std=c99

CXXFLAGS	=	$(CBASEFLAGS) \
		  -fpermissive \
		  -fno-rtti \
		  -fno-exceptions \
		  -fno-threadsafe-statics \
		  -fno-use-cxa-get-exception-ptr 

ASFLAGS	=	$(CFLAGS) 

# add -S -fverbose-asm for assembly output

LDFLAGS	= $(MACHDEP) -O2 -T$(FXCGSDK)/common/prizm.ld -Wl,-static -Wl,-gc-sections -Xlinker -Map=output.map

#---------------------------------------------------------------------------------
# any extra libraries we wish to link with the project
#---------------------------------------------------------------------------------
SYSTEMLIBS :=  -lfxcg -lm -lc -lgcc
LIBS	:=	-lzx7 -lcalctype -lsnd -lptune2_simple $(SYSTEMLIBS)

#---------------------------------------------------------------------------------
# list of directories containing libraries, this must be the top level containing
# include and lib
#---------------------------------------------------------------------------------
LIBDIRS	:=

#---------------------------------------------------------------------------------
# no real need to edit anything past this point unless you need to add additional
# rules for different file extensions
#---------------------------------------------------------------------------------
ifneq ($(BUILD),$(notdir $(CURDIR)))
#---------------------------------------------------------------------------------

export OUTPUT		:=	$(CURDIR)/$(BUILD)/$(TARGET)

export VPATH	:=	$(foreach dir,$(SOURCES),$(CURDIR)/$(dir)) \
					$(foreach dir,$(DATA),$(CURDIR)/$(dir))

export DEPSDIR	:=	$(CURDIR)/$(BUILD)

#---------------------------------------------------------------------------------
# automatically build a list of object files for our project
#---------------------------------------------------------------------------------
CFILES		:=	$(foreach dir,$(SOURCES),$(notdir $(wildcard $(dir)/*.c)))
CPPFILES	:=	$(foreach dir,$(SOURCES),$(notdir $(wildcard $(dir)/*.cpp)))
SFILES		:=	$(foreach dir,$(SOURCES),$(notdir $(wildcard $(dir)/*.S)))
BINFILES	:=	$(foreach dir,$(DATA),$(notdir $(wildcard $(dir)/*.*)))

#---------------------------------------------------------------------------------
# use CXX for linking C++ projects, CC for standard C
#---------------------------------------------------------------------------------
ifeq ($(strip $(CPPFILES)),)
	export LD	:=	$(CC)
else
	export LD	:=	$(CXX)
endif

export OFILES	:=	$(addsuffix .o,$(BINFILES)) \
					$(CPPFILES:.cpp=.o) $(CFILES:.c=.o) \
					$(SFILES:.S=.o)

#---------------------------------------------------------------------------------
# build a list of include paths
#---------------------------------------------------------------------------------
export INCLUDE	:=	$(foreach dir,$(INCLUDES), -iquote $(CURDIR)/$(dir)) \
					$(foreach dir,$(LIBDIRS),-I$(dir)/include) \
					-I$(CURDIR)/$(BUILD) -I$(LIBFXCG_INC) -I$(UTILS_INC)

#---------------------------------------------------------------------------------
# build a list of library paths
#---------------------------------------------------------------------------------
export LIBPATHS	:=	$(foreach dir,$(LIBDIRS),-L$(dir)/lib) \
					-L$(FXCGSDK)/utils/lib \
					-L$(LIBFXCG_LIB) 
					
export OUTPUT		:=	$(CURDIR)/$(BUILD)/$(TARGET)
export OUTPUT_FINAL		:=	$(CURDIR)/$(TARGET)
.PHONY: $(BUILD) clean

#---------------------------------------------------------------------------------
$(BUILD):
	@[ -d $@ ] || mkdir $@
	@make --no-print-directory -C $(BUILD) -f $(CURDIR)/Makefile

#---------------------------------------------------------------------------------
export CYGWIN := nodosfilewarning
clean:
	$(RM) -fr $(BUILD) $(OUTPUT).bin $(OUTPUT_FINAL).g3a

#---------------------------------------------------------------------------------
else

DEPENDS	:=	$(OFILES:.o=.d)

#---------------------------------------------------------------------------------
# main targets
#---------------------------------------------------------------------------------
$(OUTPUT_FINAL).g3a: $(OUTPUT).bin
	$(MKG3A) $(MKG3AFLAGS) $< $@
	
$(OUTPUT).bin: $(OFILES) 

-include $(DEPENDS)

#---------------------------------------------------------------------------------
endif
#---------------------------------------------------------------------------------