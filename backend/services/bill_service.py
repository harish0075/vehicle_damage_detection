from services.insurance_rules import coverage_percentage

DAMAGE_COSTS = {
    "scratch": 2000,
    "dent": 5000,
    "crack": 3000,
    "glass_shatter": 8000,
    "lamp_broken": 6000
}

def generate_bill(damages, policy):
    total_cost = 0
    insurance_pays = 0

    for d in damages:
        damage_type = d["type"]
        base_cost = DAMAGE_COSTS.get(damage_type, 1000)
        coverage = coverage_percentage(damage_type, policy)

        total_cost += base_cost
        insurance_pays += base_cost * coverage

    insurance_pays -= policy["deductible"]

    return {
        "total_repair_cost": total_cost,
        "insurance_pays": max(insurance_pays, 0),
        "user_pays": max(total_cost - insurance_pays, 0)
    }
