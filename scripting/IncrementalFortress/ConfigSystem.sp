int CategoryID;
void LoadConfigurationFiles(){
    //wake me up when sourcepawn has declarable values for multi-dimension arrays
    for(int i = 0;i < MaxCategories;++i){
        for(int j = 0;j < MaxSubcategories;++j){
            for(int k = 0; k < MaxAttributesPerCategory;++k){
                UpgradeListAttributes[i][j][k] = -1;
            }
        }
    }

    WeaponListTrie = CreateTrie();
    CategoryListTrie = CreateTrie();
    UpgradesListTrie = CreateTrie();
    CategoryExceptionsMap = new AnyMap();

    Handle kv = CreateKeyValues("if_weapons");
    FileToKeyValues(kv, "addons/sourcemod/configs/if_weapons.txt");

    SetTrieValue(CategoryListTrie, "body_base" , CategoryID, true);
    CategoryID++;
    SetTrieValue(CategoryListTrie, "body_scout" , CategoryID, true);
    CategoryID++;
    SetTrieValue(CategoryListTrie, "body_sniper" , CategoryID, true);
    CategoryID++;
    SetTrieValue(CategoryListTrie, "body_soldier" , CategoryID, true);
    CategoryID++;
    SetTrieValue(CategoryListTrie, "body_demoman" , CategoryID, true);
    CategoryID++;
    SetTrieValue(CategoryListTrie, "body_medic" , CategoryID, true);
    CategoryID++;
    SetTrieValue(CategoryListTrie, "body_heavy" , CategoryID, true);
    CategoryID++;
    SetTrieValue(CategoryListTrie, "body_pyro" , CategoryID, true);
    CategoryID++;
    SetTrieValue(CategoryListTrie, "body_spy" , CategoryID, true);
    CategoryID++;
    SetTrieValue(CategoryListTrie, "body_engie" , CategoryID, true);
    CategoryID++;
    SetTrieValue(CategoryListTrie, "canteen" , CategoryID, true);

    PrintToServer("[Incremental Fortress] %d weapons loaded.", LoadUpgradeCategories(kv)-1);
    delete kv;

    kv = CreateKeyValues("if_upgrades");
    FileToKeyValues(kv, "addons/sourcemod/configs/if_upgrades.txt");
    PrintToServer("[Incremental Fortress] %d upgrades loaded.", LoadAttributes(kv));
    delete kv;

    kv = CreateKeyValues("if_lists");
    FileToKeyValues(kv, "addons/sourcemod/configs/if_lists.txt");
    LoadCategoryLists(kv, -1, -1, -1, 0);
    delete kv;

}

char SubCategory[CategoryMaxLength];
int LoadUpgradeCategories(Handle kv, int level = 1){
    char Buffer[CategoryMaxLength];
    do{
        if(level == 2){
            KvGetSectionName(kv, SubCategory, sizeof(SubCategory));
        }

        if (KvGotoFirstSubKey(kv, false)){
            LoadUpgradeCategories(kv, level + 1);
            KvGoBack(kv);
        }
        else{
            if (KvGetDataType(kv, NULL_STRING) != KvData_None){
                KvGetSectionName(kv, Buffer, sizeof(Buffer));
                if(StrEqual(SubCategory, "Classnames")){
                    WeaponCategoryName[CategoryID] = Buffer;
                    KvGetString(kv, "", Buffer, sizeof(Buffer));

                    int GetValue;
                    if(!GetTrieValue(CategoryListTrie, Buffer, GetValue) || GetValue == 0){
                        CategoryID++;
                        GetValue = CategoryID;
                        KvGetSectionName(kv, Buffer, sizeof(Buffer));
                        WeaponCategoryName[GetValue] = Buffer;
                        KvGetString(kv, "", Buffer, sizeof(Buffer));
                    }

                    PrintToServer("%i value | %i cat", GetValue, CategoryID);

                    if (SetTrieValue(WeaponListTrie, WeaponCategoryName[CategoryID], GetValue, false)){
                        PrintToServer("IF | Loaded category %s for %s | Cat = %i", Buffer, WeaponCategoryName[CategoryID], GetValue);
                        SetTrieValue(CategoryListTrie, Buffer, GetValue, false)
                    }else{
                        PrintToServer("IF | Something went wrong trying to load the category of %s", Buffer);
                    }
                }else if(StrEqual(SubCategory, "Exceptions")){
                    int id = StringToInt(Buffer);
                    KvGetString(kv, "", Buffer, sizeof(Buffer));
                    CategoryExceptionsMap.SetString(id, Buffer);
                }
            }

        }
    }
    while (KvGotoNextKey(kv, false));
    return CategoryID;
}

int AttributeID;
int LoadAttributes(Handle kv){
    char Buffer[128];
    TF2EconDynAttribute attrib = new TF2EconDynAttribute();
    bool ShouldRegister = false;
    do
    {
        if (KvGotoFirstSubKey(kv, false))
        {
            LoadAttributes(kv);
            KvGoBack(kv);
        }
        else
        {
            if (KvGetDataType(kv, NULL_STRING) != KvData_None)
            {
                KvGetSectionName(kv, Buffer, sizeof(Buffer));
                if (!strcmp(Buffer,"name"))
                {
                    KvGetString(kv, "", UpgradesArray[AttributeID].Name, sizeof(Buffer));
                    SetTrieValue(UpgradesListTrie, UpgradesArray[AttributeID].Name, AttributeID, true);
                }
                else if (!strcmp(Buffer,"attribute"))
                {
                    KvGetString(kv, "", UpgradesArray[AttributeID].AttributeName, sizeof(Buffer));
                }
                else if (!strcmp(Buffer, "attr_class"))
                {
                    KvGetString(kv, "", Buffer, sizeof(Buffer));
                    attrib.SetName(UpgradesArray[AttributeID].AttributeName);
                    attrib.SetClass(Buffer);
                    PrintToServer("IF | Registering attribute \"%s\" with class \"%s\"", UpgradesArray[AttributeID].AttributeName, Buffer);
                    ShouldRegister = true;
                }
                else if (!strcmp(Buffer,"cost"))
                {
                    KvGetString(kv, "", Buffer, sizeof(Buffer));
                    UpgradesArray[AttributeID].Cost = ParseShorthand(Buffer,sizeof(Buffer));
                }
                else if (!strcmp(Buffer,"overcost"))
                {
                    KvGetString(kv, "", Buffer, sizeof(Buffer));
                    UpgradesArray[AttributeID].CostIncreasePerUpgrade = StringToFloat(Buffer);
                }
                else if (!strcmp(Buffer,"increment"))
                {
                    KvGetString(kv, "", Buffer, sizeof(Buffer));
                    UpgradesArray[AttributeID].IncrementPerUpgrade = StringToFloat(Buffer);
                }
                else if (!strcmp(Buffer,"initial_value"))
                {
                    KvGetString(kv, "", Buffer, sizeof(Buffer));
                    UpgradesArray[AttributeID].InitialValue = StringToFloat(Buffer);
                }
                else if(!strcmp(Buffer,"description"))
                {
                    KvGetString(kv, "", Buffer, sizeof(Buffer));
                    ReplaceString(Buffer, sizeof(Buffer), "\\n", "\n");
                    ReplaceString(Buffer, sizeof(Buffer), "%", "％");
                    Format(UpgradesArray[AttributeID].Description, 256, "%s:\n%s\n", UpgradesArray[AttributeID].Name, Buffer);
                }
                else if(!strcmp(Buffer,"display"))
                {
                    KvGetString(kv, "", Buffer, sizeof(Buffer));
                    strcopy(UpgradesArray[AttributeID].DisplayValue, 64, Buffer);
                    if(StrContains(Buffer, "%%") != -1){
                        attrib.SetDescriptionFormat("value_is_percentage");
                    }
                    else{
                        attrib.SetDescriptionFormat("value_is_additive");
                    }
                }
                else if(!strcmp(Buffer,"display_name"))
                {
                    KvGetString(kv, "", UpgradesArray[AttributeID].DisplayName, sizeof(Buffer));
                }
                else if (!strcmp(Buffer,"max"))
                {
                    KvGetString(kv, "", Buffer, sizeof(Buffer));
                    UpgradesArray[AttributeID].MaximumValue = StringToFloat(Buffer);
                    AttributeID++;
                    if(ShouldRegister)
                        attrib.Register();
                }
            }
        }
    }
    while (KvGotoNextKey(kv, false));
    delete attrib;
    return AttributeID;
}

void LoadCategoryLists(Handle kv, int WeaponID, int WeaponSubcatID, int WeaponAttributeID, int level)
{
    char Buf[64];
    do
    {
        KvGetSectionName(kv, Buf, sizeof(Buf));
        if (level == 1)
        {
            if (!GetTrieValue(CategoryListTrie, Buf, WeaponID))
            {
                PrintToServer("Category \"%s\" [if_lists.txt] was not found", Buf)
            }
            WeaponSubcatID = -1;
        }
        else if (level == 2)
        {
            if (!strcmp(Buf, "parent"))
            {
                int ParentID;
                KvGetString(kv, "", Buf, 64);
                if (!GetTrieValue(CategoryListTrie, Buf, ParentID)){
                    PrintToServer("Category \"%s\" [if_lists.txt] was not found (parent)", Buf)
                }
                else{
                    UpgradeListSubcategoryCount[WeaponID] = UpgradeListSubcategoryCount[ParentID];
                    for(int i = 0 ;i < UpgradeListSubcategoryCount[ParentID]; ++i){
                        UpgradeListSubcategoryNames[WeaponID][i] = UpgradeListSubcategoryNames[ParentID][i]
                        UpgradeListAttributes[WeaponID][i] = UpgradeListAttributes[ParentID][i];
                    }
                    WeaponSubcatID+=UpgradeListSubcategoryCount[ParentID];
                    WeaponAttributeID = 0;
                }
            }
            else
            {
                WeaponSubcatID++
                UpgradeListSubcategoryNames[WeaponID][WeaponSubcatID] = Buf;
                UpgradeListSubcategoryCount[WeaponID]++;
                WeaponAttributeID = 0;
            }
        }

        if (KvGotoFirstSubKey(kv, false))
        {
            KvGetSectionName(kv, Buf, sizeof(Buf));
            LoadCategoryLists(kv, WeaponID, WeaponSubcatID, WeaponAttributeID, level + 1);
            KvGoBack(kv);
        }
        else
        {
            if (KvGetDataType(kv, NULL_STRING) != KvData_None)
            {
                int attr_id;
                KvGetSectionName(kv, Buf, sizeof(Buf));

                if (strcmp(Buf, "parent"))
                {
                    KvGetString(kv, "", Buf, sizeof(Buf));
                    if (!GetTrieValue(UpgradesListTrie, Buf, attr_id))
                    {
                        PrintToServer("Attribute \"%s\" [if_lists.txt] was not found", Buf)
                    }
                    UpgradeListAttributes[WeaponID][WeaponSubcatID][WeaponAttributeID] = attr_id;
                    WeaponAttributeID++
                }
            }
        }
    }
    while (KvGotoNextKey(kv, false));
}