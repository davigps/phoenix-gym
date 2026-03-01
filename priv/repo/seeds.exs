# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Seeds are also run automatically on deploy (after migrations) via Phoenixgym.Release.seed/0.

Application.ensure_all_started(:phoenixgym)

{inserted, updated} = Phoenixgym.Seeds.seed_exercises()
IO.puts("Seeding exercises: inserted #{inserted}, updated #{updated}.")
