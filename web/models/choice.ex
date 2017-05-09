defmodule Survey.Choice do
  use Survey.Web, :model

  schema "choices" do
    field :key, :integer
    field :name, :string
    belongs_to :question, Survey.Question
    has_many :answers, Survey.Answer

    timestamps()
  end

  @fields ~w(key name question_id)

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
