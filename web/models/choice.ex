defmodule Survey.Choice do
  use Survey.Web, :model

  schema "choices" do
    field :key, :integer
    field :name, :string
    belongs_to :question, Survey.Question
    has_many :answers, Survey.Answer

    timestamps
  end

  @required_fields ~w(key name question_id)
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
