from transformers import pipeline
import re

qa_pipeline = pipeline(
    "question-answering",
    model="deepset/roberta-base-squad2",
    tokenizer="deepset/roberta-base-squad2"
)


def ask(question: str, context: str, min_score: float = 0.25):
    if not context or len(context.strip()) < 50:
        return None

    try:
        result = qa_pipeline(
            question=question,
            context=context
        )
        if result["score"] >= min_score:
            return result["answer"]
    except Exception:
        pass

    return None


def parse_insurance(text: str):

    context = text.replace("\n", " ")

    policy = {
        "insurer": None,
        "policy_type": None,
        "deductible": None,
        "coverages": {
            "personal_belongings": None,
            "own_damage": None,
            "glass_damage": None,
            "electrical_accessories": None
        },
        "addons": {
            "zero_depreciation": False,
            "engine_protect": False,
            "roadside_assistance": False
        }
    }

    policy["insurer"] = ask(
        "Which insurance company provides this policy?",
        context
    )

    is_comprehensive = ask(
        "Does this policy include own damage cover?",
        context
    )

    is_third_party_only = ask(
        "Is this policy limited to third party liability only?",
        context
    )

    if is_comprehensive and "yes" in is_comprehensive.lower():
        policy["policy_type"] = "comprehensive"
    elif is_third_party_only and "yes" in is_third_party_only.lower():
        policy["policy_type"] = "third_party"
    else:
        policy["policy_type"] = "own_damage"


    deductible_answer = ask(
        "What is the deductible amount in rupees?",
        context
    )

    if deductible_answer:
        num = re.search(r"\d{3,6}", deductible_answer.replace(",", ""))
        policy["deductible"] = int(num.group()) if num else 5000
    else:
        policy["deductible"] = 5000


    personal_belongings = ask(
        "What is the maximum coverage for loss or damage of personal belongings?",
        context
    )

    if personal_belongings:
        policy["coverages"]["personal_belongings"] = personal_belongings

    own_damage = ask(
        "What damage to the insured vehicle is covered under this policy?",
        context
    )

    if own_damage:
        policy["coverages"]["own_damage"] = own_damage

    glass_damage = ask(
        "Is damage to glass or windshield covered?",
        context
    )

    if glass_damage:
        policy["coverages"]["glass_damage"] = glass_damage

    electrical_cover = ask(
        "Are electrical accessories such as headlights covered?",
        context
    )

    if electrical_cover:
        policy["coverages"]["electrical_accessories"] = electrical_cover

    text_lower = context.lower()

    policy["addons"]["zero_depreciation"] = (
        "zero depreciation" in text_lower
        or "nil depreciation" in text_lower
        or "depreciation reimbursement" in text_lower
    )

    policy["addons"]["engine_protect"] = (
        "engine protect" in text_lower
        or "engine guard" in text_lower
    )

    policy["addons"]["roadside_assistance"] = (
        "road side assistance" in text_lower
        or "rsa" in text_lower
    )

    return policy
