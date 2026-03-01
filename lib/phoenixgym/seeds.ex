defmodule Phoenixgym.Seeds do
  @moduledoc """
  Idempotent seed data for the application. Used by mix run priv/repo/seeds.exs
  and by Phoenixgym.Release.seed/0 on deploy.
  """
  alias Phoenixgym.Repo
  alias Phoenixgym.Exercises.Exercise

  @exercises [
    # CHEST
    %{
      code: "barbell_bench_press",
      name: "Supino reto com barra",
      name_en: "Barbell Bench Press",
      category: "strength",
      primary_muscle: "chest",
      equipment: "barbell"
    },
    %{
      code: "incline_barbell_bench_press",
      name: "Supino inclinado com barra",
      name_en: "Incline Barbell Bench Press",
      category: "strength",
      primary_muscle: "chest",
      equipment: "barbell"
    },
    %{
      code: "decline_barbell_bench_press",
      name: "Supino declinado com barra",
      name_en: "Decline Barbell Bench Press",
      category: "strength",
      primary_muscle: "chest",
      equipment: "barbell"
    },
    %{
      code: "dumbbell_bench_press",
      name: "Supino reto com haltere",
      name_en: "Dumbbell Bench Press",
      category: "strength",
      primary_muscle: "chest",
      equipment: "dumbbell"
    },
    %{
      code: "incline_dumbbell_press",
      name: "Supino inclinado com haltere",
      name_en: "Incline Dumbbell Press",
      category: "strength",
      primary_muscle: "chest",
      equipment: "dumbbell"
    },
    %{
      code: "decline_dumbbell_press",
      name: "Supino declinado com haltere",
      name_en: "Decline Dumbbell Press",
      category: "strength",
      primary_muscle: "chest",
      equipment: "dumbbell"
    },
    %{
      code: "dumbbell_fly",
      name: "Crucifixo com haltere",
      name_en: "Dumbbell Fly",
      category: "strength",
      primary_muscle: "chest",
      equipment: "dumbbell"
    },
    %{
      code: "incline_dumbbell_fly",
      name: "Crucifixo inclinado com haltere",
      name_en: "Incline Dumbbell Fly",
      category: "strength",
      primary_muscle: "chest",
      equipment: "dumbbell"
    },
    %{
      code: "cable_fly",
      name: "Crucifixo na polia",
      name_en: "Cable Fly",
      category: "strength",
      primary_muscle: "chest",
      equipment: "cable"
    },
    %{
      code: "low_cable_fly",
      name: "Crucifixo na polia baixa",
      name_en: "Low Cable Fly",
      category: "strength",
      primary_muscle: "chest",
      equipment: "cable"
    },
    %{
      code: "high_cable_fly",
      name: "Crucifixo na polia alta",
      name_en: "High Cable Fly",
      category: "strength",
      primary_muscle: "chest",
      equipment: "cable"
    },
    %{
      code: "pec_deck_machine",
      name: "Peck deck",
      name_en: "Pec Deck Machine",
      category: "strength",
      primary_muscle: "chest",
      equipment: "machine"
    },
    %{
      code: "chest_press_machine",
      name: "Supino no aparelho",
      name_en: "Chest Press Machine",
      category: "strength",
      primary_muscle: "chest",
      equipment: "machine"
    },
    %{
      code: "push_up",
      name: "Flexão de braço",
      name_en: "Push-Up",
      category: "strength",
      primary_muscle: "chest",
      equipment: "bodyweight"
    },
    %{
      code: "wide_push_up",
      name: "Flexão de braço aberta",
      name_en: "Wide Push-Up",
      category: "strength",
      primary_muscle: "chest",
      equipment: "bodyweight"
    },
    %{
      code: "diamond_push_up",
      name: "Flexão diamante",
      name_en: "Diamond Push-Up",
      category: "strength",
      primary_muscle: "chest",
      equipment: "bodyweight"
    },
    %{
      code: "chest_dips",
      name: "Mergulho para peitoral",
      name_en: "Chest Dips",
      category: "strength",
      primary_muscle: "chest",
      equipment: "bodyweight"
    },
    %{
      code: "svend_press",
      name: "Svend press",
      name_en: "Svend Press",
      category: "strength",
      primary_muscle: "chest",
      equipment: "other"
    },
    # BACK
    %{
      code: "barbell_row",
      name: "Remada com barra",
      name_en: "Barbell Row",
      category: "strength",
      primary_muscle: "back",
      equipment: "barbell"
    },
    %{
      code: "pendlay_row",
      name: "Remada Pendlay",
      name_en: "Pendlay Row",
      category: "strength",
      primary_muscle: "back",
      equipment: "barbell"
    },
    %{
      code: "t_bar_row",
      name: "Remada T",
      name_en: "T-Bar Row",
      category: "strength",
      primary_muscle: "back",
      equipment: "barbell"
    },
    %{
      code: "dumbbell_row",
      name: "Remada com haltere",
      name_en: "Dumbbell Row",
      category: "strength",
      primary_muscle: "back",
      equipment: "dumbbell"
    },
    %{
      code: "incline_dumbbell_row",
      name: "Remada inclinada com haltere",
      name_en: "Incline Dumbbell Row",
      category: "strength",
      primary_muscle: "back",
      equipment: "dumbbell"
    },
    %{
      code: "pull_up",
      name: "Barra fixa",
      name_en: "Pull-Up",
      category: "strength",
      primary_muscle: "back",
      equipment: "bodyweight"
    },
    %{
      code: "chin_up",
      name: "Barra fixa pegada supinada",
      name_en: "Chin-Up",
      category: "strength",
      primary_muscle: "back",
      equipment: "bodyweight"
    },
    %{
      code: "neutral_grip_pull_up",
      name: "Barra fixa pegada neutra",
      name_en: "Neutral Grip Pull-Up",
      category: "strength",
      primary_muscle: "back",
      equipment: "bodyweight"
    },
    %{
      code: "lat_pulldown",
      name: "Puxada frontal",
      name_en: "Lat Pulldown",
      category: "strength",
      primary_muscle: "back",
      equipment: "cable"
    },
    %{
      code: "wide_grip_lat_pulldown",
      name: "Puxada frontal pegada larga",
      name_en: "Wide Grip Lat Pulldown",
      category: "strength",
      primary_muscle: "back",
      equipment: "cable"
    },
    %{
      code: "close_grip_lat_pulldown",
      name: "Puxada frontal pegada fechada",
      name_en: "Close Grip Lat Pulldown",
      category: "strength",
      primary_muscle: "back",
      equipment: "cable"
    },
    %{
      code: "seated_cable_row",
      name: "Remada sentada na polia",
      name_en: "Seated Cable Row",
      category: "strength",
      primary_muscle: "back",
      equipment: "cable"
    },
    %{
      code: "straight_arm_pulldown",
      name: "Puxada com braços estendidos",
      name_en: "Straight Arm Pulldown",
      category: "strength",
      primary_muscle: "back",
      equipment: "cable"
    },
    %{
      code: "cable_row_wide_grip",
      name: "Remada na polia pegada larga",
      name_en: "Cable Row Wide Grip",
      category: "strength",
      primary_muscle: "back",
      equipment: "cable"
    },
    %{
      code: "deadlift",
      name: "Levantamento terra",
      name_en: "Deadlift",
      category: "strength",
      primary_muscle: "back",
      equipment: "barbell"
    },
    %{
      code: "romanian_deadlift",
      name: "Levantamento terra romeno",
      name_en: "Romanian Deadlift",
      category: "strength",
      primary_muscle: "back",
      equipment: "barbell"
    },
    %{
      code: "sumo_deadlift",
      name: "Levantamento terra sumo",
      name_en: "Sumo Deadlift",
      category: "strength",
      primary_muscle: "back",
      equipment: "barbell"
    },
    %{
      code: "machine_row",
      name: "Remada no aparelho",
      name_en: "Machine Row",
      category: "strength",
      primary_muscle: "back",
      equipment: "machine"
    },
    %{
      code: "chest_supported_row",
      name: "Remada com apoio no peito",
      name_en: "Chest Supported Row",
      category: "strength",
      primary_muscle: "back",
      equipment: "machine"
    },
    %{
      code: "good_morning",
      name: "Good morning",
      name_en: "Good Morning",
      category: "strength",
      primary_muscle: "back",
      equipment: "barbell"
    },
    %{
      code: "back_extension",
      name: "Extensão lombar",
      name_en: "Back Extension",
      category: "strength",
      primary_muscle: "back",
      equipment: "bodyweight"
    },
    # SHOULDERS
    %{
      code: "barbell_overhead_press",
      name: "Desenvolvimento com barra",
      name_en: "Barbell Overhead Press",
      category: "strength",
      primary_muscle: "shoulders",
      equipment: "barbell"
    },
    %{
      code: "seated_barbell_overhead_press",
      name: "Desenvolvimento sentado com barra",
      name_en: "Seated Barbell Overhead Press",
      category: "strength",
      primary_muscle: "shoulders",
      equipment: "barbell"
    },
    %{
      code: "dumbbell_shoulder_press",
      name: "Desenvolvimento com haltere",
      name_en: "Dumbbell Shoulder Press",
      category: "strength",
      primary_muscle: "shoulders",
      equipment: "dumbbell"
    },
    %{
      code: "arnold_press",
      name: "Desenvolvimento Arnold",
      name_en: "Arnold Press",
      category: "strength",
      primary_muscle: "shoulders",
      equipment: "dumbbell"
    },
    %{
      code: "seated_dumbbell_shoulder_press",
      name: "Desenvolvimento sentado com haltere",
      name_en: "Seated Dumbbell Shoulder Press",
      category: "strength",
      primary_muscle: "shoulders",
      equipment: "dumbbell"
    },
    %{
      code: "dumbbell_lateral_raise",
      name: "Elevação lateral com haltere",
      name_en: "Dumbbell Lateral Raise",
      category: "strength",
      primary_muscle: "shoulders",
      equipment: "dumbbell"
    },
    %{
      code: "cable_lateral_raise",
      name: "Elevação lateral na polia",
      name_en: "Cable Lateral Raise",
      category: "strength",
      primary_muscle: "shoulders",
      equipment: "cable"
    },
    %{
      code: "dumbbell_front_raise",
      name: "Elevação frontal com haltere",
      name_en: "Dumbbell Front Raise",
      category: "strength",
      primary_muscle: "shoulders",
      equipment: "dumbbell"
    },
    %{
      code: "cable_front_raise",
      name: "Elevação frontal na polia",
      name_en: "Cable Front Raise",
      category: "strength",
      primary_muscle: "shoulders",
      equipment: "cable"
    },
    %{
      code: "face_pull",
      name: "Face pull",
      name_en: "Face Pull",
      category: "strength",
      primary_muscle: "shoulders",
      equipment: "cable"
    },
    %{
      code: "rear_delt_fly",
      name: "Crucifixo invertido com haltere",
      name_en: "Rear Delt Fly",
      category: "strength",
      primary_muscle: "shoulders",
      equipment: "dumbbell"
    },
    %{
      code: "reverse_pec_deck",
      name: "Pec deck invertido",
      name_en: "Reverse Pec Deck",
      category: "strength",
      primary_muscle: "shoulders",
      equipment: "machine"
    },
    %{
      code: "machine_shoulder_press",
      name: "Desenvolvimento no aparelho",
      name_en: "Machine Shoulder Press",
      category: "strength",
      primary_muscle: "shoulders",
      equipment: "machine"
    },
    %{
      code: "upright_row",
      name: "Remada alta",
      name_en: "Upright Row",
      category: "strength",
      primary_muscle: "shoulders",
      equipment: "barbell"
    },
    %{
      code: "barbell_shrug",
      name: "Encolhimento com barra",
      name_en: "Barbell Shrug",
      category: "strength",
      primary_muscle: "shoulders",
      equipment: "barbell"
    },
    %{
      code: "dumbbell_shrug",
      name: "Encolhimento com haltere",
      name_en: "Dumbbell Shrug",
      category: "strength",
      primary_muscle: "shoulders",
      equipment: "dumbbell"
    },
    # BICEPS
    %{
      code: "barbell_curl",
      name: "Rosca direta com barra",
      name_en: "Barbell Curl",
      category: "strength",
      primary_muscle: "biceps",
      equipment: "barbell"
    },
    %{
      code: "ez_bar_curl",
      name: "Rosca com barra W",
      name_en: "EZ Bar Curl",
      category: "strength",
      primary_muscle: "biceps",
      equipment: "barbell"
    },
    %{
      code: "dumbbell_curl",
      name: "Rosca direta com haltere",
      name_en: "Dumbbell Curl",
      category: "strength",
      primary_muscle: "biceps",
      equipment: "dumbbell"
    },
    %{
      code: "hammer_curl",
      name: "Rosca martelo",
      name_en: "Hammer Curl",
      category: "strength",
      primary_muscle: "biceps",
      equipment: "dumbbell"
    },
    %{
      code: "incline_dumbbell_curl",
      name: "Rosca inclinada com haltere",
      name_en: "Incline Dumbbell Curl",
      category: "strength",
      primary_muscle: "biceps",
      equipment: "dumbbell"
    },
    %{
      code: "concentration_curl",
      name: "Rosca concentrada",
      name_en: "Concentration Curl",
      category: "strength",
      primary_muscle: "biceps",
      equipment: "dumbbell"
    },
    %{
      code: "preacher_curl",
      name: "Rosca scott",
      name_en: "Preacher Curl",
      category: "strength",
      primary_muscle: "biceps",
      equipment: "barbell"
    },
    %{
      code: "cable_curl",
      name: "Rosca na polia",
      name_en: "Cable Curl",
      category: "strength",
      primary_muscle: "biceps",
      equipment: "cable"
    },
    %{
      code: "high_cable_curl",
      name: "Rosca na polia alta",
      name_en: "High Cable Curl",
      category: "strength",
      primary_muscle: "biceps",
      equipment: "cable"
    },
    %{
      code: "machine_curl",
      name: "Rosca no aparelho",
      name_en: "Machine Curl",
      category: "strength",
      primary_muscle: "biceps",
      equipment: "machine"
    },
    %{
      code: "zottman_curl",
      name: "Rosca Zottman",
      name_en: "Zottman Curl",
      category: "strength",
      primary_muscle: "biceps",
      equipment: "dumbbell"
    },
    %{
      code: "cross_body_hammer_curl",
      name: "Rosca martelo cruzada",
      name_en: "Cross Body Hammer Curl",
      category: "strength",
      primary_muscle: "biceps",
      equipment: "dumbbell"
    },
    %{
      code: "reverse_curl",
      name: "Rosca inversa",
      name_en: "Reverse Curl",
      category: "strength",
      primary_muscle: "biceps",
      equipment: "barbell"
    },
    # TRICEPS
    %{
      code: "skull_crusher",
      name: "Extensão de tríceps com barra",
      name_en: "Skull Crusher",
      category: "strength",
      primary_muscle: "triceps",
      equipment: "barbell"
    },
    %{
      code: "ez_bar_skull_crusher",
      name: "Extensão de tríceps com barra W",
      name_en: "EZ Bar Skull Crusher",
      category: "strength",
      primary_muscle: "triceps",
      equipment: "barbell"
    },
    %{
      code: "tricep_pushdown",
      name: "Tríceps na polia",
      name_en: "Tricep Pushdown",
      category: "strength",
      primary_muscle: "triceps",
      equipment: "cable"
    },
    %{
      code: "overhead_tricep_extension",
      name: "Extensão de tríceps atrás da cabeça",
      name_en: "Overhead Tricep Extension",
      category: "strength",
      primary_muscle: "triceps",
      equipment: "cable"
    },
    %{
      code: "rope_pushdown",
      name: "Tríceps na corda",
      name_en: "Rope Pushdown",
      category: "strength",
      primary_muscle: "triceps",
      equipment: "cable"
    },
    %{
      code: "close_grip_bench_press",
      name: "Supino fechado",
      name_en: "Close-Grip Bench Press",
      category: "strength",
      primary_muscle: "triceps",
      equipment: "barbell"
    },
    %{
      code: "tricep_dips",
      name: "Mergulho para tríceps",
      name_en: "Tricep Dips",
      category: "strength",
      primary_muscle: "triceps",
      equipment: "bodyweight"
    },
    %{
      code: "tricep_kickback",
      name: "Tríceps kickback",
      name_en: "Tricep Kickback",
      category: "strength",
      primary_muscle: "triceps",
      equipment: "dumbbell"
    },
    %{
      code: "overhead_dumbbell_tricep_extension",
      name: "Extensão de tríceps com haltere",
      name_en: "Overhead Dumbbell Tricep Extension",
      category: "strength",
      primary_muscle: "triceps",
      equipment: "dumbbell"
    },
    %{
      code: "machine_tricep_press",
      name: "Tríceps no aparelho",
      name_en: "Machine Tricep Press",
      category: "strength",
      primary_muscle: "triceps",
      equipment: "machine"
    },
    %{
      code: "jm_press",
      name: "JM press",
      name_en: "JM Press",
      category: "strength",
      primary_muscle: "triceps",
      equipment: "barbell"
    },
    # LEGS
    %{
      code: "barbell_squat",
      name: "Agachamento com barra",
      name_en: "Barbell Squat",
      category: "strength",
      primary_muscle: "legs",
      equipment: "barbell"
    },
    %{
      code: "front_squat",
      name: "Agachamento frontal",
      name_en: "Front Squat",
      category: "strength",
      primary_muscle: "legs",
      equipment: "barbell"
    },
    %{
      code: "goblet_squat",
      name: "Agachamento goblet",
      name_en: "Goblet Squat",
      category: "strength",
      primary_muscle: "legs",
      equipment: "kettlebell"
    },
    %{
      code: "leg_press",
      name: "Leg press",
      name_en: "Leg Press",
      category: "strength",
      primary_muscle: "legs",
      equipment: "machine"
    },
    %{
      code: "hack_squat",
      name: "Hack squat",
      name_en: "Hack Squat",
      category: "strength",
      primary_muscle: "legs",
      equipment: "machine"
    },
    %{
      code: "leg_extension",
      name: "Cadeira extensora",
      name_en: "Leg Extension",
      category: "strength",
      primary_muscle: "legs",
      equipment: "machine"
    },
    %{
      code: "lying_leg_curl",
      name: "Cadeira flexora deitado",
      name_en: "Lying Leg Curl",
      category: "strength",
      primary_muscle: "legs",
      equipment: "machine"
    },
    %{
      code: "seated_leg_curl",
      name: "Cadeira flexora sentado",
      name_en: "Seated Leg Curl",
      category: "strength",
      primary_muscle: "legs",
      equipment: "machine"
    },
    %{
      code: "romanian_deadlift_hamstring",
      name: "Stiff com barra para posterior",
      name_en: "Romanian Deadlift Hamstring",
      category: "strength",
      primary_muscle: "legs",
      equipment: "barbell"
    },
    %{
      code: "stiff_leg_deadlift",
      name: "Stiff com barra",
      name_en: "Stiff Leg Deadlift",
      category: "strength",
      primary_muscle: "legs",
      equipment: "barbell"
    },
    %{
      code: "dumbbell_romanian_deadlift",
      name: "Stiff com haltere",
      name_en: "Dumbbell Romanian Deadlift",
      category: "strength",
      primary_muscle: "legs",
      equipment: "dumbbell"
    },
    %{
      code: "barbell_lunge",
      name: "Afundo com barra",
      name_en: "Barbell Lunge",
      category: "strength",
      primary_muscle: "legs",
      equipment: "barbell"
    },
    %{
      code: "dumbbell_lunge",
      name: "Afundo com haltere",
      name_en: "Dumbbell Lunge",
      category: "strength",
      primary_muscle: "legs",
      equipment: "dumbbell"
    },
    %{
      code: "walking_lunge",
      name: "Afundo caminhando",
      name_en: "Walking Lunge",
      category: "strength",
      primary_muscle: "legs",
      equipment: "dumbbell"
    },
    %{
      code: "bulgarian_split_squat",
      name: "Agachamento búlgaro",
      name_en: "Bulgarian Split Squat",
      category: "strength",
      primary_muscle: "legs",
      equipment: "dumbbell"
    },
    %{
      code: "step_up",
      name: "Subida no step",
      name_en: "Step Up",
      category: "strength",
      primary_muscle: "legs",
      equipment: "dumbbell"
    },
    %{
      code: "box_squat",
      name: "Agachamento no box",
      name_en: "Box Squat",
      category: "strength",
      primary_muscle: "legs",
      equipment: "barbell"
    },
    %{
      code: "wall_sit",
      name: "Sentar na parede",
      name_en: "Wall Sit",
      category: "strength",
      primary_muscle: "legs",
      equipment: "bodyweight"
    },
    %{
      code: "nordic_hamstring_curl",
      name: "Nordic curl",
      name_en: "Nordic Hamstring Curl",
      category: "strength",
      primary_muscle: "legs",
      equipment: "bodyweight"
    },
    %{
      code: "cable_pull_through",
      name: "Pull-through na polia",
      name_en: "Cable Pull-Through",
      category: "strength",
      primary_muscle: "legs",
      equipment: "cable"
    },
    %{
      code: "pause_squat",
      name: "Agachamento com pausa",
      name_en: "Pause Squat",
      category: "strength",
      primary_muscle: "legs",
      equipment: "barbell"
    },
    %{
      code: "safety_bar_squat",
      name: "Agachamento com barra de segurança",
      name_en: "Safety Bar Squat",
      category: "strength",
      primary_muscle: "legs",
      equipment: "barbell"
    },
    %{
      code: "single_leg_press",
      name: "Leg press unilateral",
      name_en: "Single Leg Press",
      category: "strength",
      primary_muscle: "legs",
      equipment: "machine"
    },
    %{
      code: "dumbbell_sumo_deadlift",
      name: "Levantamento terra sumo com haltere",
      name_en: "Dumbbell Sumo Deadlift",
      category: "strength",
      primary_muscle: "legs",
      equipment: "dumbbell"
    },
    %{
      code: "banded_squat",
      name: "Agachamento com elástico",
      name_en: "Banded Squat",
      category: "strength",
      primary_muscle: "legs",
      equipment: "resistance_band"
    },
    # GLUTES
    %{
      code: "barbell_hip_thrust",
      name: "Hip thrust com barra",
      name_en: "Barbell Hip Thrust",
      category: "strength",
      primary_muscle: "glutes",
      equipment: "barbell"
    },
    %{
      code: "dumbbell_hip_thrust",
      name: "Hip thrust com haltere",
      name_en: "Dumbbell Hip Thrust",
      category: "strength",
      primary_muscle: "glutes",
      equipment: "dumbbell"
    },
    %{
      code: "glute_bridge",
      name: "Ponte de glúteos",
      name_en: "Glute Bridge",
      category: "strength",
      primary_muscle: "glutes",
      equipment: "bodyweight"
    },
    %{
      code: "barbell_glute_bridge",
      name: "Ponte de glúteos com barra",
      name_en: "Barbell Glute Bridge",
      category: "strength",
      primary_muscle: "glutes",
      equipment: "barbell"
    },
    %{
      code: "cable_glute_kickback",
      name: "Coice na polia",
      name_en: "Cable Glute Kickback",
      category: "strength",
      primary_muscle: "glutes",
      equipment: "cable"
    },
    %{
      code: "donkey_kickback_machine",
      name: "Coice no aparelho",
      name_en: "Donkey Kickback Machine",
      category: "strength",
      primary_muscle: "glutes",
      equipment: "machine"
    },
    %{
      code: "hip_abduction_machine",
      name: "Abdução de quadril no aparelho",
      name_en: "Hip Abduction Machine",
      category: "strength",
      primary_muscle: "glutes",
      equipment: "machine"
    },
    %{
      code: "lateral_band_walk",
      name: "Caminhada lateral com elástico",
      name_en: "Lateral Band Walk",
      category: "strength",
      primary_muscle: "glutes",
      equipment: "resistance_band"
    },
    %{
      code: "banded_hip_thrust",
      name: "Hip thrust com elástico",
      name_en: "Banded Hip Thrust",
      category: "strength",
      primary_muscle: "glutes",
      equipment: "resistance_band"
    },
    %{
      code: "cable_hip_abduction",
      name: "Abdução de quadril na polia",
      name_en: "Cable Hip Abduction",
      category: "strength",
      primary_muscle: "glutes",
      equipment: "cable"
    },
    %{
      code: "frog_pump",
      name: "Frog pump",
      name_en: "Frog Pump",
      category: "strength",
      primary_muscle: "glutes",
      equipment: "bodyweight"
    },
    # CALVES
    %{
      code: "standing_calf_raise",
      name: "Panturrilha em pé",
      name_en: "Standing Calf Raise",
      category: "strength",
      primary_muscle: "calves",
      equipment: "machine"
    },
    %{
      code: "seated_calf_raise",
      name: "Panturrilha sentado",
      name_en: "Seated Calf Raise",
      category: "strength",
      primary_muscle: "calves",
      equipment: "machine"
    },
    %{
      code: "donkey_calf_raise",
      name: "Panturrilha burro",
      name_en: "Donkey Calf Raise",
      category: "strength",
      primary_muscle: "calves",
      equipment: "bodyweight"
    },
    %{
      code: "barbell_calf_raise",
      name: "Panturrilha com barra",
      name_en: "Barbell Calf Raise",
      category: "strength",
      primary_muscle: "calves",
      equipment: "barbell"
    },
    %{
      code: "dumbbell_calf_raise",
      name: "Panturrilha com haltere",
      name_en: "Dumbbell Calf Raise",
      category: "strength",
      primary_muscle: "calves",
      equipment: "dumbbell"
    },
    %{
      code: "single_leg_calf_raise",
      name: "Panturrilha unilateral",
      name_en: "Single Leg Calf Raise",
      category: "strength",
      primary_muscle: "calves",
      equipment: "bodyweight"
    },
    %{
      code: "leg_press_calf_raise",
      name: "Panturrilha no leg press",
      name_en: "Leg Press Calf Raise",
      category: "strength",
      primary_muscle: "calves",
      equipment: "machine"
    },
    # CORE
    %{
      code: "plank",
      name: "Prancha",
      name_en: "Plank",
      category: "strength",
      primary_muscle: "core",
      equipment: "bodyweight"
    },
    %{
      code: "side_plank",
      name: "Prancha lateral",
      name_en: "Side Plank",
      category: "strength",
      primary_muscle: "core",
      equipment: "bodyweight"
    },
    %{
      code: "hollow_body_hold",
      name: "Hollow body",
      name_en: "Hollow Body Hold",
      category: "strength",
      primary_muscle: "core",
      equipment: "bodyweight"
    },
    %{
      code: "crunch",
      name: "Abdominal crunch",
      name_en: "Crunch",
      category: "strength",
      primary_muscle: "core",
      equipment: "bodyweight"
    },
    %{
      code: "bicycle_crunch",
      name: "Abdominal bicicleta",
      name_en: "Bicycle Crunch",
      category: "strength",
      primary_muscle: "core",
      equipment: "bodyweight"
    },
    %{
      code: "reverse_crunch",
      name: "Abdominal reverso",
      name_en: "Reverse Crunch",
      category: "strength",
      primary_muscle: "core",
      equipment: "bodyweight"
    },
    %{
      code: "decline_crunch",
      name: "Abdominal declinado",
      name_en: "Decline Crunch",
      category: "strength",
      primary_muscle: "core",
      equipment: "bodyweight"
    },
    %{
      code: "hanging_leg_raise",
      name: "Elevação de pernas na barra",
      name_en: "Hanging Leg Raise",
      category: "strength",
      primary_muscle: "core",
      equipment: "bodyweight"
    },
    %{
      code: "hanging_knee_raise",
      name: "Elevação de joelhos na barra",
      name_en: "Hanging Knee Raise",
      category: "strength",
      primary_muscle: "core",
      equipment: "bodyweight"
    },
    %{
      code: "ab_wheel_rollout",
      name: "Roda abdominal",
      name_en: "Ab Wheel Rollout",
      category: "strength",
      primary_muscle: "core",
      equipment: "other"
    },
    %{
      code: "cable_crunch",
      name: "Crunch na polia",
      name_en: "Cable Crunch",
      category: "strength",
      primary_muscle: "core",
      equipment: "cable"
    },
    %{
      code: "russian_twist",
      name: "Rotação russa",
      name_en: "Russian Twist",
      category: "strength",
      primary_muscle: "core",
      equipment: "other"
    },
    %{
      code: "woodchop_cable",
      name: "Woodchop na polia",
      name_en: "Woodchop Cable",
      category: "strength",
      primary_muscle: "core",
      equipment: "cable"
    },
    %{
      code: "dead_bug",
      name: "Dead bug",
      name_en: "Dead Bug",
      category: "strength",
      primary_muscle: "core",
      equipment: "bodyweight"
    },
    %{
      code: "dragon_flag",
      name: "Bandeira do dragão",
      name_en: "Dragon Flag",
      category: "strength",
      primary_muscle: "core",
      equipment: "bodyweight"
    },
    %{
      code: "toes_to_bar",
      name: "Pés na barra",
      name_en: "Toes to Bar",
      category: "strength",
      primary_muscle: "core",
      equipment: "bodyweight"
    },
    %{
      code: "sit_up",
      name: "Abdominal completo",
      name_en: "Sit-Up",
      category: "strength",
      primary_muscle: "core",
      equipment: "bodyweight"
    },
    %{
      code: "v_up",
      name: "V-up",
      name_en: "V-Up",
      category: "strength",
      primary_muscle: "core",
      equipment: "bodyweight"
    },
    %{
      code: "pallof_press",
      name: "Pallof press",
      name_en: "Pallof Press",
      category: "strength",
      primary_muscle: "core",
      equipment: "cable"
    },
    %{
      code: "copenhagen_plank",
      name: "Prancha de Copenhague",
      name_en: "Copenhagen Plank",
      category: "strength",
      primary_muscle: "core",
      equipment: "bodyweight"
    },
    %{
      code: "weighted_plank",
      name: "Prancha com peso",
      name_en: "Weighted Plank",
      category: "strength",
      primary_muscle: "core",
      equipment: "other"
    },
    # FOREARMS
    %{
      code: "wrist_curl",
      name: "Flexão de punho",
      name_en: "Wrist Curl",
      category: "strength",
      primary_muscle: "forearms",
      equipment: "barbell"
    },
    %{
      code: "reverse_wrist_curl",
      name: "Extensão de punho",
      name_en: "Reverse Wrist Curl",
      category: "strength",
      primary_muscle: "forearms",
      equipment: "barbell"
    },
    %{
      code: "wrist_roller",
      name: "Rolo de punho",
      name_en: "Wrist Roller",
      category: "strength",
      primary_muscle: "forearms",
      equipment: "other"
    },
    %{
      code: "farmers_walk",
      name: "Caminhada do fazendeiro",
      name_en: "Farmer's Walk",
      category: "strength",
      primary_muscle: "forearms",
      equipment: "dumbbell"
    },
    %{
      code: "dead_hang",
      name: "Dead hang",
      name_en: "Dead Hang",
      category: "strength",
      primary_muscle: "forearms",
      equipment: "bodyweight"
    },
    %{
      code: "plate_pinch",
      name: "Pinça de disco",
      name_en: "Plate Pinch",
      category: "strength",
      primary_muscle: "forearms",
      equipment: "other"
    },
    # OLYMPIC
    %{
      code: "clean_and_jerk",
      name: "Arranco e arremesso",
      name_en: "Clean and Jerk",
      category: "olympic",
      primary_muscle: "full_body",
      equipment: "barbell"
    },
    %{
      code: "snatch",
      name: "Arranco",
      name_en: "Snatch",
      category: "olympic",
      primary_muscle: "full_body",
      equipment: "barbell"
    },
    %{
      code: "power_clean",
      name: "Power clean",
      name_en: "Power Clean",
      category: "olympic",
      primary_muscle: "full_body",
      equipment: "barbell"
    },
    %{
      code: "hang_clean",
      name: "Hang clean",
      name_en: "Hang Clean",
      category: "olympic",
      primary_muscle: "full_body",
      equipment: "barbell"
    },
    %{
      code: "power_snatch",
      name: "Power snatch",
      name_en: "Power Snatch",
      category: "olympic",
      primary_muscle: "full_body",
      equipment: "barbell"
    },
    %{
      code: "hang_snatch",
      name: "Hang snatch",
      name_en: "Hang Snatch",
      category: "olympic",
      primary_muscle: "full_body",
      equipment: "barbell"
    },
    %{
      code: "push_press",
      name: "Push press",
      name_en: "Push Press",
      category: "olympic",
      primary_muscle: "shoulders",
      equipment: "barbell"
    },
    %{
      code: "push_jerk",
      name: "Push jerk",
      name_en: "Push Jerk",
      category: "olympic",
      primary_muscle: "shoulders",
      equipment: "barbell"
    },
    %{
      code: "clean_pull",
      name: "Clean pull",
      name_en: "Clean Pull",
      category: "olympic",
      primary_muscle: "back",
      equipment: "barbell"
    },
    %{
      code: "snatch_pull",
      name: "Snatch pull",
      name_en: "Snatch Pull",
      category: "olympic",
      primary_muscle: "back",
      equipment: "barbell"
    },
    # PLYOMETRIC / FULL BODY
    %{
      code: "burpee",
      name: "Burpee",
      name_en: "Burpee",
      category: "plyometric",
      primary_muscle: "full_body",
      equipment: "bodyweight"
    },
    %{
      code: "box_jump",
      name: "Salto no box",
      name_en: "Box Jump",
      category: "plyometric",
      primary_muscle: "legs",
      equipment: "other"
    },
    %{
      code: "jump_squat",
      name: "Agachamento com salto",
      name_en: "Jump Squat",
      category: "plyometric",
      primary_muscle: "legs",
      equipment: "bodyweight"
    },
    %{
      code: "broad_jump",
      name: "Salto em distância",
      name_en: "Broad Jump",
      category: "plyometric",
      primary_muscle: "legs",
      equipment: "bodyweight"
    },
    %{
      code: "depth_jump",
      name: "Salto em profundidade",
      name_en: "Depth Jump",
      category: "plyometric",
      primary_muscle: "legs",
      equipment: "other"
    },
    %{
      code: "lateral_box_jump",
      name: "Salto lateral no box",
      name_en: "Lateral Box Jump",
      category: "plyometric",
      primary_muscle: "legs",
      equipment: "other"
    },
    %{
      code: "plyo_push_up",
      name: "Flexão com salto",
      name_en: "Plyo Push-Up",
      category: "plyometric",
      primary_muscle: "chest",
      equipment: "bodyweight"
    },
    %{
      code: "medicine_ball_slam",
      name: "Slam com medicine ball",
      name_en: "Medicine Ball Slam",
      category: "plyometric",
      primary_muscle: "full_body",
      equipment: "other"
    },
    %{
      code: "battle_ropes",
      name: "Cordas de batalha",
      name_en: "Battle Ropes",
      category: "plyometric",
      primary_muscle: "full_body",
      equipment: "other"
    },
    %{
      code: "turkish_get_up",
      name: "Turkish get-up",
      name_en: "Turkish Get-Up",
      category: "strength",
      primary_muscle: "full_body",
      equipment: "kettlebell"
    },
    %{
      code: "kettlebell_swing",
      name: "Kettlebell swing",
      name_en: "Kettlebell Swing",
      category: "strength",
      primary_muscle: "full_body",
      equipment: "kettlebell"
    },
    %{
      code: "kettlebell_goblet_squat",
      name: "Agachamento goblet com kettlebell",
      name_en: "Kettlebell Goblet Squat",
      category: "strength",
      primary_muscle: "legs",
      equipment: "kettlebell"
    },
    %{
      code: "kettlebell_clean",
      name: "Kettlebell clean",
      name_en: "Kettlebell Clean",
      category: "strength",
      primary_muscle: "full_body",
      equipment: "kettlebell"
    },
    %{
      code: "kettlebell_press",
      name: "Kettlebell press",
      name_en: "Kettlebell Press",
      category: "strength",
      primary_muscle: "shoulders",
      equipment: "kettlebell"
    },
    %{
      code: "kettlebell_snatch",
      name: "Kettlebell snatch",
      name_en: "Kettlebell Snatch",
      category: "strength",
      primary_muscle: "full_body",
      equipment: "kettlebell"
    },
    %{
      code: "sled_push",
      name: "Empurrar trenó",
      name_en: "Sled Push",
      category: "strength",
      primary_muscle: "full_body",
      equipment: "other"
    },
    %{
      code: "sled_pull",
      name: "Puxar trenó",
      name_en: "Sled Pull",
      category: "strength",
      primary_muscle: "full_body",
      equipment: "other"
    },
    # CARDIO
    %{
      code: "treadmill_run",
      name: "Corrida na esteira",
      name_en: "Treadmill Run",
      category: "cardio",
      primary_muscle: "cardio",
      equipment: "machine"
    },
    %{
      code: "treadmill_walk",
      name: "Caminhada na esteira",
      name_en: "Treadmill Walk",
      category: "cardio",
      primary_muscle: "cardio",
      equipment: "machine"
    },
    %{
      code: "elliptical",
      name: "Elíptico",
      name_en: "Elliptical",
      category: "cardio",
      primary_muscle: "cardio",
      equipment: "machine"
    },
    %{
      code: "rowing_machine",
      name: "Remo ergométrico",
      name_en: "Rowing Machine",
      category: "cardio",
      primary_muscle: "cardio",
      equipment: "machine"
    },
    %{
      code: "stationary_bike",
      name: "Bike ergométrica",
      name_en: "Stationary Bike",
      category: "cardio",
      primary_muscle: "cardio",
      equipment: "machine"
    },
    %{
      code: "assault_bike",
      name: "Assault bike",
      name_en: "Assault Bike",
      category: "cardio",
      primary_muscle: "cardio",
      equipment: "machine"
    },
    %{
      code: "stair_climber",
      name: "Escada",
      name_en: "Stair Climber",
      category: "cardio",
      primary_muscle: "cardio",
      equipment: "machine"
    },
    %{
      code: "jump_rope",
      name: "Pular corda",
      name_en: "Jump Rope",
      category: "cardio",
      primary_muscle: "cardio",
      equipment: "other"
    },
    %{
      code: "cycling_outdoor",
      name: "Ciclismo ao ar livre",
      name_en: "Cycling Outdoor",
      category: "cardio",
      primary_muscle: "cardio",
      equipment: "other"
    },
    %{
      code: "running_outdoor",
      name: "Corrida ao ar livre",
      name_en: "Running Outdoor",
      category: "cardio",
      primary_muscle: "cardio",
      equipment: "other"
    },
    %{
      code: "swimming",
      name: "Natação",
      name_en: "Swimming",
      category: "cardio",
      primary_muscle: "cardio",
      equipment: "other"
    },
    %{
      code: "hiking",
      name: "Caminhada na natureza",
      name_en: "Hiking",
      category: "cardio",
      primary_muscle: "cardio",
      equipment: "other"
    },
    # FLEXIBILITY
    %{
      code: "hip_flexor_stretch",
      name: "Alongamento de flexores do quadril",
      name_en: "Hip Flexor Stretch",
      category: "flexibility",
      primary_muscle: "legs",
      equipment: "bodyweight"
    },
    %{
      code: "hamstring_stretch",
      name: "Alongamento de posterior",
      name_en: "Hamstring Stretch",
      category: "flexibility",
      primary_muscle: "legs",
      equipment: "bodyweight"
    },
    %{
      code: "quad_stretch",
      name: "Alongamento de quadríceps",
      name_en: "Quad Stretch",
      category: "flexibility",
      primary_muscle: "legs",
      equipment: "bodyweight"
    },
    %{
      code: "calf_stretch",
      name: "Alongamento de panturrilha",
      name_en: "Calf Stretch",
      category: "flexibility",
      primary_muscle: "calves",
      equipment: "bodyweight"
    },
    %{
      code: "chest_stretch",
      name: "Alongamento de peitoral",
      name_en: "Chest Stretch",
      category: "flexibility",
      primary_muscle: "chest",
      equipment: "bodyweight"
    },
    %{
      code: "shoulder_stretch",
      name: "Alongamento de ombros",
      name_en: "Shoulder Stretch",
      category: "flexibility",
      primary_muscle: "shoulders",
      equipment: "bodyweight"
    },
    %{
      code: "lat_stretch",
      name: "Alongamento de dorsais",
      name_en: "Lat Stretch",
      category: "flexibility",
      primary_muscle: "back",
      equipment: "bodyweight"
    },
    %{
      code: "thoracic_extension",
      name: "Extensão torácica",
      name_en: "Thoracic Extension",
      category: "flexibility",
      primary_muscle: "back",
      equipment: "other"
    },
    %{
      code: "pigeon_pose",
      name: "Postura do pombo",
      name_en: "Pigeon Pose",
      category: "flexibility",
      primary_muscle: "glutes",
      equipment: "bodyweight"
    },
    %{
      code: "worlds_greatest_stretch",
      name: "O maior alongamento do mundo",
      name_en: "World's Greatest Stretch",
      category: "flexibility",
      primary_muscle: "full_body",
      equipment: "bodyweight"
    },
    # ADDITIONAL
    %{
      code: "barbell_row_underhand",
      name: "Remada com barra pegada supinada",
      name_en: "Barbell Row Underhand",
      category: "strength",
      primary_muscle: "back",
      equipment: "barbell"
    },
    %{
      code: "one_arm_dumbbell_row",
      name: "Remada unilateral com haltere",
      name_en: "One Arm Dumbbell Row",
      category: "strength",
      primary_muscle: "back",
      equipment: "dumbbell"
    },
    %{
      code: "hex_bar_deadlift",
      name: "Levantamento terra com barra hexagonal",
      name_en: "Hex Bar Deadlift",
      category: "strength",
      primary_muscle: "back",
      equipment: "barbell"
    },
    %{
      code: "dumbbell_deadlift",
      name: "Levantamento terra com haltere",
      name_en: "Dumbbell Deadlift",
      category: "strength",
      primary_muscle: "back",
      equipment: "dumbbell"
    },
    %{
      code: "trap_bar_deadlift",
      name: "Levantamento terra com barra trapézio",
      name_en: "Trap Bar Deadlift",
      category: "strength",
      primary_muscle: "back",
      equipment: "barbell"
    },
    %{
      code: "resistance_band_pull_apart",
      name: "Abertura com elástico",
      name_en: "Resistance Band Pull Apart",
      category: "strength",
      primary_muscle: "shoulders",
      equipment: "resistance_band"
    },
    %{
      code: "band_bicep_curl",
      name: "Rosca com elástico",
      name_en: "Band Bicep Curl",
      category: "strength",
      primary_muscle: "biceps",
      equipment: "resistance_band"
    },
    %{
      code: "band_tricep_extension",
      name: "Extensão de tríceps com elástico",
      name_en: "Band Tricep Extension",
      category: "strength",
      primary_muscle: "triceps",
      equipment: "resistance_band"
    },
    %{
      code: "cable_woodchop_diagonal",
      name: "Woodchop diagonal na polia",
      name_en: "Cable Woodchop Diagonal",
      category: "strength",
      primary_muscle: "core",
      equipment: "cable"
    }
  ]

  @doc "Seeds exercises idempotently (by code or by English name for existing DBs). Returns {inserted, updated}."
  def seed_exercises do
    {inserted, updated} =
      Enum.reduce(@exercises, {0, 0}, fn attrs, {ins, upd} ->
        code = attrs.code
        name_pt = attrs.name
        name_en = attrs.name_en

        case Repo.get_by(Exercise, code: code) do
          existing when not is_nil(existing) ->
            existing
            |> Exercise.changeset(%{
              name: name_pt,
              category: attrs.category,
              primary_muscle: attrs.primary_muscle,
              equipment: attrs.equipment
            })
            |> Repo.update!()

            {ins, upd + 1}

          nil ->
            case name_en && Repo.get_by(Exercise, name: name_en) do
              existing when not is_nil(existing) ->
                existing
                |> Exercise.changeset(%{
                  code: code,
                  name: name_pt,
                  category: attrs.category,
                  primary_muscle: attrs.primary_muscle,
                  equipment: attrs.equipment
                })
                |> Repo.update!()

                {ins, upd + 1}

              _ ->
                %Exercise{}
                |> Exercise.changeset(%{
                  code: code,
                  name: name_pt,
                  category: attrs.category,
                  primary_muscle: attrs.primary_muscle,
                  equipment: attrs.equipment,
                  is_custom: false
                })
                |> Repo.insert!()

                {ins + 1, upd}
            end
        end
      end)

    {inserted, updated}
  end
end
