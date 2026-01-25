PART_DEPRECIATION = {
    "metal": 0.2,
    "plastic": 0.5,
    "glass": 0.0
}

DAMAGE_PART_MAP = {
    "dent": "metal",
    "scratch": "metal",
    "crack": "glass",
    "glass_shatter": "glass",
    "lamp_broken": "plastic"
}

def coverage_percentage(damage_type, policy):
    if policy["policy_type"] == "third_party":
        return 0.0

    if policy["addons"]["zero_depreciation"]:
        return 1.0

    if damage_type == "lamp_broken":
        return 0.5 if policy["addons"]["electrical_accessories"] else 0.0

    part = DAMAGE_PART_MAP.get(damage_type, "metal")
    depreciation = PART_DEPRECIATION.get(part, 0.5)

    return 1 - depreciation
