# seniorease
SeniorEase is a digital inclusion platform designed specifically for elderly users.  The platform helps older adults manage daily activities, reminders, appointments and digital interactions with confidence and autonomy.

# Adicionar como submódulo no Web e Mobile:
git submodule add git@github.com:deytt/seniorease-memory-bank.git memory-bank
mkdir -p .cursor/rules
cp memory-bank/.cursor/rules/memory-bank.mdc .cursor/rules/memory-bank.mdc
git add . && git commit -m "chore: add memory-bank submodule and cursor rule"

23/07/2026