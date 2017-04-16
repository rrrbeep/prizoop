
#include "platform.h"

#include "memory.h"
#include "debug.h"
#include "mbc.h"
#include "cgb.h"

#include "rom.h"

static char curRomFile[64];
static char curSaveFile[64];

unsigned char loadROM(const char *filename) {
	char name[17];
	enum mbcType type;
	int i;
	
	int length;
	
	unsigned char header[0x180];

	unsigned char isColor = filename[strlen(filename) - 1] == 'c' ? 1 : 0;

	strcpy(curRomFile, "\\\\fls0\\");
	strcat(curRomFile, filename);

	strcpy(curSaveFile, "\\\\fls0\\");
	strcat(curSaveFile, filename);
	curSaveFile[strlen(curSaveFile) - 2 - isColor] = 0;
	strcat(curSaveFile, "SAV");

	int hFile;
	unsigned short pFile[256];
	Bfile_StrToName_ncpy(pFile, (const char*)curRomFile, strlen(curRomFile)+2);
	
	hFile = Bfile_OpenFile_OS(pFile, READ, 0); // Get handle
	if (hFile < 0) {
		printf("Not found! %d\n", hFile);
		return 0;
	}

	length = Bfile_GetFileSize_OS(hFile);
	if(length < 0x180) {
		printf("ROM is too small! (%d bytes)\n", length);
		Bfile_CloseFile_OS(hFile);
		return 0;
	}

	if (length > 4 * 1024 * 1024) {
		// 4 MB max
		printf("ROM is too big! (%d kbytes)\n", length / 1024);
		Bfile_CloseFile_OS(hFile);
		return 0;
	}

	// read in the header and print out info
	Bfile_ReadFile_OS(hFile, header, 0x180, 0);
	
	memset(name, '\0', 17);
	for(i = 0; i < 16; i++) {
		if(header[i + ROM_OFFSET_NAME] == 0x80 || header[i + ROM_OFFSET_NAME] == 0xc0) name[i] = '\0';
		else name[i] = header[i + ROM_OFFSET_NAME];
	}

	bool isCGB = header[ROM_OFFSET_GBC] == 0x80 || header[ROM_OFFSET_GBC] == 0xc0;
	if (isCGB) {
		printf("CGB ROM name: %s\n", name);
	} else {
		printf("GB ROM name: %s\n", name);
	}

	resetMemoryMaps(isCGB);
	cpuReset();

	if (isCGB) {
		// init CGB mode
		cgbInitROM();
	} else {
		cgb.isCGB = false;
	}

	// determine mbc controller support and initialize
	type = (mbcType) header[ROM_OFFSET_TYPE];
	unsigned char romSizeByte = header[ROM_OFFSET_ROM_SIZE];
	unsigned char ramSizeByte = header[ROM_OFFSET_RAM_SIZE];

	if (!setupMBCType(type, romSizeByte, ramSizeByte, hFile)) {
		printf("Unsupported MBC: %s, (%02x ROM, %02x RAM)\n", getMBCTypeString(type), romSizeByte, ramSizeByte);
		unloadROM();
		return 0;
	}

	printf("MBC type: %s\n", getMBCTypeString(type));
	printf("RAM type: %s\n", getRAMTypeString(mbc.ramType));
	printf("Num ROM Banks: %d\n", mbc.numRomBanks);
		
	// read permanent ROM Area in
	Bfile_ReadFile_OS(hFile, cart, /*min(length,*/ 0x4000/*)*/, 0);

	if (mbc.batteryBacked) {
		if (tryLoadSRAM(curSaveFile)) {
			printf("Save file loaded\n");
		}
		else {
			printf("No save file in system\n");
		}
	} else {
		printf("No save file, not battery backed\n");
	}

	return 1;
}

void unloadROM(void) {
	if (mbc.romFile) {
		Bfile_CloseFile_OS(mbc.romFile);
		mbc.romFile = 0;
	}

	saveRAM();

	// free up vram
	if (vram) {
		free((void*)vram);
		vram = NULL;
	}

	if (cgb.isCGB) {
		// clean up CGB mode stuff
		cgbCleanup();
	}
}

void saveRAM(void) {
	if (mbc.batteryBacked) {
		trySaveSRAM(curSaveFile);
	}
}