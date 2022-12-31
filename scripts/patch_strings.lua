-- patches for existing strings files
-- 'on top if it' -> 'on top of it'
if STRINGS.DLC1 and string.find(STRINGS.DLC1.KINETIC_CAPACITOR_FLAVOR, 'on top if it.') then
    STRINGS.DLC1.KINETIC_CAPACITOR_FLAVOR =
            "20th century watch technology with nearly a century of advancement on top of it."
end
