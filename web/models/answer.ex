defmodule Survey.Answer do
  use Survey.Web, :model

  schema "answers" do
    belongs_to :seating, Survey.Seating
    belongs_to :question, Survey.Question
    belongs_to :choice, Survey.Choice

    timestamps
  end

  @required_fields ~w(seating_id question_id choice_id)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
