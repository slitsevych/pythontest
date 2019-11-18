import random

buzz = (
    "AVGVSTVS",
    "CAESAR",
    "CLAVDIVS",
    "TIBERIVS",
    "GAIVS",
    "ANTONINVS",
    "MARCVS",
    "FLAVIVS",
)
adjectives = (
    "Imperator",
    "Destinatus",
    "Princeps",
    "Dominus",
    "Basileus",
    "Magister militum",
)
adverbs = (
    "Pontifex Maximus",
    "Perpetuus",
    "Invictus",
    "Nobilissimus",
    "Divi",
    "Filius",
)
verbs = (
    "Consul",
    "Censor",
    "Pater Patriae",
    "Pius Felix",
    "Praefectus",
)


def sample(l, n=1):
    result = random.sample(l, n)
    if n == 1:
        return result[0]
    return result


def generate_buzz():
    buzz_terms = sample(buzz, 2)
    phrase = " ".join(
        [
            sample(adjectives),
            buzz_terms[0],
            sample(adverbs),
            sample(verbs),
            buzz_terms[1],
        ]
    )
    return phrase.title()


if __name__ == "__main__":
    print(generate_buzz())
