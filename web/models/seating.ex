defmodule Survey.Seating do
  use Survey.Web, :model

  schema "seatings" do
    field :caller, :string
    belongs_to :survey, Survey.Survey
    has_many :answers, Survey.Answer

    timestamps
  end

  @required_fields ~w(caller survey_id)
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
