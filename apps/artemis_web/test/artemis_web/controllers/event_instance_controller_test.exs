defmodule ArtemisWeb.EventInstanceControllerTest do
  use ArtemisWeb.ConnCase

  import Artemis.Factories

  setup %{conn: conn} do
    date = Date.to_iso8601(Date.utc_today())
    event_template = insert(:event_template)
    event_question = insert(:event_question, event_template: event_template)

    {:ok, conn: sign_in(conn), date: date, event_question: event_question, event_template: event_template}
  end

  describe "index" do
    test "lists all event_instances", %{conn: conn, event_template: event_template} do
      conn = get(conn, Routes.event_instance_path(conn, :index, event_template))
      assert html_response(conn, 200) =~ "Instances"
    end
  end

  describe "new event instance" do
    test "renders edit form", %{conn: conn, date: date, event_template: event_template} do
      conn = get(conn, Routes.event_instance_path(conn, :edit, event_template, date))
      assert html_response(conn, 200) =~ "Save"
    end
  end

  describe "create event instance" do
    test "redirects to show when data is valid", %{
      conn: conn,
      date: date,
      event_question: event_question,
      event_template: event_template
    } do
      user = Mock.system_user()
      event_answer_params = params_for(:event_answer, date: date, event_question: event_question, user: user)

      params = %{
        event_template.id => %{
          "1" => event_answer_params
        }
      }

      conn = put(conn, Routes.event_instance_path(conn, :update, event_template, date), event_instance: params)

      assert %{id: date} = redirected_params(conn)
      assert redirected_to(conn) == Routes.event_instance_path(conn, :show, event_template, date)

      conn = get(conn, Routes.event_instance_path(conn, :show, event_template, date))
      assert html_response(conn, 200) =~ event_answer_params.value
    end

    test "renders errors when passed invalid params", %{
      conn: conn,
      date: date,
      event_question: event_question,
      event_template: event_template
    } do
      user = Mock.system_user()

      event_answer_params = params_for(:event_answer, date: date, event_question: event_question, user: user, value: "")

      invalid_params = %{
        event_template.id => %{
          "1" => event_answer_params
        }
      }

      conn = put(conn, Routes.event_instance_path(conn, :update, event_template, date), event_instance: invalid_params)
      assert html_response(conn, 200) =~ "Save"
    end
  end

  describe "show" do
    setup [:create_record]

    test "shows event_instance", %{conn: conn, date: date, event_answers: event_answers, event_template: event_template} do
      conn = get(conn, Routes.event_instance_path(conn, :show, event_template, date))

      assert html_response(conn, 200) =~ hd(event_answers).value
    end
  end

  describe "edit event_instance" do
    setup [:create_record]

    test "renders form for editing chosen event_instance", %{
      conn: conn,
      date: date,
      event_template: event_template
    } do
      conn = get(conn, Routes.event_instance_path(conn, :edit, event_template, date))

      assert html_response(conn, 200) =~ "Save"
    end
  end

  describe "update event_instance" do
    setup [:create_record]

    test "redirects when data is valid", %{
      conn: conn,
      date: date,
      event_answers: event_answers,
      event_template: event_template
    } do
      event_answer_params = %{
        event_question_id: hd(event_answers).event_question_id,
        id: hd(event_answers).id,
        value: "updated value"
      }

      params = %{
        event_template.id => %{
          "1" => event_answer_params
        }
      }

      conn = put(conn, Routes.event_instance_path(conn, :update, event_template, date), event_instance: params)

      assert %{id: date} = redirected_params(conn)
      assert redirected_to(conn) == Routes.event_instance_path(conn, :show, event_template, date)

      conn = get(conn, Routes.event_instance_path(conn, :show, event_template, date))
      assert html_response(conn, 200) =~ "updated value"
    end

    test "renders errors when passed invalid params", %{
      conn: conn,
      date: date,
      event_answers: event_answers,
      event_template: event_template
    } do
      event_answer_params = %{
        event_question_id: hd(event_answers).event_question_id,
        id: hd(event_answers).id,
        value: ""
      }

      invalid_params = %{
        event_template.id => %{
          "1" => event_answer_params
        }
      }

      conn = put(conn, Routes.event_instance_path(conn, :update, event_template, date), event_instance: invalid_params)
      assert html_response(conn, 200) =~ "Error"
    end
  end

  # describe "delete event instance" do
  #   setup [:create_record]

  #   test "deletes chosen event_instance", %{conn: conn, event_template: event_template, event_answers: event_answers} do
  #     conn = delete(conn, Routes.event_instance_path(conn, :delete, event_template, event_answers))
  #     assert redirected_to(conn) == Routes.event_instance_path(conn, :index, event_template)

  #     assert_error_sent 404, fn ->
  #       get(conn, Routes.event_instance_path(conn, :show, event_template, event_answers))
  #     end
  #   end
  # end

  defp create_record(params) do
    event_answer_params = [
      date: params[:date],
      event_question: params[:event_question],
      user: Mock.system_user()
    ]

    event_answers = insert_list(3, :event_answer, event_answer_params)

    {:ok, event_answers: event_answers}
  end
end
