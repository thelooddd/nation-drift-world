//==============================================================================
//                         GarHouse v1.3 by [03]Garsino!
//==============================================================================
// - Credits to DracoBlue for dini, dcmd and dudb.
// - Credits to Incognito for his awesome streamer.
// - Credits to Y_Less for sscanf2.
// - Credits to whoever made GetPosInFrontOfPlayer.
// - Credits to mick88 for FM (FormatMoney).
// - Thanks to everyone who gave me ideas for this house system.
// - Thanks to everyone who helped me find bugs.
//==============================================================================
//                                  Changelog v1.3
//==============================================================================
// - [Added] Added defines for SendClientMessages and all dialogs except the ones wich uses list items (now you can just replace these with yours instead of translating the script everytime a new release is out).
// - [Fixed] Fixed small typo in /removehcar.
// - [Fixed] Fixed small typo in a comment in the configuration section wich was misleading.
// - [Added] Added /changehcar - this command allows you to change the model id for a housecar.
// - [Added] Added Madd Dogg's Mansion as a house interior (house interior #10)
//==============================================================================
//                              Includes
//==============================================================================
#include <a_samp> // Credits to the SA:MP Developement Team
#include <streamer> // Credits to Incognito
#include <dini> // Credits to dracoblue
#include <dudb> // Credits to dracoblue
#include <sscanf2> // Credits to Y_Less
//==============================================================================
//                              Macros
//==============================================================================
//##############################################################################
#undef MAX_PLAYERS
#define MAX_PLAYERS 500 // Change it to the amount of server slots!!
//##############################################################################
#define dcmd(%1,%2,%3) if (!strcmp((%3)[1], #%1, true, (%2)) && ((((%3)[(%2) + 1] == '\0') && (dcmd_%1(playerid, ""))) || (((%3)[(%2) + 1] == ' ') && (dcmd_%1(playerid, (%3)[(%2) + 2]))))) return 1
new FALSE = false, CMDSString[1000];
#define ShowInfoBox(%0,%1,%2,%3) do{format(CMDSString, 1000, %2, %3); ShowPlayerDialog(%0, HOUSEMENU-1, DIALOG_STYLE_MSGBOX, %1, CMDSString, "�������", "������");}while(FALSE)
#define SendMSG(%0,%1,%2,%3,%4) do{new _str[%2]; format(_str,%2,%3,%4); SendClientMessage(%0,%1,_str);}while(FALSE)
#define Loop(%0,%1) for(new %0 = 0; %0 < %1; %0++)
#define TYPE_OUT (0)
#define TYPE_INT (1)
//==============================================================================
//                              Colours
//==============================================================================
#define COLOUR_INFO			   			0x00FFFFFF
#define COLOUR_SYSTEM 		   			0xB60000FF
#define COLOUR_YELLOW 					0xFFFF2AFF
#define COLOUR_GREEN 					0x00BC00FF
//==============================================================================
//                              Configuration
//==============================================================================
#define HOUSEMENU 						21700 // Dialog ID
#define SPAWN_IN_HOUSE // Comment if you do not want the player to spawn in his house the next time he rejoins.
#define GH_USE_MAPICONS // Comment if you do not want map icons.
#define GH_USE_CPS // Comment if you want to use pickups instead
#define GH_HINTERIOR_UPGRADE // Comment if you do not want players to be able to upgrade their house interior.
#define HSPAWN_TIMER_RATE   1000 // After how long will the timer call the spawn in house function? (in ms)
#define MICON_VD 50.0 // Map icon visible range (drawdistance).
#define DEFAULT_H_INTERIOR  0 // Default house interior when creating a house
#define DEFAULT_H_INTERIOR_PRICE  3000000 // Default house interior price when creating a house
//#define GH_USE_WEAPONSTORAGE // If defined the house owner may store their weapons in the house storage.
//#define GH_SAVE_ADMINWEPS // If defined the house owner may save weapons like minigun, grenades, RPG's, etc.
//#define GH_DEBUGGING // If defined it will enable debugging prints in the server console.
//#define GH_HOUSECARS // If defined the script will have house cars (note: you need to add the house car position using /addhcar)
// Note2: You need to define SPAWN_IN_HOUSE for it to create the housecar on the first spawn.
#define HCAR_COLOUR1 -1 // The first colour of the housecar
#define HCAR_COLOUR2 -1 // The second colour of the housecar
#define HCAR_RESPAWN 60 // The respawn delay of the house car (in seconds)
#define HCAR_RANGE  10.0 // The range to check for nearby vehicles when saving the house car.
#define MAX_HOUSES 						3000 // Max houses created
#define MAX_HOUSES_OWNED    			1 // Max houses owned per player
#define PICKUP_MODEL_OUT (1273)
#define PICKUP_MODEL_INT (1272)
#define PICKUP_TYPE (1)
#define HOUSEFILE_LENGTH                30 // The length of the housefile (Default is /GarHouse/Houses/<0-MAX_HOUSES>.ini
#define MAX_VISIT_TIME                  1 // The max time the player can be visiting in (In Minutes).
#define INVALID_HOWNER_NAME             "INVALID_PLAYER_ID" // The "name" of the house owner when there is no real house owner (if that made sense)
#define TIME_BETWEEN_VISITS             2 // The time the player have to wait before previewing a new house interior (In minutes).
#define H_INT_0_VALUE   				3000000 // House interior price for house interior 0
#define H_INT_1_VALUE   				100000 // House interior price for house interior 1
#define H_INT_2_VALUE   				1000000 // House interior price for house interior 2
#define H_INT_3_VALUE   				1500000 // House interior price for house interior 3
#define H_INT_4_VALUE   				1500000 // House interior price for house interior 4
#define H_INT_5_VALUE   				2500000 // House interior price for house interior 5
#define H_INT_6_VALUE   				3000000 // House interior price for house interior 6
#define H_INT_7_VALUE   				5000000 // House interior price for house interior 7
#define H_INT_8_VALUE   				7500000 // House interior price for house interior 8
#define H_INT_9_VALUE   				10000000 // House interior price for house interior 9
#define H_INT_10_VALUE   				25000000 // House interior price for house interior 10
#define HOUSE_SELLING_PROCENT   		75 // The amount of the house value the player will get when the house is sold.
#define HOUSE_SELLING_PROCENT2 			6.5 // The total percentage the nearby houses will go up/down by when a house is sold/bought nearby.
#define RANGE_BETWEEN_HOUSES            200 // The range used when increasing/decreasing the value of nearby houses when a house is bought/sold (set to 0 to disable)
#define MAX_HOUSE_NAME                  35 // Max length of a house name
#define MIN_HOUSE_NAME                  4 // Min length of a house name
#define MAX_HOUSE_PASSWORD              35 // Max length of a house password
#define MIN_HOUSE_PASSWORD              4 // Min length of a house password
#define DEFAULT_HOUSE_NAME              "House For Sale!" // The default name when a house is created/sold
#define MIN_HOUSE_VALUE                 100000 // Min house value of a house (ofc prices will change when a house is bought/sold nearby)
#define MAX_HOUSE_VALUE                 25000000 // Max house value of a house (ofc prices will change when a house is bought/sold nearby)
#define CASE_SENSETIVE                  true // Used in strcmp name checks. Define as true/false [0/1]. Read wiki for more information
#if defined GH_USE_CPS
new HouseCPOut[MAX_HOUSES], HouseCPInt[MAX_HOUSES];
#endif
#if !defined GH_USE_CPS
new HousePickupOut[MAX_HOUSES], HousePickupInt[MAX_HOUSES];
#endif
new Text3D:HouseLabel[MAX_HOUSES];
new Float:X, Float:Y, Float:Z, Float:Angle;
#if defined GH_USE_MAPICONS
new HouseMIcon[MAX_HOUSES];
#endif
#if defined GH_HOUSECARS
new HouseCar[MAX_HOUSES];
#endif
//==============================================================================
//                   Translation / SendClientMessage Messages
//==============================================================================
/*
	- Below you will find a list of messages.
	- You can translate these messages to whatever language you want.
	- When updating to a new version, simply replace the messages with the ones you translated.
	- But read the note where it says what version the messages below were added for.
 		- There might have been some more messages added after this version of GarHouse (v1.3),
		- so do not replace all of the messages without looking carefully if there is any new ones.
	- And be careful when editing messages containing placeholders (%s, %d, %i, etc),
		- if you change the position of these it will screw up eventually.
		- and do not remove or add any more placeholders if you do NOT know what you're doing.
	- Oh and one more thing, I did not translate the dialogs wich uses list items. You will have to do that yourself.
	
	
	Thanks,
	[03]Garsino.
*/
//##############################################################################
//                          Messages added in v1.3
//##############################################################################
//------------------------------------------------------------------------------
//                              Important.
//------------------------------------------------------------------------------
#define LABELTEXT1 "�������� ����: %s\n��������: No Owner\n����: $%d\nID: %d"
#define LABELTEXT2 "�������� ����: %s\n��������: %s\n����: $%d\nID: %d"
#define FILEPATH "/GarHouse/Houses/%d.ini"
#define INFORMATION_HEADER "GarHouse v1.3 By [03]Garsino(������� ����� samp-mods.com) - ����������"
//------------------------------------------------------------------------------
// 				Information and error messages
//------------------------------------------------------------------------------
#define E_NO_HOUSES_OWNED "�� �� �������� ������� �����."
#define I_HMENU "����� /housemenu, ����� ���������� ���� �����."
#define E_H_ALREADY_OWNED "���� ����� ��� ����� �������."
#define E_INVALID_HPASS_LENGTH "������������ ����� ������."
#define E_INVALID_HPASS "������������ ������. �� �� ������ ������������ ���� ������."
#define E_INVALID_HPASS_CHARS "��� ������ �������� ������������ ������� (����� ��� ~)."
#define E_INVALID_HNAME_LENGTH "������������ ����� �������� ����."
#define E_INVALID_HNAME_CHARS "�������� ���� �������� ������������ �������(����� ��� ~)."
#define I_HPASS_NO_CHANGE "��� ������ �� ���� ������� �������."
#define I_HPASS_REMOVED "������ �� ���� ��� �����."
#define E_NOT_ENOUGH_PMONEY "� ��� ���� ������� �����!"
#define E_INVALID_AMOUNT "������������ ����������."
#define E_HSTORAGE_L_REACHED "�� �� ������ ������� ������� ����� � ����. ������������ ����� $25,000,000."
#define E_NOT_ENOUGH_HSMONEY "� ��� ���� ������� ����� � ����!"
#define E_NO_WEAPONS "�� �� ������ �������� ������."
#define E_NO_HS_WEAPONS "�� �� ������ ���������� ������ � ����."
#define E_INVALID_HPASS_CHARS2 "������ �� ����� � ��� �������� ������������ ������� (����� ��� ~)."
#define E_C_ACCESS_SE_HM "�� �� ������ ������� ���� ������ ����."
#define E_NOT_IN_HOUSE "�� ������ ���� � ���� ����� ������������ ��� �������."
#define E_NOT_HOWNER "�� ������ ���� ���������� ���� ����� ������������ ��� �������."
#define E_HCAR_NOT_IN_VEH "�� ������ ���� � ������, ����� �������� �� � ����."
#define E_INVALID_HID "������������ ID. ������ ID ���� �� ����������."
#define E_NO_HCAR "� ���� � ���� ID ��� �����. ���������� �������."
#define E_H_A_F_SALE "���� ��� ��� ��������� �� �������. �� �� ������ ������� ���."
#define HMENU_ENTER_PASS "�������� ����: %s\n��������: %s\n����: $%d\nID: %d\n\n������� ������ � ���� ���� �� ������ �����:"
#define HMENU_BUY_HOUSE "%s, �� ������ ������ ��� �� $%d?"
#define HMENU_BUY_HINTERIOR "�� ������ ������ �������� ���� %s �� $%d?"
#define HMENU_SELL_HOUSE "%s, �� ��������, ��� ������ ������� ��� %s �� $%d?"
#define I_SELL_HOUSE1 "�� ������� ������� ��� �� $%d.\n����� �� �������: $%d.\n$%d �� ������ ���� ���� ���������� ���."
#define I_SELL_HOUSE2 "�� ������� ������� ��� \"%s\" �� $%d.\n����� �� �������: $%d."
#define I_BUY_HOUSE "�� ������� ������ ��� �� $%d!"
#define I_HPASSWORD_CHANGED "�� ������� ���������� �� ��� ������ \"%s\"!"
#define I_HNAME_CHANGED "�� ������� �������� ��� ���� �� \"%s\"!"
#define E_ALREADY_HAVE_HINTERIOR "� ��� ��� ���� ���� �������� ����."
#define I_VISITING_HOUSEINT "������ �� ��������� �������� %s.\n��� ���� $%d.\n����� ��������� ���������� ����� %d ������%s."
#define E_CANT_AFFORD_HINT "�� �� ������ ��������� ������ ���� �������� %s.\n���� ��������� ����: $%d.\n�� ������: $%d.\n��� ��� �����: $%d."
#define I_HINT_BOUGHT "�� ������ �������� %s �� $%d."
#define I_HINT_DEPOSIT1 "� ��� ���� $%d �� �������� � ����� ����.\n\n������� �����, ������� �� ������ ��������:"
#define I_HINT_WITHDRAW1 "� ��� ���� $%d �� �������� � ����� ����.\n\n������� �����, ������� �������� �����:"
#define I_HINT_DEPOSIT2 "�� ������� �������� $%d � ��� ��� �� ��������.\n������� ������: $%d"
#define I_HINT_WITHDRAW2 "�� ������� ����� $%d �� ������ ����.\n������� ������: $%d"
#define I_HINT_CHECKBALANCE "� ��� ���� $%d �� �������� � ����."
#define E_HINT_WAIT_BEFORE_VISITING "���������� ��������� �� ��������� ��������� ���� �����."
#define I_HS_WEAPONS1 "�� ������� ��������� %d ������%s � ����."
#define I_HS_WEAPONS2 "�� ������� ����� %d ������%s �� ����."
#define I_WRONG_HPASS1 "�� �� ����� � ��� ������ %s, ��������� ������ \"%s\"."
#define I_WRONG_HPASS2 "����������: %s (%d) ������� ����� � ���, ��������� ������ \"%s\"!"
#define I_CORRECT_HPASS1 "�� ������� ����� � ��� ������ %s, ��������� ������ \"%s\"!"
#define I_CORRECT_HPASS2 "����������: %s (%d) ������� ����� � ���, ��������� ������ \"%s\"!"
#define E_TOO_MANY_HOUSES "��������, �� ��� �������� %d �����.\n������� ���� ��� ��������� ��� ��������� ����� � �������."
#define E_INVALID_HVALUE "������������ ���� ����. ���� ������ ���� � ���������� $1,500,000-$25,000,000."
#define I_H_CREATED "��� � ID %d ������..."
#define I_HCAR_EXIST_ALREADY "��� � ID %d ��� ����� ������. �������� ������� ������."
#define I_HCAR_CREATED "������ ��� ���� � ID %d ��������..."
#define I_H_DESTROYED "��� � ID %d ������..."
#define I_HCAR_REMOVED "������ ��� ���� � ID %d ���� �������..."
#define I_ALLH_DESTROYED "��� ���� �������. (%d � �����)"
#define I_ALLHCAR_REMOVED "��� ������ � ����� �������. (%d � �����)"
#define I_HSPAWN_CHANGED "�� �������� ������� ������ � ���� ��� ���� � ID %d."
#define I_TELEPORT_MSG "�� ���� ���������������� � ��� � ID %d."
#define I_H_SOLD "�� ������� ��� � ID %d..."
#define I_ALLH_SOLD "��� ���� �� ������� ���� ��������. (%d � �����)"
#define I_H_PRICE_CHANGED "���� �� ��� � ID %d ���� ��������� �� $%d."
#define I_ALLH_PRICE_CHANGED "�� �������� ���� ��� ���� ����� �� ������� ��  $%d. (%d � �����)"
#define I_HINT_VISIT_OVER "���� ����� ��������� �����������.\n�� ������ ������ �������� ���� %s �� $%d?"
#define E_INVALID_HCAR_MODEL "������������ ������ ������. ���������� ������ � ���������� 400-612."
#define I_HCAR_CHANGED "������ ������ ��� ���� � ID %d ��������� �� %d."
//------------------------------------------------------------------------------
#define E_CMD_USAGE_CREATEHOUSE "�������������: /createhouse (����) (�����������: �������� ����)"
#define E_CMD_USAGE_ADDHCAR "�������������: /addhcar (id ����)"
#define E_CMD_USAGE_REMOVEHOUSE "�������������: /removehouse (id ����)"
#define E_CMD_USAGE_REMOVEHCAR "�������������: /removehcar (id ����)"
#define E_CMD_USAGE_CHANGEHCAR "�������������: /changehcar (id ����) (id ������: 400-612)"
#define E_CMD_USAGE_CHANGESPAWN "�������������: /changespawn (id ����)"
#define E_CMD_USAGE_GOTOHOUSE "�������������: /gotohouse (id ����)"
#define E_CMD_USAGE_SELLHOUSE "�������������: /sellhouse (id ����)"
#define E_CMD_USAGE_CHANGEPRICE "�������������: /changeprice (id ����) (����)"
#define E_CMD_USAGE_CHANGEALLPRICE "�������������: /changeallprices (����)"
//------------------------------------------------------------------------------
//                          Debug messages
//------------------------------------------------------------------------------
#if defined GH_DEBUGGING
#define DEBUG_OP_DISCONNECT "[GarHouse Debug] (OnPlayerDisconnect) - %s (%d) ����� �� ������ ����."
#define DEBUG_OP_ED_CP1 "[GarHouse Debug] (OnPlayerEnterDynamicCP) - %s (%d) ����� � ���� ��� [House ID: %d]."
#define DEBUG_OP_ED_CP2 "[GarHouse Debug] (OnPlayerEnterDynamicCP) - %s (%d) ����� �� ���� � ID %d."
#define DEBUG_OP_PUD_PICKUP1 "[GarHouse Debug] (OnPlayerPickUpDynamicPickup) - %s (%d) ����� � ��� [House ID: %d]."
#define DEBUG_OP_PUD_PICKUP2 "[GarHouse Debug] (OnPlayerPickUpDynamicPickup) - %s (%d) ����� �� ���� � ID %d."
#define DEBUG_ODR1 "[GarHouse Debug] (OnDialogResponse) - %s (%d) ����� ��� ID %d �� $%d."
#define DEBUG_ODR2 "[GarHouse Debug] (OnDialogResponse) - %s (%d) ������� �������� ���� � ID %d �� %s."
#define DEBUG_ODR3 "[GarHouse Debug] (OnDialogResponse) - %s (%d) ����� �������� %s �� $%d. [House ID: %d]."
#define DEBUG_ODR4 "[GarHouse Debug] (OnDialogResponse) - %s (%d) ������� �������� %s [House ID: %d]."
#define DEBUG_ODR5 "[GarHouse Debug] (OnDialogResponse) - �������� ��� ���� � ID %d ��� ���������� �� %d."
#define DEBUG_ODR6 "[GarHouse Debug] (OnDialogResponse) - %s (%d) �������� ������ � ���� � ID %d. [Balance: $%d]"
#define DEBUG_ODR7 "[GarHouse Debug] (OnDialogResponse) - %s (%d) ������� $%d � ��� � ID %d."
#define DEBUG_ODR8 "[GarHouse Debug] (OnDialogResponse) - %s (%d) ���� $%d �� ���� � ID %d."
#define DEBUG_ODR9 "[GarHouse Debug] (OnDialogResponse) - %s (%d) ������ %d ������%s �� �������� � ��� � ID %d."
#define DEBUG_ODR10 "[GarHouse Debug] (OnDialogResponse) - %s (%d) ������ %d ������%s �� �������� � ��� � ID %d."
#define DEBUG_ODR11 "[GarHouse Debug] (OnDialogResponse) - %s (%d) ������� %d ������%s �� ���� � ID %d."
#define DEBUG_ODR12 "[GarHouse Debug] (OnDialogResponse) - %s (%d) ������� ����� � ��� � ID %d, ��������� ������ �� ����."
#define DEBUG_ODR13 "[GarHouse Debug] (OnDialogResponse) - %s (%d) ������ ��� �� $%d (������ � ����: $%d). [House ID: %d]"
#define DEBUG_ODR14 "[GarHouse Debug] (OnDialogResponse) - %s (%d) ������� ������ �� ���� � ID %d."
#define DEBUG_OP_CMD1 "[GarHouse Debug] (OnPlayerCommandText) - %s (%d) ������ ���. [House ID: %d | House Value: $%d | Total Houses: %d]"
#define DEBUG_OP_CMD2 "[GarHouse Debug] (OnPlayerCommandText) - %s (%d) ������ ������ � ���� ID %d."
#define DEBUG_OP_CMD3 "[GarHouse Debug] (OnPlayerCommandText) - %s (%d) ������ ��� � ID %d."
#define DEBUG_OP_CMD4 "[GarHouse Debug] (OnPlayerCommandText) - %s (%d) ������ ������ �� ���� � ID %d."
#define DEBUG_OP_CMD5 "[GarHouse Debug] (OnPlayerCommandText) - %s (%d) ������ ��� ���� �� �������. [%d In Total]"
#define DEBUG_OP_CMD6 "[GarHouse Debug] (OnPlayerCommandText) - %s (%d) ������ ��� ������ �� ����� �� �������. [%d In Total]"
#define DEBUG_OP_CMD7 "[GarHouse Debug] (OnPlayerCommandText) - %s (%d) ������� ������� ������ � ���� ��� ���� � ID %d."
#define DEBUG_OP_CMD8 "[GarHouse Debug] (OnPlayerCommandText) - %s (%d) ������ ��� � ID %d."
#define DEBUG_OP_CMD9 "[GarHouse Debug] (OnPlayerCommandText) - %s (%d) ������ ��� ���� �� �������. [%d In Total]"
#define DEBUG_OP_CMD10 "[GarHouse Debug] (OnPlayerCommandText) - %s (%d) ������� ���� ���� � ID %d �� $%d."
#define DEBUG_OP_CMD11 "[GarHouse Debug] (OnPlayerCommandText) - %s (%d) ������� ���� ���� ����� �� ������� �� $%d. [%d In Total]"
#define DEBUG_OP_CMD12 "[GarHouse Debug] (OnPlayerCommandText) - %s (%d) ������� ������ ������ � ���� � ID %d �� %d."
#define DEBUG_OP_SPAWN "[GarHouse Debug] (OnPlayerSpawn) - %s (%d) ��������� � ����� ����."
#endif
//------------------------------------------------------------------------------
//==============================================================================
//                              Awesomeness
//==============================================================================
public OnFilterScriptInit() {
    print("\n>> GarHouse v1.3 By [03]Garsino Loaded <<\n");
    LoadHouses(); // Load houses
    Loop(i, MAX_PLAYERS) {
        if (IsPlayerConnected(i) && !IsPlayerNPC(i)) {
            SetPVarInt(i, "HousePrevTime", 0);
        }
    }
    return 1;
}
public OnFilterScriptExit() {
    new file[HOUSEFILE_LENGTH], tmp;
    Loop(i, MAX_PLAYERS) {
        if (IsPlayerConnected(i) && !IsPlayerNPC(i)) {
            tmp = GetPVarInt(i, "LastHouseCP");
            format(file, sizeof(file), FILEPATH, tmp);
            if (!strcmp(GetHouseOwner(tmp), pNick(i), CASE_SENSETIVE) && GetPVarInt(i, "IsInHouse") == 1 && dini_Exists(file)) {
                dini_IntSet(file, "QuitInHouse", 1);
			    #if defined GH_HOUSECARS
                SaveHouseCar(tmp);
		        #endif
            }
        }
    }
    UnloadHouses(); // Unload houses (also unloads the house cars)
    print("\n>> GarHouse v1.3 By [03]Garsino Unloaded <<\n");
    return 1;
}
public OnPlayerSpawn(playerid) {
    if (GetPVarInt(playerid, "FirstSpawn") == 0) {
        // Used to make the player spawn in their house if they quit in their house (only called for first spawn)
		#if defined SPAWN_IN_HOUSE
        SetTimerEx("HouseSpawning", HSPAWN_TIMER_RATE, false, "i", playerid);
    	#endif
        // Increase timer rate if your gamemodes OnPlayerSpawn gets called after the timer has ended
    }
    return 1;
}
public OnPlayerDisconnect(playerid, reason) {
    new file[HOUSEFILE_LENGTH];
    format(file, sizeof(file), FILEPATH, GetPVarInt(playerid, "LastHouseCP"));
    if (!strcmp(GetHouseOwner(GetPVarInt(playerid, "LastHouseCP")), pNick(playerid), CASE_SENSETIVE) && GetPVarInt(playerid, "IsInHouse") == 1 && dini_Exists(file)) {
        dini_IntSet(file, "QuitInHouse", 1);
	    #if defined GH_HOUSECARS
        SaveHouseCar(GetPVarInt(playerid, "LastHouseCP"));
        UnloadHouseCar(GetPVarInt(playerid, "LastHouseCP"));
        #endif
	    #if defined GH_DEBUGGING
        printf(DEBUG_OP_DISCONNECT, pNick(playerid), playerid);
    	#endif
    }
    return 1;
}
public OnPlayerCommandText(playerid, cmdtext[]) {
    dcmd(removeallhouses, 15, cmdtext);
    dcmd(changeallprices, 15, cmdtext);
    dcmd(removeallhcars, 14, cmdtext);
    dcmd(sellallhouses, 13, cmdtext);
    dcmd(createhouse, 11, cmdtext);
    dcmd(removehouse, 11, cmdtext);
    dcmd(changeprice, 11, cmdtext);
    dcmd(changespawn, 11, cmdtext);
    dcmd(removehcar, 10, cmdtext);
    dcmd(changehcar, 10, cmdtext);
    dcmd(sellhouse, 9, cmdtext);
    dcmd(housemenu, 9, cmdtext);
    dcmd(gotohouse, 9, cmdtext);
    dcmd(addhcar, 7, cmdtext);
    dcmd(ghcmds, 6, cmdtext);
    return 0;
}
#if defined GH_USE_CPS
public OnPlayerEnterDynamicCP(playerid, checkpointid) {
    if (GetPlayerState(playerid) == PLAYER_STATE_ONFOOT) {
        new file[HOUSEFILE_LENGTH], string[256]; // Don't complain about huge size, just change it if you need.
        Loop(h, MAX_HOUSES) {
            format(file, sizeof(file), FILEPATH, h);
            if (checkpointid == HouseCPOut[h]) {
                SetPVarInt(playerid, "LastHouseCP", h);
                if (!strcmp(GetHouseOwner(h), pNick(playerid), CASE_SENSETIVE) /* || IsPlayerAdmin(playerid)*/ ) // If you remove the comment, RCON admins may enter any house they want.
                {
                    SetPVarInt(playerid, "IsInHouse", 1);
                    SetPlayerHouseInterior(playerid, h);
                    if (!strcmp(GetHouseOwner(h), pNick(playerid), CASE_SENSETIVE)) {
                        SendClientMessage(playerid, COLOUR_INFO, I_HMENU);
                    }
			        #if defined GH_DEBUGGING
                    printf(DEBUG_OP_ED_CP1, pNick(playerid), playerid, h);
			    	#endif
                }
                if (strcmp(GetHouseOwner(h), pNick(playerid), CASE_SENSETIVE) && strcmp(GetHouseOwner(h), INVALID_HOWNER_NAME, CASE_SENSETIVE)) {
                    if (!strcmp(dini_Get(file, "HousePassword"), "INVALID_HOUSE_PASSWORD", CASE_SENSETIVE)) {
                        ShowInfoBox(playerid, INFORMATION_HEADER, LABELTEXT2, GetHouseName(h), GetHouseOwner(h), GetHouseValue(h), h);
                    }
                    if (strcmp(dini_Get(file, "HousePassword"), "INVALID_HOUSE_PASSWORD", CASE_SENSETIVE)) {
                        format(string, sizeof(string), HMENU_ENTER_PASS, GetHouseName(h), GetHouseOwner(h), GetHouseValue(h), h);
                        ShowPlayerDialog(playerid, HOUSEMENU + 60, DIALOG_STYLE_INPUT, "GarHouse v1.3 By [03]Garsino - ���� � ����", string, "�����", "�������");
                    }
                }
                if (!strcmp(GetHouseOwner(h), INVALID_HOWNER_NAME, CASE_SENSETIVE) && dini_Int(file, "HouseValue") > 0 && GetPVarInt(playerid, "JustCreatedHouse") == 0) {
                    format(string, sizeof(string), HMENU_BUY_HOUSE, pNick(playerid), GetHouseValue(h));
                    ShowPlayerDialog(playerid, HOUSEMENU + 4, DIALOG_STYLE_MSGBOX, "GarHouse v1.3 By [03]Garsino - ������� ����", string, "������", "������");
                }
                break;
            }
            if (checkpointid == HouseCPInt[h]) {
		        #if defined GH_HINTERIOR_UPGRADE
                if (GetPVarInt(playerid, "HousePreview") == 1) {
                    new tmpstring[50];
                    GetPVarString(playerid, "HousePrevName", tmpstring, 50);
                    format(string, sizeof(string), HMENU_BUY_HINTERIOR, tmpstring, GetPVarInt(playerid, "HousePrevValue"));
                    ShowPlayerDialog(playerid, HOUSEMENU + 17, DIALOG_STYLE_MSGBOX, "GarHouse v1.3 By [03]Garsino - ����� ���������", string, "������", "������");
                }
		        #endif
                if (GetPVarInt(playerid, "HousePreview") == 0) {
                    SetPVarInt(playerid, "IsInHouse", 0);
                    SetPlayerPosEx(playerid, dini_Float(file, "SpawnOutX"), dini_Float(file, "SpawnOutY"), dini_Float(file, "SpawnOutZ"), dini_Int(file, "SpawnInterior"), dini_Int(file, "SpawnWorld"));
                    SetPlayerFacingAngle(playerid, dini_Float(file, "SpawnOutAngle"));
                    SetPlayerInterior(playerid, dini_Int(file, "SpawnInterior"));
                    SetPlayerVirtualWorld(playerid, dini_Int(file, "SpawnWorld"));
			        #if defined GH_DEBUGGING
                    printf(DEBUG_OP_ED_CP2, pNick(playerid), playerid, h);
			    	#endif
                }
                break;
            }
        }
    }
    return 1;
}
public OnPlayerLeaveDynamicCP(playerid, checkpointid) {
    if (GetPlayerState(playerid) == PLAYER_STATE_ONFOOT && GetPVarInt(playerid, "JustCreatedHouse") == 1) {
        Loop(h, MAX_HOUSES) {
            if (checkpointid == HouseCPOut[h]) {
                SetPVarInt(playerid, "JustCreatedHouse", 0);
                break;
            }
        }
    }
    return 1;
}
#endif
#if !defined GH_USE_CPS
public OnPlayerPickUpDynamicPickup(playerid, pickupid) {
    if (GetPlayerState(playerid) == PLAYER_STATE_ONFOOT) {
        new file[HOUSEFILE_LENGTH], string[256]; // Don't complain about huge size, just change it if you need.
        Loop(h, MAX_HOUSES) {
            format(file, sizeof(file), FILEPATH, h);
            if (pickupid == HousePickupOut[h]) {
                SetPVarInt(playerid, "LastHouseCP", h);
                if (!strcmp(GetHouseOwner(h), pNick(playerid), CASE_SENSETIVE) /* || IsPlayerAdmin(playerid)*/ ) // If you remove the comment, RCON admins may enter any house they want.
                {
                    SetPVarInt(playerid, "IsInHouse", 1);
                    SetPlayerHouseInterior(playerid, h);
                    if (!strcmp(GetHouseOwner(h), pNick(playerid), CASE_SENSETIVE)) {
                        SendClientMessage(playerid, COLOUR_INFO, I_HMENU);
                    }
			        #if defined GH_DEBUGGING
                    printf(DEBUG_OP_PUD_PICKUP1, pNick(playerid), playerid, h);
			    	#endif
                }
                if (strcmp(GetHouseOwner(h), pNick(playerid), CASE_SENSETIVE) && strcmp(GetHouseOwner(h), INVALID_HOWNER_NAME, CASE_SENSETIVE)) {
                    if (!strcmp(dini_Get(file, "HousePassword"), "INVALID_HOUSE_PASSWORD", CASE_SENSETIVE)) {
                        ShowInfoBox(playerid, INFORMATION_HEADER, LABELTEXT2, GetHouseName(h), GetHouseOwner(h), GetHouseValue(h), h);
                    }
                    if (strcmp(dini_Get(file, "HousePassword"), "INVALID_HOUSE_PASSWORD", CASE_SENSETIVE)) {
                        format(string, sizeof(string), HMENU_ENTER_PASS, GetHouseName(h), GetHouseOwner(h), GetHouseValue(h), h);
                        ShowPlayerDialog(playerid, HOUSEMENU + 60, DIALOG_STYLE_INPUT, "GarHouse v1.3 By [03]Garsino - ���� � ����", string, "�����", "�������");
                    }
                }
                if (!strcmp(GetHouseOwner(h), INVALID_HOWNER_NAME, CASE_SENSETIVE) && dini_Int(file, "HouseValue") > 0) {
                    format(string, sizeof(string), HMENU_BUY_HOUSE, pNick(playerid), GetHouseValue(h));
                    ShowPlayerDialog(playerid, HOUSEMENU + 4, DIALOG_STYLE_MSGBOX, "GarHouse v1.3 By [03]Garsino - ������� ����", string, "������", "������");
                }
                break;
            }
            if (pickupid == HousePickupInt[h]) {
		        #if defined GH_HINTERIOR_UPGRADE
                if (GetPVarInt(playerid, "HousePreview") == 1) {
                    new tmpstring[50];
                    GetPVarString(playerid, "HousePrevName", tmpstring, 50);
                    format(string, sizeof(string), HMENU_BUY_HINTERIOR, tmpstring, GetPVarInt(playerid, "HousePrevValue"));
                    ShowPlayerDialog(playerid, HOUSEMENU + 17, DIALOG_STYLE_MSGBOX, "GarHouse v1.3 By [03]Garsino - ������� ���������", string, "������", "������");
                }
		        #endif
                if (GetPVarInt(playerid, "HousePreview") == 0) {
                    SetPVarInt(playerid, "IsInHouse", 0);
                    SetPlayerPosEx(playerid, dini_Float(file, "SpawnOutX"), dini_Float(file, "SpawnOutY"), dini_Float(file, "SpawnOutZ"), dini_Int(file, "SpawnInterior"), dini_Int(file, "SpawnWorld"));
                    SetPlayerFacingAngle(playerid, dini_Float(file, "SpawnOutAngle"));
                    SetPlayerInterior(playerid, dini_Int(file, "SpawnInterior"));
                    SetPlayerVirtualWorld(playerid, dini_Int(file, "SpawnWorld"));
			        #if defined GH_DEBUGGING
                    printf(DEBUG_OP_PUD_PICKUP2, pNick(playerid), playerid, h);
			    	#endif
                }
                break;
            }
        }
    }
    return 1;
}
#endif
public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) {
    new string[400], file[HOUSEFILE_LENGTH], file2[HOUSEFILE_LENGTH], h = GetPVarInt(playerid, "LastHouseCP"); // Don't complain about huge size, just change it if you need.
    format(file, sizeof(file), FILEPATH, h);
    if (dialogid == HOUSEMENU && response) {
        switch (listitem) {
            case 0: {
                format(string, sizeof(string), HMENU_SELL_HOUSE, pNick(playerid), GetHouseName(h), ReturnProcent(GetHouseValue(h), HOUSE_SELLING_PROCENT));
                ShowPlayerDialog(playerid, HOUSEMENU + 3, DIALOG_STYLE_MSGBOX, "GarHouse v1.3 By [03]Garsino - ������� ����", string, "�������", "������");
            }
            case 1: {
				#if defined GH_USE_WEAPONSTORAGE
                ShowPlayerDialog(playerid, HOUSEMENU + 18, DIALOG_STYLE_LIST, "GarHouse v1.3 By [03]Garsino - �������� � ����", "������ �� ��������\n������ �� ��������", "�������", "������");
				#endif
				#if !defined GH_USE_WEAPONSTORAGE
                ShowPlayerDialog(playerid, HOUSEMENU + 10, DIALOG_STYLE_LIST, "GarHouse v1.3 By [03]Garsino - �������� � ����", "�������� ������\n����� ������\n��������� ������", "�������", "������");
				#endif
            }
            case 2 : ShowPlayerDialog(playerid, HOUSEMENU + 14, DIALOG_STYLE_INPUT, "GarHouse v1.3 By [03]Garsino - �������� ����", "������� ����� �������� ����:\n\n������� '������' ����� ��������", "��", "������");
            case 3 : ShowPlayerDialog(playerid, HOUSEMENU + 13, DIALOG_STYLE_INPUT, "GarHouse v1.3 By [03]Garsino - ����� ������ �� ����", "������� ����� ������ �� ����:\n�������� ���� ���� �� ������ �������� ������� ������.\n������� '�������', ����� ������� ������.", "��", "�������");
            case 4 : ShowPlayerDialog(playerid, HOUSEMENU + 16, DIALOG_STYLE_LIST, "GarHouse v1.3 By [03]Garsino - ����� ��������� ����", "���������� ��������\n������ ������� ��������", "�������", "������");
        }
        return 1;
    }
    //------------------------------------------------------------------------------
    //                               House Sale
    //------------------------------------------------------------------------------
    if (dialogid == HOUSEMENU + 3 && response) {
        if (GetOwnedHouses(playerid) == 0) return SendClientMessage(playerid, COLOUR_SYSTEM, E_NO_HOUSES_OWNED);
        else {
            new tmp = dini_Int(file, "HouseStorage");
            GivePlayerMoney(playerid, ReturnProcent(GetHouseValue(h), HOUSE_SELLING_PROCENT));
            if (tmp >= 1) {
                ShowInfoBox(playerid, INFORMATION_HEADER, I_SELL_HOUSE1, ReturnProcent(GetHouseValue(h), HOUSE_SELLING_PROCENT), (GetHouseValue(h) - ReturnProcent(GetHouseValue(h), HOUSE_SELLING_PROCENT)), tmp);
                GivePlayerMoney(playerid, tmp);
            }
            if (tmp == 0) {
                ShowInfoBox(playerid, INFORMATION_HEADER, I_SELL_HOUSE2, GetHouseName(h), ReturnProcent(GetHouseValue(h), HOUSE_SELLING_PROCENT), (GetHouseValue(h) - ReturnProcent(GetHouseValue(h), HOUSE_SELLING_PROCENT)));
            }
            dini_IntSet(file, "HouseValue", ReturnProcent(GetHouseValue(h), HOUSE_SELLING_PROCENT));
            dini_Set(file, "HouseOwner", INVALID_HOWNER_NAME);
            dini_Set(file, "HousePassword", "INVALID_HOUSE_PASSWORD");
            dini_Set(file, "HouseName", DEFAULT_HOUSE_NAME);
            dini_IntSet(file, "HouseStorage", 0);
            Loop(h2, MAX_HOUSES) {
                if (IsHouseInRangeOfHouse(h, h2, RANGE_BETWEEN_HOUSES) && h2 != h) {
                    format(file2, sizeof(file2), FILEPATH, h2);
                    dini_IntSet(file2, "HouseValue", (dini_Int(file2, "HouseValue") - ReturnProcent(GetHouseValue(h2), HOUSE_SELLING_PROCENT2)));
                    UpdateHouseText(h2);
                }
            }
			#if defined GH_USE_MAPICONS
            DestroyDynamicMapIcon(HouseMIcon[h]);
            HouseMIcon[h] = CreateDynamicMapIcon(dini_Float(file, "CPOutX"), dini_Float(file, "CPOutY"), dini_Float(file, "CPOutZ"), 31, -1, dini_Int(file, "SpawnWorld"), dini_Int(file, "SpawnInterior"), -1, MICON_VD);
			#endif
            UpdateHouseText(h);
            #if defined GH_DEBUGGING
            printf(DEBUG_ODR13, pNick(playerid), playerid, GetHouseValue(h), tmp, h);
	    	#endif
        }
        return 1;
    }
    //------------------------------------------------------------------------------
    //                               House Buying
    //------------------------------------------------------------------------------
    if (dialogid == HOUSEMENU + 4) {
        if (response) {
            new hname[MAX_PLAYER_NAME + 9];
            if (GetOwnedHouses(playerid) >= MAX_HOUSES_OWNED) { ShowInfoBox(playerid, INFORMATION_HEADER, "�� ��� �������� %d ���%s. �������� ���� ���� �� ������� ������.", MAX_HOUSES_OWNED, AddS(MAX_HOUSES_OWNED)); return 0; }
            if (strcmp(GetHouseOwner(GetPVarInt(playerid, "LastHouseCP")), pNick(playerid), CASE_SENSETIVE) && strcmp(GetHouseOwner(h), INVALID_HOWNER_NAME, CASE_SENSETIVE)) return SendClientMessage(playerid, COLOUR_SYSTEM, E_H_ALREADY_OWNED);
            if (GetHouseValue(h) > GetPlayerMoney(playerid)) { ShowInfoBox(playerid, INFORMATION_HEADER, "�� �� ������ ������ ���.\n��������� ����: $%d.\n� ���: $%d.\n��� �����: $%d.", GetHouseValue(h), GetPlayerMoney(playerid), (GetHouseValue(h) - GetPlayerMoney(playerid))); return 0; } else {
                format(hname, sizeof(hname), "%s's House", pNick(playerid));
                GivePlayerMoney(playerid, -GetHouseValue(h));
                dini_Set(file, "HouseOwner", pNick(playerid));
                dini_Set(file, "HousePassword", "INVALID_HOUSE_PASSWORD");
                dini_Set(file, "HouseName", hname);
                dini_IntSet(file, "HouseStorage", 0);
                ShowInfoBox(playerid, INFORMATION_HEADER, I_BUY_HOUSE, GetHouseValue(h));
                Loop(h2, MAX_HOUSES) {
                    if (IsHouseInRangeOfHouse(h, h2, RANGE_BETWEEN_HOUSES) && h2 != h) {
                        format(file2, sizeof(file2), FILEPATH, h2);
                        dini_IntSet(file2, "HouseValue", (dini_Int(file2, "HouseValue") + ReturnProcent(GetHouseValue(h2), HOUSE_SELLING_PROCENT2)));
                        UpdateHouseText(h2);
                    }
                }
				#if defined GH_USE_MAPICONS
                DestroyDynamicMapIcon(HouseMIcon[h]);
                HouseMIcon[h] = CreateDynamicMapIcon(dini_Float(file, "CPOutX"), dini_Float(file, "CPOutY"), dini_Float(file, "CPOutZ"), 32, -1, dini_Int(file, "SpawnWorld"), dini_Int(file, "SpawnInterior"), -1, MICON_VD);
				#endif
                UpdateHouseText(h);
                #if defined GH_DEBUGGING
                printf(DEBUG_ODR1, pNick(playerid), playerid, h, GetHouseValue(h));
	    		#endif
            }
        }
        return 1;
    }
    //------------------------------------------------------------------------------
    //                               House Password
    //------------------------------------------------------------------------------
    if (dialogid == HOUSEMENU + 13) {
        if (response) {
            if (strlen(inputtext) > MAX_HOUSE_PASSWORD || (strlen(inputtext) < MIN_HOUSE_PASSWORD && strlen(inputtext) >= 1)) return SendClientMessage(playerid, COLOUR_SYSTEM, E_INVALID_HPASS_LENGTH);
            if (!strcmp(inputtext, "INVALID_HOUSE_PASSWORD", CASE_SENSETIVE)) return SendClientMessage(playerid, COLOUR_SYSTEM, E_INVALID_HPASS);
            if (strfind(inputtext, "%", CASE_SENSETIVE) != -1 || strfind(inputtext, "~", CASE_SENSETIVE) != -1) return SendClientMessage(playerid, COLOUR_SYSTEM, E_INVALID_HPASS_CHARS);
            else {
                if (strlen(inputtext) >= 1) {
                    dini_IntSet(file, "HousePassword", udb_hash(inputtext));
                    ShowInfoBox(playerid, INFORMATION_HEADER, I_HPASSWORD_CHANGED, inputtext);
                    #if defined GH_DEBUGGING
                    printf(DEBUG_ODR14, pNick(playerid), playerid, h);
	    			#endif
                } else SendClientMessage(playerid, COLOUR_INFO, I_HPASS_NO_CHANGE);
            }
        }
        if (!response) {
            dini_Set(file, "HousePassword", "INVALID_HOUSE_PASSWORD");
            SendClientMessage(playerid, COLOUR_INFO, I_HPASS_REMOVED);
        }
        return 1;
    }
    //------------------------------------------------------------------------------
    //                               House Name
    //------------------------------------------------------------------------------
    if (dialogid == HOUSEMENU + 14) {
        if (response) {
            if (strfind(inputtext, "%", CASE_SENSETIVE) != -1 || strfind(inputtext, "~", CASE_SENSETIVE) != -1) return SendClientMessage(playerid, COLOUR_SYSTEM, E_INVALID_HNAME_CHARS);
            if (strlen(inputtext) < MIN_HOUSE_NAME || strlen(inputtext) > MAX_HOUSE_NAME) return SendClientMessage(playerid, COLOUR_SYSTEM, E_INVALID_HNAME_LENGTH);
            else {
                dini_Set(file, "HouseName", inputtext);
                SendMSG(playerid, COLOUR_INFO, 128, I_HNAME_CHANGED, inputtext);
                UpdateHouseText(h);
                #if defined GH_DEBUGGING
                printf(DEBUG_ODR2, pNick(playerid), playerid, h, inputtext);
  				#endif
            }
        }
        return 1;
    }
    //------------------------------------------------------------------------------
    //                       House Interior Upgrade
    //------------------------------------------------------------------------------
    if (dialogid == HOUSEMENU + 15 && response) {
        SetPVarInt(playerid, "OldHouseInt", dini_Int(file, "HouseInterior"));
        switch (listitem) {
            case 0: {
                SetPVarInt(playerid, "HousePrevInt", 1);
                SetPVarInt(playerid, "HousePrevValue", H_INT_1_VALUE);
                SetPVarString(playerid, "HousePrevName", "Shitty Shack");
            }
            case 1: {
                SetPVarInt(playerid, "HousePrevInt", 2);
                SetPVarInt(playerid, "HousePrevValue", H_INT_2_VALUE);
                SetPVarString(playerid, "HousePrevName", "Motel Room");
            }
            case 2: {
                SetPVarInt(playerid, "HousePrevInt", 3);
                SetPVarInt(playerid, "HousePrevValue", H_INT_3_VALUE);
                SetPVarString(playerid, "HousePrevName", "Hotel Room 1");
            }
            case 3: {
                SetPVarInt(playerid, "HousePrevInt", 4);
                SetPVarInt(playerid, "HousePrevValue", H_INT_4_VALUE);
                SetPVarString(playerid, "HousePrevName", "Hotel Room 2");
            }
            case 4: {
                SetPVarInt(playerid, "HousePrevInt", 5);
                SetPVarInt(playerid, "HousePrevValue", H_INT_5_VALUE);
                SetPVarString(playerid, "HousePrevName", "Gang House");
            }
            case 5: {
                SetPVarInt(playerid, "HousePrevInt", 6);
                SetPVarInt(playerid, "HousePrevValue", H_INT_6_VALUE);
                SetPVarString(playerid, "HousePrevName", "Normal House");
            }
            case 6: {
                SetPVarInt(playerid, "HousePrevInt", 0);
                SetPVarInt(playerid, "HousePrevValue", H_INT_0_VALUE);
                SetPVarString(playerid, "HousePrevName", "Default House");
            }
            case 7: {
                SetPVarInt(playerid, "HousePrevInt", 7);
                SetPVarInt(playerid, "HousePrevValue", H_INT_7_VALUE);
                SetPVarString(playerid, "HousePrevName", "Medium Mansion");
            }
            case 8: {
                SetPVarInt(playerid, "HousePrevInt", 8);
                SetPVarInt(playerid, "HousePrevValue", H_INT_8_VALUE);
                SetPVarString(playerid, "HousePrevName", "Rich Mansion");
            }
            case 9: {
                SetPVarInt(playerid, "HousePrevInt", 9);
                SetPVarInt(playerid, "HousePrevValue", H_INT_9_VALUE);
                SetPVarString(playerid, "HousePrevName", "Huge Mansion");
            }
            case 10: {
                SetPVarInt(playerid, "HousePrevInt", 10);
                SetPVarInt(playerid, "HousePrevValue", H_INT_10_VALUE);
                SetPVarString(playerid, "HousePrevName", "Madd Dogg's Mansion");
            }
        }
        if (dini_Int(file, "HouseInterior") == GetPVarInt(playerid, "HousePrevInt")) return SendClientMessage(playerid, COLOUR_SYSTEM, E_ALREADY_HAVE_HINTERIOR);
        else {
            GetPVarString(playerid, "HousePrevName", string, 50);
            //------------------------------------------------------------------------------
            switch (GetPVarInt(playerid, "HouseIntUpgradeMod")) {
                case 1: {
                    if (GetSecondsBetweenAction(GetPVarInt(playerid, "HousePrevTime")) < (TIME_BETWEEN_VISITS * 60000) && GetPVarInt(playerid, "HousePrevTime") != 0) return SendClientMessage(playerid, COLOUR_SYSTEM, E_HINT_WAIT_BEFORE_VISITING);
                    else {
                        SetPVarInt(playerid, "IsHouseVisiting", 1);
                        SetPVarInt(playerid, "HousePreview", 1);
                        SetPVarInt(playerid, "ChangeHouseInt", 1);
                        SetPVarInt(playerid, "HousePrevTime", GetTickCount());
                        SetPVarInt(playerid, "HousePrevTimer", SetTimerEx("HouseVisiting", (MAX_VISIT_TIME * 60000), false, "i", playerid));
                        ShowInfoBox(playerid, INFORMATION_HEADER, I_VISITING_HOUSEINT, string, GetPVarInt(playerid, "HousePrevValue"), MAX_VISIT_TIME, AddS(MAX_VISIT_TIME));
	                    #if defined GH_DEBUGGING
                        printf(DEBUG_ODR4, pNick(playerid), playerid, string, h);
	  					#endif
                    }
                }
                case 2: {
                    if (GetPVarInt(playerid, "HousePrevValue") > GetPlayerMoney(playerid)) {
                        ShowInfoBox(playerid, INFORMATION_HEADER, E_CANT_AFFORD_HINT, string, GetPVarInt(playerid, "HousePrevValue"), GetPlayerMoney(playerid), (GetPVarInt(playerid, "HousePrevValue") - GetPlayerMoney(playerid)));
                    }
                    if (GetPVarInt(playerid, "HousePrevValue") <= GetPlayerMoney(playerid)) {
                        GivePlayerMoney(playerid, -GetPVarInt(playerid, "HousePrevValue"));
                        SetPVarInt(playerid, "ChangeHouseInt", 1);
                        dini_IntSet(file, "HouseInteriorValue", GetPVarInt(playerid, "HousePrevValue"));
                        ShowInfoBox(playerid, INFORMATION_HEADER, I_HINT_BOUGHT, string, GetPVarInt(playerid, "HousePrevValue"));
                        #if defined GH_DEBUGGING
                        printf(DEBUG_ODR3, pNick(playerid), playerid, string, GetPVarInt(playerid, "HousePrevValue"), h);
  						#endif
                    }
                }
            }
            //------------------------------------------------------------------------------
            if (GetPVarInt(playerid, "ChangeHouseInt") == 1) {
                dini_IntSet(file, "HouseInterior", GetPVarInt(playerid, "HousePrevInt"));
                SetPVarInt(playerid, "ChangeHouseInt", 0);
                DestroyHouseEntrance(h, TYPE_INT);
                CreateCorrectHouseExitCP(h);
                Loop(i, MAX_PLAYERS) {
                    if (GetPVarInt(i, "LastHouseCP") == h && GetPVarInt(i, "IsInHouse") == 1) {
                        SetPlayerHouseInterior(i, h);
                    }
                }
		  		#if defined GH_DEBUGGING
                printf(DEBUG_ODR5, h, GetPVarInt(playerid, "HousePrevInt"));
				#endif
            }
            //------------------------------------------------------------------------------
        }
        return 1;
    }
    //------------------------------------------------------------------------------
    //                       House Interior Mode Selecting
    //------------------------------------------------------------------------------
    #if defined GH_HINTERIOR_UPGRADE
    if (dialogid == HOUSEMENU + 16 && response) {
        switch (listitem) {
            case 0 : SetPVarInt(playerid, "HouseIntUpgradeMod", 1);
            case 1 : SetPVarInt(playerid, "HouseIntUpgradeMod", 2);
        }
        format(string, sizeof(string),
            "Shitty Shack Interior\t\t%s\nMotel Room Interior\t\t%s\nHotel Room Interior 1\t\t%s\nHotel Room Interior 2\t\t%s\nGang House Interior\t\t%s\nNormal House Interior\t\t%s\nDefault House Interior\t\t%s\nMedium Mansion Interior\t%s\nRich Mansion Interior\t\t%s\nHuge Mansion Interior\t\t%s\nMadd Dogg's Mansion\t\t%s",
            FM(H_INT_1_VALUE), FM(H_INT_2_VALUE), FM(H_INT_3_VALUE), FM(H_INT_4_VALUE), FM(H_INT_5_VALUE), FM(H_INT_6_VALUE), FM(H_INT_0_VALUE), FM(H_INT_7_VALUE), FM(H_INT_8_VALUE), FM(H_INT_9_VALUE), FM(H_INT_10_VALUE));
        ShowPlayerDialog(playerid, HOUSEMENU + 15, DIALOG_STYLE_LIST, "GarHouse v1.3 By [03]Garsino - House Interior", string, "������", "������");
        return 1;
    }
	#endif
    //------------------------------------------------------------------------------
    //                       House Interior Upgrade
    //------------------------------------------------------------------------------
    #if defined GH_HINTERIOR_UPGRADE
    if (dialogid == HOUSEMENU + 17) {
        SetPVarInt(playerid, "HousePreview", 0);
        KillTimer(GetPVarInt(playerid, "HousePrevTimer"));
        SetPVarInt(playerid, "IsHouseVisiting", 0);
        switch (response) {
            case 0: {
                dini_IntSet(file, "HouseInterior", GetPVarInt(playerid, "OldHouseInt"));
            }
            case 1: {
                GetPVarString(playerid, "HousePrevName", string, 50);
                if (GetPlayerMoney(playerid) < GetPVarInt(playerid, "HousePrevValue")) {
                    dini_IntSet(file, "HouseInterior", GetPVarInt(playerid, "OldHouseInt"));
                    ShowInfoBox(playerid, INFORMATION_HEADER, E_CANT_AFFORD_HINT, string, GetPVarInt(playerid, "HousePrevValue"), GetPlayerMoney(playerid), (GetPVarInt(playerid, "HousePrevValue") - GetPlayerMoney(playerid)));
                } else {
                    GivePlayerMoney(playerid, -GetPVarInt(playerid, "HousePrevValue"));
                    dini_Set(file, "HouseInteriorName", string);
                    dini_IntSet(file, "HouseInterior", GetPVarInt(playerid, "HousePrevInt"));
                    dini_IntSet(file, "HouseInteriorValue", GetPVarInt(playerid, "HousePrevValue"));
                    ShowInfoBox(playerid, INFORMATION_HEADER, I_HINT_BOUGHT, string, GetPVarInt(playerid, "HousePrevValue"));
                    #if defined GH_DEBUGGING
                    printf(DEBUG_ODR3, pNick(playerid), playerid, string, GetPVarInt(playerid, "HousePrevValue"), h);
					#endif
                }
            }
        }
        //------------------------------------------------------------------------------
        DestroyHouseEntrance(h, TYPE_INT);
        CreateCorrectHouseExitCP(h);
        Loop(i, MAX_PLAYERS) {
            if (GetPVarInt(i, "LastHouseCP") == h && GetPVarInt(i, "IsInHouse") == 1) {
                SetPlayerHouseInterior(i, h);
            }
        }
		#if defined GH_DEBUGGING
        printf(DEBUG_ODR5, h, GetPVarInt(playerid, "HousePrevInt"));
		#endif
        //------------------------------------------------------------------------------
        return 1;
    }
	#endif
    //------------------------------------------------------------------------------
    //                               Money Storage
    //------------------------------------------------------------------------------
    if (dialogid == HOUSEMENU + 10 && response) {
        new tmp = dini_Int(file, "HouseStorage");
        if (listitem == 0) // Deposit
        {
            format(string, sizeof(string), I_HINT_DEPOSIT1, tmp);
            ShowPlayerDialog(playerid, HOUSEMENU + 11, DIALOG_STYLE_INPUT, "GarHouse v1.3 By [03]Garsino - �������� � ����", string, "��������", "������");
        }
        if (listitem == 1) // Withdraw
        {
            format(string, sizeof(string), I_HINT_WITHDRAW1, tmp);
            ShowPlayerDialog(playerid, HOUSEMENU + 12, DIALOG_STYLE_INPUT, "GarHouse v1.3 By [03]Garsino - �������� � ����", string, "�����", "������");
        }
        if (listitem == 2) // Check Balance
        {
            ShowInfoBox(playerid, INFORMATION_HEADER, I_HINT_CHECKBALANCE, tmp);
            #if defined GH_DEBUGGING
            printf(DEBUG_ODR6, pNick(playerid), playerid, h, tmp);
			#endif
        }
        return 1;
    }
    //------------------------------------------------------------------------------
    if (dialogid == HOUSEMENU + 11 && response) {
        new amount = floatround(strval(inputtext));
        format(file, sizeof(file), FILEPATH, h);
        if (amount > GetPlayerMoney(playerid)) return SendClientMessage(playerid, COLOUR_SYSTEM, E_NOT_ENOUGH_PMONEY);
        if (amount < 1) return SendClientMessage(playerid, COLOUR_SYSTEM, E_INVALID_AMOUNT);
        if ((dini_Int(file, "HouseStorage") + amount) >= 25000000) return SendClientMessage(playerid, COLOUR_SYSTEM, E_HSTORAGE_L_REACHED);
        else {
            dini_IntSet(file, "HouseStorage", (dini_Int(file, "HouseStorage") + amount));
            GivePlayerMoney(playerid, -amount);
            ShowInfoBox(playerid, INFORMATION_HEADER, I_HINT_DEPOSIT2, amount, dini_Int(file, "HouseStorage"));
            #if defined GH_DEBUGGING
            printf(DEBUG_ODR7, pNick(playerid), playerid, amount, h);
			#endif
        }
        return 1;
    }
    //------------------------------------------------------------------------------
    if (dialogid == HOUSEMENU + 12 && response) {
        new amount = floatround(strval(inputtext));
        format(file, sizeof(file), FILEPATH, h);
        if (amount > dini_Int(file, "HouseStorage")) return SendClientMessage(playerid, COLOUR_SYSTEM, E_NOT_ENOUGH_HSMONEY);
        if (amount < 1) return SendClientMessage(playerid, COLOUR_SYSTEM, E_INVALID_AMOUNT);
        else {
            dini_IntSet(file, "HouseStorage", (dini_Int(file, "HouseStorage") - amount));
            GivePlayerMoney(playerid, amount);
            ShowInfoBox(playerid, INFORMATION_HEADER, I_HINT_WITHDRAW2, amount, dini_Int(file, "HouseStorage"));
            #if defined GH_DEBUGGING
            printf(DEBUG_ODR8, pNick(playerid), playerid, amount, h);
			#endif
        }
        return 1;
    }
    //------------------------------------------------------------------------------
    //                          House Storage
    //------------------------------------------------------------------------------
    if (dialogid == HOUSEMENU + 18 && response) {
        switch (listitem) {
            case 0 : ShowPlayerDialog(playerid, HOUSEMENU + 10, DIALOG_STYLE_LIST, "GarHouse v1.3 By [03]Garsino - �������� � ����", "�������� ������\n����� ������\n������� ������", "�������", "������");
            case 1 : ShowPlayerDialog(playerid, HOUSEMENU + 19, DIALOG_STYLE_LIST, "GarHouse v1.3 By [03]Garsino - �������� � ����", "�������� ������� ������\n�������� ������ �� ����", "�������", "������");
        }
    }
    //------------------------------------------------------------------------------
    //                          Weapon Storage
    //------------------------------------------------------------------------------
    if (dialogid == HOUSEMENU + 19 && response) {
        new WeaponData[13][2], tmp[9], tmp2[13], tmpcount;
        switch (listitem) {
            case 0 :  // Store weapons
            {
                Loop(weap, 13) {
                    format(tmp, sizeof(tmp), "Weapon%d", weap);
                    format(tmp2, sizeof(tmp2), "Weapon%dAmmo", weap);
                    if (weap == 0) continue;
				    #if !defined GH_SAVE_ADMINWEPS
                    if (weap == 7 || weap == 8 || weap == 9 || weap == 12) continue;
				    #endif
                    GetPlayerWeaponData(playerid, weap, WeaponData[weap][0], WeaponData[weap][1]);
                    if (WeaponData[weap][1] == 0 || (weap == 11 && WeaponData[weap][0] != 46)) continue;
                    dini_IntSet(file, tmp, WeaponData[weap][0]);
                    dini_IntSet(file, tmp2, WeaponData[weap][1]);
                    GivePlayerWeapon(playerid, WeaponData[weap][0], -WeaponData[weap][1]);
                    tmpcount++;
                }
                if (tmpcount >= 1) {
                    ShowInfoBox(playerid, INFORMATION_HEADER, I_HS_WEAPONS1, tmpcount, AddS(tmpcount));
                }
                if (tmpcount == 0) {
                    ShowInfoBox(playerid, INFORMATION_HEADER, E_NO_WEAPONS, tmpcount);
                }
	            #if defined GH_DEBUGGING
                printf(DEBUG_ODR10, pNick(playerid), playerid, tmpcount, AddS(tmpcount), h);
				#endif
            }
            case 1 :  // Recieve Weapons
            {
                Loop(weap, 13) {
                    format(tmp, sizeof(tmp), "Weapon%d", weap);
                    format(tmp2, sizeof(tmp2), "Weapon%dAmmo", weap);
                    if (dini_Int(file, tmp2) == 0) continue;
                    if (weap == 0) continue;
				    #if !defined GH_SAVE_ADMINWEPS
                    if (weap == 7 || weap == 8 || weap == 9 || weap == 11 || weap == 12) continue;
				    #endif
                    GivePlayerWeapon(playerid, dini_Int(file, tmp), dini_Int(file, tmp2));
                    dini_IntSet(file, tmp, 0);
                    dini_IntSet(file, tmp2, 0);
                    tmpcount++;
                }
                if (tmpcount >= 1) {
                    ShowInfoBox(playerid, INFORMATION_HEADER, I_HS_WEAPONS2, tmpcount, AddS(tmpcount));
                }
                if (tmpcount == 0) {
                    ShowInfoBox(playerid, INFORMATION_HEADER, E_NO_HS_WEAPONS, tmpcount); // I had to add tmpcount or it gave an error ^_^
                }
				#if defined GH_DEBUGGING
                printf(DEBUG_ODR11, pNick(playerid), playerid, tmpcount, AddS(tmpcount), h);
				#endif
            }
        }
    }
    //------------------------------------------------------------------------------
    //                          Enter House Using Password
    //------------------------------------------------------------------------------
    if (dialogid == HOUSEMENU + 60) {
        if (response) {
            format(file, sizeof(file), FILEPATH, h);
            if (strfind(inputtext, "%", CASE_SENSETIVE) != -1 || strfind(inputtext, "~", CASE_SENSETIVE) != -1) return SendClientMessage(playerid, COLOUR_SYSTEM, E_INVALID_HPASS_CHARS2);
            if (strlen(inputtext) < MIN_HOUSE_PASSWORD || strlen(inputtext) > MAX_HOUSE_PASSWORD) return SendClientMessage(playerid, COLOUR_SYSTEM, E_INVALID_HPASS_LENGTH);
            if (udb_hash(inputtext) != dini_Int(file, "HousePassword")) {
                ShowInfoBox(playerid, INFORMATION_HEADER, I_WRONG_HPASS1, GetHouseOwner(GetPVarInt(playerid, "LastHouseCP")), inputtext);
                if (IsPlayerConnected(GetHouseOwnerEx(GetPVarInt(playerid, "LastHouseCP")))) {
                    SendMSG(GetHouseOwnerEx(h), COLOUR_INFO, 128, I_WRONG_HPASS2, pNick(playerid), playerid, inputtext);
                }
            } else {
                ShowInfoBox(playerid, INFORMATION_HEADER, I_CORRECT_HPASS1, GetHouseOwner(GetPVarInt(playerid, "LastHouseCP")), inputtext);
                SetPVarInt(playerid, "IsInHouse", 1);
                SetPlayerHouseInterior(playerid, GetPVarInt(playerid, "LastHouseCP"));
                if (IsPlayerConnected(GetHouseOwnerEx(GetPVarInt(playerid, "LastHouseCP")))) {
                    SendMSG(GetHouseOwnerEx(h), COLOUR_INFO, 128, I_CORRECT_HPASS2, pNick(playerid), playerid, inputtext);
                }
				#if defined GH_DEBUGGING
                printf(DEBUG_ODR12, pNick(playerid), playerid, h);
				#endif
            }
        }
        return 1;
    }
    return 0; // It is important to have return 0; here at the end of ALL your scripts wich uses dialogs.
}
//==============================================================================
// GetPosInFrontOfPlayer(playerid, &Float:x, &Float:y, Float:distance);
// Used to get the position infront of a player.
// Credits to whoever made this!
//==============================================================================
stock Float:GetPosInFrontOfPlayer(playerid, & Float:x, & Float:y, Float:distance) {
    new Float:a;
    GetPlayerPos(playerid, x, y, a);
    if (IsPlayerInAnyVehicle(playerid)) GetVehicleZAngle(GetPlayerVehicleID(playerid), a);
    else GetPlayerFacingAngle(playerid, a);
    x += (distance * floatsin(-a, degrees));
    y += (distance * floatcos(-a, degrees));
    return a;
}
//##############################################################################
// 								Commands
//##############################################################################
// 							  By [03]Garsino!
//==============================================================================
// This command is used to display the house owner menu
// when a player is in a house and is the house owner.
//==============================================================================
dcmd_housemenu(playerid, params[]) {
	#pragma unused params
    if (strcmp(GetHouseOwner(GetPVarInt(playerid, "LastHouseCP")), pNick(playerid), CASE_SENSETIVE) && GetPVarInt(playerid, "IsInHouse") == 1) return SendClientMessage(playerid, COLOUR_SYSTEM, E_C_ACCESS_SE_HM);
    if (GetPVarInt(playerid, "IsInHouse") == 0) return SendClientMessage(playerid, COLOUR_SYSTEM, E_NOT_IN_HOUSE);
    if (GetOwnedHouses(playerid) == 0) return SendClientMessage(playerid, COLOUR_SYSTEM, E_NOT_HOWNER);
    if (GetPVarInt(playerid, "IsInHouse") == 1 && !strcmp(GetHouseOwner(GetPVarInt(playerid, "LastHouseCP")), pNick(playerid), CASE_SENSETIVE) && GetOwnedHouses(playerid) >= 1) {
	    #if defined GH_HINTERIOR_UPGRADE
        ShowPlayerDialog(playerid, HOUSEMENU, DIALOG_STYLE_LIST, "GarHouse v1.3 By [03]Garsino - ���� ����", "������� ���\n�������� � ����\n���������� �������� ����\n���������� ������\n������/���������� ���������", "�������", "������");
		#endif
		#if !defined GH_HINTERIOR_UPGRADE
        ShowPlayerDialog(playerid, HOUSEMENU, DIALOG_STYLE_LIST, "GarHouse v1.3 By [03]Garsino - ���� ����", "������� ���\n�������� � ����\n���������� �������� ����\n���������� ������", "�������", "������");
		#endif
    }
    return 1;
}
//==============================================================================
// This command is used to create a house.
// The only thing you have to enter is the house value,
// the rest is done by the script.
//==============================================================================
dcmd_createhouse(playerid, params[]) {
    new cost, file[HOUSEFILE_LENGTH], h = GetFreeHouseID(), labeltext[150], hinterior;
    if (!IsPlayerAdmin(playerid)) return 0;
    if (sscanf(params, "dD("
            #DEFAULT_H_INTERIOR ")", cost, hinterior)) return SendClientMessage(playerid, COLOUR_SYSTEM, E_CMD_USAGE_CREATEHOUSE);
    if (h < 0) {
        ShowInfoBox(playerid, INFORMATION_HEADER, E_TOO_MANY_HOUSES, MAX_HOUSES);
    }
    if (cost < MIN_HOUSE_VALUE || cost > MAX_HOUSE_VALUE) return SendClientMessage(playerid, COLOUR_SYSTEM, E_INVALID_HVALUE);
    else {
        format(file, sizeof(file), FILEPATH, h);
        dini_Create(file);
        GetPlayerPos(playerid, X, Y, Z);
        GetPlayerFacingAngle(playerid, Angle);
        dini_FloatSet(file, "CPOutX", X);
        dini_FloatSet(file, "CPOutY", Y);
        dini_FloatSet(file, "CPOutZ", Z);
        dini_Set(file, "HouseName", DEFAULT_HOUSE_NAME);
        dini_Set(file, "HouseOwner", INVALID_HOWNER_NAME);
        dini_Set(file, "HousePassword", "INVALID_HOUSE_PASSWORD");
        dini_Set(file, "HouseCreator", pNick(playerid));
        dini_IntSet(file, "HouseValue", cost);
        dini_IntSet(file, "HouseStorage", 0);
        format(labeltext, sizeof(labeltext), LABELTEXT1, DEFAULT_HOUSE_NAME, cost, h);
		#if defined GH_USE_CPS
        HouseCPOut[h] = CreateDynamicCP(X, Y, Z, 1.5, GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid), -1, 25.0);
        HouseCPInt[h] = CreateDynamicCP(2196.84, -1204.36, 1049.02, 1.5, (h + 1000), 6, -1, 100.0);
		#endif
		#if !defined GH_USE_CPS
        HousePickupOut[h] = CreateDynamicPickup(PICKUP_MODEL_OUT, PICKUP_TYPE, X, Y, Z, GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid), -1, 15.0);
        HousePickupInt[h] = CreateDynamicPickup(PICKUP_MODEL_INT, PICKUP_TYPE, 2196.84, -1204.36, 1049.02, (h + 1000), 6, -1, 15.0);
		#endif
		#if defined GH_USE_MAPICONS
        HouseMIcon[h] = CreateDynamicMapIcon(X, Y, Z, 31, -1, GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid), -1, 50.0);
	 	#endif
        HouseLabel[h] = Create3DTextLabel(labeltext, COLOUR_GREEN, X, Y, Z + 0.7, 25, GetPlayerVirtualWorld(playerid), 1);
        SendMSG(playerid, COLOUR_YELLOW, 128, I_H_CREATED, h);
        GetPosInFrontOfPlayer(playerid, X, Y, -2.5);
        dini_FloatSet(file, "SpawnOutX", X);
        dini_FloatSet(file, "SpawnOutY", Y);
        dini_FloatSet(file, "SpawnOutZ", Z);
        dini_FloatSet(file, "SpawnOutAngle", floatround((180 + Angle)));
        dini_IntSet(file, "SpawnWorld", GetPlayerVirtualWorld(playerid));
        dini_IntSet(file, "SpawnInterior", GetPlayerInterior(playerid));
        dini_IntSet(file, "HouseInterior", hinterior);
        switch (hinterior) {
            case 1: {
                dini_IntSet(file, "HouseInteriorValue", H_INT_1_VALUE);
                dini_Set(file, "HouseInteriorName", "Shitty Shack");
            }
            case 2: {
                dini_IntSet(file, "HouseInteriorValue", H_INT_2_VALUE);
                dini_Set(file, "HouseInteriorName", "Motel Room");
            }
            case 3: {
                dini_IntSet(file, "HouseInteriorValue", H_INT_3_VALUE);
                dini_Set(file, "HouseInteriorName", "Hotel Room 1");
            }
            case 4: {
                dini_IntSet(file, "HouseInteriorValue", H_INT_4_VALUE);
                dini_Set(file, "HouseInteriorName", "Hotel Room 2");
            }
            case 5: {
                dini_IntSet(file, "HouseInteriorValue", H_INT_5_VALUE);
                dini_Set(file, "HouseInteriorName", "Gang House");
            }
            case 6: {
                dini_IntSet(file, "HouseInteriorValue", H_INT_6_VALUE);
                dini_Set(file, "HouseInteriorName", "Normal House");
            }
            case 0: {
                dini_IntSet(file, "HouseInteriorValue", H_INT_0_VALUE);
                dini_Set(file, "HouseInteriorName", "Default House");
            }
            case 7: {
                dini_IntSet(file, "HouseInteriorValue", H_INT_7_VALUE);
                dini_Set(file, "HouseInteriorName", "Medium Mansion");
            }
            case 8: {
                dini_IntSet(file, "HouseInteriorValue", H_INT_8_VALUE);
                dini_Set(file, "HouseInteriorName", "Rich Mansion");
            }
            case 9: {
                dini_IntSet(file, "HouseInteriorValue", H_INT_9_VALUE);
                dini_Set(file, "HouseInteriorName", "Huge Mansion");
            }
            case 10: {
                dini_IntSet(file, "HouseInteriorValue", H_INT_10_VALUE);
                dini_Set(file, "HouseInteriorName", "Mad Dogg's Mansion");
            }
        }
        dini_IntSet("/GarHouse/House.ini", "CurrentID", dini_Int("/GarHouse/House.ini", "CurrentID") + 1);
        dini_IntSet("/GarHouse/House.ini", "CurrentWorld", dini_Int("/GarHouse/House.ini", "CurrentID") + 1000);
        SetPVarInt(playerid, "JustCreatedHouse", 1);
		#if defined GH_DEBUGGING
        printf(DEBUG_OP_CMD1, pNick(playerid), playerid, h, cost, GetTotalHouses());
		#endif
    }
    return 1;
}
//==============================================================================
// This command is used to add a house car for a house.
// The only thing you have to enter is the house value,
// the rest is done by the script.
//==============================================================================
dcmd_addhcar(playerid, params[]) {
    new file[HOUSEFILE_LENGTH], h;
    if (!IsPlayerAdmin(playerid)) return 0;
    if (!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, COLOUR_SYSTEM, E_HCAR_NOT_IN_VEH);
    if (sscanf(params, "d", h)) return SendClientMessage(playerid, COLOUR_SYSTEM, E_CMD_USAGE_ADDHCAR);
    format(file, sizeof(file), FILEPATH, h);
    if (!dini_Exists(file)) return SendClientMessage(playerid, COLOUR_SYSTEM, E_INVALID_HID);
    else {
        if (dini_Int(file, "HCar") == 1) { SendMSG(playerid, COLOUR_YELLOW, 128, I_HCAR_EXIST_ALREADY, h); }
        if (dini_Int(file, "HCar") == 0) { SendMSG(playerid, COLOUR_YELLOW, 128, I_HCAR_CREATED, h); }
        GetVehiclePos(GetPlayerVehicleID(playerid), X, Y, Z);
        GetVehicleZAngle(GetPlayerVehicleID(playerid), Angle);
        dini_FloatSet(file, "HCarPosX", X);
        dini_FloatSet(file, "HCarPosY", Y);
        dini_FloatSet(file, "HCarPosZ", Z);
        dini_FloatSet(file, "HCarAngle", Angle);
        dini_IntSet(file, "HCar", 1);
        dini_IntSet(file, "HCarWorld", GetPlayerVirtualWorld(playerid));
        dini_IntSet(file, "HCarInt", GetPlayerInterior(playerid));
        dini_IntSet(file, "HCarModel", GetVehicleModel(GetPlayerVehicleID(playerid)));
		#if defined GH_DEBUGGING
        printf(DEBUG_OP_CMD2, pNick(playerid), playerid, h);
		#endif
    }
    return 1;
}
//==============================================================================
// This command is used to delete a house.
// Note: It does not give any money to the house owner when the house is deleted
//==============================================================================
dcmd_removehouse(playerid, params[]) {
    new h, file[HOUSEFILE_LENGTH];
    if (!IsPlayerAdmin(playerid)) return 0;
    if (sscanf(params, "d", h)) return SendClientMessage(playerid, COLOUR_SYSTEM, E_CMD_USAGE_REMOVEHOUSE);
    format(file, sizeof(file), FILEPATH, h);
    if (!dini_Exists(file)) return SendClientMessage(playerid, COLOUR_SYSTEM, E_INVALID_HID);
    else {
        DestroyHouseEntrance(h, TYPE_OUT);
        DestroyHouseEntrance(h, TYPE_INT);
	    #if defined GH_USE_MAPICONS
        DestroyDynamicMapIcon(HouseMIcon[h]);
		#endif
        Delete3DTextLabel(HouseLabel[h]);
        SendMSG(playerid, COLOUR_YELLOW, 128, I_H_DESTROYED, h);
        dini_Remove(file);
		#if defined GH_DEBUGGING
        printf(DEBUG_OP_CMD3, pNick(playerid), playerid, h);
		#endif
    }
    return 1;
}
//==============================================================================
// This command is used to remove the house car for a house.
//==============================================================================
dcmd_removehcar(playerid, params[]) {
    new file[HOUSEFILE_LENGTH], h;
    if (!IsPlayerAdmin(playerid)) return 0;
    if (sscanf(params, "d", h)) return SendClientMessage(playerid, COLOUR_SYSTEM, E_CMD_USAGE_REMOVEHCAR);
    format(file, sizeof(file), FILEPATH, h);
    if (!dini_Exists(file)) return SendClientMessage(playerid, COLOUR_SYSTEM, E_INVALID_HID);
    if (dini_Int(file, "HCar") == 0) return SendClientMessage(playerid, COLOUR_SYSTEM, E_NO_HCAR);
    else {
        UnloadHouseCar(h);
        dini_IntSet(file, "HCar", 0);
        SendMSG(playerid, COLOUR_YELLOW, 128, I_HCAR_REMOVED, h);
		#if defined GH_DEBUGGING
        printf(DEBUG_OP_CMD4, pNick(playerid), playerid, h);
		#endif
    }
    return 1;
}
//==============================================================================
// This command is used to change the modelid of a housecar.
//==============================================================================
dcmd_changehcar(playerid, params[]) {
    new file[HOUSEFILE_LENGTH], h, modelid;
    if (!IsPlayerAdmin(playerid)) return 0;
    if (sscanf(params, "dd", h, modelid)) return SendClientMessage(playerid, COLOUR_SYSTEM, E_CMD_USAGE_CHANGEHCAR);
    format(file, sizeof(file), FILEPATH, h);
    if (!dini_Exists(file)) return SendClientMessage(playerid, COLOUR_SYSTEM, E_INVALID_HID);
    if (modelid < 400 || modelid > 612) return SendClientMessage(playerid, COLOUR_SYSTEM, E_INVALID_HCAR_MODEL);
    else {
        dini_IntSet(file, "HCarModel", modelid);
        SendMSG(playerid, COLOUR_YELLOW, 128, I_HCAR_CHANGED, h, modelid);
    	#if defined GH_HOUSECARS
        if (GetVehicleModel(HouseCar[h]) != -1) {
            if (IsVehicleOccupied(HouseCar[h])) {
                new Float:Velocity[3], Float:Pos[4], Seat[MAX_PLAYERS] = -1, interior, vw = GetVehicleVirtualWorld(HouseCar[h]);
                Loop(i, MAX_PLAYERS) {
                    if (!IsPlayerConnected(i) || IsPlayerNPC(i)) continue;
                    if (IsPlayerInVehicle(i, HouseCar[h])) {
                        Seat[i] = GetPlayerVehicleSeat(i);
                        if (Seat[i] == 0) {
                            interior = GetPlayerInterior(i); // Have to do it this way because there is no GetVehicleInterior..
                        }
                    }
                }
                GetVehiclePos(HouseCar[h], Pos[0], Pos[1], Pos[2]);
                GetVehicleZAngle(HouseCar[h], Pos[3]);
                GetVehicleVelocity(HouseCar[h], Velocity[0], Velocity[1], Velocity[2]);
                DestroyVehicle(HouseCar[h]);
                HouseCar[h] = CreateVehicle(modelid, Pos[0], Pos[1], Pos[2], Pos[3], HCAR_COLOUR1, HCAR_COLOUR2, HCAR_RESPAWN);
                LinkVehicleToInterior(HouseCar[h], interior);
                SetVehicleVirtualWorld(HouseCar[h], vw);
                Loop(i, MAX_PLAYERS) {
                    if (!IsPlayerConnected(i) || IsPlayerNPC(i) || Seat[i] == -1) continue;
                    if (IsPlayerInVehicle(i, HouseCar[h])) {
                        PutPlayerInVehicle(i, HouseCar[h], Seat[i]);
                    }
                }
                SetVehicleVelocity(HouseCar[h], Velocity[0], Velocity[1], Velocity[2]);

            }
            if (!IsVehicleOccupied(HouseCar[h])) {
                UnloadHouseCar(h);
                LoadHouseCar(h);
            }
        }
		#endif
		#if defined GH_DEBUGGING
        printf(DEBUG_OP_CMD12, pNick(playerid), playerid, h, modelid);
		#endif
    }
    return 1;
}
//==============================================================================
// This command is used to delete all houses.
// It does not give any money to the house owners when the houses is deleted.
//==============================================================================
dcmd_removeallhouses(playerid, params[]) {
	#pragma unused params
    new hcount, file[HOUSEFILE_LENGTH];
    if (!IsPlayerAdmin(playerid)) return 0;
    else {
        Loop(h, MAX_HOUSES) {
            format(file, sizeof(file), FILEPATH, h);
            if (dini_Exists(file)) {
                UnloadHouseCar(h);
                DestroyHouseEntrance(h, TYPE_OUT);
                DestroyHouseEntrance(h, TYPE_INT);
			    #if defined GH_USE_MAPICONS
                DestroyDynamicMapIcon(HouseMIcon[h]);
				#endif
                Delete3DTextLabel(HouseLabel[h]);
                dini_Remove(file);
                hcount++;
            }
        }
        SendMSG(playerid, COLOUR_YELLOW, 128, I_ALLH_DESTROYED, hcount);
		#if defined GH_DEBUGGING
        printf(DEBUG_OP_CMD5, pNick(playerid), playerid, hcount);
		#endif
    }
    return 1;
}
//==============================================================================
// This command is used remove all house cars.
// It does not delete the house cars itself due to SA:MP mixing up vehicle ID's.
//==============================================================================
dcmd_removeallhcars(playerid, params[]) {
	#pragma unused params
    new hcount, file[HOUSEFILE_LENGTH];
    if (!IsPlayerAdmin(playerid)) return 0;
    else {
        Loop(h, MAX_HOUSES) {
            UnloadHouseCar(h);
            format(file, sizeof(file), FILEPATH, h);
            if (dini_Exists(file)) {
                dini_IntSet(file, "HCar", 0);
            }
        }
        SendMSG(playerid, COLOUR_YELLOW, 128, I_ALLHCAR_REMOVED, hcount);
		#if defined GH_DEBUGGING
        printf(DEBUG_OP_CMD6, pNick(playerid), playerid, hcount);
		#endif
    }
    return 1;
}
//==============================================================================
// This command is used to change the spawnposition details of a house
//==============================================================================
dcmd_changespawn(playerid, params[]) {
    new h, file[HOUSEFILE_LENGTH];
    if (!IsPlayerAdmin(playerid)) return 0;
    if (sscanf(params, "d", h)) return SendClientMessage(playerid, COLOUR_SYSTEM, E_CMD_USAGE_CHANGESPAWN);
    format(file, sizeof(file), FILEPATH, h);
    if (!dini_Exists(file)) return SendClientMessage(playerid, COLOUR_SYSTEM, E_INVALID_HID);
    else {
        GetPlayerPos(playerid, X, Y, Z);
        GetPlayerFacingAngle(playerid, Angle);
        dini_FloatSet(file, "SpawnOutX", X);
        dini_FloatSet(file, "SpawnOutY", Y);
        dini_FloatSet(file, "SpawnOutZ", Z);
        dini_FloatSet(file, "SpawnOutAngle", Angle);
        dini_IntSet(file, "SpawnWorld", GetPlayerVirtualWorld(playerid));
        dini_IntSet(file, "SpawnInterior", GetPlayerInterior(playerid));
        SendMSG(playerid, COLOUR_YELLOW, 128, I_HSPAWN_CHANGED, h);
		#if defined GH_DEBUGGING
        printf(DEBUG_OP_CMD7, pNick(playerid), playerid, h);
		#endif
    }
    return 1;
}
//==============================================================================
// This command is used to teleport to a house.
//==============================================================================
dcmd_gotohouse(playerid, params[]) {
    new h, file[HOUSEFILE_LENGTH];
    if (!IsPlayerAdmin(playerid)) return 0;
    if (sscanf(params, "d", h)) return SendClientMessage(playerid, COLOUR_SYSTEM, E_CMD_USAGE_GOTOHOUSE);
    format(file, sizeof(file), FILEPATH, h);
    if (!dini_Exists(file)) return SendClientMessage(playerid, COLOUR_SYSTEM, E_INVALID_HID);
    else {
        SetPlayerPosEx(playerid, dini_Float(file, "SpawnOutX"), dini_Float(file, "SpawnOutY"), dini_Float(file, "SpawnOutZ"), dini_Int(file, "SpawnInterior"), dini_Int(file, "SpawnWorld"));
        SendMSG(playerid, COLOUR_YELLOW, 128, I_TELEPORT_MSG, h);
    }
    return 1;
}
//==============================================================================
// This command is used to sell a house.
// If the house owner is connected while selling the house,
// the amount in the house storage and 75% of the house value will be given to the house owner.
//==============================================================================
dcmd_sellhouse(playerid, params[]) {
    new file[HOUSEFILE_LENGTH], h, file2[HOUSEFILE_LENGTH];
    if (!IsPlayerAdmin(playerid)) return 0;
    if (sscanf(params, "d", h)) return SendClientMessage(playerid, COLOUR_SYSTEM, E_CMD_USAGE_SELLHOUSE);
    format(file, sizeof(file), FILEPATH, h);
    if (!dini_Exists(file)) return SendClientMessage(playerid, COLOUR_SYSTEM, E_INVALID_HID);
    if (!strcmp(GetHouseOwner(h), INVALID_HOWNER_NAME, CASE_SENSETIVE)) return SendClientMessage(playerid, COLOUR_SYSTEM, E_H_A_F_SALE);
    else {
        SendMSG(playerid, COLOUR_YELLOW, 128, I_H_SOLD, h);
        if (dini_Int(file, "HouseStorage") >= 1 && IsPlayerConnected(GetHouseOwnerEx(h))) {
            GivePlayerMoney(playerid, (dini_Int(file, "HouseStorage") + ReturnProcent(GetHouseValue(h), HOUSE_SELLING_PROCENT)));
        }
        dini_IntSet(file, "HouseValue", ReturnProcent(GetHouseValue(h), HOUSE_SELLING_PROCENT));
        dini_Set(file, "HouseOwner", INVALID_HOWNER_NAME);
        dini_Set(file, "HousePassword", "INVALID_HOUSE_PASSWORD");
        dini_Set(file, "HouseName", DEFAULT_HOUSE_NAME);
        dini_IntSet(file, "HouseStorage", 0);
        Loop(h2, MAX_HOUSES) {
            if (IsHouseInRangeOfHouse(h, h2, RANGE_BETWEEN_HOUSES) && h2 != h) {
                format(file2, sizeof(file2), FILEPATH, h2);
                dini_IntSet(file2, "HouseValue", (dini_Int(file2, "HouseValue") - ReturnProcent(GetHouseValue(h2), HOUSE_SELLING_PROCENT2)));
            }
        }
        Loop(i, MAX_PLAYERS) {
            if (GetPVarInt(i, "LastHouseCP") == h && GetPVarInt(i, "IsInHouse") == 1) {
                SetPVarInt(i, "IsInHouse", 0);
                SetPlayerPosEx(i, dini_Float(file, "SpawnOutX"), dini_Float(file, "SpawnOutY"), dini_Float(file, "SpawnOutZ"), dini_Int(file, "SpawnInterior"), dini_Int(file, "SpawnWorld"));
                SetPlayerFacingAngle(i, dini_Float(file, "SpawnOutAngle"));
                SetPlayerInterior(i, dini_Int(file, "SpawnInterior"));
                SetPlayerVirtualWorld(i, dini_Int(file, "SpawnWorld"));
            }
        }
		#if defined GH_USE_MAPICONS
        DestroyDynamicMapIcon(HouseMIcon[h]);
        HouseMIcon[h] = CreateDynamicMapIcon(dini_Float(file, "CPOutX"), dini_Float(file, "CPOutY"), dini_Float(file, "CPOutZ"), 31, -1, dini_Int(file, "SpawnWorld"), dini_Int(file, "SpawnInterior"), -1, MICON_VD);
		#endif
        UpdateHouseText(h);
        #if defined GH_DEBUGGING
        printf(DEBUG_OP_CMD8, pNick(playerid), playerid, h);
		#endif
    }
    return 1;
}
//==============================================================================
// This command is used to sell a house.
// If the house owner is connected while selling the house,
// the amount in the house storage and 75% of the house value will be given to the house owner.
//==============================================================================
dcmd_sellallhouses(playerid, params[]) {
	#pragma unused params
    new file[HOUSEFILE_LENGTH], hcount;
    if (!IsPlayerAdmin(playerid)) return 0;
    else {
        Loop(h, MAX_HOUSES) {
            format(file, sizeof(file), FILEPATH, h);
            if (dini_Exists(file) && strcmp(GetHouseOwner(h), INVALID_HOWNER_NAME, CASE_SENSETIVE)) {
                if (dini_Int(file, "HouseStorage") >= 1 && IsPlayerConnected(GetHouseOwnerEx(h))) {
                    GivePlayerMoney(playerid, (dini_Int(file, "HouseStorage") + ReturnProcent(GetHouseValue(h), HOUSE_SELLING_PROCENT)));
                }
                dini_IntSet(file, "HouseValue", ReturnProcent(GetHouseValue(h), HOUSE_SELLING_PROCENT));
                dini_Set(file, "HouseOwner", INVALID_HOWNER_NAME);
                dini_Set(file, "HousePassword", "INVALID_HOUSE_PASSWORD");
                dini_Set(file, "HouseName", DEFAULT_HOUSE_NAME);
                dini_IntSet(file, "HouseStorage", 0);
				#if defined GH_USE_MAPICONS
                DestroyDynamicMapIcon(HouseMIcon[h]);
                HouseMIcon[h] = CreateDynamicMapIcon(dini_Float(file, "CPOutX"), dini_Float(file, "CPOutY"), dini_Float(file, "CPOutZ"), 31, -1, dini_Int(file, "SpawnWorld"), dini_Int(file, "SpawnInterior"), -1, MICON_VD);
				#endif
                UpdateHouseText(h);
                hcount++;
            }
        }
        SendMSG(playerid, COLOUR_YELLOW, 128, I_ALLH_SOLD, hcount);
        #if defined GH_DEBUGGING
        printf(DEBUG_OP_CMD9, pNick(playerid), playerid, hcount);
		#endif
    }
    return 1;
}
//==============================================================================
// 			This command is used to change the value of a house.
//==============================================================================
dcmd_changeprice(playerid, params[]) {
    new h, file[HOUSEFILE_LENGTH], price;
    if (!IsPlayerAdmin(playerid)) return 0;
    if (sscanf(params, "dd", h, price)) return SendClientMessage(playerid, COLOUR_SYSTEM, E_CMD_USAGE_CHANGEPRICE);
    format(file, sizeof(file), FILEPATH, h);
    if (!dini_Exists(file)) return SendClientMessage(playerid, COLOUR_SYSTEM, E_INVALID_HID);
    if (price < 1500000 || price > 25000000) return SendClientMessage(playerid, COLOUR_SYSTEM, E_INVALID_HVALUE);
    else {
        dini_IntSet(file, "HouseValue", price);
        SendMSG(playerid, COLOUR_YELLOW, 128, I_H_PRICE_CHANGED, h, price);
        UpdateHouseText(h);
		#if defined GH_DEBUGGING
        printf(DEBUG_OP_CMD10, pNick(playerid), playerid, h, price);
		#endif
    }
    return 1;
}
//==============================================================================
// 		This command is used to change the value of all houses on the server.
//==============================================================================
dcmd_changeallprices(playerid, params[]) {
    new hcount, file[HOUSEFILE_LENGTH], price;
    if (!IsPlayerAdmin(playerid)) return 0;
    if (sscanf(params, "d", price)) return SendClientMessage(playerid, COLOUR_SYSTEM, E_CMD_USAGE_CHANGEALLPRICE);
    if (price < 1500000 || price > 25000000) return SendClientMessage(playerid, COLOUR_SYSTEM, E_INVALID_HVALUE);
    else {
        Loop(h, MAX_HOUSES) {
            format(file, sizeof(file), FILEPATH, h);
            if (dini_Exists(file)) {
                dini_IntSet(file, "HouseValue", price);
                UpdateHouseText(h);
                hcount++;
            }
        }
        SendMSG(playerid, COLOUR_YELLOW, 128, I_ALLH_PRICE_CHANGED, price, hcount);
        #if defined GH_DEBUGGING
        printf(DEBUG_OP_CMD11, pNick(playerid), playerid, price, hcount);
		#endif
    }
    return 1;
}
dcmd_ghcmds(playerid, params[]) {
	#pragma unused params
    if (!IsPlayerAdmin(playerid)) return 0;
    else {
        return ShowPlayerDialog(playerid, HOUSEMENU - 1, DIALOG_STYLE_MSGBOX, "GarHouse v1.3 By [03]Garsino - �������", "/changeallprices\n/removeallhcars\n/sellallhouses\n/changeprice\n/changespawn\n/removehcar\n/sellhouse\n/housemenu\n/gotohouse\n/addhcar\n/changehcar\n/ghcmds", "�������", "������");
    }
}
//##############################################################################
// 								      Publics
//##############################################################################
forward HouseVisiting(playerid);
public HouseVisiting(playerid) {
    new string[200], tmpstring[50];
    GetPVarString(playerid, "HousePrevName", tmpstring, 50);
    format(string, sizeof(string), I_HINT_VISIT_OVER, tmpstring, GetPVarInt(playerid, "HousePrevValue"));
    ShowPlayerDialog(playerid, HOUSEMENU + 17, DIALOG_STYLE_MSGBOX, "GarHouse v1.3 By [03]Garsino - ������� ���������", string, "������", "������");
    return 1;
}
forward HouseSpawning(playerid);
public HouseSpawning(playerid) {
    new file[HOUSEFILE_LENGTH];
    Loop(h, MAX_HOUSES) {
        if (!strcmp(GetHouseOwner(h), pNick(playerid), CASE_SENSETIVE)) {
            format(file, sizeof(file), FILEPATH, h);
            if (dini_Int(file, "QuitInHouse") == 1) {
                SetPVarInt(playerid, "IsInHouse", 1);
                SetPVarInt(playerid, "LastHouseCP", h);
                SetPlayerHouseInterior(playerid, h);
       			#if defined GH_HOUSECARS
                LoadHouseCar(h);
       			#endif
                SendClientMessage(playerid, COLOUR_INFO, I_HMENU);
                dini_IntSet(file, "QuitInHouse", 0);
		    	#if defined GH_DEBUGGING
                printf(DEBUG_OP_SPAWN, pNick(playerid), playerid);
		    	#endif
            }
        }
    }
    SetPVarInt(playerid, "FirstSpawn", 1);
    return 1;
}
//##############################################################################
// 								Functions
//##############################################################################
// 							  By [03]Garsino!
//==============================================================================
// LoadHouses();
// This function is used to load the houses.
// It creates all the checkpoints, map icons and
// 3D texts for all the houses and sets the correct 3D text information.
//==============================================================================
stock LoadHouses() {
    new hcount = 0;
    Loop(h, MAX_HOUSES) {
        new file[HOUSEFILE_LENGTH], labeltext[150];
        format(file, sizeof(file), FILEPATH, h);
        if (dini_Exists(file)) {
		    #if defined GH_USE_CPS
            HouseCPOut[h] = CreateDynamicCP(dini_Float(file, "CPOutX"), dini_Float(file, "CPOutY"), dini_Float(file, "CPOutZ"), 1.5, dini_Int(file, "SpawnWorld"), dini_Int(file, "SpawnInterior"), -1, 15.0);
			#endif
			#if !defined GH_USE_CPS
            HousePickupOut[h] = CreateDynamicPickup(PICKUP_MODEL_OUT, PICKUP_TYPE, dini_Float(file, "CPOutX"), dini_Float(file, "CPOutY"), dini_Float(file, "CPOutZ"), dini_Int(file, "SpawnWorld"), dini_Int(file, "SpawnInterior"), -1, 15.0);
			#endif
            CreateCorrectHouseExitCP(h);
            if (!strcmp(GetHouseOwner(h), INVALID_HOWNER_NAME, CASE_SENSETIVE)) {
                format(labeltext, sizeof(labeltext), LABELTEXT1, GetHouseName(h), GetHouseValue(h), h);
                HouseLabel[h] = Create3DTextLabel(labeltext, COLOUR_GREEN, dini_Float(file, "CPOutX"), dini_Float(file, "CPOutY"), dini_Float(file, "CPOutZ") + 0.7, 25, dini_Int(file, "SpawnWorld"), 1);
                #if defined GH_USE_MAPICONS
                HouseMIcon[h] = CreateDynamicMapIcon(dini_Float(file, "CPOutX"), dini_Float(file, "CPOutY"), dini_Float(file, "CPOutZ"), 31, -1, dini_Int(file, "SpawnWorld"), dini_Int(file, "SpawnInterior"), -1, MICON_VD);
				#endif
            }
            if (strcmp(GetHouseOwner(h), INVALID_HOWNER_NAME, CASE_SENSETIVE)) {
                format(labeltext, sizeof(labeltext), LABELTEXT2, GetHouseName(h), GetHouseOwner(h), GetHouseValue(h), h);
                HouseLabel[h] = Create3DTextLabel(labeltext, COLOUR_GREEN, dini_Float(file, "CPOutX"), dini_Float(file, "CPOutY"), dini_Float(file, "CPOutZ") + 0.7, 25, dini_Int(file, "SpawnWorld"), 1);
                #if defined GH_USE_MAPICONS
                HouseMIcon[h] = CreateDynamicMapIcon(dini_Float(file, "CPOutX"), dini_Float(file, "CPOutY"), dini_Float(file, "CPOutZ"), 32, -1, dini_Int(file, "SpawnWorld"), dini_Int(file, "SpawnInterior"), -1, MICON_VD);
				#endif
            }
            hcount++;
        }
    }
    return printf("\nTotal Houses Loaded: %d\n", hcount);
}
//==============================================================================
// LoadHouseCar(houseid);
// This function is used to load the house car for a house.
//==============================================================================
stock LoadHouseCar(houseid) {
	#if defined GH_HOUSECARS
    new file[HOUSEFILE_LENGTH];
    format(file, sizeof(file), FILEPATH, houseid);
    if (dini_Exists(file) && dini_Int(file, "HCar") == 1) {
        HouseCar[houseid] = CreateVehicle(dini_Int(file, "HCarModel"), dini_Float(file, "HCarPosX"), dini_Float(file, "HCarPosY"), dini_Float(file, "HCarPosZ"), dini_Float(file, "HCarAngle"), HCAR_COLOUR1, HCAR_COLOUR2, HCAR_RESPAWN);
        SetVehicleVirtualWorld(HouseCar[houseid], dini_Int(file, "HCarWorld"));
        LinkVehicleToInterior(HouseCar[houseid], dini_Int(file, "HCarInt"));
    }
	#endif
    return 1;
}
//==============================================================================
// UnloadHouseCar(houseid);
// This function is used to the unload house car for a house.
//==============================================================================
stock UnloadHouseCar(houseid) {
	#if !defined GH_HOUSECARS
	    #pragma unused houseid
	#endif
	#if defined GH_HOUSECARS
    new file[HOUSEFILE_LENGTH];
    format(file, sizeof(file), FILEPATH, houseid);
    if (dini_Exists(file) && dini_Int(file, "HCar") == 1) {
        if (GetVehicleModel(HouseCar[houseid]) >= 400 && GetVehicleModel(HouseCar[houseid]) <= 611 && HouseCar[houseid] >= 1) {
            DestroyVehicle(HouseCar[houseid]);
            HouseCar[houseid] = -1;
        }
    }
	#endif
    return 1;
}
//==============================================================================
// SaveHouseCar(houseid);
// This function is used to check if there is any vehicles
// near the housecar spawn.
//==============================================================================
stock SaveHouseCar(houseid) {
	#if defined GH_HOUSECARS
    new file[HOUSEFILE_LENGTH], Float:tmpx, Float:tmpy, Float:tmpz;
    format(file, sizeof(file), FILEPATH, houseid);
    if (dini_Exists(file) && dini_Int(file, "HCar") == 1) {
        tmpx = dini_Float(file, "HCarPosX"), tmpy = dini_Float(file, "HCarPosY"), tmpz = dini_Float(file, "HCarPosZ");
        Loop(v, MAX_VEHICLES) {
            if (GetVehicleModel(v) < 400 || GetVehicleModel(v) > 611 || IsVehicleOccupied(v)) continue;
            GetVehiclePos(v, X, Y, Z);
            if (PointInRangeOfPoint(HCAR_RANGE, X, Y, Z, tmpx, tmpy, tmpz)) {
                dini_IntSet(file, "HCarModel", GetVehicleModel(v));
                DestroyVehicle(v);
                break;
            }
        }
    }
	#endif
    return 1;
}
//==============================================================================
// GetOwnedHouses(playerid);
// This function is used to find out how many houses a player owns
//==============================================================================
stock GetOwnedHouses(playerid) {
    new file[HOUSEFILE_LENGTH], tmpcount;
    Loop(h, MAX_HOUSES) {
        format(file, sizeof(file), FILEPATH, h);
        if (dini_Exists(file)) {
            if (!strcmp(dini_Get(file, "HouseOwner"), pNick(playerid), CASE_SENSETIVE)) {
                tmpcount++;
            }
        }
    }
    return tmpcount;
}
//==============================================================================
// GetHouseOwnerEx(houseid);
// This function is used to get the house owner of a house
// and return the playerid, it will return INVALID_PLAYER_ID
// if the house owner is not connected
//==============================================================================
stock GetHouseOwnerEx(houseid) {
    new file[HOUSEFILE_LENGTH];
    format(file, sizeof(file), FILEPATH, houseid);
    if (dini_Exists(file)) {
        Loop(i, MAX_PLAYERS) {
            if (!strcmp(pNick(i), GetHouseOwner(houseid), CASE_SENSETIVE)) {
                return i;
            }
        }
    }
    return INVALID_PLAYER_ID;
}
//==============================================================================
// ReturnPlayerHouseID(playerid, houseslot);
// This function is used to return the house id from a players house 'slot'
// Example: ReturnPlayerHouseID(playerid, 0);
// Would return for example house ID 500.
//==============================================================================
stock ReturnPlayerHouseID(playerid, houseslot) {
    new file[HOUSEFILE_LENGTH], tmpcount = 0;
    if (houseslot < 1 && houseslot > MAX_HOUSES_OWNED) return -1;
    Loop(h, MAX_HOUSES) {
        format(file, sizeof(file), FILEPATH, h);
        if (dini_Exists(file)) {
            if (!strcmp(pNick(playerid), dini_Get(file, "HouseOwner"), CASE_SENSETIVE)) {
                tmpcount++;
                if (tmpcount == houseslot) {
                    return h;
                }
            }
        }
    }
    return -1;
}
//==============================================================================
// UnloadHouses();
// This function is used to unload the houses.
// It deletes all the checkpoints, map icons and 3D texts for all the houses.
//==============================================================================
stock UnloadHouses() {
    Loop(h, MAX_HOUSES) {
        DestroyHouseEntrance(h, TYPE_OUT);
        DestroyHouseEntrance(h, TYPE_INT);
		#if defined GH_USE_MAPICONS
        DestroyDynamicMapIcon(HouseMIcon[h]);
		#endif
        Delete3DTextLabel(HouseLabel[h]);
		#if defined GH_HOUSECARS
        UnloadHouseCar(h);
		#endif
    }
    return 1;
}
//==============================================================================
// GetHouseValue(houseid);
// This function is used to get the value of a house
//==============================================================================
stock GetHouseValue(houseid) {
    new file[HOUSEFILE_LENGTH];
    format(file, sizeof(file), FILEPATH, houseid);
    if (dini_Exists(file)) {
        return dini_Int(file, "HouseValue");
    } else return printf("Couldn't Get House Value For House ID %d. File Doesn't Exist...", houseid);
}
//==============================================================================
// GetHouseName(houseid);
// This function is used to get the name of a house
//==============================================================================
stock GetHouseName(houseid) {
    new file[HOUSEFILE_LENGTH], hname[MAX_HOUSE_NAME];
    format(hname, MAX_HOUSE_NAME, "%s", DEFAULT_HOUSE_NAME);
    format(file, sizeof(file), FILEPATH, houseid);
    if (dini_Exists(file)) {
        format(hname, MAX_HOUSE_NAME, "%s", dini_Get(file, "HouseName"));
        return hname;
    }
    return hname;
}
//==============================================================================
// GetHouseOwner(houseid);
// This function is used to get the owner of a house
//==============================================================================
stock GetHouseOwner(houseid) {
    new file[HOUSEFILE_LENGTH], howner[MAX_PLAYER_NAME];
    format(howner, MAX_PLAYER_NAME, INVALID_HOWNER_NAME);
    format(file, sizeof(file), FILEPATH, houseid);
    if (dini_Exists(file)) {
        format(howner, MAX_PLAYER_NAME, "%s", dini_Get(file, "HouseOwner"));
        return howner;
    }
    return howner;
}
//==============================================================================
// IsHouseInRangeOfHouse(house, house2, Float:range);
// This function is used to check if a house is in range of another house
// Default range is 250.0
//==============================================================================
stock IsHouseInRangeOfHouse(house, house2, Float:range = 250.0) {
    new file[HOUSEFILE_LENGTH], file2[25];
    format(file, sizeof(file), FILEPATH, house);
    format(file2, sizeof(file2), FILEPATH, house2);
    if (dini_Exists(file) && dini_Exists(file2)) {
        if (PointInRangeOfPoint(range, dini_Float(file, "CPOutX"), dini_Float(file, "CPOutY"), dini_Float(file, "CPOutZ"), dini_Float(file2, "CPOutX"), dini_Float(file2, "CPOutY"), dini_Float(file2, "CPOutZ"))) {
            return 1;
        }
    }
    return 0;
}
//==============================================================================
// CreateCorrectHouseExitCP(houseid);
// This function is used to create the correct house exit checkpoint for the houseid
// based on the house interior ID
//==============================================================================
stock CreateCorrectHouseExitCP(houseid) {
    new file[HOUSEFILE_LENGTH];
    format(file, sizeof(file), FILEPATH, houseid);
	#if defined GH_USE_CPS
    switch (dini_Int(file, "HouseInterior")) {
        case 0 : HouseCPInt[houseid] = CreateDynamicCP(2196.84, -1204.36, 1049.02, 1.5, (houseid + 1000), 6, -1, 10.0); // Default House
        case 1 : HouseCPInt[houseid] = CreateDynamicCP(2259.38, -1135.89, 1050.64, 1.50, (houseid + 1000), 10, -1, 10.0); // Shitty Shack House Interior
        case 2 : HouseCPInt[houseid] = CreateDynamicCP(2282.99, -1140.28, 1050.89, 1.50, (houseid + 1000), 11, -1, 10.0); // Motel House Interior
        case 3 : HouseCPInt[houseid] = CreateDynamicCP(2233.69, -1115.26, 1050.88, 1.50, (houseid + 1000), 5, -1, 10.0); // Hotel House Interior
        case 4 : HouseCPInt[houseid] = CreateDynamicCP(2218.39, -1076.21, 1050.48, 1.50, (houseid + 1000), 1, -1, 10.0); // Hotel 2 House Interior
        case 5 : HouseCPInt[houseid] = CreateDynamicCP(2496.00, -1692.08, 1014.74, 1.50, (houseid + 1000), 3, -1, 10.0); // CJ's House Interior
        case 6 : HouseCPInt[houseid] = CreateDynamicCP(2365.25, -1135.58, 1050.88, 1.50, (houseid + 1000), 8, -1, 10.0); // Verdant Bluff's Safehouse House Interior
        case 7 : HouseCPInt[houseid] = CreateDynamicCP(2317.77, -1026.76, 1050.21, 1.50, (houseid + 1000), 9, -1, 10.0); // Medium Mansion House Interior
        case 8 : HouseCPInt[houseid] = CreateDynamicCP(2324.41, -1149.54, 1050.71, 1.50, (houseid + 1000), 12, -1, 10.0); // Rich Mansion House Interior
        case 9 : HouseCPInt[houseid] = CreateDynamicCP(140.28, 1365.92, 1083.85, 1.50, (houseid + 1000), 5, -1, 10.0); // Huge Mansion House Interior
        case 10 : HouseCPInt[houseid] = CreateDynamicCP(1260.6603, -785.4005, 1091.9063, 1.50, (houseid + 1000), 5, -1, 10.0); // Madd Dogg's Mansion House Interior
    }
	#endif
	#if !defined GH_USE_CPS
    switch (dini_Int(file, "HouseInterior")) {
        case 0 : HousePickupInt[houseid] = CreateDynamicPickup(PICKUP_MODEL_INT, PICKUP_TYPE, 2196.84, -1204.36, 1049.02, (houseid + 1000), 6, -1, 10.0); // Default House
        case 1 : HousePickupInt[houseid] = CreateDynamicPickup(PICKUP_MODEL_INT, PICKUP_TYPE, 2259.38, -1135.89, 1050.64, (houseid + 1000), 10, -1, 10.0); // Shitty Shack House Interior
        case 2 : HousePickupInt[houseid] = CreateDynamicPickup(PICKUP_MODEL_INT, PICKUP_TYPE, 2282.99, -1140.28, 1050.89, (houseid + 1000), 11, -1, 10.0); // Motel House Interior
        case 3 : HousePickupInt[houseid] = CreateDynamicPickup(PICKUP_MODEL_INT, PICKUP_TYPE, 2233.69, -1115.26, 1050.88, (houseid + 1000), 5, -1, 10.0); // Hotel House Interior
        case 4 : HousePickupInt[houseid] = CreateDynamicPickup(PICKUP_MODEL_INT, PICKUP_TYPE, 2218.39, -1076.21, 1050.48, (houseid + 1000), 1, -1, 10.0); // Hotel 2 House Interior
        case 5 : HousePickupInt[houseid] = CreateDynamicPickup(PICKUP_MODEL_INT, PICKUP_TYPE, 2496.00, -1692.08, 1014.74, (houseid + 1000), 3, -1, 10.0); // CJ's House Interior
        case 6 : HousePickupInt[houseid] = CreateDynamicPickup(PICKUP_MODEL_INT, PICKUP_TYPE, 2365.25, -1135.58, 1050.88, (houseid + 1000), 8, -1, 10.0); // Verdant Bluff's Safehouse House Interior
        case 7 : HousePickupInt[houseid] = CreateDynamicPickup(PICKUP_MODEL_INT, PICKUP_TYPE, 2317.77, -1026.76, 1050.21, (houseid + 1000), 9, -1, 10.0); // Medium Mansion House Interior
        case 8 : HousePickupInt[houseid] = CreateDynamicPickup(PICKUP_MODEL_INT, PICKUP_TYPE, 2324.41, -1149.54, 1050.71, (houseid + 1000), 12, -1, 10.0); // Rich Mansion House Interior
        case 9 : HousePickupInt[houseid] = CreateDynamicPickup(PICKUP_MODEL_INT, PICKUP_TYPE, 140.28, 1365.92, 1083.85, (houseid + 1000), 5, -1, 10.0); // Huge Mansion House Interior
        case 10 : HousePickupInt[houseid] = CreateDynamicPickup(PICKUP_MODEL_INT, PICKUP_TYPE, 1260.6603, -785.4005, 1091.9063, (houseid + 1000), 5, -1, 10.0); // Madd Dogg's Mansion House Interior
    }
	#endif
    return 1;
}
//==============================================================================
// SetPlayerHouseInterior(playerid, house);
// This function is used to set the correct house interior for a player when he enters a house or buy a new house interior.
//==============================================================================
stock SetPlayerHouseInterior(playerid, house) {
    new file[HOUSEFILE_LENGTH];
    format(file, sizeof(file), FILEPATH, house);
    switch (dini_Int(file, "HouseInterior")) {
        case 0: {
            SetPlayerPosEx(playerid, 2193.9001, -1202.4185, 1049.0234, 6, (house + 1000));
            SetPlayerFacingAngle(playerid, 91.9386); // Default House Interior - Spawnpoint
        }
        case 1: {
            SetPlayerPosEx(playerid, 2262.5627, -1136.1664, 1050.6328, 10, (house + 1000));
            SetPlayerFacingAngle(playerid, 267.5372); // Shitty Shack House Interior - Spawnpoint
        }
        case 2: {
            SetPlayerPosEx(playerid, 2283.0632, -1136.9760, 1050.8984, 11, (house + 1000));
            SetPlayerFacingAngle(playerid, 358.7963); // Motel Room House Interior - Spawnpoint
        }
        case 3: {
            SetPlayerPosEx(playerid, 2233.6057, -1111.7039, 1050.8828, 5, (house + 1000));
            SetPlayerFacingAngle(playerid, 2.9124); // Hotel House Interior - Spawnpoint
        }
        case 4: {
            SetPlayerPosEx(playerid, 2214.8909, -1076.0967, 1050.4844, 1, (house + 1000));
            SetPlayerFacingAngle(playerid, 88.8910); // Hotel 2 House Interior - Spawnpoint
        }
        case 5: {
            SetPlayerPosEx(playerid, 2495.8035, -1695.0997, 1014.7422, 3, (house + 1000));
            SetPlayerFacingAngle(playerid, 181.9661); // CJ's House Interior - Spawnpoint
        }
        case 6: {
            SetPlayerPosEx(playerid, 2365.2883, -1132.5228, 1050.8750, 8, (house + 1000));
            SetPlayerFacingAngle(playerid, 358.0393); // Verdant Bluff's Safehouse House Interior - Spawnpoint
        }
        case 7: {
            SetPlayerPosEx(playerid, 2320.0730, -1023.9533, 1050.2109, 9, (house + 1000));
            SetPlayerFacingAngle(playerid, 358.4915); // Medium Mansion House Interior - Spawnpoint
        }
        case 8: {
            SetPlayerPosEx(playerid, 2324.4490, -1145.2841, 1050.7101, 12, (house + 1000));
            SetPlayerFacingAngle(playerid, 357.5873); // Richouse Mansion House Interior - Spawnpoint
        }
        case 9: {
            SetPlayerPosEx(playerid, 140.1788, 1369.1936, 1083.8641, 5, (house + 1000));
            SetPlayerFacingAngle(playerid, 359.2263); // Huge Mansion House Interior - Spawnpoint
        }
        case 10: {
            SetPlayerPosEx(playerid, 1264.7765, -781.2485, 1091.9063, 5, (house + 1000));
            SetPlayerFacingAngle(playerid, 270.6992); // Madd Dogg's Mansion House Interior - Spawnpoint
        }
    }
}
//==============================================================================
// pNick(playerid);
// Used to get the name of a player.
//==============================================================================
stock pNick(playerid) {
    new GHNick[MAX_PLAYER_NAME];
    GetPlayerName(playerid, GHNick, MAX_PLAYER_NAME);
    return GHNick;
}
//==============================================================================
// PointInRangeOfPoint(Float:range, Float:x2, Float:y2, Float:z2, Float:X2, Float:Y2, Float:Z2);
// Used to check if a point is in range of another point.
// Credits to whoever made this!
//==============================================================================
stock PointInRangeOfPoint(Float:range, Float:x2, Float:y2, Float:z2, Float:X2, Float:Y2, Float:Z2) {
    X2 -= x2;
    Y2 -= y2;
    Z2 -= z2;
    return ((X2 * X2) + (Y2 * Y2) + (Z2 * Z2)) < (range * range);
}
//==============================================================================
// ReturnProcent(Float:amount, Float:procent);
// Used to return the procent of an value.
//==============================================================================
stock ReturnProcent(Float:amount, Float:procent) {
    return floatround((amount / 100 * procent));
}
//==============================================================================
// SetPlayerPosEx(playerid, Float:posX, Float:posY, Float:posZ, Interior = 0, World = 0);
// Used to set the position of a player with optional interiorid and worldid parameters
//==============================================================================
stock SetPlayerPosEx(playerid, Float:posX, Float:posY, Float:posZ, Interior = 0, World = 0) {
    SetPlayerVirtualWorld(playerid, World);
    SetPlayerInterior(playerid, Interior);
    SetPlayerPos(playerid, posX, posY, posZ);
    SetCameraBehindPlayer(playerid);
    return 1;
}
//==============================================================================
// GetFreeHouseID();
// Used to get the next free house ID. Will return -1 if there is none free.
//==============================================================================
stock GetFreeHouseID() {
    new file[HOUSEFILE_LENGTH];
    Loop(h, MAX_HOUSES) {
        format(file, sizeof(file), FILEPATH, h);
        if (!dini_Exists(file)) {
            return h;
        }
    }
    return -1;
}
//==============================================================================
// GetTotalHouses();
// Used to get the amount of existing houses.
//==============================================================================
stock GetTotalHouses() {
    new tmpcount, file[HOUSEFILE_LENGTH];
    Loop(h, MAX_HOUSES) {
        format(file, sizeof(file), FILEPATH, h);
        if (dini_Exists(file)) {
            tmpcount++;
        }
    }
    return tmpcount;
}
stock UpdateHouseText(houseid) {
    new labeltext[150], file[HOUSEFILE_LENGTH];
    format(file, sizeof(file), FILEPATH, houseid);
    if (dini_Exists(file)) {
        if (!strcmp(dini_Get(file, "HouseOwner"), INVALID_HOWNER_NAME, CASE_SENSETIVE)) {
            format(labeltext, sizeof(labeltext), LABELTEXT1, GetHouseName(houseid), GetHouseValue(houseid), houseid);
        } else {
            format(labeltext, sizeof(labeltext), LABELTEXT2, GetHouseName(houseid), GetHouseOwner(houseid), GetHouseValue(houseid), houseid);
        }
        Update3DTextLabelText(HouseLabel[houseid], COLOUR_GREEN, labeltext);
    }
}
//==============================================================================
// FM(amount, Optional(Delimiter));
// Used to format the money (from 100000 to 100,000).
// Credits to mick88
//==============================================================================
stock FM(amount, delimiter[2] = ",") {
    new txt[20];
    format(txt, 20, "$%d", amount);
    new l = strlen(txt);
    if (amount < 0) // -
    {
        if (l >= 5) strins(txt, delimiter, l - 3);
        if (l >= 8) strins(txt, delimiter, l - 6);
        if (l >= 11) strins(txt, delimiter, l - 9);
    } else {
        if (l >= 4) strins(txt, delimiter, l - 3);
        if (l >= 7) strins(txt, delimiter, l - 6);
        if (l >= 10) strins(txt, delimiter, l - 9);
    }
    return txt;
}
//==============================================================================
// AddS(amount);
// By [03]Garsino.
//==============================================================================
stock AddS(amount) {
    new returnstring[2];
    format(returnstring, 2, "��");
    if (amount != 1 && amount != -1) {
        format(returnstring, 2, "���");
    }
    return returnstring;
}
//==============================================================================
// GetSecondsBetweenAction(action);
// By [03]Garsino.
//==============================================================================
stock GetSecondsBetweenAction(action) {
    return floatround(floatdiv((GetTickCount() - action), 1000), floatround_tozero);
}
//==============================================================================
// DestroyHouseEntrance(houseid, type);
// Destroys the house entrance of a house (pickup or checkpoint).
// Type can be: TYPE_OUT (0) and TYPE_INT (1)
// By [03]Garsino.
//==============================================================================
stock DestroyHouseEntrance(houseid, type) {
	#if defined GH_USE_CPS
    if (type == TYPE_OUT) { DestroyDynamicCP(HouseCPOut[houseid]); }
    if (type == TYPE_INT) { DestroyDynamicCP(HouseCPInt[houseid]); }
	#endif
	#if !defined GH_USE_CPS
    if (type == TYPE_OUT) { DestroyDynamicPickup(HousePickupOut[houseid]); }
    if (type == TYPE_INT) { DestroyDynamicPickup(HousePickupInt[houseid]); }
	#endif
    return 1;
}
//==============================================================================
// IsVehicleOccupied(vehicleid);
// Checks if a vehicle is occupied or not.
// By [03]Garsino.
//==============================================================================
stock IsVehicleOccupied(vehicleid) {
    Loop(i, MAX_PLAYERS) {
        if (IsPlayerInVehicle(i, vehicleid)) {
            return 1;
        }
    }
    return 0;
}
// � [03]Garsino - Keep The Credits!