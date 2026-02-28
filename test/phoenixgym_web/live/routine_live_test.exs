defmodule PhoenixgymWeb.RoutineLiveTest do
  use PhoenixgymWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Phoenixgym.Fixtures

  alias Phoenixgym.Routines

  # ── RoutineLive.Index ─────────────────────────────────────────────────────

  describe "RoutineLive.Index" do
    setup :register_and_log_in_user

    test "shows empty state CTA when no routines exist", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/routines")

      assert html =~ "Nenhuma rotina ainda"
      assert html =~ "Nova rotina"
    end

    test "lists routines as cards with their names", %{conn: conn} do
      routine = routine_fixture(%{"name" => "PushDay#{System.unique_integer()}"})

      {:ok, _view, html} = live(conn, "/routines")

      assert html =~ routine.name
    end

    test "shows correct exercise count on routine card", %{conn: conn} do
      routine = routine_fixture()
      ex1 = exercise_fixture()
      ex2 = exercise_fixture()
      Routines.add_exercise_to_routine(routine.id, ex1.id)
      Routines.add_exercise_to_routine(routine.id, ex2.id)

      {:ok, _view, html} = live(conn, "/routines")

      assert html =~ "2 exercícios"
    end

    test "shows 0 exercises for an empty routine", %{conn: conn} do
      routine_fixture()

      {:ok, _view, html} = live(conn, "/routines")

      assert html =~ "0 exercícios"
    end

    test "links to /routines/new for creating routines", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/routines")

      assert html =~ "/routines/new"
    end

    test "inline new routine form shown when live_action is :new", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/routines/new")

      assert html =~ "Nova rotina"
    end

    test "creating a routine redirects to its edit page", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/routines/new")

      assert {:error, {:live_redirect, %{to: path}}} =
               view
               |> form("form[phx-submit='create']", %{
                 "routine" => %{"name" => "MyNewRoutine#{System.unique_integer()}"}
               })
               |> render_submit()

      assert path =~ ~r|/routines/\d+/edit|
    end

    test "creating routine with empty name shows error", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/routines/new")

      html =
        view
        |> form("form[phx-submit='create']", %{"routine" => %{"name" => ""}})
        |> render_submit()

      assert html =~ "não pode ficar em branco" or html =~ "em branco"
    end
  end

  # ── RoutineLive.Show ──────────────────────────────────────────────────────

  describe "RoutineLive.Show" do
    setup :register_and_log_in_user

    test "renders routine name and exercises", %{conn: conn} do
      routine = routine_fixture(%{"name" => "ShowTestRoutine#{System.unique_integer()}"})
      exercise = exercise_fixture(%{"name" => "ShowTestExercise#{System.unique_integer()}"})
      Routines.add_exercise_to_routine(routine.id, exercise.id)

      {:ok, _view, html} = live(conn, "/routines/#{routine.id}")

      assert html =~ routine.name
      assert html =~ exercise.name
    end

    test "shows total exercise count", %{conn: conn} do
      routine = routine_fixture()
      ex1 = exercise_fixture()
      ex2 = exercise_fixture()
      Routines.add_exercise_to_routine(routine.id, ex1.id)
      Routines.add_exercise_to_routine(routine.id, ex2.id)

      {:ok, _view, html} = live(conn, "/routines/#{routine.id}")

      assert html =~ "2 exercícios"
    end

    test "shows routine notes when present", %{conn: conn} do
      routine =
        routine_fixture(%{
          "name" => "NotedRoutine#{System.unique_integer()}",
          "notes" => "My special training notes"
        })

      {:ok, _view, html} = live(conn, "/routines/#{routine.id}")

      assert html =~ "My special training notes"
    end

    test "shows target sets for each exercise", %{conn: conn} do
      routine = routine_fixture()
      exercise = exercise_fixture()
      {:ok, re} = Routines.add_exercise_to_routine(routine.id, exercise.id)
      Routines.update_routine_exercise(re, %{target_sets: 4})

      {:ok, _view, html} = live(conn, "/routines/#{routine.id}")

      assert html =~ "4 séries"
    end

    test "edit button links to edit page", %{conn: conn} do
      routine = routine_fixture()

      {:ok, _view, html} = live(conn, "/routines/#{routine.id}")

      assert html =~ "/routines/#{routine.id}/edit"
    end

    test "start_workout redirects to /workout/active", %{conn: conn} do
      routine = routine_fixture()

      {:ok, view, _html} = live(conn, "/routines/#{routine.id}")

      assert {:error, {:live_redirect, %{to: "/workout/active"}}} =
               view |> element("button[phx-click='start_workout']") |> render_click()
    end

    test "duplicate creates a copy and redirects to its edit page", %{conn: conn} do
      routine = routine_fixture(%{"name" => "OriginalToDuplicate#{System.unique_integer()}"})

      {:ok, view, _html} = live(conn, "/routines/#{routine.id}")

      assert {:error, {:live_redirect, %{to: path}}} =
               view |> element("button[phx-click='duplicate']") |> render_click()

      assert path =~ ~r|/routines/\d+/edit|

      routines = Routines.list_routines()
      assert Enum.any?(routines, &String.contains?(&1.name, "Cópia"))
    end

    test "confirm_delete event removes routine and redirects to list", %{conn: conn} do
      routine = routine_fixture(%{"name" => "ToDelete#{System.unique_integer()}"})

      {:ok, view, _html} = live(conn, "/routines/#{routine.id}")

      assert {:error, {:live_redirect, %{to: "/routines"}}} =
               view |> element("button[phx-click='confirm_delete']") |> render_click()

      assert_raise Ecto.NoResultsError, fn -> Routines.get_routine!(routine.id) end
    end

    test "delete button opens confirmation dialog (modal present in HTML)", %{conn: conn} do
      routine = routine_fixture()

      {:ok, _view, html} = live(conn, "/routines/#{routine.id}")

      assert html =~ "confirm_delete"
      assert html =~ "Excluir"
    end
  end

  # ── RoutineLive.Edit ──────────────────────────────────────────────────────

  describe "RoutineLive.Edit" do
    setup :register_and_log_in_user

    test "mounts and shows routine name and notes form", %{conn: conn} do
      routine =
        routine_fixture(%{
          "name" => "EditMeRoutine#{System.unique_integer()}",
          "notes" => "Edit notes here"
        })

      {:ok, _view, html} = live(conn, "/routines/#{routine.id}/edit")

      assert html =~ "Editar rotina"
      assert html =~ "EditMeRoutine"
      assert html =~ "Edit notes here"
    end

    test "add exercise via picker appends to list", %{conn: conn} do
      routine = routine_fixture()
      exercise = exercise_fixture(%{"name" => "PickerAdd#{System.unique_integer()}"})

      {:ok, view, _html} = live(conn, "/routines/#{routine.id}/edit")

      # Open the picker
      view |> element("button[phx-click='show_picker']") |> render_click()

      # Select the exercise
      html =
        view
        |> element("button[phx-click='add_exercise'][phx-value-id='#{exercise.id}']")
        |> render_click()

      assert html =~ exercise.name
    end

    test "remove exercise removes its row from the list", %{conn: conn} do
      routine = routine_fixture()
      exercise = exercise_fixture(%{"name" => "RemoveMe#{System.unique_integer()}"})
      {:ok, re} = Routines.add_exercise_to_routine(routine.id, exercise.id)

      {:ok, view, _html} = live(conn, "/routines/#{routine.id}/edit")

      view
      |> element("button[phx-click='remove_exercise'][phx-value-id='#{re.id}']")
      |> render_click()

      # Verify removal persisted to DB
      updated = Routines.get_routine!(routine.id)
      assert updated.routine_exercises == []
    end

    test "move_down reorders exercise to next position", %{conn: conn} do
      routine = routine_fixture()
      ex1 = exercise_fixture(%{"name" => "FirstEx#{System.unique_integer()}"})
      ex2 = exercise_fixture(%{"name" => "SecondEx#{System.unique_integer()}"})
      Routines.add_exercise_to_routine(routine.id, ex1.id)
      Routines.add_exercise_to_routine(routine.id, ex2.id)

      {:ok, view, _html} = live(conn, "/routines/#{routine.id}/edit")

      view
      |> element("button[phx-click='move_down'][phx-value-id='#{ex1.id}']")
      |> render_click()

      updated = Routines.get_routine!(routine.id)
      ordered_ids = Enum.map(updated.routine_exercises, & &1.exercise_id)
      assert hd(ordered_ids) == ex2.id
    end

    test "move_up reorders exercise to previous position", %{conn: conn} do
      routine = routine_fixture()
      ex1 = exercise_fixture(%{"name" => "MoveUpFirst#{System.unique_integer()}"})
      ex2 = exercise_fixture(%{"name" => "MoveUpSecond#{System.unique_integer()}"})
      Routines.add_exercise_to_routine(routine.id, ex1.id)
      Routines.add_exercise_to_routine(routine.id, ex2.id)

      {:ok, view, _html} = live(conn, "/routines/#{routine.id}/edit")

      view
      |> element("button[phx-click='move_up'][phx-value-id='#{ex2.id}']")
      |> render_click()

      updated = Routines.get_routine!(routine.id)
      ordered_ids = Enum.map(updated.routine_exercises, & &1.exercise_id)
      assert hd(ordered_ids) == ex2.id
    end

    test "save persists name change and redirects to show page", %{conn: conn} do
      routine = routine_fixture(%{"name" => "BeforeSave#{System.unique_integer()}"})

      {:ok, view, _html} = live(conn, "/routines/#{routine.id}/edit")

      # Update the form
      view
      |> element("form[phx-change='update_form']")
      |> render_change(%{"routine" => %{"name" => "AfterSave", "notes" => ""}})

      assert {:error, {:live_redirect, %{to: path}}} =
               view |> element("button[phx-click='save']") |> render_click()

      assert path == "/routines/#{routine.id}"

      updated = Routines.get_routine!(routine.id)
      assert updated.name == "AfterSave"
    end

    test "save with invalid name shows error", %{conn: conn} do
      routine = routine_fixture(%{"name" => "ValidName#{System.unique_integer()}"})

      {:ok, view, _html} = live(conn, "/routines/#{routine.id}/edit")

      view
      |> element("form[phx-change='update_form']")
      |> render_change(%{"routine" => %{"name" => "", "notes" => ""}})

      html = view |> element("button[phx-click='save']") |> render_click()

      assert html =~ "não pode ficar em branco" or html =~ "em branco"
    end

    test "picker search filters exercises by name", %{conn: conn} do
      routine = routine_fixture()
      unique = "PkrSearchEx#{System.unique_integer()}"
      exercise_fixture(%{"name" => unique, "primary_muscle" => "chest"})
      exercise_fixture(%{"name" => "OtherUnrelatedName#{System.unique_integer()}"})

      {:ok, view, _html} = live(conn, "/routines/#{routine.id}/edit")

      # Open picker
      view |> element("button[phx-click='show_picker']") |> render_click()

      html =
        view
        |> element("input[phx-keyup='picker_search']")
        |> render_keyup(%{"value" => unique})

      assert html =~ unique
      refute html =~ "OtherUnrelated"
    end

    test "update_sets changes target_sets for an exercise", %{conn: conn} do
      routine = routine_fixture()
      exercise = exercise_fixture()
      {:ok, re} = Routines.add_exercise_to_routine(routine.id, exercise.id)

      {:ok, view, _html} = live(conn, "/routines/#{routine.id}/edit")

      # phx-value-id must be passed explicitly alongside form data
      view
      |> element("input[phx-change='update_sets'][phx-value-id='#{re.id}']")
      |> render_change(%{"target_sets" => "5", "id" => to_string(re.id)})

      updated_re =
        Routines.get_routine!(routine.id)
        |> Map.fetch!(:routine_exercises)
        |> hd()

      assert updated_re.target_sets == 5
    end
  end
end
