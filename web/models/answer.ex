defmodule Survey.Answer do
  use Survey.Web, :model

  schema "answers" do
    belongs_to :seating, Survey.Seating
    belongs_to :question, Survey.Question
    belongs_to :choice, Survey.Choice

    timestamps()
  end

  @fields ~w(seating_id question_id choice_id)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @fields)
  end
end
