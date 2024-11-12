enum struct Upgrade{
    float IncrementPerUpgrade;
    float InitialValue;
    float MaximumValue;
    //Probably not going to exist, except on a few outliers.
    float CostIncreasePerUpgrade;
    //It's gonna be one!
    float Cost;
    char Name[64];
    char DisplayName[64];
    char AttributeName[64];
    char DisplayValue[64];
    char Description[256];
}

enum struct DOTTick{
    int ownerReference;
    int damageType;
    float damage;
}