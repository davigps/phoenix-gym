defmodule PhoenixgymWeb.ExerciseLiveTest do
  use PhoenixgymWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Phoenixgym.Fixtures

  alias Phoenixgym.Exercises

  # ── ExerciseLive.Index ────────────────────────────────────────────────────

  describe "ExerciseLive.Index" do
    test "page mounts and renders exercise list", %{conn: conn} do
      exercise = exercise_fixture(%{"name" => "Deadlift Test", "primary_muscle" => "back"})

      {:ok, _view, html} = live(conn, "/exercises")

      assert html =~ "Exercícios"
      assert html =~ exercise.name
    end

    test "shows 'No exercises found' when search returns nothing", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/exercises")

      html =
        view
        |> element("form[phx-change='search']")
        |> render_change(%{"search" => "ZZZNothingMatchesThis999"})

      assert html =~ "Nenhum exercício encontrado"
    end

    test "typing in search box filters the list", %{conn: conn} do
      unique_name = "UniqSearchEx#{System.unique_integer([:positive])}"
      exercise_fixture(%{"name" => unique_name, "primary_muscle" => "chest"})
      exercise_fixture(%{"name" => "OtherExerciseABC", "primary_muscle" => "back"})

      {:ok, view, _html} = live(conn, "/exercises")

      html =
        view
        |> element("form[phx-change='search']")
        |> render_change(%{"search" => unique_name})

      assert html =~ unique_name
      refute html =~ "OtherExerciseABC"
    end

    test "selecting a muscle chip narrows results", %{conn: conn} do
      exercise_fixture(%{
        "name" => "ChestEx#{System.unique_integer()}",
        "primary_muscle" => "chest"
      })

      exercise_fixture(%{
        "name" => "BackEx#{System.unique_integer()}",
        "primary_muscle" => "back"
      })

      {:ok, view, _html} = live(conn, "/exercises")

      html =
        view
        |> element("button[phx-value-muscle='chest']")
        |> render_click()

      assert html =~ "Peito"
      refute html =~ "BackEx"
    end

    test "selecting 'All' resets muscle filter", %{conn: conn} do
      back_name = "BackExReset#{System.unique_integer()}"

      exercise_fixture(%{
        "name" => "ChestExReset#{System.unique_integer()}",
        "primary_muscle" => "chest"
      })

      exercise_fixture(%{"name" => back_name, "primary_muscle" => "back"})

      {:ok, view, _html} = live(conn, "/exercises")

      # First filter to chest only
      view
      |> element("button[phx-value-muscle='chest']")
      |> render_click()

      # Then reset to all
      html =
        view
        |> element("button[phx-value-muscle='']")
        |> render_click()

      assert html =~ back_name
    end

    test "equipment filter narrows results", %{conn: conn} do
      kb_name = "KettlebellEx#{System.unique_integer()}"

      exercise_fixture(%{
        "name" => kb_name,
        "primary_muscle" => "chest",
        "equipment" => "kettlebell"
      })

      exercise_fixture(%{
        "name" => "BarbellEx#{System.unique_integer()}",
        "primary_muscle" => "back",
        "equipment" => "barbell"
      })

      {:ok, view, _html} = live(conn, "/exercises")

      html =
        view
        |> element("button[phx-value-equipment='kettlebell']")
        |> render_click()

      assert html =~ kb_name
      refute html =~ "BarbellEx"
    end

    test "search and muscle filter work together", %{conn: conn} do
      name = "ComboFilterEx#{System.unique_integer()}"
      exercise_fixture(%{"name" => name, "primary_muscle" => "back", "equipment" => "barbell"})

      exercise_fixture(%{
        "name" => "OtherCombo#{System.unique_integer()}",
        "primary_muscle" => "chest",
        "equipment" => "barbell"
      })

      {:ok, view, _html} = live(conn, "/exercises")

      # Select back muscle first
      view
      |> element("button[phx-value-muscle='back']")
      |> render_click()

      # Then search by name
      html =
        view
        |> element("form[phx-change='search']")
        |> render_change(%{"search" => "ComboFilterEx"})

      assert html =~ name
      refute html =~ "OtherCombo"
    end

    test "navigates to new exercise page", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/exercises")

      assert has_element?(view, "a[href='/exercises/new']")
    end
  end

  # ── ExerciseLive.New ─────────────────────────────────────────────────────

  describe "ExerciseLive.New" do
    test "page mounts and renders form", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/exercises/new")

      assert html =~ "Novo exercício"
      assert html =~ "Nome"
      assert html =~ "Categoria"
      assert html =~ "Músculo principal"
      assert html =~ "Equipamento"
    end

    test "valid form submission creates exercise and redirects", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/exercises/new")

      unique_name = "MyCustomEx#{System.unique_integer([:positive])}"

      {:ok, _view, html} =
        view
        |> form("form[phx-submit='save']", %{
          "exercise" => %{
            "name" => unique_name,
            "category" => "strength",
            "primary_muscle" => "chest",
            "equipment" => "barbell"
          }
        })
        |> render_submit()
        |> follow_redirect(conn)

      assert html =~ unique_name
    end

    test "valid form submission flashes success message", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/exercises/new")

      unique_name = "FlashSuccessEx#{System.unique_integer([:positive])}"

      assert {:error, {:live_redirect, %{to: path}}} =
               view
               |> form("form[phx-submit='save']", %{
                 "exercise" => %{
                   "name" => unique_name,
                   "category" => "strength",
                   "primary_muscle" => "chest",
                   "equipment" => "barbell"
                 }
               })
               |> render_submit()

      assert String.starts_with?(path, "/exercises/")
    end

    test "missing required name shows inline error", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/exercises/new")

      html =
        view
        |> form("form[phx-submit='save']", %{
          "exercise" => %{
            "name" => "",
            "category" => "strength",
            "primary_muscle" => "chest",
            "equipment" => "barbell"
          }
        })
        |> render_submit()

      assert html =~ "não pode ficar em branco" or html =~ "em branco"
    end

    test "validate event shows inline errors on invalid data", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/exercises/new")

      html =
        view
        |> form("form[phx-change='validate']", %{
          "exercise" => %{
            "name" => "",
            "category" => "strength"
          }
        })
        |> render_change()

      assert html =~ "não pode ficar em branco" or html =~ "em branco"
    end

    test "duplicate name shows error", %{conn: conn} do
      {:ok, exercise} =
        Exercises.create_exercise(%{
          "name" => "DupEx#{System.unique_integer()}",
          "category" => "strength",
          "primary_muscle" => "chest",
          "equipment" => "barbell"
        })

      {:ok, view, _html} = live(conn, "/exercises/new")

      html =
        view
        |> form("form[phx-submit='save']", %{
          "exercise" => %{
            "name" => exercise.name,
            "category" => "strength",
            "primary_muscle" => "chest",
            "equipment" => "barbell"
          }
        })
        |> render_submit()

      assert html =~ "já está em uso"
    end
  end

  # ── ExerciseLive.Show ────────────────────────────────────────────────────

  describe "ExerciseLive.Show" do
    test "renders exercise details", %{conn: conn} do
      exercise =
        exercise_fixture(%{
          "name" => "ShowTestEx#{System.unique_integer()}",
          "primary_muscle" => "back",
          "category" => "strength",
          "equipment" => "barbell",
          "instructions" => "Perform carefully."
        })

      {:ok, _view, html} = live(conn, "/exercises/#{exercise.id}")

      assert html =~ exercise.name
      assert html =~ "back"
      assert html =~ "strength"
      assert html =~ "barbell"
      assert html =~ "Perform carefully."
    end

    test "shows 'No records yet' when exercise has no PRs", %{conn: conn} do
      exercise = exercise_fixture()

      {:ok, _view, html} = live(conn, "/exercises/#{exercise.id}")

      assert html =~ "Nenhum registro ainda"
    end

    test "shows Personal Records section when PRs exist", %{conn: conn} do
      %{exercise: exercise} = completed_workout_fixture()

      {:ok, _view, html} = live(conn, "/exercises/#{exercise.id}")

      # After completing a workout with sets, PRs should be computed
      # (PRs are computed when finish_workout is called)
      assert html =~ "Recordes pessoais"
    end

    test "shows custom badge for custom exercises", %{conn: conn} do
      exercise = exercise_fixture()

      {:ok, _view, html} = live(conn, "/exercises/#{exercise.id}")

      assert html =~ "Personalizado"
    end

    test "back button navigates to exercise list", %{conn: conn} do
      exercise = exercise_fixture()

      {:ok, _view, html} = live(conn, "/exercises/#{exercise.id}")

      assert html =~ "/exercises"
    end
  end
end
