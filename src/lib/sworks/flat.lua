local ffi = require("ffi")
local win = ffi.os == "Windows"
local little = ffi.abi("le")
local x64 = ffi.abi("64bit")

ffi.cdef([[

// API 

typedef unsigned char uint8;
typedef signed char int8;
typedef short int16;
typedef unsigned short uint16;
typedef int int32;
typedef unsigned int uint32;
typedef long long int64;
typedef unsigned long long uint64;
typedef int64 lint64;
typedef uint64 ulint64;
typedef uint8 Salt_t[8];
typedef uint64 GID_t;
typedef uint64 JobID_t;
typedef GID_t TxnID_t;
typedef uint32 PackageId_t;
typedef uint32 BundleId_t;
typedef uint32 AppId_t;
typedef uint64 AssetClassId_t;
typedef uint32 PhysicalItemId_t;
typedef uint32 DepotId_t;
typedef uint32 RTime32;
typedef uint32 CellID_t;
typedef uint64 SteamAPICall_t;
typedef uint32 AccountID_t;
typedef uint32 PartnerId_t;
typedef uint64 ManifestId_t;
typedef uint64 SiteId_t;
typedef uint64 PartyBeaconID_t;
typedef uint32 HAuthTicket;
typedef void* BREAKPAD_HANDLE;
typedef char compile_time_assert_type[1];
typedef int32 HSteamPipe;
typedef int32 HSteamUser;
typedef int16 FriendsGroupID_t;
typedef void* HServerListRequest;
typedef int HServerQuery;
typedef uint64 UGCHandle_t;
typedef uint64 PublishedFileUpdateHandle_t;
typedef uint64 PublishedFileId_t;
typedef uint64 UGCFileWriteStreamHandle_t;
typedef char compile_time_assert_type[1];
typedef uint64 SteamLeaderboard_t;
typedef uint64 SteamLeaderboardEntries_t;
typedef uint32 SNetSocket_t;
typedef uint32 SNetListenSocket_t;
typedef uint32 ScreenshotHandle;
typedef uint32 HTTPRequestHandle;
typedef uint32 HTTPCookieContainerHandle;
typedef uint64 InputHandle_t;
typedef uint64 InputActionSetHandle_t;
typedef uint64 InputDigitalActionHandle_t;
typedef uint64 InputAnalogActionHandle_t;
typedef uint64 ControllerHandle_t;
typedef uint64 ControllerActionSetHandle_t;
typedef uint64 ControllerDigitalActionHandle_t;
typedef uint64 ControllerAnalogActionHandle_t;
typedef uint64 UGCQueryHandle_t;
typedef uint64 UGCUpdateHandle_t;
typedef uint32 HHTMLBrowser;
typedef uint64 SteamItemInstanceID_t;
typedef int32 SteamItemDef_t;
typedef int32 SteamInventoryResult_t;
typedef uint64 SteamInventoryUpdateHandle_t;

typedef uint32 HSteamListenSocket;
typedef uint32 HSteamNetConnection;
typedef int64 SteamNetworkingMicroseconds;

typedef uint64 uint64_steamid;
typedef uint64 uint64_gameid;

// OpenVR Constants

static const int const_k_iSteamUserCallbacks = 100;
static const int const_k_iSteamGameServerCallbacks = 200;
static const int const_k_iSteamFriendsCallbacks = 300;
static const int const_k_iSteamBillingCallbacks = 400;
static const int const_k_iSteamMatchmakingCallbacks = 500;
static const int const_k_iSteamContentServerCallbacks = 600;
static const int const_k_iSteamUtilsCallbacks = 700;
static const int const_k_iClientFriendsCallbacks = 800;
static const int const_k_iClientUserCallbacks = 900;
static const int const_k_iSteamAppsCallbacks = 1000;
static const int const_k_iSteamUserStatsCallbacks = 1100;
static const int const_k_iSteamNetworkingCallbacks = 1200;
static const int const_k_iSteamNetworkingSocketsCallbacks = 1220;
static const int const_k_iSteamNetworkingMessagesCallbacks = 1250;
static const int const_k_iSteamNetworkingUtilsCallbacks = 1280;
static const int const_k_iClientRemoteStorageCallbacks = 1300;
static const int const_k_iClientDepotBuilderCallbacks = 1400;
static const int const_k_iSteamGameServerItemsCallbacks = 1500;
static const int const_k_iClientUtilsCallbacks = 1600;
static const int const_k_iSteamGameCoordinatorCallbacks = 1700;
static const int const_k_iSteamGameServerStatsCallbacks = 1800;
static const int const_k_iSteam2AsyncCallbacks = 1900;
static const int const_k_iSteamGameStatsCallbacks = 2000;
static const int const_k_iClientHTTPCallbacks = 2100;
static const int const_k_iClientScreenshotsCallbacks = 2200;
static const int const_k_iSteamScreenshotsCallbacks = 2300;
static const int const_k_iClientAudioCallbacks = 2400;
static const int const_k_iClientUnifiedMessagesCallbacks = 2500;
static const int const_k_iSteamStreamLauncherCallbacks = 2600;
static const int const_k_iClientControllerCallbacks = 2700;
static const int const_k_iSteamControllerCallbacks = 2800;
static const int const_k_iClientParentalSettingsCallbacks = 2900;
static const int const_k_iClientDeviceAuthCallbacks = 3000;
static const int const_k_iClientNetworkDeviceManagerCallbacks = 3100;
static const int const_k_iClientMusicCallbacks = 3200;
static const int const_k_iClientRemoteClientManagerCallbacks = 3300;
static const int const_k_iClientUGCCallbacks = 3400;
static const int const_k_iSteamStreamClientCallbacks = 3500;
static const int const_k_IClientProductBuilderCallbacks = 3600;
static const int const_k_iClientShortcutsCallbacks = 3700;
static const int const_k_iClientRemoteControlManagerCallbacks = 3800;
static const int const_k_iSteamAppListCallbacks = 3900;
static const int const_k_iSteamMusicCallbacks = 4000;
static const int const_k_iSteamMusicRemoteCallbacks = 4100;
static const int const_k_iClientVRCallbacks = 4200;
static const int const_k_iClientGameNotificationCallbacks = 4300;
static const int const_k_iSteamGameNotificationCallbacks = 4400;
static const int const_k_iSteamHTMLSurfaceCallbacks = 4500;
static const int const_k_iClientVideoCallbacks = 4600;
static const int const_k_iClientInventoryCallbacks = 4700;
static const int const_k_iClientBluetoothManagerCallbacks = 4800;
static const int const_k_iClientSharedConnectionCallbacks = 4900;
static const int const_k_ISteamParentalSettingsCallbacks = 5000;
static const int const_k_iClientShaderCallbacks = 5100;
static const int const_k_iSteamGameSearchCallbacks = 5200;
static const int const_k_iSteamPartiesCallbacks = 5300;
static const int const_k_iClientPartiesCallbacks = 5400;
static const int const_k_iSteamSTARCallbacks = 5500;
static const int const_k_iClientSTARCallbacks = 5600;
static const int const_k_iSteamRemotePlayCallbacks = 5700;
static const int const_k_cchPersonaNameMax = 128;
static const int const_k_cwchPersonaNameMax = 32;
static const int const_k_cchMaxRichPresenceKeys = 30;
static const int const_k_cchMaxRichPresenceKeyLength = 64;
static const int const_k_cchMaxRichPresenceValueLength = 256;
static const int const_k_cchStatNameMax = 128;
static const int const_k_cchLeaderboardNameMax = 128;
static const int const_k_cLeaderboardDetailsMax = 64;
//static const unsigned long const_k_SteamItemInstanceIDInvalid = 0xffffffff;
static const int const_k_SteamInventoryResultInvalid = -1;
static const int const_k_cchBroadcastGameDataMax = 8192;

static const int const_k_cchMaxGenericString = 32;
static const int const_k_cbMaxGenericBytes = 32;
static const int const_k_cchMaxString = 128;

// Enums
typedef uint32 EAccountType;
typedef uint32 EVoiceResult;
typedef uint32 EBeginAuthSessionResult;
typedef uint32 EUserHasLicenseForAppResult;
typedef uint32 EPersonaState;
typedef uint32 EFriendRelationship;
typedef uint32 EActivateGameOverlayToWebPageMode;
typedef uint32 EOverlayToStoreFlag;
typedef uint32 EChatEntryType;
typedef uint32 EUniverse;
typedef uint32 ENotificationPosition;
typedef uint32 ESteamAPICallFailure;
typedef uint32 EGamepadTextInputMode;
typedef uint32 EGamepadTextInputLineMode;
typedef uint32 ELobbyComparison;
typedef uint32 ELobbyDistanceFilter;
typedef uint32 ELobbyType;
typedef uint32 EMatchMakingServerResponse;
typedef uint32 EGameSearchErrorCode_t;
typedef uint32 EPlayerResult_t;
typedef uint32 ESteamPartyBeaconLocationData;
typedef uint32 ERemoteStoragePlatform;
typedef uint32 EUGCReadAction;
typedef uint32 ERemoteStoragePublishedFileVisibility;
typedef uint32 EWorkshopFileType;
typedef uint32 EWorkshopVideoProvider;
typedef uint32 EWorkshopFileAction;
typedef uint32 EWorkshopEnumerationType;
typedef uint32 ELeaderboardSortMethod;
typedef uint32 ELeaderboardDisplayType;
typedef uint32 ELeaderboardDataRequest;
typedef uint32 ELeaderboardUploadScoreMethod;
typedef uint32 EP2PSend;
typedef uint32 ESNetSocketConnectionType;
typedef uint32 EVRScreenshotType;
typedef uint32 AudioPlayback_Status;
typedef uint32 EHTTPMethod;
typedef uint32 EInputActionOrigin;
typedef uint32 ESteamControllerPad;
typedef uint32 ESteamInputType;
typedef uint32 EXboxOrigin;
typedef uint32 EControllerActionOrigin;
typedef uint32 EUserUGCList;
typedef uint32 EUGCMatchingUGCType;
typedef uint32 EUserUGCListSortOrder;
typedef uint32 EUGCQuery;
typedef uint32 EItemStatistic;
typedef uint32 EItemPreviewType;
typedef uint32 EItemUpdateStatus;
typedef uint32 EHTMLMouseButton;
typedef uint32 EHTMLKeyModifiers;
typedef uint32 EResult;
typedef uint32 ESteamTVRegionBehavior;
typedef uint32 EParentalFeature;
typedef uint32 ESteamDeviceFormFactor;
typedef uint32 EChatRoomEnterResponse;
typedef uint32 ESteamNetworkingAvailability;
typedef uint32 HSteamNetPollGroup;
typedef uint32 SteamNetworkingPOPID;
typedef uint32 ESteamNetworkingConfigValue;
typedef uint32 ESteamNetworkingSocketsDebugOutputType;
typedef uint32 ESteamNetworkingConfigScope;
typedef uint32 ESteamNetworkingConfigDataType;
typedef uint32 ESteamNetworkingGetConfigValueResult;
typedef uint32 EDurationControlOnlineState;
typedef uint32 ETextFilteringContext;
typedef uint32 ESteamNetworkingIdentityType;
typedef uint32 ESteamNetworkingConnectionState;
typedef uint32 EHTTPStatusCode;
typedef uint32 EInputSourceMode;

typedef void* SteamAPIWarningMessageHook_t;


// Structures

#pragma pack(1);

typedef struct CSteamID_BE
{
  unsigned int m_EUniverse : 8;
  unsigned int m_EAccountType : 4;
  unsigned int m_unAccountInstance : 20;
  uint32 m_unAccountID : 32;
} CSteamID_BE;
typedef struct CSteamID_LE
{
  uint32 m_unAccountID : 32;
  unsigned int m_unAccountInstance : 20;
  unsigned int m_EAccountType : 4;
  unsigned int m_EUniverse : 8;
} CSteamID_LE;
typedef union CSteamID_union
{
  uint64 m_unAll64Bits;
  CSteamID_]]..(little and "LE" or "BE")..[[ m_comp;
} CSteamID_union;
typedef struct CSteamID
{
  CSteamID_union m_steamid;
} CSteamID;

typedef struct CGameID_BE
{
  unsigned int m_nModID : 32;
  unsigned int m_nType : 8;
  unsigned int m_nAppID : 24;
} CGameID_BE;
typedef struct CGameID_LE
{
  unsigned int m_nAppID : 24;
  unsigned int m_nType : 8;
  unsigned int m_nModID : 32;
} CGameID_LE;
typedef union CGameID_union
{
  uint64 raw;
  CGameID_]]..(little and "LE" or "BE")..[[ parts;
} CGameID_union;

#pragma pop();

static const int k_iSteamUserCallbacks = 100;
static const int k_iSteamGameServerCallbacks = 200;
static const int k_iSteamFriendsCallbacks = 300;
static const int k_iSteamBillingCallbacks = 400;
static const int k_iSteamMatchmakingCallbacks = 500;
static const int k_iSteamContentServerCallbacks = 600;
static const int k_iSteamUtilsCallbacks = 700;
static const int k_iClientFriendsCallbacks = 800;
static const int k_iClientUserCallbacks = 900;
static const int k_iSteamAppsCallbacks = 1000;
static const int k_iSteamUserStatsCallbacks = 1100;
static const int k_iSteamNetworkingCallbacks = 1200;
static const int k_iSteamNetworkingSocketsCallbacks = 1220;
static const int k_iSteamNetworkingMessagesCallbacks = 1250;
static const int k_iSteamNetworkingUtilsCallbacks = 1280;
static const int k_iClientRemoteStorageCallbacks = 1300;
static const int k_iClientDepotBuilderCallbacks = 1400;
static const int k_iSteamGameServerItemsCallbacks = 1500;
static const int k_iClientUtilsCallbacks = 1600;
static const int k_iSteamGameCoordinatorCallbacks = 1700;
static const int k_iSteamGameServerStatsCallbacks = 1800;
static const int k_iSteam2AsyncCallbacks = 1900;
static const int k_iSteamGameStatsCallbacks = 2000;
static const int k_iClientHTTPCallbacks = 2100;
static const int k_iClientScreenshotsCallbacks = 2200;
static const int k_iSteamScreenshotsCallbacks = 2300;
static const int k_iClientAudioCallbacks = 2400;
static const int k_iClientUnifiedMessagesCallbacks = 2500;
static const int k_iSteamStreamLauncherCallbacks = 2600;
static const int k_iClientControllerCallbacks = 2700;
static const int k_iSteamControllerCallbacks = 2800;
static const int k_iClientParentalSettingsCallbacks = 2900;
static const int k_iClientDeviceAuthCallbacks = 3000;
static const int k_iClientNetworkDeviceManagerCallbacks = 3100;
static const int k_iClientMusicCallbacks = 3200;
static const int k_iClientRemoteClientManagerCallbacks = 3300;
static const int k_iClientUGCCallbacks = 3400;
static const int k_iSteamStreamClientCallbacks = 3500;
static const int k_IClientProductBuilderCallbacks = 3600;
static const int k_iClientShortcutsCallbacks = 3700;
static const int k_iClientRemoteControlManagerCallbacks = 3800;
static const int k_iSteamAppListCallbacks = 3900;
static const int k_iSteamMusicCallbacks = 4000;
static const int k_iSteamMusicRemoteCallbacks = 4100;
static const int k_iClientVRCallbacks = 4200;
static const int k_iClientGameNotificationCallbacks = 4300;
static const int k_iSteamGameNotificationCallbacks = 4400;
static const int k_iSteamHTMLSurfaceCallbacks = 4500;
static const int k_iClientVideoCallbacks = 4600;
static const int k_iClientInventoryCallbacks = 4700;
static const int k_iClientBluetoothManagerCallbacks = 4800;
static const int k_iClientSharedConnectionCallbacks = 4900;
static const int k_ISteamParentalSettingsCallbacks = 5000;
static const int k_iClientShaderCallbacks = 5100;
static const int k_iSteamGameSearchCallbacks = 5200;
static const int k_iSteamPartiesCallbacks = 5300;
static const int k_iClientPartiesCallbacks = 5400;
static const int k_iSteamSTARCallbacks = 5500;
static const int k_iClientSTARCallbacks = 5600;
static const int k_iSteamRemotePlayCallbacks = 5700;
static const int k_cchPersonaNameMax = 128;
static const int k_cwchPersonaNameMax = 32;
static const int k_cchMaxRichPresenceKeys = 30;
static const int k_cchMaxRichPresenceKeyLength = 64;
static const int k_cchMaxRichPresenceValueLength = 256;
static const int k_cchStatNameMax = 128;
static const int k_cchLeaderboardNameMax = 128;
static const int k_cLeaderboardDetailsMax = 64;
//static const ulong k_SteamItemInstanceIDInvalid = 0xffffffffffffffff;
static const int k_SteamInventoryResultInvalid = -1;
static const int k_cchBroadcastGameDataMax = 8192;

static const uint32 k_cchFilenameMax = 260;
static const uint32 k_cchPublishedFileURLMax = 256;
static const uint32 k_cchPublishedDocumentTitleMax = 128 + 1;
static const uint32 k_cchPublishedDocumentDescriptionMax = 8000;
static const uint32 k_cchTagListMax = 1024 + 1;

// Structs

// 8 byte aligned on Windows, 4 byte aligned on OSX/Linux
#pragma pack(push, ]]..(win and 8 or 4)..[[);

// Lobby
typedef struct LobbyCreated_t
{
	//enum { k_iCallback = k_iSteamMatchmakingCallbacks + 13 };
  static const int k_iCallback = k_iSteamMatchmakingCallbacks + 13;
	EResult m_eResult;
	uint64 m_ulSteamIDLobby;
} LobbyCreated_t;
typedef struct LobbyEnter_t
{
	//enum { k_iCallback = k_iSteamMatchmakingCallbacks + 4 };
  static const int k_iCallback = k_iSteamMatchmakingCallbacks + 4;
	uint64 m_ulSteamIDLobby;
	uint32 m_rgfChatPermissions;
	bool m_bLocked;
	uint32 m_EChatRoomEnterResponse;
} LobbyEnter_t;
typedef struct LobbyChatUpdate_t
{
	//enum { k_iCallback = k_iSteamMatchmakingCallbacks + 6 };
  static const int k_iCallback = k_iSteamMatchmakingCallbacks + 6;
	uint64 m_ulSteamIDLobby;
	uint64 m_ulSteamIDUserChanged;
	uint64 m_ulSteamIDMakingChange;
	uint32 m_rgfChatMemberStateChange;
} LobbyChatUpdate_t;
typedef struct LobbyMatchList_t
{
  enum { k_iCallback = k_iSteamMatchmakingCallbacks + 10 };
  static const int k_iCallback = k_iSteamMatchmakingCallbacks + 10;
  uint32 m_nLobbiesMatching;
} LobbyMatchList_t;

// Leaderboards
typedef struct LeaderboardFindResult_t
{
	//enum { k_iCallback = k_iSteamUserStatsCallbacks + 4 };
  static const int k_iCallback = k_iSteamUserStatsCallbacks + 4;
	SteamLeaderboard_t m_hSteamLeaderboard;
	uint8 m_bLeaderboardFound;
} LeaderboardFindResult_t;
typedef struct LeaderboardScoresDownloaded_t
{
	//enum { k_iCallback = k_iSteamUserStatsCallbacks + 5 };
  static const int k_iCallback = k_iSteamUserStatsCallbacks + 5;
  SteamLeaderboard_t m_hSteamLeaderboard;
  SteamLeaderboardEntries_t m_hSteamLeaderboardEntries;
  int m_cEntryCount;
} LeaderboardScoresDownloaded_t;
typedef struct LeaderboardScoreUploaded_t
{
	//enum { k_iCallback = k_iSteamUserStatsCallbacks + 6 };
  static const int k_iCallback = k_iSteamUserStatsCallbacks + 6;
	uint8 m_bSuccess;
	SteamLeaderboard_t m_hSteamLeaderboard;
	int32 m_nScore;
	uint8 m_bScoreChanged;
	int m_nGlobalRankNew;
	int m_nGlobalRankPrevious;
} LeaderboardScoreUploaded_t;
typedef struct LeaderboardUGCSet_t
{
	//enum { k_iCallback = k_iSteamUserStatsCallbacks + 11 };
  static const int k_iCallback = k_iSteamUserStatsCallbacks + 11;
	EResult m_eResult;
	SteamLeaderboard_t m_hSteamLeaderboard;
} LeaderboardUGCSet_t;

// User
typedef struct UserStatsReceived_t
{
	//enum { k_iCallback = k_iSteamUserStatsCallbacks + 1 };
  static const int k_iCallback = k_iSteamUserStatsCallbacks + 1;
	uint64 m_nGameID;
	EResult m_eResult;
	CSteamID m_steamIDUser;
} UserStatsReceived_t;
typedef struct UserStatsStored_t
{
	//enum { k_iCallback = k_iSteamUserStatsCallbacks + 2 };
  static const int k_iCallback = k_iSteamUserStatsCallbacks + 2;
	uint64 m_nGameID;
	EResult m_eResult;
} UserStatsStored_t;
typedef struct UserAchievementStored_t
{
	//enum { k_iCallback = k_iSteamUserStatsCallbacks + 3 };
  static const int k_iCallback = k_iSteamUserStatsCallbacks + 3;
	uint64 m_nGameID;
	bool m_bGroupAchievement;
	//char m_rgchAchievementName[k_cchStatNameMax];
	uint32 m_nCurProgress;
	uint32 m_nMaxProgress;
  //uint8 m_nPadding2[4];
} UserAchievementStored_t;

// Friends
typedef struct AvatarImageLoaded_t {
  // enum { k_iCallback = k_iSteamFriendsCallbacks + 34 };
  static const int k_iCallback = k_iSteamFriendsCallbacks + 34;
  uint64 m_steamID;
  int m_iImage;
  int m_iWide;
  int m_iTall;
} AvatarImageLoaded_t;

// Clans
typedef struct DownloadClanActivityCountsResult_t
{
	//enum { k_iCallback = k_iSteamFriendsCallbacks + 41 };
  static const int k_iCallback = k_iSteamFriendsCallbacks + 41;
	bool m_bSuccess;
} DownloadClanActivityCountsResult_t;

// P2P
typedef struct P2PSessionState_t
{
	uint8 m_bConnectionActive;
	uint8 m_bConnecting;
	uint8 m_eP2PSessionFail;
	uint8 m_bUsingRelay;
	int32 m_nBytesQueuedForSend;
	int32 m_nPacketsQueuedForSend;
  union
  {
    unsigned int integer;
    unsigned char byte[4];
  } m_nRemoteIP;
	//uint32 m_nRemoteIP;
	uint16 m_nRemotePort;
} P2PSessionState_t;

// UGC
typedef struct SteamParamStringArray_t
{
	const char** m_ppStrings;
	int32 m_nNumStrings;
} SteamParamStringArray_t;
typedef struct SteamUGCDetails_t
{
	PublishedFileId_t m_nPublishedFileId;
	EResult m_eResult;
	EWorkshopFileType m_eFileType;
	AppId_t m_nCreatorAppID;
	AppId_t m_nConsumerAppID;
	char m_rgchTitle[k_cchPublishedDocumentTitleMax];
	char m_rgchDescription[k_cchPublishedDocumentDescriptionMax];
	uint64 m_ulSteamIDOwner;
	uint32 m_rtimeCreated;
	uint32 m_rtimeUpdated;
	uint32 m_rtimeAddedToUserList;
	ERemoteStoragePublishedFileVisibility m_eVisibility;
	bool m_bBanned;
	bool m_bAcceptedForUse;
	bool m_bTagsTruncated;
	char m_rgchTags[k_cchTagListMax];
	UGCHandle_t m_hFile;
	UGCHandle_t m_hPreviewFile;
	char m_pchFileName[k_cchFilenameMax];
	int32 m_nFileSize;
	int32 m_nPreviewFileSize;
	char m_rgchURL[k_cchPublishedFileURLMax];
	uint32 m_unVotesUp;
	uint32 m_unVotesDown;
	float m_flScore;
	uint32 m_unNumChildren;							
} SteamUGCDetails_t;
typedef struct SteamUGCQueryCompleted_t
{
	//enum { k_iCallback = k_iClientUGCCallbacks + 1 };
  static const int k_iCallback = k_iClientUGCCallbacks + 1;
	UGCQueryHandle_t m_handle;
	EResult m_eResult;
	uint32 m_unNumResultsReturned;
	uint32 m_unTotalMatchingResults;
	bool m_bCachedData;
	char m_rgchNextCursor[k_cchPublishedFileURLMax];
} SteamUGCQueryCompleted_t;
typedef struct SteamUGCRequestUGCDetailsResult_t
{
	//enum { k_iCallback = k_iClientUGCCallbacks + 2 };
  static const int k_iCallback = k_iClientUGCCallbacks + 2;
	SteamUGCDetails_t m_details;
	bool m_bCachedData;
} SteamUGCRequestUGCDetailsResult_t;
typedef struct CreateItemResult_t
{
	// enum { k_iCallback = k_iClientUGCCallbacks + 3 };
  static const int k_iCallback = k_iClientUGCCallbacks + 3;
	EResult m_eResult;
	PublishedFileId_t m_nPublishedFileId; 
	bool m_bUserNeedsToAcceptWorkshopLegalAgreement;
} CreateItemResult_t;
typedef struct SubmitItemUpdateResult_t
{
	//enum { k_iCallback = k_iClientUGCCallbacks + 4 };
  static const int k_iCallback = k_iClientUGCCallbacks + 4;
	EResult m_eResult;
	bool m_bUserNeedsToAcceptWorkshopLegalAgreement;
	PublishedFileId_t m_nPublishedFileId;
} SubmitItemUpdateResult_t;
typedef struct DownloadItemResult_t
{
	//enum { k_iCallback = k_iClientUGCCallbacks + 6 };
  static const int k_iCallback = k_iClientUGCCallbacks + 6;
	AppId_t m_unAppID;
	PublishedFileId_t m_nPublishedFileId;
	EResult m_eResult;
} DownloadItemResult_t;
typedef struct StartPlaytimeTrackingResult_t
{
	//enum { k_iCallback = k_iClientUGCCallbacks + 10 };
  static const int k_iCallback = k_iClientUGCCallbacks + 10;
	EResult m_eResult;
} StartPlaytimeTrackingResult_t;
typedef struct StopPlaytimeTrackingResult_t
{
	//enum { k_iCallback = k_iClientUGCCallbacks + 11 };
  static const int k_iCallback = k_iClientUGCCallbacks + 11;
	EResult m_eResult;
} StopPlaytimeTrackingResult_t;
typedef struct DeleteItemResult_t
{
  //enum { k_iCallback = k_iClientUGCCallbacks + 17 };
  static const int k_iCallback = k_iClientUGCCallbacks + 17;
  EResult m_eResult;
  PublishedFileId_t m_nPublishedFileId;
} DeleteItemResult_t;
typedef struct RemoteStorageSubscribePublishedFileResult_t
{
	//enum { k_iCallback = k_iClientRemoteStorageCallbacks + 13 };
  static const int k_iCallback = k_iClientRemoteStorageCallbacks + 13;
	EResult m_eResult;
	PublishedFileId_t m_nPublishedFileId;
} RemoteStorageSubscribePublishedFileResult_t;

// Utils
typedef struct HTTPRequestCompleted_t
{
	//enum { k_iCallback = k_iClientHTTPCallbacks + 1 };
  static const int k_iCallback = k_iClientHTTPCallbacks + 1;
	HTTPRequestHandle m_hRequest;
	uint64 m_ulContextValue;
	bool m_bRequestSuccessful;
	EHTTPStatusCode m_eStatusCode;
	uint32 m_unBodySize;
} HTTPRequestCompleted_t;

// Input
typedef struct InputDigitalActionData_t
{
	bool bState;
	bool bActive;
} InputDigitalActionData_t;
typedef struct InputAnalogActionData_t
{
	EInputSourceMode eMode;
	float x, y;
	bool bActive;
} InputAnalogActionData_t;
typedef struct InputMotionData_t
{
	float rotQuatX;
	float rotQuatY;
	float rotQuatZ;
	float rotQuatW;
	float posAccelX;
	float posAccelY;
	float posAccelZ;
	float rotVelX;
	float rotVelY;
	float rotVelZ;
} InputMotionData_t;

// all structs containing CSteamID are not packed at all on Windows
typedef struct FriendGameInfo_t
{
	//CGameID m_gameID;
	CGameID_union m_gameID;
	uint32 m_unGameIP;
	uint16 m_usGamePort;
	uint16 m_usQueryPort;
	CSteamID m_steamIDLobby;
} FriendGameInfo_t;
typedef struct LeaderboardEntry_t
{
  CSteamID m_steamIDUser;
  int32 m_nGlobalRank;
  int32 m_nScore;
  int32 m_cDetails;
  UGCHandle_t m_hUGC;
} LeaderboardEntry_t;
typedef struct ClanOfficerListResponse_t
{
	//enum { k_iCallback = k_iSteamFriendsCallbacks + 35 };
  static const int k_iCallback = k_iSteamFriendsCallbacks + 35;
	CSteamID m_steamIDClan;
	int m_cOfficers;
	uint8 m_bSuccess;
} ClanOfficerListResponse_t;
typedef struct JoinClanChatRoomCompletionResult_t
{
	//enum { k_iCallback = k_iSteamFriendsCallbacks + 42 };
  static const int k_iCallback = k_iSteamFriendsCallbacks + 42;
	CSteamID m_steamIDClanChat;
	EChatRoomEnterResponse m_eChatRoomEnterResponse;
} JoinClanChatRoomCompletionResult_t;
typedef struct FriendsIsFollowing_t
{
	//enum { k_iCallback = k_iSteamFriendsCallbacks + 45 };
  static const int k_iCallback = k_iSteamFriendsCallbacks + 45;
	EResult m_eResult;
	CSteamID m_steamID;
	bool m_bIsFollowing;
} FriendsIsFollowing_t;

#pragma pack(pop);

// Legacy

bool SteamAPI_Init();
void SteamAPI_Shutdown();
bool SteamAPI_RestartAppIfNecessary(uint32);
bool SteamAPI_IsSteamRunning();

HSteamUser SteamAPI_GetHSteamUser();
HSteamPipe SteamAPI_GetHSteamPipe();

intptr_t SteamInternal_CreateInterface(const char*);
intptr_t SteamInternal_FindOrCreateUserInterface(HSteamUser, const char*);

// Api

HSteamPipe SteamAPI_ISteamClient_CreateSteamPipe(intptr_t);
bool SteamAPI_ISteamClient_BReleaseSteamPipe(intptr_t,HSteamPipe);
HSteamUser SteamAPI_ISteamClient_ConnectToGlobalUser(intptr_t,HSteamPipe);
HSteamUser SteamAPI_ISteamClient_CreateLocalUser(intptr_t,HSteamPipe*,EAccountType);
void SteamAPI_ISteamClient_ReleaseUser(intptr_t,HSteamPipe,HSteamUser);
intptr_t SteamAPI_ISteamClient_GetISteamUser(intptr_t,HSteamUser,HSteamPipe,const char*);
intptr_t SteamAPI_ISteamClient_GetISteamGameServer(intptr_t,HSteamUser,HSteamPipe,const char*);
void SteamAPI_ISteamClient_SetLocalIPBinding(intptr_t,const char&,uint16);
intptr_t SteamAPI_ISteamClient_GetISteamFriends(intptr_t,HSteamUser,HSteamPipe,const char*);
intptr_t SteamAPI_ISteamClient_GetISteamUtils(intptr_t,HSteamPipe,const char*);
intptr_t SteamAPI_ISteamClient_GetISteamMatchmaking(intptr_t,HSteamUser,HSteamPipe,const char*);
intptr_t SteamAPI_ISteamClient_GetISteamMatchmakingServers(intptr_t,HSteamUser,HSteamPipe,const char*);
void*SteamAPI_ISteamClient_GetISteamGenericInterface(intptr_t,HSteamUser,HSteamPipe,const char*);
intptr_t SteamAPI_ISteamClient_GetISteamUserStats(intptr_t,HSteamUser,HSteamPipe,const char*);
intptr_t SteamAPI_ISteamClient_GetISteamGameServerStats(intptr_t,HSteamUser,HSteamPipe,const char*);
intptr_t SteamAPI_ISteamClient_GetISteamApps(intptr_t,HSteamUser,HSteamPipe,const char*);
intptr_t SteamAPI_ISteamClient_GetISteamNetworking(intptr_t,HSteamUser,HSteamPipe,const char*);
intptr_t SteamAPI_ISteamClient_GetISteamRemoteStorage(intptr_t,HSteamUser,HSteamPipe,const char*);
intptr_t SteamAPI_ISteamClient_GetISteamScreenshots(intptr_t,HSteamUser,HSteamPipe,const char*);
intptr_t SteamAPI_ISteamClient_GetISteamGameSearch(intptr_t,HSteamUser,HSteamPipe,const char*);
uint32 SteamAPI_ISteamClient_GetIPCCallCount(intptr_t);
void SteamAPI_ISteamClient_SetWarningMessageHook(intptr_t,SteamAPIWarningMessageHook_t);
bool SteamAPI_ISteamClient_BShutdownIfAllPipesClosed(intptr_t);
intptr_t SteamAPI_ISteamClient_GetISteamHTTP(intptr_t,HSteamUser,HSteamPipe,const char*);
intptr_t SteamAPI_ISteamClient_GetISteamController(intptr_t,HSteamUser,HSteamPipe,const char*);
intptr_t SteamAPI_ISteamClient_GetISteamUGC(intptr_t,HSteamUser,HSteamPipe,const char*);
intptr_t SteamAPI_ISteamClient_GetISteamAppList(intptr_t,HSteamUser,HSteamPipe,const char*);
intptr_t SteamAPI_ISteamClient_GetISteamMusic(intptr_t,HSteamUser,HSteamPipe,const char*);
intptr_t SteamAPI_ISteamClient_GetISteamMusicRemote(intptr_t,HSteamUser,HSteamPipe,const char*);
intptr_t SteamAPI_ISteamClient_GetISteamHTMLSurface(intptr_t,HSteamUser,HSteamPipe,const char*);
intptr_t SteamAPI_ISteamClient_GetISteamInventory(intptr_t,HSteamUser,HSteamPipe,const char*);
intptr_t SteamAPI_ISteamClient_GetISteamVideo(intptr_t,HSteamUser,HSteamPipe,const char*);
intptr_t SteamAPI_ISteamClient_GetISteamParentalSettings(intptr_t,HSteamUser,HSteamPipe,const char*);
intptr_t SteamAPI_ISteamClient_GetISteamInput(intptr_t,HSteamUser,HSteamPipe,const char*);
intptr_t SteamAPI_ISteamClient_GetISteamParties(intptr_t,HSteamUser,HSteamPipe,const char*);
intptr_t SteamAPI_ISteamClient_GetISteamRemotePlay(intptr_t,HSteamUser,HSteamPipe,const char*);

intptr_t SteamAPI_SteamUser_v021();
HSteamUser SteamAPI_ISteamUser_GetHSteamUser(intptr_t);
bool SteamAPI_ISteamUser_BLoggedOn(intptr_t);
uint64_steamid SteamAPI_ISteamUser_GetSteamID(intptr_t);
int SteamAPI_ISteamUser_InitiateGameConnection(intptr_t,void*,int,uint64_steamid,uint32,uint16,bool);
void SteamAPI_ISteamUser_TerminateGameConnection(intptr_t,uint32,uint16);
void SteamAPI_ISteamUser_TrackAppUsageEvent(intptr_t,uint64_gameid,int,const char*);
bool SteamAPI_ISteamUser_GetUserDataFolder(intptr_t,char*,int);
void SteamAPI_ISteamUser_StartVoiceRecording(intptr_t);
void SteamAPI_ISteamUser_StopVoiceRecording(intptr_t);
EVoiceResult SteamAPI_ISteamUser_GetAvailableVoice(intptr_t,uint32*,uint32*,uint32);
EVoiceResult SteamAPI_ISteamUser_GetVoice(intptr_t,bool,void*,uint32,uint32*,bool,void*,uint32,uint32*,uint32);
EVoiceResult SteamAPI_ISteamUser_DecompressVoice(intptr_t,const void*,uint32,void*,uint32,uint32*,uint32);
uint32 SteamAPI_ISteamUser_GetVoiceOptimalSampleRate(intptr_t);
HAuthTicket SteamAPI_ISteamUser_GetAuthSessionTicket(intptr_t,void*,int ,uint32*);
EBeginAuthSessionResult SteamAPI_ISteamUser_BeginAuthSession(intptr_t,const void*,int cbAuthTicket,uint64_steamid steamID);
void SteamAPI_ISteamUser_EndAuthSession(intptr_t,uint64_steamid);
void SteamAPI_ISteamUser_CancelAuthTicket(intptr_t,HAuthTicket);
EUserHasLicenseForAppResult SteamAPI_ISteamUser_UserHasLicenseForApp(intptr_t,uint64_steamid,AppId_t);
bool SteamAPI_ISteamUser_BIsBehindNAT(intptr_t);
void SteamAPI_ISteamUser_AdvertiseGame(intptr_t,uint64_steamid,uint32,uint16);
SteamAPICall_t SteamAPI_ISteamUser_RequestEncryptedAppTicket(intptr_t,void*,int);
bool SteamAPI_ISteamUser_GetEncryptedAppTicket(intptr_t,void*,int,uint32*);
int SteamAPI_ISteamUser_GetGameBadgeLevel(intptr_t,int,bool);
int SteamAPI_ISteamUser_GetPlayerSteamLevel(intptr_t);
SteamAPICall_t SteamAPI_ISteamUser_RequestStoreAuthURL(intptr_t,const char*);
bool SteamAPI_ISteamUser_BIsPhoneVerified(intptr_t);
bool SteamAPI_ISteamUser_BIsTwoFactorEnabled(intptr_t);
bool SteamAPI_ISteamUser_BIsPhoneIdentifying(intptr_t);
bool SteamAPI_ISteamUser_BIsPhoneRequiringVerification(intptr_t);
SteamAPICall_t SteamAPI_ISteamUser_GetMarketEligibility(intptr_t);
SteamAPICall_t SteamAPI_ISteamUser_GetDurationControl(intptr_t);
bool SteamAPI_ISteamUser_BSetDurationControlOnlineState(intptr_t,EDurationControlOnlineState);

intptr_t SteamAPI_SteamFriends_v017();
const char*SteamAPI_ISteamFriends_GetPersonaName(intptr_t);
SteamAPICall_t SteamAPI_ISteamFriends_SetPersonaName(intptr_t,const char*);
EPersonaState SteamAPI_ISteamFriends_GetPersonaState(intptr_t);
int SteamAPI_ISteamFriends_GetFriendCount(intptr_t,int);
uint64_steamid SteamAPI_ISteamFriends_GetFriendByIndex(intptr_t,int,int);
EFriendRelationship SteamAPI_ISteamFriends_GetFriendRelationship(intptr_t,uint64_steamid);
EPersonaState SteamAPI_ISteamFriends_GetFriendPersonaState(intptr_t,uint64_steamid);
const char*SteamAPI_ISteamFriends_GetFriendPersonaName(intptr_t,uint64_steamid);
bool SteamAPI_ISteamFriends_GetFriendGamePlayed(intptr_t,uint64_steamid,struct FriendGameInfo_t*);
const char*SteamAPI_ISteamFriends_GetFriendPersonaNameHistory(intptr_t,uint64_steamid,int);
int SteamAPI_ISteamFriends_GetFriendSteamLevel(intptr_t,uint64_steamid);
const char*SteamAPI_ISteamFriends_GetPlayerNickname(intptr_t,uint64_steamid);
int SteamAPI_ISteamFriends_GetFriendsGroupCount(intptr_t);
FriendsGroupID_t SteamAPI_ISteamFriends_GetFriendsGroupIDByIndex(intptr_t,int);
const char*SteamAPI_ISteamFriends_GetFriendsGroupName(intptr_t,FriendsGroupID_t);
int SteamAPI_ISteamFriends_GetFriendsGroupMembersCount(intptr_t,FriendsGroupID_t);
void SteamAPI_ISteamFriends_GetFriendsGroupMembersList(intptr_t,FriendsGroupID_t,struct CSteamID*,int);
bool SteamAPI_ISteamFriends_HasFriend(intptr_t,uint64_steamid,int);
int SteamAPI_ISteamFriends_GetClanCount(intptr_t);
uint64_steamid SteamAPI_ISteamFriends_GetClanByIndex(intptr_t,int);
const char*SteamAPI_ISteamFriends_GetClanName(intptr_t,uint64_steamid);
const char*SteamAPI_ISteamFriends_GetClanTag(intptr_t,uint64_steamid);
bool SteamAPI_ISteamFriends_GetClanActivityCounts(intptr_t,uint64_steamid,int*,int*,int*);
SteamAPICall_t SteamAPI_ISteamFriends_DownloadClanActivityCounts(intptr_t,struct CSteamID*,int);
int SteamAPI_ISteamFriends_GetFriendCountFromSource(intptr_t,uint64_steamid);
uint64_steamid SteamAPI_ISteamFriends_GetFriendFromSourceByIndex(intptr_t,uint64_steamid,int);
bool SteamAPI_ISteamFriends_IsUserInSource(intptr_t,uint64_steamid,uint64_steamid);
void SteamAPI_ISteamFriends_SetInGameVoiceSpeaking(intptr_t,uint64_steamid,bool);
void SteamAPI_ISteamFriends_ActivateGameOverlay(intptr_t,const char*);
void SteamAPI_ISteamFriends_ActivateGameOverlayToUser(intptr_t,const char*,uint64_steamid);
void SteamAPI_ISteamFriends_ActivateGameOverlayToWebPage(intptr_t,const char*,EActivateGameOverlayToWebPageMode);
void SteamAPI_ISteamFriends_ActivateGameOverlayToStore(intptr_t,AppId_t,EOverlayToStoreFlag);
void SteamAPI_ISteamFriends_SetPlayedWith(intptr_t,uint64_steamid);
void SteamAPI_ISteamFriends_ActivateGameOverlayInviteDialog(intptr_t,uint64_steamid);
int SteamAPI_ISteamFriends_GetSmallFriendAvatar(intptr_t,uint64_steamid);
int SteamAPI_ISteamFriends_GetMediumFriendAvatar(intptr_t,uint64_steamid);
int SteamAPI_ISteamFriends_GetLargeFriendAvatar(intptr_t,uint64_steamid);
bool SteamAPI_ISteamFriends_RequestUserInformation(intptr_t,uint64_steamid,bool);
SteamAPICall_t SteamAPI_ISteamFriends_RequestClanOfficerList(intptr_t,uint64_steamid);
uint64_steamid SteamAPI_ISteamFriends_GetClanOwner(intptr_t,uint64_steamid);
int SteamAPI_ISteamFriends_GetClanOfficerCount(intptr_t,uint64_steamid);
uint64_steamid SteamAPI_ISteamFriends_GetClanOfficerByIndex(intptr_t,uint64_steamid,int);
uint32 SteamAPI_ISteamFriends_GetUserRestrictions(intptr_t);
bool SteamAPI_ISteamFriends_SetRichPresence(intptr_t,const char*,const char*);
void SteamAPI_ISteamFriends_ClearRichPresence(intptr_t);
const char*SteamAPI_ISteamFriends_GetFriendRichPresence(intptr_t,uint64_steamid,const char*);
int SteamAPI_ISteamFriends_GetFriendRichPresenceKeyCount(intptr_t,uint64_steamid);
const char*SteamAPI_ISteamFriends_GetFriendRichPresenceKeyByIndex(intptr_t,uint64_steamid,int);
void SteamAPI_ISteamFriends_RequestFriendRichPresence(intptr_t,uint64_steamid);
bool SteamAPI_ISteamFriends_InviteUserToGame(intptr_t,uint64_steamid,const char*);
int SteamAPI_ISteamFriends_GetCoplayFriendCount(intptr_t);
uint64_steamid SteamAPI_ISteamFriends_GetCoplayFriend(intptr_t,int);
int SteamAPI_ISteamFriends_GetFriendCoplayTime(intptr_t,uint64_steamid);
AppId_t SteamAPI_ISteamFriends_GetFriendCoplayGame(intptr_t,uint64_steamid);
SteamAPICall_t SteamAPI_ISteamFriends_JoinClanChatRoom(intptr_t,uint64_steamid);
bool SteamAPI_ISteamFriends_LeaveClanChatRoom(intptr_t,uint64_steamid);
int SteamAPI_ISteamFriends_GetClanChatMemberCount(intptr_t,uint64_steamid);
uint64_steamid SteamAPI_ISteamFriends_GetChatMemberByIndex(intptr_t,uint64_steamid,int);
bool SteamAPI_ISteamFriends_SendClanChatMessage(intptr_t,uint64_steamid,const char*);
int SteamAPI_ISteamFriends_GetClanChatMessage(intptr_t,uint64_steamid,int,void*,int,EChatEntryType*,struct CSteamID*);
bool SteamAPI_ISteamFriends_IsClanChatAdmin(intptr_t,uint64_steamid,uint64_steamid);
bool SteamAPI_ISteamFriends_IsClanChatWindowOpenInSteam(intptr_t,uint64_steamid);
bool SteamAPI_ISteamFriends_OpenClanChatWindowInSteam(intptr_t,uint64_steamid);
bool SteamAPI_ISteamFriends_CloseClanChatWindowInSteam(intptr_t,uint64_steamid);
bool SteamAPI_ISteamFriends_SetListenForFriendsMessages(intptr_t,bool);
bool SteamAPI_ISteamFriends_ReplyToFriendMessage(intptr_t,uint64_steamid,const char*);
int SteamAPI_ISteamFriends_GetFriendMessage(intptr_t,uint64_steamid,int,void*,int,EChatEntryType*);
SteamAPICall_t SteamAPI_ISteamFriends_GetFollowerCount(intptr_t,uint64_steamid);
SteamAPICall_t SteamAPI_ISteamFriends_IsFollowing(intptr_t,uint64_steamid);
SteamAPICall_t SteamAPI_ISteamFriends_EnumerateFollowingList(intptr_t,uint32);
bool SteamAPI_ISteamFriends_IsClanPublic(intptr_t,uint64_steamid);
bool SteamAPI_ISteamFriends_IsClanOfficialGameGroup(intptr_t,uint64_steamid);
int SteamAPI_ISteamFriends_GetNumChatsWithUnreadPriorityMessages(intptr_t);
void SteamAPI_ISteamFriends_ActivateGameOverlayRemotePlayTogetherInviteDialog(intptr_t,uint64_steamid);
bool SteamAPI_ISteamFriends_RegisterProtocolInOverlayBrowser(intptr_t,const char*);
void SteamAPI_ISteamFriends_ActivateGameOverlayInviteDialogConnectString(intptr_t,const char*);

intptr_t SteamAPI_SteamUtils_v010();
intptr_t SteamAPI_SteamGameServerUtils_v010();
uint32 SteamAPI_ISteamUtils_GetSecondsSinceAppActive(intptr_t);
uint32 SteamAPI_ISteamUtils_GetSecondsSinceComputerActive(intptr_t);
EUniverse SteamAPI_ISteamUtils_GetConnectedUniverse(intptr_t);
uint32 SteamAPI_ISteamUtils_GetServerRealTime(intptr_t);
const char*SteamAPI_ISteamUtils_GetIPCountry(intptr_t);
bool SteamAPI_ISteamUtils_GetImageSize(intptr_t,int,uint32*,uint32*);
bool SteamAPI_ISteamUtils_GetImageRGBA(intptr_t,int,uint8*,int);
bool SteamAPI_ISteamUtils_GetCSERIPPort(intptr_t,uint32*,uint16*);
uint8 SteamAPI_ISteamUtils_GetCurrentBatteryPower(intptr_t);
uint32 SteamAPI_ISteamUtils_GetAppID(intptr_t);
void SteamAPI_ISteamUtils_SetOverlayNotificationPosition(intptr_t,ENotificationPosition);
bool SteamAPI_ISteamUtils_IsAPICallCompleted(intptr_t,SteamAPICall_t,bool*);
ESteamAPICallFailure SteamAPI_ISteamUtils_GetAPICallFailureReason(intptr_t,SteamAPICall_t);
bool SteamAPI_ISteamUtils_GetAPICallResult(intptr_t,SteamAPICall_t,void*,int,int,bool*);
uint32 SteamAPI_ISteamUtils_GetIPCCallCount(intptr_t);
void SteamAPI_ISteamUtils_SetWarningMessageHook(intptr_t,SteamAPIWarningMessageHook_t);
bool SteamAPI_ISteamUtils_IsOverlayEnabled(intptr_t);
bool SteamAPI_ISteamUtils_BOverlayNeedsPresent(intptr_t);
SteamAPICall_t SteamAPI_ISteamUtils_CheckFileSignature(intptr_t,const char*);
bool SteamAPI_ISteamUtils_ShowGamepadTextInput(intptr_t,EGamepadTextInputMode,EGamepadTextInputLineMode,const char*,uint32,const char*);
uint32 SteamAPI_ISteamUtils_GetEnteredGamepadTextLength(intptr_t);
bool SteamAPI_ISteamUtils_GetEnteredGamepadTextInput(intptr_t,char*,uint32);
const char*SteamAPI_ISteamUtils_GetSteamUILanguage(intptr_t);
bool SteamAPI_ISteamUtils_IsSteamRunningInVR(intptr_t);
void SteamAPI_ISteamUtils_SetOverlayNotificationInset(intptr_t,int,int);
bool SteamAPI_ISteamUtils_IsSteamInBigPictureMode(intptr_t);
void SteamAPI_ISteamUtils_StartVRDashboard(intptr_t);
bool SteamAPI_ISteamUtils_IsVRHeadsetStreamingEnabled(intptr_t);
void SteamAPI_ISteamUtils_SetVRHeadsetStreamingEnabled(intptr_t,bool);
bool SteamAPI_ISteamUtils_IsSteamChinaLauncher(intptr_t);
bool SteamAPI_ISteamUtils_InitFilterText(intptr_t,uint32);
int SteamAPI_ISteamUtils_FilterText(intptr_t,ETextFilteringContext,uint64_steamid,const char*,char*,uint32);
//ESteamIPv6ConnectivityState SteamAPI_ISteamUtils_GetIPv6ConnectivityState(intptr_t,ESteamIPv6ConnectivityProtocol);

intptr_t SteamAPI_SteamMatchmaking_v009();
int SteamAPI_ISteamMatchmaking_GetFavoriteGameCount(intptr_t);
bool SteamAPI_ISteamMatchmaking_GetFavoriteGame(intptr_t,int,AppId_t*,uint32*,uint16*,uint16*,uint32*,uint32*);
int SteamAPI_ISteamMatchmaking_AddFavoriteGame(intptr_t,AppId_t,uint32,uint16,uint16,uint32,uint32);
bool SteamAPI_ISteamMatchmaking_RemoveFavoriteGame(intptr_t,AppId_t,uint32,uint16,uint16,uint32);
SteamAPICall_t SteamAPI_ISteamMatchmaking_RequestLobbyList(intptr_t);
void SteamAPI_ISteamMatchmaking_AddRequestLobbyListStringFilter(intptr_t,const char*,const char*,ELobbyComparison);
void SteamAPI_ISteamMatchmaking_AddRequestLobbyListNumericalFilter(intptr_t,const char*,int,ELobbyComparison);
void SteamAPI_ISteamMatchmaking_AddRequestLobbyListNearValueFilter(intptr_t,const char*,int);
void SteamAPI_ISteamMatchmaking_AddRequestLobbyListFilterSlotsAvailable(intptr_t,int);
void SteamAPI_ISteamMatchmaking_AddRequestLobbyListDistanceFilter(intptr_t,ELobbyDistanceFilter);
void SteamAPI_ISteamMatchmaking_AddRequestLobbyListResultCountFilter(intptr_t,int);
void SteamAPI_ISteamMatchmaking_AddRequestLobbyListCompatibleMembersFilter(intptr_t,uint64_steamid);
uint64_steamid SteamAPI_ISteamMatchmaking_GetLobbyByIndex(intptr_t,int);
SteamAPICall_t SteamAPI_ISteamMatchmaking_CreateLobby(intptr_t,ELobbyType,int);
SteamAPICall_t SteamAPI_ISteamMatchmaking_JoinLobby(intptr_t,uint64_steamid);
void SteamAPI_ISteamMatchmaking_LeaveLobby(intptr_t,uint64_steamid);
bool SteamAPI_ISteamMatchmaking_InviteUserToLobby(intptr_t,uint64_steamid,uint64_steamid);
int SteamAPI_ISteamMatchmaking_GetNumLobbyMembers(intptr_t,uint64_steamid);
uint64_steamid SteamAPI_ISteamMatchmaking_GetLobbyMemberByIndex(intptr_t,uint64_steamid,int);
const char*SteamAPI_ISteamMatchmaking_GetLobbyData(intptr_t,uint64_steamid,const char*);
bool SteamAPI_ISteamMatchmaking_SetLobbyData(intptr_t,uint64_steamid,const char*,const char*);
int SteamAPI_ISteamMatchmaking_GetLobbyDataCount(intptr_t,uint64_steamid);
bool SteamAPI_ISteamMatchmaking_GetLobbyDataByIndex(intptr_t,uint64_steamid,int,char*,int,char*,int);
bool SteamAPI_ISteamMatchmaking_DeleteLobbyData(intptr_t,uint64_steamid,const char*);
const char*SteamAPI_ISteamMatchmaking_GetLobbyMemberData(intptr_t,uint64_steamid,uint64_steamid,const char*);
void SteamAPI_ISteamMatchmaking_SetLobbyMemberData(intptr_t,uint64_steamid,const char*,const char*);
bool SteamAPI_ISteamMatchmaking_SendLobbyChatMsg(intptr_t,uint64_steamid,const char*,int);
int SteamAPI_ISteamMatchmaking_GetLobbyChatEntry(intptr_t,uint64_steamid,int,struct CSteamID*,void*,int,EChatEntryType*);
bool SteamAPI_ISteamMatchmaking_RequestLobbyData(intptr_t,uint64_steamid);
void SteamAPI_ISteamMatchmaking_SetLobbyGameServer(intptr_t,uint64_steamid,uint32,uint16,uint64_steamid);
bool SteamAPI_ISteamMatchmaking_GetLobbyGameServer(intptr_t,uint64_steamid,uint32*,uint16*,struct CSteamID*);
bool SteamAPI_ISteamMatchmaking_SetLobbyMemberLimit(intptr_t,uint64_steamid,int);
int SteamAPI_ISteamMatchmaking_GetLobbyMemberLimit(intptr_t,uint64_steamid);
bool SteamAPI_ISteamMatchmaking_SetLobbyType(intptr_t,uint64_steamid,ELobbyType);
bool SteamAPI_ISteamMatchmaking_SetLobbyJoinable(intptr_t,uint64_steamid,bool);
uint64_steamid SteamAPI_ISteamMatchmaking_GetLobbyOwner(intptr_t,uint64_steamid);
bool SteamAPI_ISteamMatchmaking_SetLobbyOwner(intptr_t,uint64_steamid,uint64_steamid);
bool SteamAPI_ISteamMatchmaking_SetLinkedLobby(intptr_t,uint64_steamid,uint64_steamid);

void SteamAPI_ISteamMatchmakingServerListResponse_ServerResponded(struct ISteamMatchmakingServerListResponse*,HServerListRequest,int);
void SteamAPI_ISteamMatchmakingServerListResponse_ServerFailedToRespond(struct ISteamMatchmakingServerListResponse*,HServerListRequest,int);
void SteamAPI_ISteamMatchmakingServerListResponse_RefreshComplete(struct ISteamMatchmakingServerListResponse*,HServerListRequest,EMatchMakingServerResponse);

void SteamAPI_ISteamMatchmakingPingResponse_ServerResponded(struct ISteamMatchmakingPingResponse*,struct gameserveritem_t&);
void SteamAPI_ISteamMatchmakingPingResponse_ServerFailedToRespond(struct ISteamMatchmakingPingResponse*);

void SteamAPI_ISteamMatchmakingPlayersResponse_AddPlayerToList(struct ISteamMatchmakingPlayersResponse*,const char*,int,float);
void SteamAPI_ISteamMatchmakingPlayersResponse_PlayersFailedToRespond(struct ISteamMatchmakingPlayersResponse*);
void SteamAPI_ISteamMatchmakingPlayersResponse_PlayersRefreshComplete(struct ISteamMatchmakingPlayersResponse*);

void SteamAPI_ISteamMatchmakingRulesResponse_RulesResponded(struct ISteamMatchmakingRulesResponse*,const char*,const char*);
void SteamAPI_ISteamMatchmakingRulesResponse_RulesFailedToRespond(struct ISteamMatchmakingRulesResponse*);
void SteamAPI_ISteamMatchmakingRulesResponse_RulesRefreshComplete(struct ISteamMatchmakingRulesResponse*);

intptr_t SteamAPI_SteamMatchmakingServers_v002();
HServerListRequest SteamAPI_ISteamMatchmakingServers_RequestInternetServerList(intptr_t,AppId_t,struct MatchMakingKeyValuePair_t**,uint32,struct ISteamMatchmakingServerListResponse*);
HServerListRequest SteamAPI_ISteamMatchmakingServers_RequestLANServerList(intptr_t,AppId_t,struct ISteamMatchmakingServerListResponse*);
HServerListRequest SteamAPI_ISteamMatchmakingServers_RequestFriendsServerList(intptr_t,AppId_t,struct MatchMakingKeyValuePair_t**,uint32,struct ISteamMatchmakingServerListResponse*);
HServerListRequest SteamAPI_ISteamMatchmakingServers_RequestFavoritesServerList(intptr_t,AppId_t,struct MatchMakingKeyValuePair_t**,uint32,struct ISteamMatchmakingServerListResponse*);
HServerListRequest SteamAPI_ISteamMatchmakingServers_RequestHistoryServerList(intptr_t,AppId_t,struct MatchMakingKeyValuePair_t**,uint32,struct ISteamMatchmakingServerListResponse*);
HServerListRequest SteamAPI_ISteamMatchmakingServers_RequestSpectatorServerList(intptr_t,AppId_t,struct MatchMakingKeyValuePair_t**,uint32,struct ISteamMatchmakingServerListResponse*);
void SteamAPI_ISteamMatchmakingServers_ReleaseRequest(intptr_t,HServerListRequest);
struct gameserveritem_t*SteamAPI_ISteamMatchmakingServers_GetServerDetails(intptr_t,HServerListRequest,int);
void SteamAPI_ISteamMatchmakingServers_CancelQuery(intptr_t,HServerListRequest);
void SteamAPI_ISteamMatchmakingServers_RefreshQuery(intptr_t,HServerListRequest);
bool SteamAPI_ISteamMatchmakingServers_IsRefreshing(intptr_t,HServerListRequest);
int SteamAPI_ISteamMatchmakingServers_GetServerCount(intptr_t,HServerListRequest);
void SteamAPI_ISteamMatchmakingServers_RefreshServer(intptr_t,HServerListRequest,int);
HServerQuery SteamAPI_ISteamMatchmakingServers_PingServer(intptr_t,uint32,uint16,struct ISteamMatchmakingPingResponse*);
HServerQuery SteamAPI_ISteamMatchmakingServers_PlayerDetails(intptr_t,uint32,uint16,struct ISteamMatchmakingPlayersResponse*);
HServerQuery SteamAPI_ISteamMatchmakingServers_ServerRules(intptr_t,uint32,uint16,struct ISteamMatchmakingRulesResponse*);
void SteamAPI_ISteamMatchmakingServers_CancelServerQuery(intptr_t,HServerQuery);

intptr_t SteamAPI_SteamGameSearch_v001();
EGameSearchErrorCode_t SteamAPI_ISteamGameSearch_AddGameSearchParams(intptr_t,const char*,const char*);
EGameSearchErrorCode_t SteamAPI_ISteamGameSearch_SearchForGameWithLobby(intptr_t,uint64_steamid,int,int);
EGameSearchErrorCode_t SteamAPI_ISteamGameSearch_SearchForGameSolo(intptr_t,int,int);
EGameSearchErrorCode_t SteamAPI_ISteamGameSearch_AcceptGame(intptr_t);
EGameSearchErrorCode_t SteamAPI_ISteamGameSearch_DeclineGame(intptr_t);
EGameSearchErrorCode_t SteamAPI_ISteamGameSearch_RetrieveConnectionDetails(intptr_t,uint64_steamid,char*,int);
EGameSearchErrorCode_t SteamAPI_ISteamGameSearch_EndGameSearch(intptr_t);
EGameSearchErrorCode_t SteamAPI_ISteamGameSearch_SetGameHostParams(intptr_t,const char*,const char*);
EGameSearchErrorCode_t SteamAPI_ISteamGameSearch_SetConnectionDetails(intptr_t,const char*,int);
EGameSearchErrorCode_t SteamAPI_ISteamGameSearch_RequestPlayersForGame(intptr_t,int,int,int);
EGameSearchErrorCode_t SteamAPI_ISteamGameSearch_HostConfirmGameStart(intptr_t,uint64);
EGameSearchErrorCode_t SteamAPI_ISteamGameSearch_CancelRequestPlayersForGame(intptr_t);
EGameSearchErrorCode_t SteamAPI_ISteamGameSearch_SubmitPlayerResult(intptr_t,uint64,uint64_steamid,EPlayerResult_t);
EGameSearchErrorCode_t SteamAPI_ISteamGameSearch_EndGame(intptr_t,uint64);

intptr_t SteamAPI_SteamParties_v002();
uint32 SteamAPI_ISteamParties_GetNumActiveBeacons(intptr_t);
PartyBeaconID_t SteamAPI_ISteamParties_GetBeaconByIndex(intptr_t,uint32);
bool SteamAPI_ISteamParties_GetBeaconDetails(intptr_t,PartyBeaconID_t,struct CSteamID*,struct SteamPartyBeaconLocation_t*,char*,int);
SteamAPICall_t SteamAPI_ISteamParties_JoinParty(intptr_t,PartyBeaconID_t);
bool SteamAPI_ISteamParties_GetNumAvailableBeaconLocations(intptr_t,uint32*);
bool SteamAPI_ISteamParties_GetAvailableBeaconLocations(intptr_t,struct SteamPartyBeaconLocation_t*,uint32);
SteamAPICall_t SteamAPI_ISteamParties_CreateBeacon(intptr_t,uint32,struct SteamPartyBeaconLocation_t*,const char*,const char*);
void SteamAPI_ISteamParties_OnReservationCompleted(intptr_t,PartyBeaconID_t,uint64_steamid);
void SteamAPI_ISteamParties_CancelReservation(intptr_t,PartyBeaconID_t,uint64_steamid);
SteamAPICall_t SteamAPI_ISteamParties_ChangeNumOpenSlots(intptr_t,PartyBeaconID_t,uint32);
bool SteamAPI_ISteamParties_DestroyBeacon(intptr_t,PartyBeaconID_t);
bool SteamAPI_ISteamParties_GetBeaconLocationData(intptr_t,struct SteamPartyBeaconLocation_t,ESteamPartyBeaconLocationData,char*,int);

intptr_t SteamAPI_SteamRemoteStorage_v014();
bool SteamAPI_ISteamRemoteStorage_FileWrite(intptr_t,const char*,const char*,int32);
int32 SteamAPI_ISteamRemoteStorage_FileRead(intptr_t,const char*,void*,int32);
SteamAPICall_t SteamAPI_ISteamRemoteStorage_FileWriteAsync(intptr_t,const char*,const char*,uint32);
SteamAPICall_t SteamAPI_ISteamRemoteStorage_FileReadAsync(intptr_t,const char*,uint32,uint32);
bool SteamAPI_ISteamRemoteStorage_FileReadAsyncComplete(intptr_t,SteamAPICall_t,void*,uint32);
bool SteamAPI_ISteamRemoteStorage_FileForget(intptr_t,const char*);
bool SteamAPI_ISteamRemoteStorage_FileDelete(intptr_t,const char*);
SteamAPICall_t SteamAPI_ISteamRemoteStorage_FileShare(intptr_t,const char*);
bool SteamAPI_ISteamRemoteStorage_SetSyncPlatforms(intptr_t,const char*,ERemoteStoragePlatform);
UGCFileWriteStreamHandle_t SteamAPI_ISteamRemoteStorage_FileWriteStreamOpen(intptr_t,const char*);
bool SteamAPI_ISteamRemoteStorage_FileWriteStreamWriteChunk(intptr_t,UGCFileWriteStreamHandle_t,const char*,int32);
bool SteamAPI_ISteamRemoteStorage_FileWriteStreamClose(intptr_t,UGCFileWriteStreamHandle_t);
bool SteamAPI_ISteamRemoteStorage_FileWriteStreamCancel(intptr_t,UGCFileWriteStreamHandle_t);
bool SteamAPI_ISteamRemoteStorage_FileExists(intptr_t,const char*);
bool SteamAPI_ISteamRemoteStorage_FilePersisted(intptr_t,const char*);
int32 SteamAPI_ISteamRemoteStorage_GetFileSize(intptr_t,const char*);
int64 SteamAPI_ISteamRemoteStorage_GetFileTimestamp(intptr_t,const char*);
ERemoteStoragePlatform SteamAPI_ISteamRemoteStorage_GetSyncPlatforms(intptr_t,const char*);
int32 SteamAPI_ISteamRemoteStorage_GetFileCount(intptr_t);
const char*SteamAPI_ISteamRemoteStorage_GetFileNameAndSize(intptr_t,int,int32*);
bool SteamAPI_ISteamRemoteStorage_GetQuota(intptr_t,uint64*,uint64*);
bool SteamAPI_ISteamRemoteStorage_IsCloudEnabledForAccount(intptr_t);
bool SteamAPI_ISteamRemoteStorage_IsCloudEnabledForApp(intptr_t);
void SteamAPI_ISteamRemoteStorage_SetCloudEnabledForApp(intptr_t,bool);
SteamAPICall_t SteamAPI_ISteamRemoteStorage_UGCDownload(intptr_t,UGCHandle_t,uint32);
bool SteamAPI_ISteamRemoteStorage_GetUGCDownloadProgress(intptr_t,UGCHandle_t,int32*,int32*);
bool SteamAPI_ISteamRemoteStorage_GetUGCDetails(intptr_t,UGCHandle_t,AppId_t*,char**,int32*,struct CSteamID*);
int32 SteamAPI_ISteamRemoteStorage_UGCRead(intptr_t,UGCHandle_t,void*,int32,uint32,EUGCReadAction);
int32 SteamAPI_ISteamRemoteStorage_GetCachedUGCCount(intptr_t);
UGCHandle_t SteamAPI_ISteamRemoteStorage_GetCachedUGCHandle(intptr_t,int32);
SteamAPICall_t SteamAPI_ISteamRemoteStorage_PublishWorkshopFile(intptr_t,const char*,const char*,AppId_t,const char*,const char*,ERemoteStoragePublishedFileVisibility,struct SteamParamStringArray_t*,EWorkshopFileType);
PublishedFileUpdateHandle_t SteamAPI_ISteamRemoteStorage_CreatePublishedFileUpdateRequest(intptr_t,PublishedFileId_t);
bool SteamAPI_ISteamRemoteStorage_UpdatePublishedFileFile(intptr_t,PublishedFileUpdateHandle_t,const char*);
bool SteamAPI_ISteamRemoteStorage_UpdatePublishedFilePreviewFile(intptr_t,PublishedFileUpdateHandle_t,const char*);
bool SteamAPI_ISteamRemoteStorage_UpdatePublishedFileTitle(intptr_t,PublishedFileUpdateHandle_t,const char*);
bool SteamAPI_ISteamRemoteStorage_UpdatePublishedFileDescription(intptr_t,PublishedFileUpdateHandle_t,const char*);
bool SteamAPI_ISteamRemoteStorage_UpdatePublishedFileVisibility(intptr_t,PublishedFileUpdateHandle_t,ERemoteStoragePublishedFileVisibility);
bool SteamAPI_ISteamRemoteStorage_UpdatePublishedFileTags(intptr_t,PublishedFileUpdateHandle_t,struct SteamParamStringArray_t*);
SteamAPICall_t SteamAPI_ISteamRemoteStorage_CommitPublishedFileUpdate(intptr_t,PublishedFileUpdateHandle_t);
SteamAPICall_t SteamAPI_ISteamRemoteStorage_GetPublishedFileDetails(intptr_t,PublishedFileId_t,uint32);
SteamAPICall_t SteamAPI_ISteamRemoteStorage_DeletePublishedFile(intptr_t,PublishedFileId_t);
SteamAPICall_t SteamAPI_ISteamRemoteStorage_EnumerateUserPublishedFiles(intptr_t,uint32);
SteamAPICall_t SteamAPI_ISteamRemoteStorage_SubscribePublishedFile(intptr_t,PublishedFileId_t);
SteamAPICall_t SteamAPI_ISteamRemoteStorage_EnumerateUserSubscribedFiles(intptr_t,uint32);
SteamAPICall_t SteamAPI_ISteamRemoteStorage_UnsubscribePublishedFile(intptr_t,PublishedFileId_t);
bool SteamAPI_ISteamRemoteStorage_UpdatePublishedFileSetChangeDescription(intptr_t,PublishedFileUpdateHandle_t,const char*);
SteamAPICall_t SteamAPI_ISteamRemoteStorage_GetPublishedItemVoteDetails(intptr_t,PublishedFileId_t);
SteamAPICall_t SteamAPI_ISteamRemoteStorage_UpdateUserPublishedItemVote(intptr_t,PublishedFileId_t,bool);
SteamAPICall_t SteamAPI_ISteamRemoteStorage_GetUserPublishedItemVoteDetails(intptr_t,PublishedFileId_t);
SteamAPICall_t SteamAPI_ISteamRemoteStorage_EnumerateUserSharedWorkshopFiles(intptr_t,uint64_steamid,uint32,struct SteamParamStringArray_t*,struct SteamParamStringArray_t*);
SteamAPICall_t SteamAPI_ISteamRemoteStorage_PublishVideo(intptr_t,EWorkshopVideoProvider,const char*,const char*,const char*,AppId_t,const char*,const char*,ERemoteStoragePublishedFileVisibility,struct SteamParamStringArray_t*);
SteamAPICall_t SteamAPI_ISteamRemoteStorage_SetUserPublishedFileAction(intptr_t,PublishedFileId_t,EWorkshopFileAction);
SteamAPICall_t SteamAPI_ISteamRemoteStorage_EnumeratePublishedFilesByUserAction(intptr_t,EWorkshopFileAction,uint32);
SteamAPICall_t SteamAPI_ISteamRemoteStorage_EnumeratePublishedWorkshopFiles(intptr_t,EWorkshopEnumerationType,uint32,uint32,uint32,struct SteamParamStringArray_t*,struct SteamParamStringArray_t*);
SteamAPICall_t SteamAPI_ISteamRemoteStorage_UGCDownloadToLocation(intptr_t,UGCHandle_t,const char*,uint32);

// ISteamUserStats
intptr_t SteamAPI_SteamUserStats_v012();
bool SteamAPI_ISteamUserStats_RequestCurrentStats(intptr_t);
bool SteamAPI_ISteamUserStats_GetStatInt32(intptr_t,const char*,int32*);
bool SteamAPI_ISteamUserStats_GetStatFloat(intptr_t,const char*,float*);
bool SteamAPI_ISteamUserStats_SetStatInt32(intptr_t,const char*,int32);
bool SteamAPI_ISteamUserStats_SetStatFloat(intptr_t,const char*,float);
bool SteamAPI_ISteamUserStats_UpdateAvgRateStat(intptr_t,const char*,float,double);
bool SteamAPI_ISteamUserStats_GetAchievement(intptr_t,const char*,bool*);
bool SteamAPI_ISteamUserStats_SetAchievement(intptr_t,const char*);
bool SteamAPI_ISteamUserStats_ClearAchievement(intptr_t,const char*);
bool SteamAPI_ISteamUserStats_GetAchievementAndUnlockTime(intptr_t,const char*,bool*,uint32*);
bool SteamAPI_ISteamUserStats_StoreStats(intptr_t);
int SteamAPI_ISteamUserStats_GetAchievementIcon(intptr_t,const char*);
const char* SteamAPI_ISteamUserStats_GetAchievementDisplayAttribute(intptr_t,const char*,const char*);
bool SteamAPI_ISteamUserStats_IndicateAchievementProgress(intptr_t,const char*,uint32,uint32);
uint32 SteamAPI_ISteamUserStats_GetNumAchievements(intptr_t);
const char* SteamAPI_ISteamUserStats_GetAchievementName(intptr_t,uint32);
SteamAPICall_t SteamAPI_ISteamUserStats_RequestUserStats(intptr_t,uint64_steamid);
bool SteamAPI_ISteamUserStats_GetUserStatInt32(intptr_t,uint64_steamid,const char*,int32*);
bool SteamAPI_ISteamUserStats_GetUserStatFloat(intptr_t,uint64_steamid,const char*,float*);
bool SteamAPI_ISteamUserStats_GetUserAchievement(intptr_t,uint64_steamid,const char*,bool*);
bool SteamAPI_ISteamUserStats_GetUserAchievementAndUnlockTime(intptr_t,uint64_steamid,const char*,bool*,uint32*);
bool SteamAPI_ISteamUserStats_ResetAllStats(intptr_t,bool);
SteamAPICall_t SteamAPI_ISteamUserStats_FindOrCreateLeaderboard(intptr_t,const char*,ELeaderboardSortMethod,ELeaderboardDisplayType);
SteamAPICall_t SteamAPI_ISteamUserStats_FindLeaderboard(intptr_t,const char*);
const char* SteamAPI_ISteamUserStats_GetLeaderboardName(intptr_t,SteamLeaderboard_t);
int SteamAPI_ISteamUserStats_GetLeaderboardEntryCount(intptr_t,SteamLeaderboard_t);
ELeaderboardSortMethod SteamAPI_ISteamUserStats_GetLeaderboardSortMethod(intptr_t,SteamLeaderboard_t);
ELeaderboardDisplayType SteamAPI_ISteamUserStats_GetLeaderboardDisplayType(intptr_t,SteamLeaderboard_t);
SteamAPICall_t SteamAPI_ISteamUserStats_DownloadLeaderboardEntries(intptr_t,SteamLeaderboard_t,ELeaderboardDataRequest,int,int);
SteamAPICall_t SteamAPI_ISteamUserStats_DownloadLeaderboardEntriesForUsers(intptr_t,SteamLeaderboard_t,struct CSteamID*,int);
bool SteamAPI_ISteamUserStats_GetDownloadedLeaderboardEntry(intptr_t,SteamLeaderboardEntries_t,int,struct LeaderboardEntry_t*,int32*,int);
SteamAPICall_t SteamAPI_ISteamUserStats_UploadLeaderboardScore(intptr_t,SteamLeaderboard_t,ELeaderboardUploadScoreMethod,int32,const int32*,int);
SteamAPICall_t SteamAPI_ISteamUserStats_AttachLeaderboardUGC(intptr_t,SteamLeaderboard_t,UGCHandle_t);
SteamAPICall_t SteamAPI_ISteamUserStats_GetNumberOfCurrentPlayers(intptr_t);
SteamAPICall_t SteamAPI_ISteamUserStats_RequestGlobalAchievementPercentages(intptr_t);
int SteamAPI_ISteamUserStats_GetMostAchievedAchievementInfo(intptr_t,char*,uint32,float*,bool*);
int SteamAPI_ISteamUserStats_GetNextMostAchievedAchievementInfo(intptr_t,int,char*,uint32,float*,bool*);
bool SteamAPI_ISteamUserStats_GetAchievementAchievedPercent(intptr_t,const char*,float*);
SteamAPICall_t SteamAPI_ISteamUserStats_RequestGlobalStats(intptr_t,int);
bool SteamAPI_ISteamUserStats_GetGlobalStatInt64(intptr_t,const char*,int64*);
bool SteamAPI_ISteamUserStats_GetGlobalStatDouble(intptr_t,const char*,double*);
int32 SteamAPI_ISteamUserStats_GetGlobalStatHistoryInt64(intptr_t,const char*,int64*,uint32);
int32 SteamAPI_ISteamUserStats_GetGlobalStatHistoryDouble(intptr_t,const char*,double*,uint32);
bool SteamAPI_ISteamUserStats_GetAchievementProgressLimitsInt32(intptr_t,const char*,int32*,int32*);
bool SteamAPI_ISteamUserStats_GetAchievementProgressLimitsFloat(intptr_t,const char*,float*,float*);

intptr_t SteamAPI_SteamApps_v008();
intptr_t SteamAPI_SteamGameServerApps_v008();
bool SteamAPI_ISteamApps_BIsSubscribed(intptr_t);
bool SteamAPI_ISteamApps_BIsLowViolence(intptr_t);
bool SteamAPI_ISteamApps_BIsCybercafe(intptr_t);
bool SteamAPI_ISteamApps_BIsVACBanned(intptr_t);
const char*SteamAPI_ISteamApps_GetCurrentGameLanguage(intptr_t);
const char*SteamAPI_ISteamApps_GetAvailableGameLanguages(intptr_t);
bool SteamAPI_ISteamApps_BIsSubscribedApp(intptr_t,AppId_t);
bool SteamAPI_ISteamApps_BIsDlcInstalled(intptr_t,AppId_t);
uint32 SteamAPI_ISteamApps_GetEarliestPurchaseUnixTime(intptr_t,AppId_t);
bool SteamAPI_ISteamApps_BIsSubscribedFromFreeWeekend(intptr_t);
int SteamAPI_ISteamApps_GetDLCCount(intptr_t);
bool SteamAPI_ISteamApps_BGetDLCDataByIndex(intptr_t,int,AppId_t*,bool*,char*,int);
void SteamAPI_ISteamApps_InstallDLC(intptr_t,AppId_t);
void SteamAPI_ISteamApps_UninstallDLC(intptr_t,AppId_t);
void SteamAPI_ISteamApps_RequestAppProofOfPurchaseKey(intptr_t,AppId_t);
bool SteamAPI_ISteamApps_GetCurrentBetaName(intptr_t,char*,int);
bool SteamAPI_ISteamApps_MarkContentCorrupt(intptr_t,bool);
uint32 SteamAPI_ISteamApps_GetInstalledDepots(intptr_t,AppId_t,DepotId_t*,uint32);
uint32 SteamAPI_ISteamApps_GetAppInstallDir(intptr_t,AppId_t,char*,uint32);
bool SteamAPI_ISteamApps_BIsAppInstalled(intptr_t,AppId_t);
uint64_steamid SteamAPI_ISteamApps_GetAppOwner(intptr_t);
const char*SteamAPI_ISteamApps_GetLaunchQueryParam(intptr_t,const char*);
bool SteamAPI_ISteamApps_GetDlcDownloadProgress(intptr_t,AppId_t,uint64*,uint64*);
int SteamAPI_ISteamApps_GetAppBuildId(intptr_t);
void SteamAPI_ISteamApps_RequestAllProofOfPurchaseKeys(intptr_t);
SteamAPICall_t SteamAPI_ISteamApps_GetFileDetails(intptr_t,const char*);
int SteamAPI_ISteamApps_GetLaunchCommandLine(intptr_t,char*,int);
bool SteamAPI_ISteamApps_BIsSubscribedFromFamilySharing(intptr_t);

intptr_t SteamAPI_SteamNetworking_v006();
intptr_t SteamAPI_SteamGameServerNetworking_v006();
bool SteamAPI_ISteamNetworking_SendP2PPacket(intptr_t,uint64_steamid,const char*,uint32,EP2PSend,int);
bool SteamAPI_ISteamNetworking_IsP2PPacketAvailable(intptr_t,uint32*,int);
bool SteamAPI_ISteamNetworking_ReadP2PPacket(intptr_t,void*,uint32,uint32*,struct CSteamID*,int);
bool SteamAPI_ISteamNetworking_AcceptP2PSessionWithUser(intptr_t,uint64_steamid);
bool SteamAPI_ISteamNetworking_CloseP2PSessionWithUser(intptr_t,uint64_steamid);
bool SteamAPI_ISteamNetworking_CloseP2PChannelWithUser(intptr_t,uint64_steamid,int);
bool SteamAPI_ISteamNetworking_GetP2PSessionState(intptr_t,uint64_steamid,struct P2PSessionState_t*);
bool SteamAPI_ISteamNetworking_AllowP2PPacketRelay(intptr_t,bool);
SNetListenSocket_t SteamAPI_ISteamNetworking_CreateListenSocket(intptr_t,int,struct SteamIPAddress_t,uint16,bool);
SNetSocket_t SteamAPI_ISteamNetworking_CreateP2PConnectionSocket(intptr_t,uint64_steamid,int,int,bool);
SNetSocket_t SteamAPI_ISteamNetworking_CreateConnectionSocket(intptr_t,struct SteamIPAddress_t,uint16,int);
bool SteamAPI_ISteamNetworking_DestroySocket(intptr_t,SNetSocket_t,bool);
bool SteamAPI_ISteamNetworking_DestroyListenSocket(intptr_t,SNetListenSocket_t,bool);
bool SteamAPI_ISteamNetworking_SendDataOnSocket(intptr_t,SNetSocket_t,void*,uint32,bool);
bool SteamAPI_ISteamNetworking_IsDataAvailableOnSocket(intptr_t,SNetSocket_t,uint32*);
bool SteamAPI_ISteamNetworking_RetrieveDataFromSocket(intptr_t,SNetSocket_t,void*,uint32,uint32*);
bool SteamAPI_ISteamNetworking_IsDataAvailable(intptr_t,SNetListenSocket_t,uint32*,SNetSocket_t*);
bool SteamAPI_ISteamNetworking_RetrieveData(intptr_t,SNetListenSocket_t,void*,uint32,uint32*,SNetSocket_t*);
bool SteamAPI_ISteamNetworking_GetSocketInfo(intptr_t,SNetSocket_t,struct CSteamID*,int*,struct SteamIPAddress_t*,uint16*);
bool SteamAPI_ISteamNetworking_GetListenSocketInfo(intptr_t,SNetListenSocket_t,struct SteamIPAddress_t*,uint16*);
ESNetSocketConnectionType SteamAPI_ISteamNetworking_GetSocketConnectionType(intptr_t,SNetSocket_t);
int SteamAPI_ISteamNetworking_GetMaxPacketSize(intptr_t,SNetSocket_t);

intptr_t SteamAPI_SteamScreenshots_v003();
ScreenshotHandle SteamAPI_ISteamScreenshots_WriteScreenshot(intptr_t,void*,uint32,int,int);
ScreenshotHandle SteamAPI_ISteamScreenshots_AddScreenshotToLibrary(intptr_t,const char*,const char*,int,int);
void SteamAPI_ISteamScreenshots_TriggerScreenshot(intptr_t);
void SteamAPI_ISteamScreenshots_HookScreenshots(intptr_t,bool);
bool SteamAPI_ISteamScreenshots_SetLocation(intptr_t,ScreenshotHandle,const char*);
bool SteamAPI_ISteamScreenshots_TagUser(intptr_t,ScreenshotHandle,uint64_steamid);
bool SteamAPI_ISteamScreenshots_TagPublishedFile(intptr_t,ScreenshotHandle,PublishedFileId_t);
bool SteamAPI_ISteamScreenshots_IsScreenshotsHooked(intptr_t);
ScreenshotHandle SteamAPI_ISteamScreenshots_AddVRScreenshotToLibrary(intptr_t,EVRScreenshotType,const char*,const char*);

intptr_t SteamAPI_SteamMusic_v001();
bool SteamAPI_ISteamMusic_BIsEnabled(intptr_t);
bool SteamAPI_ISteamMusic_BIsPlaying(intptr_t);
AudioPlayback_Status SteamAPI_ISteamMusic_GetPlaybackStatus(intptr_t);
void SteamAPI_ISteamMusic_Play(intptr_t);
void SteamAPI_ISteamMusic_Pause(intptr_t);
void SteamAPI_ISteamMusic_PlayPrevious(intptr_t);
void SteamAPI_ISteamMusic_PlayNext(intptr_t);
void SteamAPI_ISteamMusic_SetVolume(intptr_t,float);
float SteamAPI_ISteamMusic_GetVolume(intptr_t);

intptr_t SteamAPI_SteamMusicRemote_v001();
bool SteamAPI_ISteamMusicRemote_RegisterSteamMusicRemote(intptr_t,const char*);
bool SteamAPI_ISteamMusicRemote_DeregisterSteamMusicRemote(intptr_t);
bool SteamAPI_ISteamMusicRemote_BIsCurrentMusicRemote(intptr_t);
bool SteamAPI_ISteamMusicRemote_BActivationSuccess(intptr_t,bool);
bool SteamAPI_ISteamMusicRemote_SetDisplayName(intptr_t,const char*);
bool SteamAPI_ISteamMusicRemote_SetPNGIcon_64x64(intptr_t,void*,uint32);
bool SteamAPI_ISteamMusicRemote_EnablePlayPrevious(intptr_t,bool);
bool SteamAPI_ISteamMusicRemote_EnablePlayNext(intptr_t,bool);
bool SteamAPI_ISteamMusicRemote_EnableShuffled(intptr_t,bool);
bool SteamAPI_ISteamMusicRemote_EnableLooped(intptr_t,bool);
bool SteamAPI_ISteamMusicRemote_EnableQueue(intptr_t,bool);
bool SteamAPI_ISteamMusicRemote_EnablePlaylists(intptr_t,bool);
bool SteamAPI_ISteamMusicRemote_UpdatePlaybackStatus(intptr_t,AudioPlayback_Status);
bool SteamAPI_ISteamMusicRemote_UpdateShuffled(intptr_t,bool);
bool SteamAPI_ISteamMusicRemote_UpdateLooped(intptr_t,bool);
bool SteamAPI_ISteamMusicRemote_UpdateVolume(intptr_t,float);
bool SteamAPI_ISteamMusicRemote_CurrentEntryWillChange(intptr_t);
bool SteamAPI_ISteamMusicRemote_CurrentEntryIsAvailable(intptr_t,bool);
bool SteamAPI_ISteamMusicRemote_UpdateCurrentEntryText(intptr_t,const char*);
bool SteamAPI_ISteamMusicRemote_UpdateCurrentEntryElapsedSeconds(intptr_t,int);
bool SteamAPI_ISteamMusicRemote_UpdateCurrentEntryCoverArt(intptr_t,void*,uint32);
bool SteamAPI_ISteamMusicRemote_CurrentEntryDidChange(intptr_t);
bool SteamAPI_ISteamMusicRemote_QueueWillChange(intptr_t);
bool SteamAPI_ISteamMusicRemote_ResetQueueEntries(intptr_t);
bool SteamAPI_ISteamMusicRemote_SetQueueEntry(intptr_t,int,int,const char*);
bool SteamAPI_ISteamMusicRemote_SetCurrentQueueEntry(intptr_t,int);
bool SteamAPI_ISteamMusicRemote_QueueDidChange(intptr_t);
bool SteamAPI_ISteamMusicRemote_PlaylistWillChange(intptr_t);
bool SteamAPI_ISteamMusicRemote_ResetPlaylistEntries(intptr_t);
bool SteamAPI_ISteamMusicRemote_SetPlaylistEntry(intptr_t,int,int,const char*);
bool SteamAPI_ISteamMusicRemote_SetCurrentPlaylistEntry(intptr_t,int);
bool SteamAPI_ISteamMusicRemote_PlaylistDidChange(intptr_t);

intptr_t SteamAPI_SteamHTTP_v003();
intptr_t SteamAPI_SteamGameServerHTTP_v003();
HTTPRequestHandle SteamAPI_ISteamHTTP_CreateHTTPRequest(intptr_t,EHTTPMethod,const char*);
bool SteamAPI_ISteamHTTP_SetHTTPRequestContextValue(intptr_t,HTTPRequestHandle,uint64);
bool SteamAPI_ISteamHTTP_SetHTTPRequestNetworkActivityTimeout(intptr_t,HTTPRequestHandle,uint32);
bool SteamAPI_ISteamHTTP_SetHTTPRequestHeaderValue(intptr_t,HTTPRequestHandle,const char*,const char*);
bool SteamAPI_ISteamHTTP_SetHTTPRequestGetOrPostParameter(intptr_t,HTTPRequestHandle,const char*,const char*);
bool SteamAPI_ISteamHTTP_SendHTTPRequest(intptr_t,HTTPRequestHandle,SteamAPICall_t*);
bool SteamAPI_ISteamHTTP_SendHTTPRequestAndStreamResponse(intptr_t,HTTPRequestHandle,SteamAPICall_t*);
bool SteamAPI_ISteamHTTP_DeferHTTPRequest(intptr_t,HTTPRequestHandle);
bool SteamAPI_ISteamHTTP_PrioritizeHTTPRequest(intptr_t,HTTPRequestHandle);
bool SteamAPI_ISteamHTTP_GetHTTPResponseHeaderSize(intptr_t,HTTPRequestHandle,const char*,uint32*);
bool SteamAPI_ISteamHTTP_GetHTTPResponseHeaderValue(intptr_t,HTTPRequestHandle,const char*,uint8*,uint32);
bool SteamAPI_ISteamHTTP_GetHTTPResponseBodySize(intptr_t,HTTPRequestHandle,uint32*);
bool SteamAPI_ISteamHTTP_GetHTTPResponseBodyData(intptr_t,HTTPRequestHandle,uint8*,uint32);
bool SteamAPI_ISteamHTTP_GetHTTPStreamingResponseBodyData(intptr_t,HTTPRequestHandle,uint32,uint8*,uint32);
bool SteamAPI_ISteamHTTP_ReleaseHTTPRequest(intptr_t,HTTPRequestHandle);
bool SteamAPI_ISteamHTTP_GetHTTPDownloadProgressPct(intptr_t,HTTPRequestHandle,float*);
bool SteamAPI_ISteamHTTP_SetHTTPRequestRawPostBody(intptr_t,HTTPRequestHandle,const char*,uint8*,uint32);
HTTPCookieContainerHandle SteamAPI_ISteamHTTP_CreateCookieContainer(intptr_t,bool);
bool SteamAPI_ISteamHTTP_ReleaseCookieContainer(intptr_t,HTTPCookieContainerHandle);
bool SteamAPI_ISteamHTTP_SetCookie(intptr_t,HTTPCookieContainerHandle,const char*,const char*,const char*);
bool SteamAPI_ISteamHTTP_SetHTTPRequestCookieContainer(intptr_t,HTTPRequestHandle,HTTPCookieContainerHandle);
bool SteamAPI_ISteamHTTP_SetHTTPRequestUserAgentInfo(intptr_t,HTTPRequestHandle,const char*);
bool SteamAPI_ISteamHTTP_SetHTTPRequestRequiresVerifiedCertificate(intptr_t,HTTPRequestHandle,bool);
bool SteamAPI_ISteamHTTP_SetHTTPRequestAbsoluteTimeoutMS(intptr_t,HTTPRequestHandle,uint32);
bool SteamAPI_ISteamHTTP_GetHTTPRequestWasTimedOut(intptr_t,HTTPRequestHandle,bool*);

intptr_t SteamAPI_SteamInput_v002();
bool SteamAPI_ISteamInput_Init(intptr_t);
bool SteamAPI_ISteamInput_Shutdown(intptr_t);
void SteamAPI_ISteamInput_RunFrame(intptr_t);
int SteamAPI_ISteamInput_GetConnectedControllers(intptr_t,InputHandle_t*);
InputActionSetHandle_t SteamAPI_ISteamInput_GetActionSetHandle(intptr_t,const char*);
void SteamAPI_ISteamInput_ActivateActionSet(intptr_t,InputHandle_t,InputActionSetHandle_t);
InputActionSetHandle_t SteamAPI_ISteamInput_GetCurrentActionSet(intptr_t,InputHandle_t);
void SteamAPI_ISteamInput_ActivateActionSetLayer(intptr_t,InputHandle_t,InputActionSetHandle_t);
void SteamAPI_ISteamInput_DeactivateActionSetLayer(intptr_t,InputHandle_t,InputActionSetHandle_t);
void SteamAPI_ISteamInput_DeactivateAllActionSetLayers(intptr_t,InputHandle_t);
int SteamAPI_ISteamInput_GetActiveActionSetLayers(intptr_t,InputHandle_t,InputActionSetHandle_t*);
InputDigitalActionHandle_t SteamAPI_ISteamInput_GetDigitalActionHandle(intptr_t,const char*);
InputDigitalActionData_t SteamAPI_ISteamInput_GetDigitalActionData(intptr_t,InputHandle_t,InputDigitalActionHandle_t);
int SteamAPI_ISteamInput_GetDigitalActionOrigins(intptr_t,InputHandle_t,InputActionSetHandle_t,InputDigitalActionHandle_t,EInputActionOrigin*);
InputAnalogActionHandle_t SteamAPI_ISteamInput_GetAnalogActionHandle(intptr_t,const char*);
InputAnalogActionData_t SteamAPI_ISteamInput_GetAnalogActionData(intptr_t,InputHandle_t,InputAnalogActionHandle_t);
int SteamAPI_ISteamInput_GetAnalogActionOrigins(intptr_t,InputHandle_t,InputActionSetHandle_t,InputAnalogActionHandle_t,EInputActionOrigin*);
const char* SteamAPI_ISteamInput_GetGlyphForActionOrigin(intptr_t,EInputActionOrigin);
const char* SteamAPI_ISteamInput_GetStringForActionOrigin(intptr_t,EInputActionOrigin);
void SteamAPI_ISteamInput_StopAnalogActionMomentum(intptr_t,InputHandle_t,InputAnalogActionHandle_t);
InputMotionData_t SteamAPI_ISteamInput_GetMotionData(intptr_t,InputHandle_t);
void SteamAPI_ISteamInput_TriggerVibration(intptr_t,InputHandle_t,unsigned short,unsigned short);
void SteamAPI_ISteamInput_SetLEDColor(intptr_t,InputHandle_t,uint8,uint8,uint8,unsigned int);
void SteamAPI_ISteamInput_TriggerHapticPulse(intptr_t,InputHandle_t,ESteamControllerPad,unsigned short);
void SteamAPI_ISteamInput_TriggerRepeatedHapticPulse(intptr_t,InputHandle_t,ESteamControllerPad,unsigned short,unsigned short,unsigned short,unsigned int);
bool SteamAPI_ISteamInput_ShowBindingPanel(intptr_t,InputHandle_t);
ESteamInputType SteamAPI_ISteamInput_GetInputTypeForHandle(intptr_t,InputHandle_t);
InputHandle_t SteamAPI_ISteamInput_GetControllerForGamepadIndex(intptr_t,int);
int SteamAPI_ISteamInput_GetGamepadIndexForController(intptr_t,InputHandle_t);
const char* SteamAPI_ISteamInput_GetStringForXboxOrigin(intptr_t,EXboxOrigin);
const char* SteamAPI_ISteamInput_GetGlyphForXboxOrigin(intptr_t,EXboxOrigin);
EInputActionOrigin SteamAPI_ISteamInput_GetActionOriginFromXboxOrigin(intptr_t,InputHandle_t,EXboxOrigin);
EInputActionOrigin SteamAPI_ISteamInput_TranslateActionOrigin(intptr_t,ESteamInputType,EInputActionOrigin);
bool SteamAPI_ISteamInput_GetDeviceBindingRevision(intptr_t,InputHandle_t,int*,int*);
uint32 SteamAPI_ISteamInput_GetRemotePlaySessionID(intptr_t,InputHandle_t);

intptr_t SteamAPI_SteamController_v008();
bool SteamAPI_ISteamController_Init(intptr_t);
bool SteamAPI_ISteamController_Shutdown(intptr_t);
void SteamAPI_ISteamController_RunFrame(intptr_t);
int SteamAPI_ISteamController_GetConnectedControllers(intptr_t,ControllerHandle_t*);
ControllerActionSetHandle_t SteamAPI_ISteamController_GetActionSetHandle(intptr_t,const char*);
void SteamAPI_ISteamController_ActivateActionSet(intptr_t,ControllerHandle_t,ControllerActionSetHandle_t);
ControllerActionSetHandle_t SteamAPI_ISteamController_GetCurrentActionSet(intptr_t,ControllerHandle_t);
void SteamAPI_ISteamController_ActivateActionSetLayer(intptr_t,ControllerHandle_t,ControllerActionSetHandle_t);
void SteamAPI_ISteamController_DeactivateActionSetLayer(intptr_t,ControllerHandle_t,ControllerActionSetHandle_t);
void SteamAPI_ISteamController_DeactivateAllActionSetLayers(intptr_t,ControllerHandle_t);
int SteamAPI_ISteamController_GetActiveActionSetLayers(intptr_t,ControllerHandle_t,ControllerActionSetHandle_t*);
ControllerDigitalActionHandle_t SteamAPI_ISteamController_GetDigitalActionHandle(intptr_t,const char*);
InputDigitalActionData_t SteamAPI_ISteamController_GetDigitalActionData(intptr_t,ControllerHandle_t,ControllerDigitalActionHandle_t);
int SteamAPI_ISteamController_GetDigitalActionOrigins(intptr_t,ControllerHandle_t,ControllerActionSetHandle_t,ControllerDigitalActionHandle_t,EControllerActionOrigin*);
ControllerAnalogActionHandle_t SteamAPI_ISteamController_GetAnalogActionHandle(intptr_t,const char*);
InputAnalogActionData_t SteamAPI_ISteamController_GetAnalogActionData(intptr_t,ControllerHandle_t,ControllerAnalogActionHandle_t);
int SteamAPI_ISteamController_GetAnalogActionOrigins(intptr_t,ControllerHandle_t,ControllerActionSetHandle_t,ControllerAnalogActionHandle_t,EControllerActionOrigin*);
const char* SteamAPI_ISteamController_GetGlyphForActionOrigin(intptr_t,EControllerActionOrigin);
const char* SteamAPI_ISteamController_GetStringForActionOrigin(intptr_t,EControllerActionOrigin);
void SteamAPI_ISteamController_StopAnalogActionMomentum(intptr_t,ControllerHandle_t,ControllerAnalogActionHandle_t);
InputMotionData_t SteamAPI_ISteamController_GetMotionData(intptr_t,ControllerHandle_t);
void SteamAPI_ISteamController_TriggerHapticPulse(intptr_t,ControllerHandle_t,ESteamControllerPad,unsigned short);
void SteamAPI_ISteamController_TriggerRepeatedHapticPulse(intptr_t,ControllerHandle_t,ESteamControllerPad,unsigned short,unsigned short,unsigned short,unsigned int);
void SteamAPI_ISteamController_TriggerVibration(intptr_t,ControllerHandle_t,unsigned short,unsigned short);
void SteamAPI_ISteamController_SetLEDColor(intptr_t,ControllerHandle_t,uint8,uint8,uint8,unsigned int);
bool SteamAPI_ISteamController_ShowBindingPanel(intptr_t,ControllerHandle_t);
ESteamInputType SteamAPI_ISteamController_GetInputTypeForHandle(intptr_t,ControllerHandle_t);
ControllerHandle_t SteamAPI_ISteamController_GetControllerForGamepadIndex(intptr_t,int);
int SteamAPI_ISteamController_GetGamepadIndexForController(intptr_t,ControllerHandle_t);
const char* SteamAPI_ISteamController_GetStringForXboxOrigin(intptr_t,EXboxOrigin);
const char* SteamAPI_ISteamController_GetGlyphForXboxOrigin(intptr_t,EXboxOrigin);
EControllerActionOrigin SteamAPI_ISteamController_GetActionOriginFromXboxOrigin(intptr_t,ControllerHandle_t,EXboxOrigin);
EControllerActionOrigin SteamAPI_ISteamController_TranslateActionOrigin(intptr_t,ESteamInputType,EControllerActionOrigin);
bool SteamAPI_ISteamController_GetControllerBindingRevision(intptr_t,ControllerHandle_t,int*,int*);

intptr_t SteamAPI_SteamUGC_v015();
intptr_t SteamAPI_SteamGameServerUGC_v015();
UGCQueryHandle_t SteamAPI_ISteamUGC_CreateQueryUserUGCRequest(intptr_t,AccountID_t,EUserUGCList,EUGCMatchingUGCType,EUserUGCListSortOrder,AppId_t,AppId_t,uint32);
UGCQueryHandle_t SteamAPI_ISteamUGC_CreateQueryAllUGCRequestPage(intptr_t,EUGCQuery,EUGCMatchingUGCType,AppId_t,AppId_t,uint32);
UGCQueryHandle_t SteamAPI_ISteamUGC_CreateQueryAllUGCRequestCursor(intptr_t,EUGCQuery,EUGCMatchingUGCType,AppId_t,AppId_t,const char*);
UGCQueryHandle_t SteamAPI_ISteamUGC_CreateQueryUGCDetailsRequest(intptr_t,PublishedFileId_t*,uint32);
SteamAPICall_t SteamAPI_ISteamUGC_SendQueryUGCRequest(intptr_t,UGCQueryHandle_t);
bool SteamAPI_ISteamUGC_GetQueryUGCResult(intptr_t,UGCQueryHandle_t,uint32,struct SteamUGCDetails_t*);
uint32 SteamAPI_ISteamUGC_GetQueryUGCNumTags(intptr_t,UGCQueryHandle_t,uint32);
bool SteamAPI_ISteamUGC_GetQueryUGCTag(intptr_t,UGCQueryHandle_t,uint32,uint32,char*,uint32 );
bool SteamAPI_ISteamUGC_GetQueryUGCTagDisplayName(intptr_t,UGCQueryHandle_t,uint32,uint32,char*,uint32 );
bool SteamAPI_ISteamUGC_GetQueryUGCPreviewURL(intptr_t,UGCQueryHandle_t,uint32,char*,uint32);
bool SteamAPI_ISteamUGC_GetQueryUGCMetadata(intptr_t,UGCQueryHandle_t,uint32,char*,uint32);
bool SteamAPI_ISteamUGC_GetQueryUGCChildren(intptr_t,UGCQueryHandle_t,uint32,PublishedFileId_t*,uint32);
bool SteamAPI_ISteamUGC_GetQueryUGCStatistic(intptr_t,UGCQueryHandle_t,uint32,EItemStatistic,uint64*);
uint32 SteamAPI_ISteamUGC_GetQueryUGCNumAdditionalPreviews(intptr_t,UGCQueryHandle_t,uint32);
bool SteamAPI_ISteamUGC_GetQueryUGCAdditionalPreview(intptr_t,UGCQueryHandle_t,uint32,uint32,char*,uint32,char*,uint32,EItemPreviewType*);
uint32 SteamAPI_ISteamUGC_GetQueryUGCNumKeyValueTags(intptr_t,UGCQueryHandle_t,uint32);
bool SteamAPI_ISteamUGC_GetQueryUGCKeyValueTag(intptr_t,UGCQueryHandle_t,uint32,uint32,char*,uint32,char*,uint32 );
bool SteamAPI_ISteamUGC_GetQueryFirstUGCKeyValueTag(intptr_t,UGCQueryHandle_t,uint32,const char*,char*,uint32 );
bool SteamAPI_ISteamUGC_ReleaseQueryUGCRequest(intptr_t,UGCQueryHandle_t);
bool SteamAPI_ISteamUGC_AddRequiredTag(intptr_t,UGCQueryHandle_t,const char*);
bool SteamAPI_ISteamUGC_AddRequiredTagGroup(intptr_t,UGCQueryHandle_t,const struct SteamParamStringArray_t*);
bool SteamAPI_ISteamUGC_AddExcludedTag(intptr_t,UGCQueryHandle_t,const char*);
bool SteamAPI_ISteamUGC_SetReturnOnlyIDs(intptr_t,UGCQueryHandle_t,bool);
bool SteamAPI_ISteamUGC_SetReturnKeyValueTags(intptr_t,UGCQueryHandle_t,bool);
bool SteamAPI_ISteamUGC_SetReturnLongDescription(intptr_t,UGCQueryHandle_t,bool);
bool SteamAPI_ISteamUGC_SetReturnMetadata(intptr_t,UGCQueryHandle_t,bool);
bool SteamAPI_ISteamUGC_SetReturnChildren(intptr_t,UGCQueryHandle_t,bool);
bool SteamAPI_ISteamUGC_SetReturnAdditionalPreviews(intptr_t,UGCQueryHandle_t,bool);
bool SteamAPI_ISteamUGC_SetReturnTotalOnly(intptr_t,UGCQueryHandle_t,bool);
bool SteamAPI_ISteamUGC_SetReturnPlaytimeStats(intptr_t,UGCQueryHandle_t,uint32);
bool SteamAPI_ISteamUGC_SetLanguage(intptr_t,UGCQueryHandle_t,const char*);
bool SteamAPI_ISteamUGC_SetAllowCachedResponse(intptr_t,UGCQueryHandle_t,uint32);
bool SteamAPI_ISteamUGC_SetCloudFileNameFilter(intptr_t,UGCQueryHandle_t,const char*);
bool SteamAPI_ISteamUGC_SetMatchAnyTag(intptr_t,UGCQueryHandle_t,bool);
bool SteamAPI_ISteamUGC_SetSearchText(intptr_t,UGCQueryHandle_t,const char*);
bool SteamAPI_ISteamUGC_SetRankedByTrendDays(intptr_t,UGCQueryHandle_t,uint32);
bool SteamAPI_ISteamUGC_AddRequiredKeyValueTag(intptr_t,UGCQueryHandle_t,const char*,const char*);
SteamAPICall_t SteamAPI_ISteamUGC_RequestUGCDetails(intptr_t,PublishedFileId_t,uint32);
SteamAPICall_t SteamAPI_ISteamUGC_CreateItem(intptr_t,AppId_t,EWorkshopFileType eFileType);
UGCUpdateHandle_t SteamAPI_ISteamUGC_StartItemUpdate(intptr_t,AppId_t,PublishedFileId_t);
bool SteamAPI_ISteamUGC_SetItemTitle(intptr_t,UGCUpdateHandle_t,const char*);
bool SteamAPI_ISteamUGC_SetItemDescription(intptr_t,UGCUpdateHandle_t,const char*);
bool SteamAPI_ISteamUGC_SetItemUpdateLanguage(intptr_t,UGCUpdateHandle_t,const char*);
bool SteamAPI_ISteamUGC_SetItemMetadata(intptr_t,UGCUpdateHandle_t,const char*);
bool SteamAPI_ISteamUGC_SetItemVisibility(intptr_t,UGCUpdateHandle_t,ERemoteStoragePublishedFileVisibility);
bool SteamAPI_ISteamUGC_SetItemTags(intptr_t,UGCUpdateHandle_t updateHandle,const struct SteamParamStringArray_t*);
bool SteamAPI_ISteamUGC_SetItemContent(intptr_t,UGCUpdateHandle_t,const char*);
bool SteamAPI_ISteamUGC_SetItemPreview(intptr_t,UGCUpdateHandle_t,const char*);
bool SteamAPI_ISteamUGC_SetAllowLegacyUpload(intptr_t,UGCUpdateHandle_t,bool);
bool SteamAPI_ISteamUGC_RemoveAllItemKeyValueTags(intptr_t,UGCUpdateHandle_t);
bool SteamAPI_ISteamUGC_RemoveItemKeyValueTags(intptr_t,UGCUpdateHandle_t,const char*);
bool SteamAPI_ISteamUGC_AddItemKeyValueTag(intptr_t,UGCUpdateHandle_t,const char*,const char*);
bool SteamAPI_ISteamUGC_AddItemPreviewFile(intptr_t,UGCUpdateHandle_t,const char*,EItemPreviewType);
bool SteamAPI_ISteamUGC_AddItemPreviewVideo(intptr_t,UGCUpdateHandle_t,const char*);
bool SteamAPI_ISteamUGC_UpdateItemPreviewFile(intptr_t,UGCUpdateHandle_t,uint32,const char*);
bool SteamAPI_ISteamUGC_UpdateItemPreviewVideo(intptr_t,UGCUpdateHandle_t,uint32,const char*);
bool SteamAPI_ISteamUGC_RemoveItemPreview(intptr_t,UGCUpdateHandle_t,uint32);
SteamAPICall_t SteamAPI_ISteamUGC_SubmitItemUpdate(intptr_t,UGCUpdateHandle_t,const char*);
EItemUpdateStatus SteamAPI_ISteamUGC_GetItemUpdateProgress(intptr_t,UGCUpdateHandle_t,uint64*,uint64*);
SteamAPICall_t SteamAPI_ISteamUGC_SetUserItemVote(intptr_t,PublishedFileId_t,bool);
SteamAPICall_t SteamAPI_ISteamUGC_GetUserItemVote(intptr_t,PublishedFileId_t);
SteamAPICall_t SteamAPI_ISteamUGC_AddItemToFavorites(intptr_t,AppId_t ,PublishedFileId_t);
SteamAPICall_t SteamAPI_ISteamUGC_RemoveItemFromFavorites(intptr_t,AppId_t ,PublishedFileId_t);
SteamAPICall_t SteamAPI_ISteamUGC_SubscribeItem(intptr_t,PublishedFileId_t);
SteamAPICall_t SteamAPI_ISteamUGC_UnsubscribeItem(intptr_t,PublishedFileId_t);
uint32 SteamAPI_ISteamUGC_GetNumSubscribedItems(intptr_t);
uint32 SteamAPI_ISteamUGC_GetSubscribedItems(intptr_t,PublishedFileId_t*,uint32 cMaxEntries);
uint32 SteamAPI_ISteamUGC_GetItemState(intptr_t,PublishedFileId_t);
bool SteamAPI_ISteamUGC_GetItemInstallInfo(intptr_t,PublishedFileId_t,uint64*,char*,uint32,uint32*);
bool SteamAPI_ISteamUGC_GetItemDownloadInfo(intptr_t,PublishedFileId_t,uint64*,uint64*);
bool SteamAPI_ISteamUGC_DownloadItem(intptr_t,PublishedFileId_t,bool bHighPriority);
bool SteamAPI_ISteamUGC_BInitWorkshopForGameServer(intptr_t,DepotId_t unWorkshopDepotID,const char*);
void SteamAPI_ISteamUGC_SuspendDownloads(intptr_t,bool bSuspend);
SteamAPICall_t SteamAPI_ISteamUGC_StartPlaytimeTracking(intptr_t,PublishedFileId_t*,uint32);
SteamAPICall_t SteamAPI_ISteamUGC_StopPlaytimeTracking(intptr_t,PublishedFileId_t*,uint32);
SteamAPICall_t SteamAPI_ISteamUGC_StopPlaytimeTrackingForAllItems(intptr_t);
SteamAPICall_t SteamAPI_ISteamUGC_AddDependency(intptr_t,PublishedFileId_t,PublishedFileId_t);
SteamAPICall_t SteamAPI_ISteamUGC_RemoveDependency(intptr_t,PublishedFileId_t,PublishedFileId_t);
SteamAPICall_t SteamAPI_ISteamUGC_AddAppDependency(intptr_t,PublishedFileId_t,AppId_t );
SteamAPICall_t SteamAPI_ISteamUGC_RemoveAppDependency(intptr_t,PublishedFileId_t,AppId_t );
SteamAPICall_t SteamAPI_ISteamUGC_GetAppDependencies(intptr_t,PublishedFileId_t);
SteamAPICall_t SteamAPI_ISteamUGC_DeleteItem(intptr_t,PublishedFileId_t);

intptr_t SteamAPI_SteamAppList_v001();
uint32 SteamAPI_ISteamAppList_GetNumInstalledApps(intptr_t);
uint32 SteamAPI_ISteamAppList_GetInstalledApps(intptr_t,AppId_t*,uint32);
int SteamAPI_ISteamAppList_GetAppName(intptr_t,AppId_t,char*,int);
int SteamAPI_ISteamAppList_GetAppInstallDir(intptr_t,AppId_t,char*,int);
int SteamAPI_ISteamAppList_GetAppBuildId(intptr_t,AppId_t);

intptr_t SteamAPI_SteamHTMLSurface_v005();
bool SteamAPI_ISteamHTMLSurface_Init(intptr_t);
bool SteamAPI_ISteamHTMLSurface_Shutdown(intptr_t);
SteamAPICall_t SteamAPI_ISteamHTMLSurface_CreateBrowser(intptr_t,const char*,const char*);
void SteamAPI_ISteamHTMLSurface_RemoveBrowser(intptr_t,HHTMLBrowser);
void SteamAPI_ISteamHTMLSurface_LoadURL(intptr_t,HHTMLBrowser,const char*,const char*);
void SteamAPI_ISteamHTMLSurface_SetSize(intptr_t,HHTMLBrowser,uint32,uint32);
void SteamAPI_ISteamHTMLSurface_StopLoad(intptr_t,HHTMLBrowser);
void SteamAPI_ISteamHTMLSurface_Reload(intptr_t,HHTMLBrowser);
void SteamAPI_ISteamHTMLSurface_GoBack(intptr_t,HHTMLBrowser);
void SteamAPI_ISteamHTMLSurface_GoForward(intptr_t,HHTMLBrowser);
void SteamAPI_ISteamHTMLSurface_AddHeader(intptr_t,HHTMLBrowser,const char*,const char*);
void SteamAPI_ISteamHTMLSurface_ExecuteJavascript(intptr_t,HHTMLBrowser,const char*);
//void SteamAPI_ISteamHTMLSurface_MouseUp(intptr_t,HHTMLBrowser,ISteamHTMLSurface::EHTMLMouseButton eMouseButton);
//void SteamAPI_ISteamHTMLSurface_MouseDown(intptr_t,HHTMLBrowser,ISteamHTMLSurface::EHTMLMouseButton eMouseButton);
//void SteamAPI_ISteamHTMLSurface_MouseDoubleClick(intptr_t,HHTMLBrowser,ISteamHTMLSurface::EHTMLMouseButton eMouseButton);
void SteamAPI_ISteamHTMLSurface_MouseMove(intptr_t,HHTMLBrowser,int,int);
void SteamAPI_ISteamHTMLSurface_MouseWheel(intptr_t,HHTMLBrowser,int32);
//void SteamAPI_ISteamHTMLSurface_KeyDown(intptr_t,HHTMLBrowser,uint32,ISteamHTMLSurface::EHTMLKeyModifiers eHTMLKeyModifiers,bool);
//void SteamAPI_ISteamHTMLSurface_KeyUp(intptr_t,HHTMLBrowser,uint32,ISteamHTMLSurface::EHTMLKeyModifiers eHTMLKeyModifiers);
//void SteamAPI_ISteamHTMLSurface_KeyChar(intptr_t,HHTMLBrowser,uint32,ISteamHTMLSurface::EHTMLKeyModifiers eHTMLKeyModifiers);
void SteamAPI_ISteamHTMLSurface_SetHorizontalScroll(intptr_t,HHTMLBrowser,uint32);
void SteamAPI_ISteamHTMLSurface_SetVerticalScroll(intptr_t,HHTMLBrowser,uint32);
void SteamAPI_ISteamHTMLSurface_SetKeyFocus(intptr_t,HHTMLBrowser,bool);
void SteamAPI_ISteamHTMLSurface_ViewSource(intptr_t,HHTMLBrowser);
void SteamAPI_ISteamHTMLSurface_CopyToClipboard(intptr_t,HHTMLBrowser);
void SteamAPI_ISteamHTMLSurface_PasteFromClipboard(intptr_t,HHTMLBrowser);
void SteamAPI_ISteamHTMLSurface_Find(intptr_t,HHTMLBrowser,const char*,bool,bool);
void SteamAPI_ISteamHTMLSurface_StopFind(intptr_t,HHTMLBrowser);
void SteamAPI_ISteamHTMLSurface_GetLinkAtPosition(intptr_t,HHTMLBrowser,int,int);
void SteamAPI_ISteamHTMLSurface_SetCookie(intptr_t,const char*,const char*,const char*,const char*,RTime32,bool,bool);
void SteamAPI_ISteamHTMLSurface_SetPageScaleFactor(intptr_t,HHTMLBrowser,float,int,int);
void SteamAPI_ISteamHTMLSurface_SetBackgroundMode(intptr_t,HHTMLBrowser,bool);
void SteamAPI_ISteamHTMLSurface_SetDPIScalingFactor(intptr_t,HHTMLBrowser,float);
void SteamAPI_ISteamHTMLSurface_OpenDeveloperTools(intptr_t,HHTMLBrowser);
void SteamAPI_ISteamHTMLSurface_AllowStartRequest(intptr_t,HHTMLBrowser,bool);
void SteamAPI_ISteamHTMLSurface_JSDialogResponse(intptr_t,HHTMLBrowser,bool);
void SteamAPI_ISteamHTMLSurface_FileLoadDialogResponse(intptr_t,HHTMLBrowser,const char**);

intptr_t SteamAPI_SteamInventory_v003();
intptr_t SteamAPI_SteamGameServerInventory_v003();
EResult SteamAPI_ISteamInventory_GetResultStatus(intptr_t,SteamInventoryResult_t);
bool SteamAPI_ISteamInventory_GetResultItems(intptr_t,SteamInventoryResult_t,struct SteamItemDetails_t*,uint32*);
bool SteamAPI_ISteamInventory_GetResultItemProperty(intptr_t,SteamInventoryResult_t,uint32,const char*,char*,uint32*);
uint32 SteamAPI_ISteamInventory_GetResultTimestamp(intptr_t,SteamInventoryResult_t);
bool SteamAPI_ISteamInventory_CheckResultSteamID(intptr_t,SteamInventoryResult_t,uint64_steamid);
void SteamAPI_ISteamInventory_DestroyResult(intptr_t,SteamInventoryResult_t);
bool SteamAPI_ISteamInventory_GetAllItems(intptr_t,SteamInventoryResult_t*);
bool SteamAPI_ISteamInventory_GetItemsByID(intptr_t,SteamInventoryResult_t*,const char*,uint32);
bool SteamAPI_ISteamInventory_SerializeResult(intptr_t,SteamInventoryResult_t,void*,uint32*);
bool SteamAPI_ISteamInventory_DeserializeResult(intptr_t,SteamInventoryResult_t*,const char*,uint32,bool);
bool SteamAPI_ISteamInventory_GenerateItems(intptr_t,SteamInventoryResult_t*,const char*,const char*,uint32);
bool SteamAPI_ISteamInventory_GrantPromoItems(intptr_t,SteamInventoryResult_t*);
bool SteamAPI_ISteamInventory_AddPromoItem(intptr_t,SteamInventoryResult_t*,SteamItemDef_t);
bool SteamAPI_ISteamInventory_AddPromoItems(intptr_t,SteamInventoryResult_t*,const char*,uint32);
bool SteamAPI_ISteamInventory_ConsumeItem(intptr_t,SteamInventoryResult_t*,SteamItemInstanceID_t,uint32);
bool SteamAPI_ISteamInventory_ExchangeItems(intptr_t,SteamInventoryResult_t*,const char*,const char*,uint32,const char*,const char*,uint32);
bool SteamAPI_ISteamInventory_TransferItemQuantity(intptr_t,SteamInventoryResult_t*,SteamItemInstanceID_t,uint32,SteamItemInstanceID_t);
void SteamAPI_ISteamInventory_SendItemDropHeartbeat(intptr_t);
bool SteamAPI_ISteamInventory_TriggerItemDrop(intptr_t,SteamInventoryResult_t*,SteamItemDef_t);
bool SteamAPI_ISteamInventory_TradeItems(intptr_t,SteamInventoryResult_t*,uint64_steamid,const char*,const char*,uint32,const char*,const char*,uint32);
bool SteamAPI_ISteamInventory_LoadItemDefinitions(intptr_t);
bool SteamAPI_ISteamInventory_GetItemDefinitionIDs(intptr_t,SteamItemDef_t*,uint32*);
bool SteamAPI_ISteamInventory_GetItemDefinitionProperty(intptr_t,SteamItemDef_t,const char*,char*,uint32*);
SteamAPICall_t SteamAPI_ISteamInventory_RequestEligiblePromoItemDefinitionsIDs(intptr_t,uint64_steamid);
bool SteamAPI_ISteamInventory_GetEligiblePromoItemDefinitionIDs(intptr_t,uint64_steamid,SteamItemDef_t*,uint32*);
SteamAPICall_t SteamAPI_ISteamInventory_StartPurchase(intptr_t,const char*,const char*,uint32);
SteamAPICall_t SteamAPI_ISteamInventory_RequestPrices(intptr_t);
uint32 SteamAPI_ISteamInventory_GetNumItemsWithPrices(intptr_t);
bool SteamAPI_ISteamInventory_GetItemsWithPrices(intptr_t,SteamItemDef_t*,uint64*,uint64*,uint32);
bool SteamAPI_ISteamInventory_GetItemPrice(intptr_t,SteamItemDef_t,uint64*,uint64*);
SteamInventoryUpdateHandle_t SteamAPI_ISteamInventory_StartUpdateProperties(intptr_t);
bool SteamAPI_ISteamInventory_RemoveProperty(intptr_t,SteamInventoryUpdateHandle_t,SteamItemInstanceID_t,const char*);
bool SteamAPI_ISteamInventory_SetPropertyString(intptr_t,SteamInventoryUpdateHandle_t,SteamItemInstanceID_t,const char*,const char*);
bool SteamAPI_ISteamInventory_SetPropertyBool(intptr_t,SteamInventoryUpdateHandle_t,SteamItemInstanceID_t,const char*,bool);
bool SteamAPI_ISteamInventory_SetPropertyInt64(intptr_t,SteamInventoryUpdateHandle_t,SteamItemInstanceID_t,const char*,int64);
bool SteamAPI_ISteamInventory_SetPropertyFloat(intptr_t,SteamInventoryUpdateHandle_t,SteamItemInstanceID_t,const char*,float);
bool SteamAPI_ISteamInventory_SubmitUpdateProperties(intptr_t,SteamInventoryUpdateHandle_t,SteamInventoryResult_t*);

intptr_t SteamAPI_SteamVideo_v002();
void SteamAPI_ISteamVideo_GetVideoURL(intptr_t,AppId_t);
bool SteamAPI_ISteamVideo_IsBroadcasting(intptr_t,int*);
void SteamAPI_ISteamVideo_GetOPFSettings(intptr_t,AppId_t);
bool SteamAPI_ISteamVideo_GetOPFStringForApp(intptr_t,AppId_t,char*,int32*);

intptr_t SteamAPI_SteamTV_v001();
bool SteamAPI_ISteamTV_IsBroadcasting(intptr_t,int*);
void SteamAPI_ISteamTV_AddBroadcastGameData(intptr_t,const char*,const char*);
void SteamAPI_ISteamTV_RemoveBroadcastGameData(intptr_t,const char*);
void SteamAPI_ISteamTV_AddTimelineMarker(intptr_t,const char*,bool,uint8,uint8,uint8);
void SteamAPI_ISteamTV_RemoveTimelineMarker(intptr_t);
uint32 SteamAPI_ISteamTV_AddRegion(intptr_t,const char*,const char*,const char*,ESteamTVRegionBehavior);
void SteamAPI_ISteamTV_RemoveRegion(intptr_t,uint32);

intptr_t SteamAPI_SteamParentalSettings_v001();
bool SteamAPI_ISteamParentalSettings_BIsParentalLockEnabled(intptr_t);
bool SteamAPI_ISteamParentalSettings_BIsParentalLockLocked(intptr_t);
bool SteamAPI_ISteamParentalSettings_BIsAppBlocked(intptr_t,AppId_t);
bool SteamAPI_ISteamParentalSettings_BIsAppInBlockList(intptr_t,AppId_t);
bool SteamAPI_ISteamParentalSettings_BIsFeatureBlocked(intptr_t,EParentalFeature);
bool SteamAPI_ISteamParentalSettings_BIsFeatureInBlockList(intptr_t,EParentalFeature);

intptr_t SteamAPI_SteamRemotePlay_v001();
uint32 SteamAPI_ISteamRemotePlay_GetSessionCount(intptr_t);
struct RemotePlaySessionID_t SteamAPI_ISteamRemotePlay_GetSessionID(intptr_t,int);
uint64_steamid SteamAPI_ISteamRemotePlay_GetSessionSteamID(intptr_t,struct RemotePlaySessionID_t);
const char*SteamAPI_ISteamRemotePlay_GetSessionClientName(intptr_t,struct RemotePlaySessionID_t);
ESteamDeviceFormFactor SteamAPI_ISteamRemotePlay_GetSessionClientFormFactor(intptr_t,struct RemotePlaySessionID_t);
bool SteamAPI_ISteamRemotePlay_BGetSessionClientResolution(intptr_t,struct RemotePlaySessionID_t,int*,int*);
bool SteamAPI_ISteamRemotePlay_BSendRemotePlayTogetherInvite(intptr_t,uint64_steamid);

intptr_t SteamAPI_SteamNetworkingSockets_v009();
intptr_t SteamAPI_SteamGameServerNetworkingSockets_v009();
HSteamListenSocket SteamAPI_ISteamNetworkingSockets_CreateListenSocketIP(intptr_t,const struct SteamNetworkingIPAddr&,int,const struct SteamNetworkingConfigValue_t*);
HSteamNetConnection SteamAPI_ISteamNetworkingSockets_ConnectByIPAddress(intptr_t,const struct SteamNetworkingIPAddr&,int,const struct SteamNetworkingConfigValue_t*);
HSteamListenSocket SteamAPI_ISteamNetworkingSockets_CreateListenSocketP2P(intptr_t,int,int,const struct SteamNetworkingConfigValue_t*);
HSteamNetConnection SteamAPI_ISteamNetworkingSockets_ConnectP2P(intptr_t,const struct SteamNetworkingIdentity&,int,int,const struct SteamNetworkingConfigValue_t*);
EResult SteamAPI_ISteamNetworkingSockets_AcceptConnection(intptr_t,HSteamNetConnection);
bool SteamAPI_ISteamNetworkingSockets_CloseConnection(intptr_t,HSteamNetConnection,int,const char*,bool);
bool SteamAPI_ISteamNetworkingSockets_CloseListenSocket(intptr_t,HSteamListenSocket hSocket);
bool SteamAPI_ISteamNetworkingSockets_SetConnectionUserData(intptr_t,HSteamNetConnection,int64);
int64 SteamAPI_ISteamNetworkingSockets_GetConnectionUserData(intptr_t,HSteamNetConnection);
void SteamAPI_ISteamNetworkingSockets_SetConnectionName(intptr_t,HSteamNetConnection,const char*);
bool SteamAPI_ISteamNetworkingSockets_GetConnectionName(intptr_t,HSteamNetConnection,char*,int);
EResult SteamAPI_ISteamNetworkingSockets_SendMessageToConnection(intptr_t,HSteamNetConnection,const void*,uint32 cbData,int,int64*);
void SteamAPI_ISteamNetworkingSockets_SendMessages(intptr_t,int,struct SteamNetworkingMessage_t*const*,int64*);
EResult SteamAPI_ISteamNetworkingSockets_FlushMessagesOnConnection(intptr_t,HSteamNetConnection);
int SteamAPI_ISteamNetworkingSockets_ReceiveMessagesOnConnection(intptr_t,HSteamNetConnection,struct SteamNetworkingMessage_t**,int);
bool SteamAPI_ISteamNetworkingSockets_GetConnectionInfo(intptr_t,HSteamNetConnection,struct SteamNetConnectionInfo_t*);
bool SteamAPI_ISteamNetworkingSockets_GetQuickConnectionStatus(intptr_t,HSteamNetConnection,struct SteamNetworkingQuickConnectionStatus*);
int SteamAPI_ISteamNetworkingSockets_GetDetailedConnectionStatus(intptr_t,HSteamNetConnection,char*,int);
bool SteamAPI_ISteamNetworkingSockets_GetListenSocketAddress(intptr_t,HSteamListenSocket hSocket,struct SteamNetworkingIPAddr*);
bool SteamAPI_ISteamNetworkingSockets_CreateSocketPair(intptr_t,HSteamNetConnection*,HSteamNetConnection*,bool,const struct SteamNetworkingIdentity*,const struct SteamNetworkingIdentity*);
bool SteamAPI_ISteamNetworkingSockets_GetIdentity(intptr_t,struct SteamNetworkingIdentity*);
ESteamNetworkingAvailability SteamAPI_ISteamNetworkingSockets_InitAuthentication(intptr_t);
ESteamNetworkingAvailability SteamAPI_ISteamNetworkingSockets_GetAuthenticationStatus(intptr_t,struct SteamNetAuthenticationStatus_t*);
HSteamNetPollGroup SteamAPI_ISteamNetworkingSockets_CreatePollGroup(intptr_t);
bool SteamAPI_ISteamNetworkingSockets_DestroyPollGroup(intptr_t,HSteamNetPollGroup);
bool SteamAPI_ISteamNetworkingSockets_SetConnectionPollGroup(intptr_t,HSteamNetConnection,HSteamNetPollGroup);
int SteamAPI_ISteamNetworkingSockets_ReceiveMessagesOnPollGroup(intptr_t,HSteamNetPollGroup,struct SteamNetworkingMessage_t**,int);
bool SteamAPI_ISteamNetworkingSockets_ReceivedRelayAuthTicket(intptr_t,const void*,int,struct SteamDatagramRelayAuthTicket*);
int SteamAPI_ISteamNetworkingSockets_FindRelayAuthTicketForServer(intptr_t,const struct SteamNetworkingIdentity&,int,struct SteamDatagramRelayAuthTicket*);
HSteamNetConnection SteamAPI_ISteamNetworkingSockets_ConnectToHostedDedicatedServer(intptr_t,const struct SteamNetworkingIdentity&,int,int,const struct SteamNetworkingConfigValue_t*);
uint16 SteamAPI_ISteamNetworkingSockets_GetHostedDedicatedServerPort(intptr_t);
SteamNetworkingPOPID SteamAPI_ISteamNetworkingSockets_GetHostedDedicatedServerPOPID(intptr_t);
EResult SteamAPI_ISteamNetworkingSockets_GetHostedDedicatedServerAddress(intptr_t,struct SteamDatagramHostedAddress*);
HSteamListenSocket SteamAPI_ISteamNetworkingSockets_CreateHostedDedicatedServerListenSocket(intptr_t,int,int,const struct SteamNetworkingConfigValue_t*);
EResult SteamAPI_ISteamNetworkingSockets_GetGameCoordinatorServerLogin(intptr_t,struct SteamDatagramGameCoordinatorServerLogin*,int*,void*);
HSteamNetConnection SteamAPI_ISteamNetworkingSockets_ConnectP2PCustomSignaling(intptr_t,struct ISteamNetworkingConnectionCustomSignaling*,const struct SteamNetworkingIdentity*,int,int,const struct SteamNetworkingConfigValue_t*);
bool SteamAPI_ISteamNetworkingSockets_ReceivedP2PCustomSignal(intptr_t,const void*,int,struct ISteamNetworkingCustomSignalingRecvContext*);
//bool SteamAPI_ISteamNetworkingSockets_GetCertificateRequest(intptr_t,int*,void*,SteamNetworkingErrMsg&);
//bool SteamAPI_ISteamNetworkingSockets_SetCertificate(intptr_t,const void*,int,SteamNetworkingErrMsg&);
void SteamAPI_ISteamNetworkingSockets_RunCallbacks(intptr_t);

bool SteamAPI_ISteamNetworkingConnectionCustomSignaling_SendSignal(intptr_t,HSteamNetConnection,const char&,const char*,int);
void SteamAPI_ISteamNetworkingConnectionCustomSignaling_Release(intptr_t);

intptr_t SteamAPI_ISteamNetworkingCustomSignalingRecvContext_OnConnectRequest(intptr_t,HSteamNetConnection,const char&);
void SteamAPI_ISteamNetworkingCustomSignalingRecvContext_SendRejectionSignal(intptr_t,const char&,const char*,int);

intptr_t SteamAPI_SteamNetworkingUtils_v003();
struct SteamNetworkingMessage_t*SteamAPI_ISteamNetworkingUtils_AllocateMessage(intptr_t,int);
void SteamAPI_ISteamNetworkingUtils_InitRelayNetworkAccess(intptr_t);
ESteamNetworkingAvailability SteamAPI_ISteamNetworkingUtils_GetRelayNetworkStatus(intptr_t,struct SteamRelayNetworkStatus_t*);
float SteamAPI_ISteamNetworkingUtils_GetLocalPingLocation(intptr_t,struct SteamNetworkPingLocation_t&);
int SteamAPI_ISteamNetworkingUtils_EstimatePingTimeBetweenTwoLocations(intptr_t,const char&,const char&);
int SteamAPI_ISteamNetworkingUtils_EstimatePingTimeFromLocalHost(intptr_t,const char&);
void SteamAPI_ISteamNetworkingUtils_ConvertPingLocationToString(intptr_t,const char&,char*,int);
bool SteamAPI_ISteamNetworkingUtils_ParsePingLocationString(intptr_t,const char*,struct SteamNetworkPingLocation_t&);
bool SteamAPI_ISteamNetworkingUtils_CheckPingDataUpToDate(intptr_t,float);
int SteamAPI_ISteamNetworkingUtils_GetPingToDataCenter(intptr_t,SteamNetworkingPOPID,SteamNetworkingPOPID*);
int SteamAPI_ISteamNetworkingUtils_GetDirectPingToPOP(intptr_t,SteamNetworkingPOPID);
int SteamAPI_ISteamNetworkingUtils_GetPOPCount(intptr_t);
int SteamAPI_ISteamNetworkingUtils_GetPOPList(intptr_t,SteamNetworkingPOPID*,int);
SteamNetworkingMicroseconds SteamAPI_ISteamNetworkingUtils_GetLocalTimestamp(intptr_t);
//void SteamAPI_ISteamNetworkingUtils_SetDebugOutputFunction(intptr_t,ESteamNetworkingSocketsDebugOutputType,FSteamNetworkingSocketsDebugOutput);
bool SteamAPI_ISteamNetworkingUtils_SetGlobalConfigValueInt32(intptr_t,ESteamNetworkingConfigValue,int32);
bool SteamAPI_ISteamNetworkingUtils_SetGlobalConfigValueFloat(intptr_t,ESteamNetworkingConfigValue,float);
bool SteamAPI_ISteamNetworkingUtils_SetGlobalConfigValueString(intptr_t,ESteamNetworkingConfigValue,const char*);
bool SteamAPI_ISteamNetworkingUtils_SetConnectionConfigValueInt32(intptr_t,HSteamNetConnection,ESteamNetworkingConfigValue,int32);
bool SteamAPI_ISteamNetworkingUtils_SetConnectionConfigValueFloat(intptr_t,HSteamNetConnection,ESteamNetworkingConfigValue,float);
bool SteamAPI_ISteamNetworkingUtils_SetConnectionConfigValueString(intptr_t,HSteamNetConnection,ESteamNetworkingConfigValue,const char*);
bool SteamAPI_ISteamNetworkingUtils_SetConfigValue(intptr_t,ESteamNetworkingConfigValue,ESteamNetworkingConfigScope,intptr_t,ESteamNetworkingConfigDataType,const char*);
bool SteamAPI_ISteamNetworkingUtils_SetConfigValueStruct(intptr_t,const char&,ESteamNetworkingConfigScope,intptr_t);
ESteamNetworkingGetConfigValueResult SteamAPI_ISteamNetworkingUtils_GetConfigValue(intptr_t,ESteamNetworkingConfigValue,ESteamNetworkingConfigScope,intptr_t,ESteamNetworkingConfigDataType*,void*,size_t*);
bool SteamAPI_ISteamNetworkingUtils_GetConfigValueInfo(intptr_t,ESteamNetworkingConfigValue,const char**,ESteamNetworkingConfigDataType*,ESteamNetworkingConfigScope*,ESteamNetworkingConfigValue*);
ESteamNetworkingConfigValue SteamAPI_ISteamNetworkingUtils_GetFirstConfigValue(intptr_t);
void SteamAPI_ISteamNetworkingUtils_SteamNetworkingIPAddr_ToString(intptr_t,const char&,char*,uint32,bool);
bool SteamAPI_ISteamNetworkingUtils_SteamNetworkingIPAddr_ParseString(intptr_t,intptr_t,const char*);
void SteamAPI_ISteamNetworkingUtils_SteamNetworkingIdentity_ToString(intptr_t,const char&,char*,uint32);
bool SteamAPI_ISteamNetworkingUtils_SteamNetworkingIdentity_ParseString(intptr_t,intptr_t,const char*);

intptr_t SteamAPI_SteamGameServer_v013();
void SteamAPI_ISteamGameServer_SetProduct(intptr_t,const char*);
void SteamAPI_ISteamGameServer_SetGameDescription(intptr_t,const char*);
void SteamAPI_ISteamGameServer_SetModDir(intptr_t,const char*);
void SteamAPI_ISteamGameServer_SetDedicatedServer(intptr_t,bool);
void SteamAPI_ISteamGameServer_LogOn(intptr_t,const char*);
void SteamAPI_ISteamGameServer_LogOnAnonymous(intptr_t);
void SteamAPI_ISteamGameServer_LogOff(intptr_t);
bool SteamAPI_ISteamGameServer_BLoggedOn(intptr_t);
bool SteamAPI_ISteamGameServer_BSecure(intptr_t);
uint64_steamid SteamAPI_ISteamGameServer_GetSteamID(intptr_t);
bool SteamAPI_ISteamGameServer_WasRestartRequested(intptr_t);
void SteamAPI_ISteamGameServer_SetMaxPlayerCount(intptr_t,int);
void SteamAPI_ISteamGameServer_SetBotPlayerCount(intptr_t,int);
void SteamAPI_ISteamGameServer_SetServerName(intptr_t,const char*);
void SteamAPI_ISteamGameServer_SetMapName(intptr_t,const char*);
void SteamAPI_ISteamGameServer_SetPasswordProtected(intptr_t,bool);
void SteamAPI_ISteamGameServer_SetSpectatorPort(intptr_t,uint16);
void SteamAPI_ISteamGameServer_SetSpectatorServerName(intptr_t,const char*);
void SteamAPI_ISteamGameServer_ClearAllKeyValues(intptr_t);
void SteamAPI_ISteamGameServer_SetKeyValue(intptr_t,const char*,const char*);
void SteamAPI_ISteamGameServer_SetGameTags(intptr_t,const char*);
void SteamAPI_ISteamGameServer_SetGameData(intptr_t,const char*);
void SteamAPI_ISteamGameServer_SetRegion(intptr_t,const char*);
bool SteamAPI_ISteamGameServer_SendUserConnectAndAuthenticate(intptr_t,uint32,const char*,uint32,struct CSteamID*);
uint64_steamid SteamAPI_ISteamGameServer_CreateUnauthenticatedUserConnection(intptr_t);
void SteamAPI_ISteamGameServer_SendUserDisconnect(intptr_t,uint64_steamid);
bool SteamAPI_ISteamGameServer_BUpdateUserData(intptr_t,uint64_steamid,const char*,uint32);
HAuthTicket SteamAPI_ISteamGameServer_GetAuthSessionTicket(intptr_t,void*,int,uint32*);
EBeginAuthSessionResult SteamAPI_ISteamGameServer_BeginAuthSession(intptr_t,const char*,int,uint64_steamid);
void SteamAPI_ISteamGameServer_EndAuthSession(intptr_t,uint64_steamid);
void SteamAPI_ISteamGameServer_CancelAuthTicket(intptr_t,HAuthTicket);
EUserHasLicenseForAppResult SteamAPI_ISteamGameServer_UserHasLicenseForApp(intptr_t,uint64_steamid,AppId_t);
bool SteamAPI_ISteamGameServer_RequestUserGroupStatus(intptr_t,uint64_steamid,uint64_steamid);
void SteamAPI_ISteamGameServer_GetGameplayStats(intptr_t);
SteamAPICall_t SteamAPI_ISteamGameServer_GetServerReputation(intptr_t);
struct SteamIPAddress_t SteamAPI_ISteamGameServer_GetPublicIP(intptr_t);
bool SteamAPI_ISteamGameServer_HandleIncomingPacket(intptr_t,const char*,int,uint32,uint16);
int SteamAPI_ISteamGameServer_GetNextOutgoingPacket(intptr_t,void*,int,uint32*,uint16*);
void SteamAPI_ISteamGameServer_EnableHeartbeats(intptr_t,bool);
void SteamAPI_ISteamGameServer_SetHeartbeatInterval(intptr_t,int);
void SteamAPI_ISteamGameServer_ForceHeartbeat(intptr_t);
SteamAPICall_t SteamAPI_ISteamGameServer_AssociateWithClan(intptr_t,uint64_steamid);
SteamAPICall_t SteamAPI_ISteamGameServer_ComputeNewPlayerCompatibility(intptr_t,uint64_steamid);

intptr_t SteamAPI_SteamGameServerStats_v001();
SteamAPICall_t SteamAPI_ISteamGameServerStats_RequestUserStats(intptr_t,uint64_steamid);
bool SteamAPI_ISteamGameServerStats_GetUserStatInt32(intptr_t,uint64_steamid,const char*,int32*);
bool SteamAPI_ISteamGameServerStats_GetUserStatFloat(intptr_t,uint64_steamid,const char*,float*);
bool SteamAPI_ISteamGameServerStats_GetUserAchievement(intptr_t,uint64_steamid,const char*,bool*);
bool SteamAPI_ISteamGameServerStats_SetUserStatInt32(intptr_t,uint64_steamid,const char*,int32);
bool SteamAPI_ISteamGameServerStats_SetUserStatFloat(intptr_t,uint64_steamid,const char*,float);
bool SteamAPI_ISteamGameServerStats_UpdateUserAvgRateStat(intptr_t,uint64_steamid,const char*,float,double);
bool SteamAPI_ISteamGameServerStats_SetUserAchievement(intptr_t,uint64_steamid,const char*);
bool SteamAPI_ISteamGameServerStats_ClearUserAchievement(intptr_t,uint64_steamid,const char*);
SteamAPICall_t SteamAPI_ISteamGameServerStats_StoreUserStats(intptr_t,uint64_steamid);

bool SteamAPI_SteamIPAddress_t_IsSet(struct SteamIPAddress_t*);

void SteamAPI_MatchMakingKeyValuePair_t_Construct(struct MatchMakingKeyValuePair_t*);

void SteamAPI_servernetadr_t_Construct(struct servernetadr_t*);
void SteamAPI_servernetadr_t_Init(struct servernetadr_t*,unsigned  ip,uint16,uint16);
uint16 SteamAPI_servernetadr_t_GetQueryPort(struct servernetadr_t*);
void SteamAPI_servernetadr_t_SetQueryPort(struct servernetadr_t*,uint16);
uint16 SteamAPI_servernetadr_t_GetConnectionPort(struct servernetadr_t*);
void SteamAPI_servernetadr_t_SetConnectionPort(struct servernetadr_t*,uint16);
uint32 SteamAPI_servernetadr_t_GetIP(struct servernetadr_t*);
void SteamAPI_servernetadr_t_SetIP(struct servernetadr_t*,uint32);
const char*SteamAPI_servernetadr_t_GetConnectionAddressString(struct servernetadr_t*);
const char*SteamAPI_servernetadr_t_GetQueryAddressString(struct servernetadr_t*);
bool SteamAPI_servernetadr_t_IsLessThan(struct servernetadr_t*,const char&);
void SteamAPI_servernetadr_t_Assign(struct servernetadr_t*,const char&);

void SteamAPI_gameserveritem_t_Construct(struct gameserveritem_t*);
const char*SteamAPI_gameserveritem_t_GetName(struct gameserveritem_t*);
void SteamAPI_gameserveritem_t_SetName(struct gameserveritem_t*,const char*);

void SteamAPI_SteamNetworkingIPAddr_Clear(intptr_t);
bool SteamAPI_SteamNetworkingIPAddr_IsIPv6AllZeros(intptr_t);
void SteamAPI_SteamNetworkingIPAddr_SetIPv6(intptr_t,const char*,uint16);
void SteamAPI_SteamNetworkingIPAddr_SetIPv4(intptr_t,uint32,uint16);
bool SteamAPI_SteamNetworkingIPAddr_IsIPv4(intptr_t);
uint32 SteamAPI_SteamNetworkingIPAddr_GetIPv4(intptr_t);
void SteamAPI_SteamNetworkingIPAddr_SetIPv6LocalHost(intptr_t,uint16);
bool SteamAPI_SteamNetworkingIPAddr_IsLocalHost(intptr_t);
void SteamAPI_SteamNetworkingIPAddr_ToString(intptr_t,char*,uint32,bool);
bool SteamAPI_SteamNetworkingIPAddr_ParseString(intptr_t,const char*);
bool SteamAPI_SteamNetworkingIPAddr_IsEqualTo(intptr_t,const char&);

void SteamAPI_SteamNetworkingIdentity_Clear(intptr_t);
bool SteamAPI_SteamNetworkingIdentity_IsInvalid(intptr_t);
void SteamAPI_SteamNetworkingIdentity_SetSteamID(intptr_t,uint64_steamid);
uint64_steamid SteamAPI_SteamNetworkingIdentity_GetSteamID(intptr_t);
void SteamAPI_SteamNetworkingIdentity_SetSteamID64(intptr_t,uint64);
uint64 SteamAPI_SteamNetworkingIdentity_GetSteamID64(intptr_t);
bool SteamAPI_SteamNetworkingIdentity_SetXboxPairwiseID(intptr_t,const char*);
const char*SteamAPI_SteamNetworkingIdentity_GetXboxPairwiseID(intptr_t);
void SteamAPI_SteamNetworkingIdentity_SetIPAddr(intptr_t,const char&);
const intptr_t SteamAPI_SteamNetworkingIdentity_GetIPAddr(intptr_t);
void SteamAPI_SteamNetworkingIdentity_SetLocalHost(intptr_t);
bool SteamAPI_SteamNetworkingIdentity_IsLocalHost(intptr_t);
bool SteamAPI_SteamNetworkingIdentity_SetGenericString(intptr_t,const char*);
const char*SteamAPI_SteamNetworkingIdentity_GetGenericString(intptr_t);
bool SteamAPI_SteamNetworkingIdentity_SetGenericBytes(intptr_t,const char*,uint32);
const uint8*SteamAPI_SteamNetworkingIdentity_GetGenericBytes(intptr_t,int&);
bool SteamAPI_SteamNetworkingIdentity_IsEqualTo(intptr_t,const char&);
void SteamAPI_SteamNetworkingIdentity_ToString(intptr_t,char*,uint32);
bool SteamAPI_SteamNetworkingIdentity_ParseString(intptr_t,const char*);

void SteamAPI_SteamNetworkingMessage_t_Release(struct SteamNetworkingMessage_t*);

void SteamAPI_SteamDatagramHostedAddress_Clear(intptr_t);
SteamNetworkingPOPID SteamAPI_SteamDatagramHostedAddress_GetPopID(intptr_t);
void SteamAPI_SteamDatagramHostedAddress_SetDevAddress(intptr_t,uint32,uint16,SteamNetworkingPOPID);

// Extra
unsigned long long strtoull(const char*, char** endptr, int);

]])

local file
if ffi.os =="Linux" then
  file = "./libsteam_api.so"
elseif ffi.os == "OSX" then
  file = "./libsteam_api.dylib"
else
  file = (x64) and "./steam_api64.dll" or "./steam_api.dll"
end
return ffi.load(file)
