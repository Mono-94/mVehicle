

-- default ox_lib skillcheck https://overextended.dev/ox_lib/Modules/Interface/Client/skillcheck
local Dificult <const> = {
    easy = { 'easy', 'easy' },
    medium = { 'easy', 'easy', 'medium', 'medium' },
    hard = { 'easy', 'easy', 'medium', 'medium', 'hard', 'hard' },
    very_hard = { 'easy', 'hard', 'medium', 'medium', 'hard' }
}

VehicleClass = {
    [0] = { -- Compact
        lockpickDificult = Dificult['easy'],
        hotWireDificult = Dificult['easy']
    },
    [1] = { -- Sedan
        lockpickDificult = Dificult['easy'],
        hotWireDificult = Dificult['easy']
    },
    [2] = { -- SUV
        lockpickDificult = Dificult['medium'],
        hotWireDificult = Dificult['medium']
    },
    [3] = { -- Coupe
        lockpickDificult = Dificult['medium'],
        hotWireDificult = Dificult['medium']
    },
    [4] = { -- Muscle
        lockpickDificult = Dificult['hard'],
        hotWireDificult = Dificult['medium']
    },
    [5] = { -- Sport Classic
        lockpickDificult = Dificult['hard'],
        hotWireDificult = Dificult['hard']
    },
    [6] = { -- Sport
        lockpickDificult = Dificult['hard'],
        hotWireDificult = Dificult['hard']
    },
    [7] = { -- Super
        lockpickDificult = Dificult['very_hard'],
        hotWireDificult = Dificult['very_hard']
    },
    [8] = { -- Motorcycle
        lockpickDificult = Dificult['medium'],
        hotWireDificult = Dificult['easy']
    },
    [9] = { -- Off-road
        lockpickDificult = Dificult['medium'],
        hotWireDificult = Dificult['medium']
    },
    [10] = { -- Industrial
        lockpickDificult = Dificult['hard'],
        hotWireDificult = Dificult['hard']
    },
    [11] = { -- Utility
        lockpickDificult = Dificult['hard'],
        hotWireDificult = Dificult['hard']
    },
    [12] = { -- Van
        lockpickDificult = Dificult['medium'],
        hotWireDificult = Dificult['medium']
    },
    [13] = { -- Cycle
        lockpickDificult = Dificult['easy'],
        hotWireDificult = Dificult['easy']
    },
    [14] = { -- Boat
        lockpickDificult = Dificult['hard'],
        hotWireDificult = Dificult['hard']
    },
    [15] = { -- Helicopter
        lockpickDificult = Dificult['very_hard'],
        hotWireDificult = Dificult['very_hard']
    },
    [16] = { -- Plane
        lockpickDificult = Dificult['very_hard'],
        hotWireDificult = Dificult['very_hard']
    },
    [17] = { -- Service
        lockpickDificult = Dificult['hard'],
        hotWireDificult = Dificult['hard']
    },
    [18] = { -- Emergency
        lockpickDificult = Dificult['hard'],
        hotWireDificult = Dificult['hard']
    },
    [19] = { -- Military
        lockpickDificult = Dificult['very_hard'],
        hotWireDificult = Dificult['very_hard']
    },
    [20] = { -- Commercial
        lockpickDificult = Dificult['hard'],
        hotWireDificult = Dificult['hard']
    },
    [21] = { -- Train
        lockpickDificult = Dificult['very_hard'],
        hotWireDificult = Dificult['very_hard']
    },
    [22] = { -- Open Wheel
        lockpickDificult = Dificult['very_hard'],
        hotWireDificult = Dificult['very_hard']
    },
}
