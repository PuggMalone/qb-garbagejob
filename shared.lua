Config = {}


Config.Bins = {
    -1096777189,
    666561306,
    218085040,
    -1426008804,
    -468629664,
    -206690185,
    1437508529,
    -1681329307,
    1948359883,
    1098827230,
    897494494,
    -228596739,
}

Config.Zones = {
    -- [0] = {Zone = 'BEACH', Label = 'Beach', Coords = vector3(-1110.1, -1615.2, 4.36)},
    [0] = {Zone = 'VCANA', Label = 'Vespucci Canals', Coords = vector3(-1010.42, -1122.98, 2.11)},
    [1] = {Zone = 'DAVIS', Label = 'Grove', Coords = vector3(55.69, -1898.98, 21.67)},
    [2] = {Zone = 'RANCHO', Label = 'Jamestown', Coords = vector3(287.37, -2007.61, 20.12)},
    [3] = {Zone = 'EBURO', Label = 'El Burro Heights', Coords = vector3(1286.84, -1730.96, 53.03)},
    [4] = {Zone = 'MIRR', Label = 'Mirror Park', Coords = vector3(1105.51, -543.5, 57.47)},
    [5] = {Zone = 'RICHM', Label = 'Richman', Coords = vector3(-1942.11, 233.89, 84.51)},
    [6] = {Zone = 'WVINE', Label = 'South Central Vinewood', Coords = vector3(-359.71, 363.21, 109.68)},
    [7] = {Zone = 'SKID', Label = 'Around MRPD', Coords = vector3(402.9, -957.9, 29.45)},
    [8] = {Zone = 'DELPE', Label = 'Del Perro Pier', Coords = vector3(-1613.4, -985.66, 13.02)},
    [9] = {Zone = 'CHIL', Label = 'West Vinewood', Coords = vector3(-863.16, 706.22, 149.19)},
    [10] = {Zone = 'DTVINE', Label = 'Clinton/Power Street', Coords = vector3(364.37, 296.42, 103.48)},
    [11] = {Zone = 'KOREAT', Label = 'Little Seoul', Coords = vector3(-690.19, -962.13, 19.84)},
}

Config.Locations = {
    ["vehicle"] = {
        label = "Garbage Truck Storage",
        coords = vector4(-341.24, -1560.12, 25.23, 94.13),
    },
}

Config.TrashAmt = math.random(12, 15)

Config.Payout = math.random(200, 300)

Config.VoucherList = {
    [0] = {
        databasename = 'scrapmetal',
        label = 'Scrap metal',
        amount = 20,
    },
    [1] = {
        databasename = 'plastic',
        label = 'Plastic',
        amount = 20,
    },
    [2] = {
        databasename = 'electronics',
        label = 'Electronics',
        amount = 20,
    },
    [3] = {
        databasename = 'rubber',
        label = 'Rubber',
        amount = 20,
    },
    [4] = {
        databasename = 'steel',
        label = 'Steel',
        amount = 20,
    },
}

Config.materials = 5