# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Phoenixgym.Repo.insert!(%Phoenixgym.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Phoenixgym.Repo
alias Phoenixgym.Exercises.Exercise

exercises = [
  # ── CHEST ───────────────────────────────────────────────────────────────
  %{name: "Barbell Bench Press", category: "strength", primary_muscle: "chest", equipment: "barbell"},
  %{name: "Incline Barbell Bench Press", category: "strength", primary_muscle: "chest", equipment: "barbell"},
  %{name: "Decline Barbell Bench Press", category: "strength", primary_muscle: "chest", equipment: "barbell"},
  %{name: "Dumbbell Bench Press", category: "strength", primary_muscle: "chest", equipment: "dumbbell"},
  %{name: "Incline Dumbbell Press", category: "strength", primary_muscle: "chest", equipment: "dumbbell"},
  %{name: "Decline Dumbbell Press", category: "strength", primary_muscle: "chest", equipment: "dumbbell"},
  %{name: "Dumbbell Fly", category: "strength", primary_muscle: "chest", equipment: "dumbbell"},
  %{name: "Incline Dumbbell Fly", category: "strength", primary_muscle: "chest", equipment: "dumbbell"},
  %{name: "Cable Fly", category: "strength", primary_muscle: "chest", equipment: "cable"},
  %{name: "Low Cable Fly", category: "strength", primary_muscle: "chest", equipment: "cable"},
  %{name: "High Cable Fly", category: "strength", primary_muscle: "chest", equipment: "cable"},
  %{name: "Pec Deck Machine", category: "strength", primary_muscle: "chest", equipment: "machine"},
  %{name: "Chest Press Machine", category: "strength", primary_muscle: "chest", equipment: "machine"},
  %{name: "Push-Up", category: "strength", primary_muscle: "chest", equipment: "bodyweight"},
  %{name: "Wide Push-Up", category: "strength", primary_muscle: "chest", equipment: "bodyweight"},
  %{name: "Diamond Push-Up", category: "strength", primary_muscle: "chest", equipment: "bodyweight"},
  %{name: "Chest Dips", category: "strength", primary_muscle: "chest", equipment: "bodyweight"},
  %{name: "Svend Press", category: "strength", primary_muscle: "chest", equipment: "other"},

  # ── BACK ────────────────────────────────────────────────────────────────
  %{name: "Barbell Row", category: "strength", primary_muscle: "back", equipment: "barbell"},
  %{name: "Pendlay Row", category: "strength", primary_muscle: "back", equipment: "barbell"},
  %{name: "T-Bar Row", category: "strength", primary_muscle: "back", equipment: "barbell"},
  %{name: "Dumbbell Row", category: "strength", primary_muscle: "back", equipment: "dumbbell"},
  %{name: "Incline Dumbbell Row", category: "strength", primary_muscle: "back", equipment: "dumbbell"},
  %{name: "Pull-Up", category: "strength", primary_muscle: "back", equipment: "bodyweight"},
  %{name: "Chin-Up", category: "strength", primary_muscle: "back", equipment: "bodyweight"},
  %{name: "Neutral Grip Pull-Up", category: "strength", primary_muscle: "back", equipment: "bodyweight"},
  %{name: "Lat Pulldown", category: "strength", primary_muscle: "back", equipment: "cable"},
  %{name: "Wide Grip Lat Pulldown", category: "strength", primary_muscle: "back", equipment: "cable"},
  %{name: "Close Grip Lat Pulldown", category: "strength", primary_muscle: "back", equipment: "cable"},
  %{name: "Seated Cable Row", category: "strength", primary_muscle: "back", equipment: "cable"},
  %{name: "Straight Arm Pulldown", category: "strength", primary_muscle: "back", equipment: "cable"},
  %{name: "Cable Row Wide Grip", category: "strength", primary_muscle: "back", equipment: "cable"},
  %{name: "Deadlift", category: "strength", primary_muscle: "back", equipment: "barbell"},
  %{name: "Romanian Deadlift", category: "strength", primary_muscle: "back", equipment: "barbell"},
  %{name: "Sumo Deadlift", category: "strength", primary_muscle: "back", equipment: "barbell"},
  %{name: "Machine Row", category: "strength", primary_muscle: "back", equipment: "machine"},
  %{name: "Chest Supported Row", category: "strength", primary_muscle: "back", equipment: "machine"},
  %{name: "Good Morning", category: "strength", primary_muscle: "back", equipment: "barbell"},
  %{name: "Back Extension", category: "strength", primary_muscle: "back", equipment: "bodyweight"},

  # ── SHOULDERS ───────────────────────────────────────────────────────────
  %{name: "Barbell Overhead Press", category: "strength", primary_muscle: "shoulders", equipment: "barbell"},
  %{name: "Seated Barbell Overhead Press", category: "strength", primary_muscle: "shoulders", equipment: "barbell"},
  %{name: "Dumbbell Shoulder Press", category: "strength", primary_muscle: "shoulders", equipment: "dumbbell"},
  %{name: "Arnold Press", category: "strength", primary_muscle: "shoulders", equipment: "dumbbell"},
  %{name: "Seated Dumbbell Shoulder Press", category: "strength", primary_muscle: "shoulders", equipment: "dumbbell"},
  %{name: "Dumbbell Lateral Raise", category: "strength", primary_muscle: "shoulders", equipment: "dumbbell"},
  %{name: "Cable Lateral Raise", category: "strength", primary_muscle: "shoulders", equipment: "cable"},
  %{name: "Dumbbell Front Raise", category: "strength", primary_muscle: "shoulders", equipment: "dumbbell"},
  %{name: "Cable Front Raise", category: "strength", primary_muscle: "shoulders", equipment: "cable"},
  %{name: "Face Pull", category: "strength", primary_muscle: "shoulders", equipment: "cable"},
  %{name: "Rear Delt Fly", category: "strength", primary_muscle: "shoulders", equipment: "dumbbell"},
  %{name: "Reverse Pec Deck", category: "strength", primary_muscle: "shoulders", equipment: "machine"},
  %{name: "Machine Shoulder Press", category: "strength", primary_muscle: "shoulders", equipment: "machine"},
  %{name: "Upright Row", category: "strength", primary_muscle: "shoulders", equipment: "barbell"},
  %{name: "Barbell Shrug", category: "strength", primary_muscle: "shoulders", equipment: "barbell"},
  %{name: "Dumbbell Shrug", category: "strength", primary_muscle: "shoulders", equipment: "dumbbell"},

  # ── BICEPS ──────────────────────────────────────────────────────────────
  %{name: "Barbell Curl", category: "strength", primary_muscle: "biceps", equipment: "barbell"},
  %{name: "EZ Bar Curl", category: "strength", primary_muscle: "biceps", equipment: "barbell"},
  %{name: "Dumbbell Curl", category: "strength", primary_muscle: "biceps", equipment: "dumbbell"},
  %{name: "Hammer Curl", category: "strength", primary_muscle: "biceps", equipment: "dumbbell"},
  %{name: "Incline Dumbbell Curl", category: "strength", primary_muscle: "biceps", equipment: "dumbbell"},
  %{name: "Concentration Curl", category: "strength", primary_muscle: "biceps", equipment: "dumbbell"},
  %{name: "Preacher Curl", category: "strength", primary_muscle: "biceps", equipment: "barbell"},
  %{name: "Cable Curl", category: "strength", primary_muscle: "biceps", equipment: "cable"},
  %{name: "High Cable Curl", category: "strength", primary_muscle: "biceps", equipment: "cable"},
  %{name: "Machine Curl", category: "strength", primary_muscle: "biceps", equipment: "machine"},
  %{name: "Zottman Curl", category: "strength", primary_muscle: "biceps", equipment: "dumbbell"},
  %{name: "Cross Body Hammer Curl", category: "strength", primary_muscle: "biceps", equipment: "dumbbell"},
  %{name: "Reverse Curl", category: "strength", primary_muscle: "biceps", equipment: "barbell"},

  # ── TRICEPS ─────────────────────────────────────────────────────────────
  %{name: "Skull Crusher", category: "strength", primary_muscle: "triceps", equipment: "barbell"},
  %{name: "EZ Bar Skull Crusher", category: "strength", primary_muscle: "triceps", equipment: "barbell"},
  %{name: "Tricep Pushdown", category: "strength", primary_muscle: "triceps", equipment: "cable"},
  %{name: "Overhead Tricep Extension", category: "strength", primary_muscle: "triceps", equipment: "cable"},
  %{name: "Rope Pushdown", category: "strength", primary_muscle: "triceps", equipment: "cable"},
  %{name: "Close-Grip Bench Press", category: "strength", primary_muscle: "triceps", equipment: "barbell"},
  %{name: "Tricep Dips", category: "strength", primary_muscle: "triceps", equipment: "bodyweight"},
  %{name: "Tricep Kickback", category: "strength", primary_muscle: "triceps", equipment: "dumbbell"},
  %{name: "Overhead Dumbbell Tricep Extension", category: "strength", primary_muscle: "triceps", equipment: "dumbbell"},
  %{name: "Machine Tricep Press", category: "strength", primary_muscle: "triceps", equipment: "machine"},
  %{name: "JM Press", category: "strength", primary_muscle: "triceps", equipment: "barbell"},

  # ── LEGS ────────────────────────────────────────────────────────────────
  %{name: "Barbell Squat", category: "strength", primary_muscle: "legs", equipment: "barbell"},
  %{name: "Front Squat", category: "strength", primary_muscle: "legs", equipment: "barbell"},
  %{name: "Goblet Squat", category: "strength", primary_muscle: "legs", equipment: "kettlebell"},
  %{name: "Leg Press", category: "strength", primary_muscle: "legs", equipment: "machine"},
  %{name: "Hack Squat", category: "strength", primary_muscle: "legs", equipment: "machine"},
  %{name: "Leg Extension", category: "strength", primary_muscle: "legs", equipment: "machine"},
  %{name: "Lying Leg Curl", category: "strength", primary_muscle: "legs", equipment: "machine"},
  %{name: "Seated Leg Curl", category: "strength", primary_muscle: "legs", equipment: "machine"},
  %{name: "Romanian Deadlift Hamstring", category: "strength", primary_muscle: "legs", equipment: "barbell"},
  %{name: "Stiff Leg Deadlift", category: "strength", primary_muscle: "legs", equipment: "barbell"},
  %{name: "Dumbbell Romanian Deadlift", category: "strength", primary_muscle: "legs", equipment: "dumbbell"},
  %{name: "Barbell Lunge", category: "strength", primary_muscle: "legs", equipment: "barbell"},
  %{name: "Dumbbell Lunge", category: "strength", primary_muscle: "legs", equipment: "dumbbell"},
  %{name: "Walking Lunge", category: "strength", primary_muscle: "legs", equipment: "dumbbell"},
  %{name: "Bulgarian Split Squat", category: "strength", primary_muscle: "legs", equipment: "dumbbell"},
  %{name: "Step Up", category: "strength", primary_muscle: "legs", equipment: "dumbbell"},
  %{name: "Box Squat", category: "strength", primary_muscle: "legs", equipment: "barbell"},
  %{name: "Wall Sit", category: "strength", primary_muscle: "legs", equipment: "bodyweight"},
  %{name: "Nordic Hamstring Curl", category: "strength", primary_muscle: "legs", equipment: "bodyweight"},
  %{name: "Cable Pull-Through", category: "strength", primary_muscle: "legs", equipment: "cable"},
  %{name: "Pause Squat", category: "strength", primary_muscle: "legs", equipment: "barbell"},
  %{name: "Safety Bar Squat", category: "strength", primary_muscle: "legs", equipment: "barbell"},
  %{name: "Single Leg Press", category: "strength", primary_muscle: "legs", equipment: "machine"},
  %{name: "Dumbbell Sumo Deadlift", category: "strength", primary_muscle: "legs", equipment: "dumbbell"},
  %{name: "Banded Squat", category: "strength", primary_muscle: "legs", equipment: "resistance_band"},

  # ── GLUTES ──────────────────────────────────────────────────────────────
  %{name: "Barbell Hip Thrust", category: "strength", primary_muscle: "glutes", equipment: "barbell"},
  %{name: "Dumbbell Hip Thrust", category: "strength", primary_muscle: "glutes", equipment: "dumbbell"},
  %{name: "Glute Bridge", category: "strength", primary_muscle: "glutes", equipment: "bodyweight"},
  %{name: "Barbell Glute Bridge", category: "strength", primary_muscle: "glutes", equipment: "barbell"},
  %{name: "Cable Glute Kickback", category: "strength", primary_muscle: "glutes", equipment: "cable"},
  %{name: "Donkey Kickback Machine", category: "strength", primary_muscle: "glutes", equipment: "machine"},
  %{name: "Hip Abduction Machine", category: "strength", primary_muscle: "glutes", equipment: "machine"},
  %{name: "Lateral Band Walk", category: "strength", primary_muscle: "glutes", equipment: "resistance_band"},
  %{name: "Banded Hip Thrust", category: "strength", primary_muscle: "glutes", equipment: "resistance_band"},
  %{name: "Cable Hip Abduction", category: "strength", primary_muscle: "glutes", equipment: "cable"},
  %{name: "Frog Pump", category: "strength", primary_muscle: "glutes", equipment: "bodyweight"},

  # ── CALVES ──────────────────────────────────────────────────────────────
  %{name: "Standing Calf Raise", category: "strength", primary_muscle: "calves", equipment: "machine"},
  %{name: "Seated Calf Raise", category: "strength", primary_muscle: "calves", equipment: "machine"},
  %{name: "Donkey Calf Raise", category: "strength", primary_muscle: "calves", equipment: "bodyweight"},
  %{name: "Barbell Calf Raise", category: "strength", primary_muscle: "calves", equipment: "barbell"},
  %{name: "Dumbbell Calf Raise", category: "strength", primary_muscle: "calves", equipment: "dumbbell"},
  %{name: "Single Leg Calf Raise", category: "strength", primary_muscle: "calves", equipment: "bodyweight"},
  %{name: "Leg Press Calf Raise", category: "strength", primary_muscle: "calves", equipment: "machine"},

  # ── CORE ────────────────────────────────────────────────────────────────
  %{name: "Plank", category: "strength", primary_muscle: "core", equipment: "bodyweight"},
  %{name: "Side Plank", category: "strength", primary_muscle: "core", equipment: "bodyweight"},
  %{name: "Hollow Body Hold", category: "strength", primary_muscle: "core", equipment: "bodyweight"},
  %{name: "Crunch", category: "strength", primary_muscle: "core", equipment: "bodyweight"},
  %{name: "Bicycle Crunch", category: "strength", primary_muscle: "core", equipment: "bodyweight"},
  %{name: "Reverse Crunch", category: "strength", primary_muscle: "core", equipment: "bodyweight"},
  %{name: "Decline Crunch", category: "strength", primary_muscle: "core", equipment: "bodyweight"},
  %{name: "Hanging Leg Raise", category: "strength", primary_muscle: "core", equipment: "bodyweight"},
  %{name: "Hanging Knee Raise", category: "strength", primary_muscle: "core", equipment: "bodyweight"},
  %{name: "Ab Wheel Rollout", category: "strength", primary_muscle: "core", equipment: "other"},
  %{name: "Cable Crunch", category: "strength", primary_muscle: "core", equipment: "cable"},
  %{name: "Russian Twist", category: "strength", primary_muscle: "core", equipment: "other"},
  %{name: "Woodchop Cable", category: "strength", primary_muscle: "core", equipment: "cable"},
  %{name: "Dead Bug", category: "strength", primary_muscle: "core", equipment: "bodyweight"},
  %{name: "Dragon Flag", category: "strength", primary_muscle: "core", equipment: "bodyweight"},
  %{name: "Toes to Bar", category: "strength", primary_muscle: "core", equipment: "bodyweight"},
  %{name: "Sit-Up", category: "strength", primary_muscle: "core", equipment: "bodyweight"},
  %{name: "V-Up", category: "strength", primary_muscle: "core", equipment: "bodyweight"},
  %{name: "Pallof Press", category: "strength", primary_muscle: "core", equipment: "cable"},
  %{name: "Copenhagen Plank", category: "strength", primary_muscle: "core", equipment: "bodyweight"},
  %{name: "Weighted Plank", category: "strength", primary_muscle: "core", equipment: "other"},

  # ── FOREARMS ────────────────────────────────────────────────────────────
  %{name: "Wrist Curl", category: "strength", primary_muscle: "forearms", equipment: "barbell"},
  %{name: "Reverse Wrist Curl", category: "strength", primary_muscle: "forearms", equipment: "barbell"},
  %{name: "Wrist Roller", category: "strength", primary_muscle: "forearms", equipment: "other"},
  %{name: "Farmer's Walk", category: "strength", primary_muscle: "forearms", equipment: "dumbbell"},
  %{name: "Dead Hang", category: "strength", primary_muscle: "forearms", equipment: "bodyweight"},
  %{name: "Plate Pinch", category: "strength", primary_muscle: "forearms", equipment: "other"},

  # ── OLYMPIC ─────────────────────────────────────────────────────────────
  %{name: "Clean and Jerk", category: "olympic", primary_muscle: "full_body", equipment: "barbell"},
  %{name: "Snatch", category: "olympic", primary_muscle: "full_body", equipment: "barbell"},
  %{name: "Power Clean", category: "olympic", primary_muscle: "full_body", equipment: "barbell"},
  %{name: "Hang Clean", category: "olympic", primary_muscle: "full_body", equipment: "barbell"},
  %{name: "Power Snatch", category: "olympic", primary_muscle: "full_body", equipment: "barbell"},
  %{name: "Hang Snatch", category: "olympic", primary_muscle: "full_body", equipment: "barbell"},
  %{name: "Push Press", category: "olympic", primary_muscle: "shoulders", equipment: "barbell"},
  %{name: "Push Jerk", category: "olympic", primary_muscle: "shoulders", equipment: "barbell"},
  %{name: "Clean Pull", category: "olympic", primary_muscle: "back", equipment: "barbell"},
  %{name: "Snatch Pull", category: "olympic", primary_muscle: "back", equipment: "barbell"},

  # ── PLYOMETRIC / FULL BODY ──────────────────────────────────────────────
  %{name: "Burpee", category: "plyometric", primary_muscle: "full_body", equipment: "bodyweight"},
  %{name: "Box Jump", category: "plyometric", primary_muscle: "legs", equipment: "other"},
  %{name: "Jump Squat", category: "plyometric", primary_muscle: "legs", equipment: "bodyweight"},
  %{name: "Broad Jump", category: "plyometric", primary_muscle: "legs", equipment: "bodyweight"},
  %{name: "Depth Jump", category: "plyometric", primary_muscle: "legs", equipment: "other"},
  %{name: "Lateral Box Jump", category: "plyometric", primary_muscle: "legs", equipment: "other"},
  %{name: "Plyo Push-Up", category: "plyometric", primary_muscle: "chest", equipment: "bodyweight"},
  %{name: "Medicine Ball Slam", category: "plyometric", primary_muscle: "full_body", equipment: "other"},
  %{name: "Battle Ropes", category: "plyometric", primary_muscle: "full_body", equipment: "other"},
  %{name: "Turkish Get-Up", category: "strength", primary_muscle: "full_body", equipment: "kettlebell"},
  %{name: "Kettlebell Swing", category: "strength", primary_muscle: "full_body", equipment: "kettlebell"},
  %{name: "Kettlebell Goblet Squat", category: "strength", primary_muscle: "legs", equipment: "kettlebell"},
  %{name: "Kettlebell Clean", category: "strength", primary_muscle: "full_body", equipment: "kettlebell"},
  %{name: "Kettlebell Press", category: "strength", primary_muscle: "shoulders", equipment: "kettlebell"},
  %{name: "Kettlebell Snatch", category: "strength", primary_muscle: "full_body", equipment: "kettlebell"},
  %{name: "Sled Push", category: "strength", primary_muscle: "full_body", equipment: "other"},
  %{name: "Sled Pull", category: "strength", primary_muscle: "full_body", equipment: "other"},

  # ── CARDIO ──────────────────────────────────────────────────────────────
  %{name: "Treadmill Run", category: "cardio", primary_muscle: "cardio", equipment: "machine"},
  %{name: "Treadmill Walk", category: "cardio", primary_muscle: "cardio", equipment: "machine"},
  %{name: "Elliptical", category: "cardio", primary_muscle: "cardio", equipment: "machine"},
  %{name: "Rowing Machine", category: "cardio", primary_muscle: "cardio", equipment: "machine"},
  %{name: "Stationary Bike", category: "cardio", primary_muscle: "cardio", equipment: "machine"},
  %{name: "Assault Bike", category: "cardio", primary_muscle: "cardio", equipment: "machine"},
  %{name: "Stair Climber", category: "cardio", primary_muscle: "cardio", equipment: "machine"},
  %{name: "Jump Rope", category: "cardio", primary_muscle: "cardio", equipment: "other"},
  %{name: "Cycling Outdoor", category: "cardio", primary_muscle: "cardio", equipment: "other"},
  %{name: "Running Outdoor", category: "cardio", primary_muscle: "cardio", equipment: "other"},
  %{name: "Swimming", category: "cardio", primary_muscle: "cardio", equipment: "other"},
  %{name: "Hiking", category: "cardio", primary_muscle: "cardio", equipment: "other"},

  # ── FLEXIBILITY / MOBILITY ──────────────────────────────────────────────
  %{name: "Hip Flexor Stretch", category: "flexibility", primary_muscle: "legs", equipment: "bodyweight"},
  %{name: "Hamstring Stretch", category: "flexibility", primary_muscle: "legs", equipment: "bodyweight"},
  %{name: "Quad Stretch", category: "flexibility", primary_muscle: "legs", equipment: "bodyweight"},
  %{name: "Calf Stretch", category: "flexibility", primary_muscle: "calves", equipment: "bodyweight"},
  %{name: "Chest Stretch", category: "flexibility", primary_muscle: "chest", equipment: "bodyweight"},
  %{name: "Shoulder Stretch", category: "flexibility", primary_muscle: "shoulders", equipment: "bodyweight"},
  %{name: "Lat Stretch", category: "flexibility", primary_muscle: "back", equipment: "bodyweight"},
  %{name: "Thoracic Extension", category: "flexibility", primary_muscle: "back", equipment: "other"},
  %{name: "Pigeon Pose", category: "flexibility", primary_muscle: "glutes", equipment: "bodyweight"},
  %{name: "World's Greatest Stretch", category: "flexibility", primary_muscle: "full_body", equipment: "bodyweight"},

  # ── ADDITIONAL COMPOUND & ACCESSORY ────────────────────────────────────
  %{name: "Barbell Row Underhand", category: "strength", primary_muscle: "back", equipment: "barbell"},
  %{name: "One Arm Dumbbell Row", category: "strength", primary_muscle: "back", equipment: "dumbbell"},
  %{name: "Hex Bar Deadlift", category: "strength", primary_muscle: "back", equipment: "barbell"},
  %{name: "Dumbbell Deadlift", category: "strength", primary_muscle: "back", equipment: "dumbbell"},
  %{name: "Trap Bar Deadlift", category: "strength", primary_muscle: "back", equipment: "barbell"},
  %{name: "Resistance Band Pull Apart", category: "strength", primary_muscle: "shoulders", equipment: "resistance_band"},
  %{name: "Band Bicep Curl", category: "strength", primary_muscle: "biceps", equipment: "resistance_band"},
  %{name: "Band Tricep Extension", category: "strength", primary_muscle: "triceps", equipment: "resistance_band"},
  %{name: "Cable Woodchop Diagonal", category: "strength", primary_muscle: "core", equipment: "cable"},
]

IO.puts("Seeding #{length(exercises)} exercises...")

{inserted, skipped} =
  Enum.reduce(exercises, {0, 0}, fn attrs, {ins, skip} ->
    case Repo.get_by(Exercise, name: attrs.name) do
      nil ->
        Repo.insert!(%Exercise{
          name: attrs.name,
          category: attrs.category,
          primary_muscle: attrs.primary_muscle,
          equipment: attrs.equipment,
          secondary_muscles: [],
          is_custom: false
        })
        {ins + 1, skip}

      _existing ->
        {ins, skip + 1}
    end
  end)

IO.puts("Done! Inserted #{inserted} exercises, skipped #{skipped} already existing.")
