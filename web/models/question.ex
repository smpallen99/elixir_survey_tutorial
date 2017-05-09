defmodule Survey.Question do
  use Survey.Web, :model

  schema "questions" do
    field :name, :string
    belongs_to :survey, Survey.Survey
    has_many :choices, Survey.Choice
    has_many :answers, Survey.Answer

    timestamps()
  end

  @fields ~w(name survey_id)

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
