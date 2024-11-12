//Constants
#define MaxCategories 64
#define MaxSubcategories 7
#define MaxAttributesPerCategory 30
#define MaxAttributesPerItem 60
#define MaxSlots 8
#define MaxCanteenSlots 8
#define CategoryMaxLength 64
#define MaxAttributes 800

//Per Client Variables
float CurrentPoints[MAXPLAYERS];
float NextMenuServing[MAXPLAYERS];
float CurrentCanteenCooldowns[MAXPLAYERS];
int CurrentWeaponDefinitions[MAXPLAYERS][MaxSlots];
int CurrentWeaponEntities[MAXPLAYERS][MaxSlots];
int CurrentWeaponIDs[MAXPLAYERS][MaxSlots];
int CurrentMenuSlot[MAXPLAYERS];
int CurrentMenuCategory[MAXPLAYERS];
int CurrentButtons[MAXPLAYERS];
int CurrentCanteenSlots[MAXPLAYERS][MaxCanteenSlots];

//Handles
Handle WeaponListTrie;
Handle UpgradesListTrie;
Handle CategoryListTrie;
Handle CanteenListTrie;
Handle CanteenSnapshot;
Handle CanteenCooldownHUD;
AnyMap CategoryExceptionsMap;

//Upgrade Lists
int UpgradeListAttributes[MaxCategories][MaxSubcategories][MaxAttributesPerCategory];
int UpgradeListSubcategoryCount[MaxCategories];
char UpgradeListSubcategoryNames[MaxCategories][MaxSubcategories][CategoryMaxLength];

//Active Upgrades
int UpgradeIDsOnItem[MAXPLAYERS][MaxSlots][MaxAttributesPerItem];
int UpgradeTimesOnItem[MAXPLAYERS][MaxSlots][MaxAttributesPerItem];
float PointsSpentOnItem[MAXPLAYERS][MaxSlots];

//Chars
char WeaponCategoryName[MaxCategories][CategoryMaxLength];

//Floats
float TotalPoints;

//Enum Structs
Upgrade UpgradesArray[MaxAttributes];


// Gameplay Mechanics //

//Controls the amount of afterburn stacks & their damage on a player.
ArrayList AfterburnLists[MAXPLAYERS];