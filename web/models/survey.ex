defmodule Survey.Survey do
  use Survey.Web, :model

  schema "surveys" do
    field :name, :string
    field :called_number, :string
    has_many :questions, Survey.Question
    has_many :seatings, Survey.Seating

    timestamps()
  end

  @fields ~w(name called_number)

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
